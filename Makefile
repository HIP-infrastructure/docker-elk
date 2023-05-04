# SHELL=/bin/bash

# Make available environment variables defined in .env file
include .env
export

.DEFAULT_GOAL := help

DC=$(DOCKER_COMPOSE) --env-file ./.env -f docker-compose.yml

CERTS_DIR=./tls/certs
CERTBOT_DIR=/etc/letsencrypt/live/$(ELK_HOSTNAME)

#stack-down-except-volume: @ Make the stack down (except volume)
stack-down-except-volume:
	@echo "Make the stack down (except volume)"
	$(DOCKER_COMPOSE) down

#stack-down-all: @ Make the stack down and removing volume
stack-down-all:
	@echo "Make the stack down and removing volume"
	$(DOCKER_COMPOSE) down -v

#generate_tls_instances: @ Fill hostname and IP with values of environment variables
generate_tls_instances:
	@echo "Fill hostname and IP with values of environment variables"
	envsubst < ./tls/instances.yml.template > ./tls/instances.yml

#cert: @ Generare initial certificates with "docker-compose up tls"
cert: stack-down-except-volume clean-cert-all generate_tls_instances
	@echo "Generare initial certificates with docker-compose up tls"
	$(DC) up tls

#certbot: @ Generare CA trusted certificates for ELK_HOSTNAME"
certbot: stack-down-except-volume
	@echo "Generare initial certificates with docker-compose up tls"
	sudo certbot certonly

#stack-up: @ Deploy ELK stack
stack-up:
	@echo "Deploy ELK stack"
	$(DOCKER_COMPOSE) up -d

#clean-cert-all: @ Remove whole directory with certificates
clean-cert-all:
	@echo "Remove whole directory with certificates ($(CERTS_DIR))"
	sudo rm -Rf $(CERTS_DIR)

#clean-kibana-cert: @ Clean kibana SSL certificate and key files
clean-kibana-cert:
	@echo "Clean kibana SSL certificate and key files"
	sudo rm -vrf $(CERTS_DIR)/kibana/kibana.*

#certbot-kibana-symlinks: @ Make symlinks to certificates generated by certbot for kibana.
certbot-kibana-symlinks:
	@echo "Make symlinks to certificates generated by certbot for kibana"
	sudo ln -s $(CERTBOT_DIR)/privkey.pem $(CERTS_DIR)/kibana/kibana.key
	sudo ln -s $(CERTBOT_DIR)/fullchain.pem $(CERTS_DIR)/kibana/kibana.crt

#deploy-with-certbot: @ Full deployment from scratch. It calls certbot to generate a CA trusted SSL certificate.
deploy-with-certbot: stack-down-all certbot cert clean-kibana-cert certbot-kibana-symlinks stack-up

#deploy: @ Deployment of ELK stack with deletion of volume. This acts as resetting elasticsearch.
deploy: stack-down-all cert clean-kibana-cert certbot-kibana-symlinks stack-up

#redeploy: @ Typical redeployment of ELK stack where we want to keep the volume to make elasticsearch data persistent.
redeploy: cert clean-kibana-cert certbot-kibana-symlinks stack-up

#help: @ List available tasks on this project
help:
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(firstword $(MAKEFILE_LIST)) | tr -d '#'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
