# Installation guidelines

1. Clone the repo:

    ```bash
    $ git clone https://github.com/HIP-infrastructure/docker-elk.git
    ```

2. Checkout the `tls-8-6` branch:

    ```bash
    $ git checkout –track origin/tls-8-6
    ```

3. Copy `.env.template` as `.env` and edit or use an existing one

4. Copy `tls/instances.yml.example` as `tls/instances.yml` and edit the DNS and IP used to generate initial self-signed SSL certicates

5. If not performed yet, generate Let's encrypt SSL certificate used for kibana, for which the script of the next steps relied on:

    ```bash
    $ docker-compose down -d  # make sure the 80 port is available for certbot
    $ sudo apt-get install certbot  # command to install let's encrypt certbot 
    $ certbot --certonly  # launch the generation of the CA trusted certificate files
    ```

6. Edit `redeploy_ELK_stack.sh`. Check that `DOCKER_COMPOSE="docker-compose"` or `DOCKER_COMPOSE="docker compose"` depending on your host machine, and set `HIP_URL=<ELK_HOSTNAME>` (e.g. `HIP_URL=elk-dev.thehip.app`).

7. Deploy/redeploy the ELK stack:

    ```bash
    $ sh redeploy_ELK_stack.sh
    ```

    Note: You can see the stack status with `docker-compose ps` and see individual log with `docker logs <container_name>`, where `<container_name>` is the container name identified in the list displayed by `docker-compose ps`.
