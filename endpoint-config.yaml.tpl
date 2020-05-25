apiVersion: multicloud.ibm.com/v1alpha1
kind: EndpointConfig
metadata:
  name: CLUSTER_NAME
  namespace: CLUSTER_NAME
spec:
  applicationManager:
    enabled: true
  clusterLabels:
    cloud: auto-detect
    vendor: auto-detect
  clusterName: CLUSTER_NAME
  clusterNamespace: CLUSTER_NAME
  connectionManager:
    enabledGlobalView: false
  imageRegistry: quay.io/open-cluster-management
  imagePullSecret: quay-secret
  policyController:
    enabled: true
  searchCollector:
    enabled: true
  serviceRegistry:
    enabled: true
  certPolicyController:
    enabled: true
  cisController:
    enabled: false
  iamPolicyController:
    enabled: true
  version: 1.0.0
