-- ----------------------------------------------------------------------------------
-- Copyright (c) Microsoft Corporation.
-- Licensed under the MIT license.
--
-- THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
-- EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
-- OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
-- ----------------------------------------------------------------------------------

CREATE TABLE [dbo].[test]
(
    [col1] [nvarchar](200) NOT NULL,
    [col2] [nvarchar](255) NULL,
    [col3] [nvarchar](500) NULL
)
WITH
(
    DISTRIBUTION = HASH([col1]),
    CLUSTERED COLUMNSTORE INDEX
    --HEAP
);


COPY INTO [dbo].[test] FROM 'https://saname.dfs.core.windows.net/synapsecontainer/test.csv'
WITH (
   FIELDTERMINATOR=',',
   ROWTERMINATOR='0x0A'
) 


select * from [dbo].[test]