include:
  - nodejs
  - npm

magbot user:
  user.present:
    - name: magbot

redis-server install:
  pkg.installed:
    - name: redis-server

legacy_magbot git latest:
  git.latest:
    - name: git@github.com:magfest/legacy_magbot.git
    - target: /srv/legacy_magbot
    - identity: /root/.ssh/github_magbot_id_rsa

/srv/legacy_magbot/secret.sh:
  file.managed:
    - name: /srv/legacy_magbot/secret.sh
    - source: salt://legacy_magbot/files/secret.sh
    - template: jinja
    - show_changes: False
    - require:
      - legacy_magbot git latest

chown magbot /srv/legacy_magbot/:
  file.directory:
    - name: /srv/legacy_magbot/
    - user: magbot
    - group: magbot
    - recurse: ['user', 'group']

/var/log/legacy_magbot/:
  file.directory:
    - name: /var/log/legacy_magbot/
    - makedirs: True
    - user: syslog
    - group: adm

/var/log/legacy_magbot/deploy/:
  file.directory:
    - name: /var/log/legacy_magbot/deploy/

/etc/rsyslog.d/legacy_magbot.conf:
  file.managed:
    - name: /etc/rsyslog.d/legacy_magbot.conf
    - contents: |
        if $programname == 'legacy_magbot' then /var/log/legacy_magbot/magbot.log
        if $programname == 'legacy_magbot' then ~
    - listen_in:
      - service: rsyslog

/etc/logrotate.d/legacy_magbot:
  file.managed:
    - name: /etc/logrotate.d/legacy_magbot
    - contents: |
        /var/log/legacy_magbot/magbot.log {
            weekly
            missingok
            rotate 52
            compress
            delaycompress
            notifempty
            create 640 syslog adm
            sharedscripts
            postrotate
                invoke-rc.d rsyslog rotate > /dev/null
            endscript
        }

legacy_magbot service:
  file.managed:
    - name: /lib/systemd/system/legacy_magbot.service
    - source: salt://legacy_magbot/files/legacy_magbot.service
    - template: jinja

  service.running:
    - name: legacy_magbot
    - enable: True
    - watch_any:
      - file: /lib/systemd/system/legacy_magbot.service
      - file: /srv/legacy_magbot/secret.sh
      - git: git@github.com:magfest/legacy_magbot.git
    - require:
      - pkg: redis-server
      - sls: nodejs
      - sls: npm
