# ----------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
#
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
# OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# ----------------------------------------------------------------------------------

# User-identity passthrough for ADLS Gen 2


%%pyspark
df = spark.read.load('abfss://container@saname.dfs.core.windows.net/test.csv', format='csv'
## If header exists uncomment line below
##, header=True
)
display(df.limit(10))