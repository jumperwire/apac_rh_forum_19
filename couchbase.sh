#!/bin/bash
#
# Deploy or cleanup a couchbase install

# Step 0 - Our master environment
source ./ocp.env
source ./functions

# And login as the kubeadmin user

oc login -u ${OCP_USER} -p ${OCP_PASS} ${OCP_ENDPOINT} --insecure-skip-tls-verify=false

OCP_NAMESPACE=couchbase


setup_couchbase()
{
    echo "Create the Couchbase namespace"
    oc new-project couchbase

    echo "Populate our secret"
    oc create -f cbauthsecret.yaml -n ${OCP_NAMESPACE}
}

cleanup_couchbase()
{
    echo "Clean up our Couchbase environments and remove the Operator"
    echo "Don't worry if your see - No resources found"
    echo "Remove couchbase subscription"
    #oc delete subscriptions couchbase-enterprise-certified -n ${OCP_NAMESPACE}
    oc delete subscriptions -l csc-owner-name=installed-certified-couchbase -n ${OCP_NAMESPACE}
    oc delete clusterserviceversion couchbase-operator.v1.1.0 -n ${OCP_NAMESPACE}

    echo "Make sure we've remove couchbase from our cataloge sources"
    oc delete catalogsourceconfig -n openshift-marketplace installed-certified-couchbase


    echo "Remove couchbase operator"
    oc delete deployment -l app=couchbase-operator -n ${OCP_NAMESPACE}
    oc delete replicaset -l app=couchbase-operator -n ${OCP_NAMESPACE}
    oc delete all -l app=couchbase-operator -n ${OCP_NAMESPACE}

    echo "Remove all couchbase instances"
    oc delete all -l app=couchbase -n ${OCP_NAMESPACE}


    echo "Remove our secret"
    oc delete -f cbauthsecret.yaml -n ${OCP_NAMESPACE}

    echo "Remove the Couchbase namespace"
    oc delete namespace ${OCP_NAMESPACE}

}


case "$1" in
  setup)
        setup_couchbase
        ;;
  delete|cleanup|remove)
        cleanup_couchbase
        ;;
  *)
        echo "Usage: $N {setup|delete}" >&2
        exit 1
        ;;
esac
