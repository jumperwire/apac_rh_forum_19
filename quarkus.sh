#!/bin/bash
#
# Deploy or cleanup a quarkus install

# Step 0 - Our master environment
source ./ocp.env
source ./functions

# And login as the kubeadmin user

#oc login -u ${OCP_USER} -p ${OCP_PASS} ${OCP_ENDPOINT} --insecure-skip-tls-verify=false

OCP_NAMESPACE=supersonic-subatomic-java

# Ideally we should be cloning the repo locally for better performance
REPO_URL="https://raw.githubusercontent.com/jumperwire/supersonic-subatomic-java/master"

setup_quarkus()
{
    echo "Create the ${OCP_NAMESPACE} namespace"
    oc new-project ${OCP_NAMESPACE}

    echo "Deploy big fat java"
    oc apply -f ${REPO_URL}/deploy-big-fat-java.yaml
    
    echo "Deploy supersonic-subatomic java"
    oc apply -f ${REPO_URL}/deploy-supersonic-subatomic-java.yaml
    
    echo "Create big fat java service"
    oc apply -f ${REPO_URL}/service-big-fat-java.yaml
    
    echo "Create supersonic-subatomic java service"
    oc apply -f ${REPO_URL}/service-supersonic-subatomic-java.yaml
    
    echo "Create big fat java route"
    oc expose service big-fat-java
    
    echo "Create supersonic-subatomic java route"
    oc expose service supersonic-subatomic-java
}

cleanup_quarkus()
{
    echo "Clean up our Quarkus environments and remove the Operator"
    echo "Scaling big fat java back to 1 pod"
    oc scale --replicas=1 deployment.apps big-fat-java -n ${OCP_NAMESPACE}
    
    echo "Scaling big fat java back to 1 pod"
    oc scale --replicas=1 deployment.apps supersonic-subatomic-java -n ${OCP_NAMESPACE}
}


case "$1" in
  setup)
        oc_login
        setup_quarkus
        ;;
  cleanup)
        oc_login
        cleanup_quarkus
        ;;
  *)
        echo "Usage: $N {setup|cleanup}" >&2
        exit 1
        ;;
esac
