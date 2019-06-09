# Summary
The aim of this project is to make deployment of deep learning models easier over Spark.
Using Kubernetes as a cluster provider looks like a relevant choice according to many official conversations.
This links compares kubernetes vs. yarn when choosing a cluster manager:
[https://medium.com/@rachit1arora/why-run-spark-on-kubernetes-51c0ccb39c9b](https://medium.com/@rachit1arora/why-run-spark-on-kubernetes-51c0ccb39c9b)
The provisioned version of Spark will be 2.4.3

## Requirements
* docker-compose - for local development
* ansible - to build/deploy/submit
* minikube and kubectl - see tools/ for installers.

## Step-1: local development
Pop a docker stack using: `make dev` or `docker-compose up`
This starts a Jupyter server container provisioned with Spark. Notebooks under notebooks/ are synched with the container.
The default url is: `http://localhost:8888//?token=<YOUR_PROVIDED_JUPYTERHUB_TOKEN>`
Native spark variables (spark, spark._sc) are accessible from withing notebooks.
Please have a look at the sample notebook (imdb_sentiment_analysis_keras_spark.ipynb) that covers a typical dev case.

You must provide some code to convert you keras model (model variable in the snippet below) into an elephas model making use of Spark as the processing engine. It should look like this:
```
from elephas.utils.rdd_utils import to_simple_rdd
from elephas.spark_model import SparkModel

rdd = to_simple_rdd(spark._sc, x_train, y_train)
spark_model = SparkModel(model, frequency='epoch', mode='asynchronous')
spark_model.fit(rdd, epochs=100, batch_size=512, verbose=1, validation_split=0.1) # verbose: 0
```

This notebook can now be converted to a python script using nbconvert, and then be executed as input of a spark-submit command.

## Step-2: build an image for Spark/Kubernetes
You just have to type this command: `make build`
or alternatively: `	ansible-playbook -v --connection=local ansible/build.yml --extra-vars "notebook=${NOTEBOOK_PATH}"`
and replacing NOTEBOOK_PATH by the local path to your freshly developed notebook.

A docker image is built, based on official images for spark with kubernetes. It also converts the developped notebook to a python script, and provisions it in the docker image.

You can check that the image is contained locally using: `docker images`
In the future, we'll push them on remote registries for further usage by cloud-based kubernetes clusters.
Right now, we'll work with locally-provisioned kubernetes clusters.

## Step-3: deploy a local Kubernetes cluster.
This step is accomplished by executing: `make deploy`
or alternatively: `ansible-playbook -v --connection=local ansible/deploy.yml`
Minikube hence starts a basic cluster with about 1GB memory and 2 cpu's.

Custom service accounts are created for Spark so that everything works fine when submitting jobs using deploy mode (meaning specific pods will host the apiserver, scheduler, driver who pops executors; all of them having adequate action rights thanks to those specific custom service accounts).
Please have a look at [https://spark.apache.org/docs/latest/running-on-kubernetes.html](https://spark.apache.org/docs/latest/running-on-kubernetes.html)

Moreover: `kubectl version` should be `v1.7.6`, which is basically based on coredns for pods name resolution. Coredns should be patched (at least when minikube uses vm-driver equal to none). Indeed, without this applied patch, coredns infinitely loops. This bug may not exist with other values of vm-driver (still need to be checked).
Your system pods are visible using: `sudo kubectl -n kube-system get pods`

For instance:
```
NAME                                    READY   STATUS    RESTARTS   AGE
coredns-fb8b8dccf-bv7v8                 1/1     Running   0          3h5m
coredns-fb8b8dccf-zlzps                 1/1     Running   0          3h5m
etcd-minikube                           1/1     Running   0          3h5m
kube-addon-manager-minikube             1/1     Running   0          3h5m
kube-apiserver-minikube                 1/1     Running   0          3h5m
kube-controller-manager-minikube        1/1     Running   0          3h5m
kube-proxy-9wns5                        1/1     Running   0          3h6m
kube-scheduler-minikube                 1/1     Running   0          3h5m
kubernetes-dashboard-79dd6bfc48-25pt2   1/1     Running   0          3h6m
storage-provisioner                     1/1     Running   0          3h6m
```
## Step-4: Submitting an application
Right now, you can either run `make submit` or:
```
ansible-galaxy install geerlingguy.java
ansible-playbook -v --connection=local ansible/submit.yml
```
Under the hood, it makes usage of spark-submit to starts the classical SparkPi example from official spark jars.
WIP: give a way to take your freshly developed script as input for spark processing.

## TODO
* the submit playbook should take py script name as input.
* provision a kubernetes cluster on gcloud or digitalocean.
* dns patching is hacky.
* benchmarking.
* webapp to distribute keras models processing. Or simple command line.

## Contributions
Please feel free to contribute to this project in any way you -ay consider relevant. Thank you :) !