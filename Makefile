
NOTEBOOK_PATH="notebooks/imdb_sentiment_analysis_tensorflow_spark.ipynb"

all: config up 

config:
	# make sure user 'jovyan' has execute access on notebooks
	@chmod ao+x notebooks/

up:
	docker-compose up

deploy:
	ansible-playbook -v --connection=local ansible/deploy.yml\
					--extra-vars "notebook=${NOTEBOOK_PATH}"