--  ----------------------------------------------------------------------------------
--  THIS CODE AND INFORMATION ARE PROVIDED 'AS IS" WITHOUT WARRANTY OF ANY KIND, 
--  EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
--  OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
--  ----------------------------------------------------------------------------------


-- User-identity passthrough for ADLS Gen 2

SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://saname.dfs.core.windows.net/container/test.csv',
        FORMAT = 'CSV',
        PARSER_VERSION='2.0'
    ) AS [result]


-- Managed Identity for ADLS Gen 2

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Y*********0'

CREATE DATABASE test

CREATE DATABASE SCOPED CREDENTIAL WorkspaceIdentity
WITH IDENTITY = 'Managed Identity'

CREATE EXTERNAL DATA SOURCE mysample
WITH (    LOCATION   = 'https://<storage_account>.dfs.core.windows.net/<container>/<path>',
          CREDENTIAL = WorkspaceIdentity
)

CREATE EXTERNAL FILE FORMAT [SynapseFormat] WITH ( FORMAT_TYPE = DELIMITEDTEXT)

CREATE EXTERNAL TABLE dbo.userData ( [col1] varchar(100), [col2] varchar(100), [col3] varchar(100) )
WITH ( LOCATION = 'test.csv',
       DATA_SOURCE = [mysample],
       FILE_FORMAT = [SynapseFormat] );


select * FROM dbo.userdata;