# ----------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
#
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
# OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# ----------------------------------------------------------------------------------


from azureml.core import Workspace, Dataset

subscription_id = ''
resource_group = ''
workspace_name = ''

ws = Workspace(subscription_id=subscription_id,
               resource_group=resource_group,
               workspace_name=workspace_name)

import urllib.request
from azureml.core.model import Model
# Download model
urllib.request.urlretrieve("https://aka.ms/bidaf-9-model", 'model.onnx')

# Register model
model = Model.register(ws, model_name='bidaf_onnx', model_path='./model.onnx')


from azureml.core import Environment
from azureml.core.model import InferenceConfig

env = Environment(name='project_environment')
inf_config = InferenceConfig(environment=env, source_directory='./azureml-deployment-scripts', entry_script='./echo_score.py')


ws.update(image_build_compute = 'test')

# Model Package
from azureml.core.model import Model
package = Model.package(workspace = ws, models = [model], inference_config = inf_config, image_name = 'test_image')
package.wait_for_creation(show_output=True)

# Use the Azure CLI to deploy model in ACR to app service

# Test model
import requests
import json
headers = {'Content-Type': 'application/json'}
data = {"query": "What color is the fox", "context": "The quick brown fox jumped over the lazy dog."}
data = json.dumps(data)
response = requests.post('https://<web-app-name>.azurewebsites.net/score', data=data, headers=headers)

