enrolled-managed.sh
===================

Enrolls a cluster to RHACM and installs the compliance operator in it.

It takes three variables:

* `CLUSTER_NAME`: is the name of the cluster to enroll (the managed cluster)
* `HUBKUBECONFIG`: is the path to the kubeconfig of the Hub (which hosts RHACM)
* `MANAGEDCLUSTERKUBECONFIG`: is the path to the kubeconfig of the managed
  cluster.

These can be set as exports in a file called config.sh which is read at the
beginning of the script's execution.

This also requires you to get a file with your quay credentials (it's expected
to be called `quay-secret.yaml`). This file should allow you to pull the RHACM
images, instructions on how to get it come from the RHACM installer. but it
should look similar to this:

```
apiVersion: v1
kind: Secret
metadata:
  name: quay-secret
data:
  .dockerconfigjson: SUPER-SECRET-BASE64
type: kubernetes.io/dockerconfigjson
```
