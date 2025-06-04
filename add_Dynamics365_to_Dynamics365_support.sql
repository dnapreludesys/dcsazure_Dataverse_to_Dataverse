-- Add a new column 'event_type' to store the type/category of the event.
ALTER TABLE adf_events_log
ADD event_type VARCHAR(100) NULL;

-- Add a new column 'event_details'to store the information about removed columns and the reason behind removing them.
ALTER TABLE adf_events_log
ADD event_details NVARCHAR(MAX) NULL;

-- Add a default constraint to the 'is_excluded' column in the 'discovered_ruleset' table with default value of 0.
ALTER TABLE discovered_ruleset ADD  CONSTRAINT DF_discovered_ruleset_is_excluded  DEFAULT ((0)) FOR is_excluded
GO

-- Script to create data mappings for DATAVERSE dataset

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
('DATAVERSE', 'Memo', 'string'),
('DATAVERSE', 'State', 'string'),
('DATAVERSE', 'Status', 'string'),
('DATAVERSE', 'Uniqueidentifier', 'string'),
('DATAVERSE', 'Boolean', 'boolean');