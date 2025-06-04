# dcsazure_Dynamics365_to_Dynamics365_discovery_pl
## Delphix Compliance Services (DCS) for Azure - Dataverse to Dataverse Discovery Pipeline

This pipeline will perform automated sensitive data discovery on your Microsoft Dynamics365 environment using Delphix Compliance Services (DCS) for Azure.

### Prerequisites
1. Configure the hosted metadata database and associated Azure SQL service.
2. Configure the DCS for Azure REST service.
3. Register an application in Azure for Dynamics365 and obtain the necessary credentials. 
   NOTE: To obtain the necessary credentials, refer to Delphix documentation(https://dcs.delphix.com/docs/latest/delphixcomplianceservices-dcsforazure-2_onboarding#RegisteringaServicePrincipal-Process).
4. Configure the Dataverse REST linked service. 
   * It is helpful for the linked service to be parameterized with the following parameter:
      * `LS_ORG_NAME` - Environment name in the linked service.
5. Configure the Dataverse linked service. 
   * It is helpful for the linked service to be parameterized with the following parameter:
      * `LS_ORG_NAME` - Environment name in the linked service.

### Importing

There are several linked services that will need to be selected in order to perform the profiling and data discovery of your Dynamics365 environment.

These linked services types are needed for the following steps:

`Dataverse` (source) - Linked service associated with unmasked AzureSQL data. This will be used for the following steps:
* dcsazure_Dynamics365_to_Dynamics365_discovery_df/Source1MillRowDataSampling (DataFlow)

`Azure SQL` (metadata) - Linked service associated with your hosted metadata store. This will be used for the following steps:
* Check If We Should Rediscover Data (If Condition activity)
* Update Discovery State (Stored Procedure Activity)
* Update Discovery State Failed (Stored Procedure Activity)
* Delete_temp_table_values (Script activity)
* dcsazure_Dynamics365_to_Dynamics365_discovery_metadata_ds (Azure SQL Dataset)
* dcsazure_Dynamics365_to_Dynamics365_Fetch_Removed_Columns_df/SQLSink (DataFlow)
* dcsazure_Dynamics365_to_Dynamics365_Fetch_Removed_Columns_df/Sink (DataFlow)
* dcsazure_Dynamics365_to_Dynamics365_discovery_df/MetadataStoreRead (DataFlow)
* dcsazure_Dynamics365_to_Dynamics365_discovery_df/WriteToMetadataStore (DataFlow)

`REST` (DCS for Azure) - Linked service associated with calling DCS for Azure. This will be used for the following steps:
* dcsazure_Dynamics365_to_Dynamics365_discovery_df (DataFlow)

`Dataverse REST` (Source) - Linked service associated with Dataverse to fetch the metadata. This will be used for the following steps:
* dcsazure_Dynamics365_to_Dynamics365_discovery_source_ds (REST Dataset)
* dcsazure_Dynamics365_to_Dynamics365_Fetch_Removed_Columns_df/Source (DataFlow)

### How It Works

* Check If We Should Rediscover Data
  * If we should, Mark Tables Undiscovered. This is done by updating the metadata store to indicate that tables have not had their sensitive data discovered.
* Get tables from the source 
  * Calls the Dataverse EntityDefinitions API to fetch all table names that are:
    * Valid for Advanced Find
    * Customizable
    * Not private  
  * Stores the results in a discovered_ruleset metadata table with a dummy column name `TEMPCOLUMN`.
* Fetch table names
  * Queries the temp metadata table to select only the discovered table names where `identified_column = 'TEMPCOLUMN'`
* For Each Table  
  * Iterates over each table from `Fetch table names`. The following sub-activities run for each table:
    * Add Metadata to Ruleset table
      * Uses Dataverse API to fetch column metadata (`Attributes`) for the current table  
      * Stores column name, data type, max length, etc., into the discovered_ruleset metadata SQL table
      * Filters the columns that should be excluded (System modified, Readonly, polymorphic, lookup columns) and updates the `is_excluded` field in the discovered_ruleset metadata table
* Delete_temp_table_values
  * Deletes the `TEMPCOLUMN` columns from the discovered_ruleset metadata table column.
* Select Discovered Tables
  * After persisting the metadata to the metadata store, collect the list of discovered tables
* For Each Discovered Table
  * Call the `dcsazure_Dynamics365_to_Dynamics365_discovery_df` for profiling and tagging sensitive data.

### Variables

If you have configured your database using the metadata store scripts, these variables will not need editing. If you have customized your metadata store, then these variables may need editing.

* `METADATA_SCHEMA` - This is the schema to be used for in the self-hosted AzureSQL database for storing metadata (default `dbo`)
* `METADATA_RULESET_TABLE` - This is the table to be used for storing the discovered ruleset (default `discovered_ruleset`)
* `DATASET` - This is used to identify data that belongs to this pipeline in the metadata store (default `DATAVERSE`)
* `METADATA_EVENT_PROCEDURE_NAME` - This is the name of the procedure used to capture pipeline information in the metadata data store and sets the discovery state on the items discovered during execution (default `insert_adf_discovery_event`)
* `NUMBER_OF_ROWS_TO_PROFILE` - This is the number of rows we should select for profiling, note that raising this value could cause requests to fail (default `1000`)
* `METADATA_EVENTS_LOG_TABLE` - This is the table to be used for storing the removed columns from discovered ruleset (default `adf_events_log`)

### Parameters

* `P_SOURCE_DATABASE` - String - This is the Dynamics365 environment that may contain sensitive data
* `P_SOURCE_SCHEMA` - String - Logical schema within Dataverse (default `dbo`)
* `P_REDISCOVER` - This is a Bool that specifies if we should re-execute the data discovery dataflow for previously discovered files that have not had their schema modified (default `true`)