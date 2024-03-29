
NOTEBOOK_PATH="notebooks/imdb_sentiment_analysis_keras_spark.ipynb"

all: clean config build deploy

# Local development
config:
	# make sure user 'jovyan' has execute access on notebooks
	@chmod ao+x notebooks/

dev:
	@echo "Starting local Jupyter with Spark up & ready !"
	@docker-compose up

# Build image
build:
	ansible-playbook -v --connection=local ansible/build.yml\
					--extra-vars "notebook=${NOTEBOOK_PATH}"\
					--ask-become-pass

# Deploy Kubernetes/Spark cluster
deploy:
	ansible-playbook -v --connection=local ansible/deploy.yml\
					--ask-become-pass

# Show basic informations about cluster status
info:
	@sudo kubectl get cluster-info
	@sudo kubectl -n kube-system get pods
	@sudo kubectl get pods

# Submit a job to the cluster
submit:
	@ansible-galaxy install geerlingguy.java
	ansible-playbook -v --connection=local ansible/submit.yml\
					--ask-become-pass

run_spark_keras_container:
	@docker run -it spark-keras-nb bash

# Tools for build/deploy
install_tools:
	@./tools/install_minikube.sh
	@./tools/install_kubectl.sh
	@./tools/install_ansible.sh

clean:
	@rm -rf build/

.PHONY: build