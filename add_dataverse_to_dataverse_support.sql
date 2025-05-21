/* Script to create a temp table for discovery pipeline */
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [discovered_ruleset_D365](
	[identified_table] [varchar](255) NOT NULL,
	[identified_column] [varchar](255) NOT NULL,
	[identified_column_type] [varchar](100) NULL,
	[identified_column_max_length] [int] NULL,
	[ordinal_position] [int] NULL,
	[row_count] [bigint] NULL,
	[source_metadata] [nvarchar](max) NULL,
	[profiled_domain] [varchar](100) NULL,
	[profiled_algorithm] [varchar](100) NULL,
	[confidence_score] [decimal](6, 5) NULL,
	[rows_profiled] [bigint] NULL,
	[assigned_algorithm] [varchar](max) NULL,
	[last_profiled_updated_timestamp] [datetime] NULL,
	[discovery_complete] [bit] NULL,
	[latest_event] [uniqueidentifier] NULL,
	[algorithm_metadata] [nvarchar](max) NULL,
 CONSTRAINT [discovered_ruleset_D365_pk] PRIMARY KEY CLUSTERED 
(
	[identified_table] ASC,
	[identified_column] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [discovered_ruleset_temp] ADD  DEFAULT ((0)) FOR [rows_profiled]
GO

/* Script to create Remove columns table for D365 pipeline */
CREATE TABLE [D365_Removed_Columns] (
    dataset NVARCHAR(100)not null,
    specified_database NVARCHAR(100)not null,
    specified_table NVARCHAR(100)not null,
    columnname NVARCHAR(100)not null,
    reason_to_remove NVARCHAR(MAX),
    CONSTRAINT PK_RemovedColumns PRIMARY KEY (dataset, specified_database, specified_table, columnname)
);


/* Script to create data mappings for DATAVERSE dataset */

INSERT INTO adf_type_mapping(dataset, dataset_type, adf_type)
   VALUES
('DATAVERSE', 'BigInt', 'long'),
('DATAVERSE', 'Picklist', 'string'),
('DATAVERSE', 'MultiSelectPicklist', 'string'),
('DATAVERSE', 'Money', 'double'),
('DATAVERSE', 'DateTime', 'timestamp'),
('DATAVERSE', 'Decimal', 'double'),
('DATAVERSE', 'Integer', 'integer'),
('DATAVERSE', 'String', 'string'),
('DATAVERSE', 'File', 'binary'),
('DATAVERSE', 'Double', 'double'),
('DATAVERSE', 'Image', 'binary'),
('DATAVERSE', 'Lookup', 'string'),
('DATAVERSE', 'Memo', 'string'),
('DATAVERSE', 'Uniqueidentifier', 'string'),
('DATAVERSE', 'Boolean', 'boolean');
