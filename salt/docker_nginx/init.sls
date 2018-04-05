docker_nginx:
  docker_container.running:
    - name: nginx
    - image: nginx:latest
    - restart_policy: unless-stopped
    - ports: 80,443
    - network_mode: docker_internal_network
    - networks:
      - docker_internal_network
    - require:
      - pip install docker
      - docker_internal_network