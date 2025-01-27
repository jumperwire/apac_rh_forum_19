#!/bin/bash

# Step 0 - Our master environment
source ./ocp.env

# Step 1 - 3scale specific settings
source ./3scale.env

# And login as the kubeadmin user

oc login -u ${OCP_USER} -p ${OCP_PASS} ${OCP_ENDPOINT} --insecure-skip-tls-verify=false

OCP_NAMESPACE=$API_MANAGER_NS

#  This has a simple cleanup
echo "Deleting the project ${OCP_NAMESPACE}"
echo "This might take a couple of minutes to return"

oc delete project ${OCP_NAMESPACE}

