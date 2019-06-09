
NOTEBOOK_PATH="notebooks/imdb_sentiment_analysis_tensorflow_spark.ipynb"

all: clean config build deploy

config:
	# make sure user 'jovyan' has execute access on notebooks
	@chmod ao+x notebooks/

dev:
	@Echo "Starting local Jupyter with Spark up & ready !"
	@docker-compose up

build:
	ansible-playbook -v --connection=local ansible/build.yml\
					--extra-vars "notebook=${NOTEBOOK_PATH}"

deploy:
	ansible-playbook -v --connection=local ansible/deploy.yml

install_build_tools:
	@echo "Installing tools for local Kuberbetes/Spark stack.."

clean:
	@rm -rf build/