apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: compliance-operator-bundle
  namespace: CLUSTER_NAME
spec:
  channel: alpha
  installPlanApproval: Automatic
  name: compliance-operator-bundle
  source: compliance-operator
  sourceNamespace: openshift-marketplace
  startingCSV: compliance-operator.v0.1.9
