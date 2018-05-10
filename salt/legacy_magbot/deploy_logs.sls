include:
  - docker_network_proxy

/var/log/legacy_magbot/nginx/error.log:
  file.managed:
    - name: /var/log/legacy_magbot/nginx/error.log
    - makedirs: True

/var/log/legacy_magbot/nginx/access.log:
  file.managed:
    - name: /var/log/legacy_magbot/nginx/access.log
    - makedirs: True

/etc/legacy_magbot/nginx/conf.d/default.conf:
  file.managed:
    - name: /etc/legacy_magbot/nginx/conf.d/default.conf
    - source: salt://legacy_magbot/deploy_logs_nginx.conf
    - makedirs: True
    - template: jinja

deploy_logs:
  docker_container.running:
    - name: magbot_deploy_logs
    - image: nginx
    - auto_remove: True
    - binds:
      - /etc/legacy_magbot/nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf:ro
      - /var/log/legacy_magbot/deploy:/usr/share/nginx/html:ro
      - /var/log/legacy_magbot/nginx/error.log:/var/log/nginx/error.log
      - /var/log/legacy_magbot/nginx/access.log:/var/log/nginx/access.log
    - labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:{{ salt['pillar.get']('magbot:deploy_log_domain') }}
      - traefik.frontend.entryPoints=http,https
      - traefik.port=80
      - traefik.docker.network=docker_network_internal
    - networks:
      - docker_network_internal
    - watch:
      - file: /etc/legacy_magbot/nginx/conf.d/default.conf
    - require:
      - docker_network: docker_network_internal
      - sls: legacy_magbot