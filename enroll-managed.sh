#!/bin/bash

if [ -f config.sh ]; then
    source config.sh
fi

if [ -z "$CLUSTER_NAME" ]; then
    read -r -p "> specify the name of the managed cluster to enroll (CLUSTER_NAME): " CLUSTER_NAME
fi
if [ -z "$HUBKUBECONFIG" ]; then
    read -r -p "> specify the path of Hub's kubeconfig (HUBKUBECONFIG): " HUBKUBECONFIG
fi
if [ -z "$MANAGEDCLUSTERKUBECONFIG" ]; then
    read -r -p "> specify the path of the managed cluster's kubeconfig (MANAGEDCLUSTERKUBECONFIG): " MANAGEDCLUSTERKUBECONFIG
fi

echo "* Enrolling cluster '$CLUSTER_NAME' to RHACM hub"

echo "===== IN HUB CLUSTER ====="
export KUBECONFIG="$HUBKUBECONFIG"

oc new-project "$CLUSTER_NAME"

echo "* Ensuring quay secret"
oc apply -n "$CLUSTER_NAME" --wait -f quay-secret.yaml
echo "* Ensuring cluster registry CRD"
sed "s/CLUSTER_NAME/$CLUSTER_NAME/" cluster-registry.yaml.tpl | oc apply --wait -f -
echo "* Endpoint config CRD"
sed "s/CLUSTER_NAME/$CLUSTER_NAME/" endpoint-config.yaml.tpl | oc apply --wait -f -

# Sleep while the secret gets persisted in the cluster
sleep 5

echo "* Getting endpoint CRD"
oc get secret "${CLUSTER_NAME}-import" -n "${CLUSTER_NAME}" -o jsonpath="{.data.endpoint-crd\\.yaml}" | base64 --decode > endpoint-crd.yaml

echo "* Getting import config"
oc get secret "${CLUSTER_NAME}-import" -n "${CLUSTER_NAME}" -o jsonpath="{.data.import\\.yaml}" | base64 --decode > import.yaml

echo "===== IN MANAGED CLUSTER ====="

export KUBECONFIG="$MANAGEDCLUSTERKUBECONFIG"

echo "* Ensuring endpoint CRD"
oc apply -f endpoint-crd.yaml

echo "* Ensuring import config"
oc apply -f import.yaml

rm import.yaml endpoint-crd.yaml

echo "===== IN HUB CLUSTER ====="
export KUBECONFIG="$HUBKUBECONFIG"
echo "* Waiting until cluster is enrolled"
while oc get cluster -n "$CLUSTER_NAME" --no-headers "$CLUSTER_NAME" | grep Pending > /dev/null; do
    sleep 30
    oc get cluster -n "$CLUSTER_NAME" --no-headers "$CLUSTER_NAME"
done

oc get cluster -n "$CLUSTER_NAME" --no-headers "$CLUSTER_NAME"
echo "* Cluster is enrolled!"

echo "===== IN MANAGED CLUSTER ====="

export KUBECONFIG="$MANAGEDCLUSTERKUBECONFIG"

echo "* Ensuring namespace for compliance-operator"
oc apply -f compliance-operator-ns.yaml

echo "* Ensuring source to get compliance-operator"
oc apply -f compliance-operator-source.yaml

echo "* Ensuring operatorgroup for compliance-operator"
sed "s/CLUSTER_NAME/$CLUSTER_NAME/" compliance-operator-operator-group.yaml.tpl | oc apply --wait -f -

echo "* Ensuring subscription for compliance-operator"
sed "s/CLUSTER_NAME/$CLUSTER_NAME/" compliance-operator-alpha-subscription.yaml.tpl | oc apply --wait -f -

