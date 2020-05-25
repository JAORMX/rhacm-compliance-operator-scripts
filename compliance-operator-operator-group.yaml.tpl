apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-compliance
  namespace: CLUSTER_NAME
spec:
  targetNamespaces:
  - CLUSTER_NAME
