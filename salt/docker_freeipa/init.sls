{%- set hostname = 'freeipa.' ~ salt['pillar.get']('master_domain') -%}

rng-tools:
  pkg.installed

{{ salt['pillar.get']('data_path') }}/freeipa/ipa-data/:
  file.directory:
    - makedirs: True

docker_freeipa:
  docker_container.running:
    - name: freeipa
    - image: freeipa/freeipa-server:latest
    - auto_remove: True
    - binds:
      - {{ salt['pillar.get']('data_path') }}/freeipa/ipa-data:/data:Z
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    - ports: 80,88,88/udp,123/udp,389,443,464,464/udp,636
    - port_bindings:
      - 88:88       # kerberos
      - 88:88/udp   # kerberos
      - 464:464     # kerberos_passwd
      - 464:464/udp # kerberos_passwd
      - 389:389     # ldap
      - 636:636     # ldapssl
    - environment:
      - IPA_SERVER_INSTALL_OPTS: >
          --realm={{ salt['pillar.get']('freeipa:realm')|upper }}
          --ds-password={{ salt['pillar.get']('freeipa:ds_password') }}
          --admin-password={{ salt['pillar.get']('freeipa:admin_password') }}
          --no-ntp
          --unattended
      - IPA_SERVER_HOSTNAME: {{ hostname }}
    - tmpfs:
      - /run: ''
      - /tmp: ''
    - labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:{{ hostname }}
      - traefik.frontend.entryPoints=https
      - traefik.port=443
      - traefik.protocol=https
      - traefik.docker.network=docker_network_internal
    - networks:
      - docker_network_external
      - docker_network_internal
    - require:
      - docker_network: docker_network_external
      - docker_network: docker_network_internal
      - pkg: rng-tools
      - file: {{ salt['pillar.get']('data_path') }}/freeipa/ipa-data/
    - require_in:
      - ipa-client-install
