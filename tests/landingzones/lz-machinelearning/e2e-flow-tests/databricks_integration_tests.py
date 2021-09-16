# ----------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
#
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
# OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# ----------------------------------------------------------------------------------

# Databricks notebook source
# MAGIC %md #### Test Plan integration step
# MAGIC 
# MAGIC Here are the steps for the integration tests:
# MAGIC 
# MAGIC * Get secret from Key Vault
# MAGIC * Connect to data from SQL Database / SQL MI
# MAGIC * Connect to data lake (storage account)

# COMMAND ----------

# MAGIC %md Key Vault integration

# COMMAND ----------

dbutils.library.installPyPI('azure-identity')
dbutils.library.installPyPI('azure-keyvault-secrets')

from azure.keyvault.secrets import SecretClient
from azure.identity import DeviceCodeCredential

keyVaultName = '<name-key-vault>'
KVUri = f"https://{keyVaultName}.vault.azure.net"

credential = DeviceCodeCredential()
client = SecretClient(vault_url=KVUri, credential=credential)

retrieved_secret = client.get_secret('<name>')

secret1pw = retrieved_secret.value

# dbutils.secrets.list(scope = 'test')

# COMMAND ----------

# MAGIC %md Storage Account

# COMMAND ----------

# MAGIC %md ... with credential passthrough

# COMMAND ----------

import pandas as pd
spark_df = spark.createDataFrame(pd.DataFrame({'hello':[1,2]})).write.csv('abfss://test@<storageaccountname>.dfs.core.windows.net/test.csv')

# COMMAND ----------

dbutils.fs.ls("abfss://test@<storageaccountname>.dfs.core.windows.net")

# COMMAND ----------

sparkDf = spark.read.csv('abfss://test@<storageaccountname>.dfs.core.windows.net/test.csv')

# COMMAND ----------

display(sparkDf)

# COMMAND ----------

# MAGIC %md SQL Database

# COMMAND ----------

secret1pw = dbutils.secrets.get(scope = 'test', key = 'sqldbPassword')

# COMMAND ----------

jdbcHostname = ""
jdbcDatabase = "test"
jdbcPort = 1433
jdbcUrl = "jdbc:sqlserver://{0}:{1};databaseName={2};user={3};password={4}".format(jdbcHostname, jdbcPort, jdbcDatabase, "login", secret1pw)
connectionProperties = {
  "driver" : "com.microsoft.sqlserver.jdbc.SQLServerDriver"
}

# COMMAND ----------

sparkDf.write.jdbc(url=jdbcUrl, table="test", properties=connectionProperties)

# COMMAND ----------

display(spark.read.jdbc(url=jdbcUrl, table="test", properties=connectionProperties))

# COMMAND ----------

# MAGIC %md SQL Managed Instance

# COMMAND ----------

secret2pw = dbutils.secrets.get(scope = 'test', key = 'sqlmiPassword')

# COMMAND ----------

jdbcHostname = ""
jdbcDatabase = "test"
jdbcPort = 1433
jdbcUrl = "jdbc:sqlserver://{0}:{1};databaseName={2};user={3};password={4}".format(jdbcHostname, jdbcPort, jdbcDatabase, "login", secret1pw)
connectionProperties = {
  "driver" : "com.microsoft.sqlserver.jdbc.SQLServerDriver"
}

# COMMAND ----------

sparkDf.write.jdbc(url=jdbcUrl, table="test", properties=connectionProperties)

# COMMAND ----------

display(spark.read.jdbc(url=jdbcUrl, table="test", properties=connectionProperties))

# COMMAND ----------


