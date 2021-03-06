include:
  - nodejs
  - npm

slack-irc user:
  user.present:
    - name: slack-irc

slack-irc:
  npm.installed:
    - name: slack-irc
    - require:
      - sls: nodejs
      - sls: npm

/var/log/slack-irc/:
  file.directory:
    - name: /var/log/slack-irc/
    - makedirs: True
    - user: syslog
    - group: adm

slack-irc rsyslog conf:
  file.managed:
    - name: /etc/rsyslog.d/slack-irc.conf
    - contents: |
        if $programname == 'slack-irc' then /var/log/slack-irc/slack-irc.log
        if $programname == 'slack-irc' then ~
    - listen_in:
      - service: rsyslog

/etc/logrotate.d/slack-irc:
  file.managed:
    - name: /etc/logrotate.d/slack-irc
    - contents: |
        /var/log/slack-irc/slack-irc.log {
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

slack-irc.service:
  file.managed:
    - name: /lib/systemd/system/slack-irc.service
    - source: salt://slack_irc/files/slack-irc.service
    - template: jinja

slack-irc.conf.json:
  file.managed:
    - name: /etc/slack-irc.conf.json
    - source: salt://slack_irc/files/slack-irc.conf.json
    - user: root
    - group: slack-irc
    - mode: 640
    - template: jinja
    - show_changes: False

slack-irc.service running:
  service.running:
    - name: slack-irc
    - enable: True
    - watch_any:
      - file: /lib/systemd/system/slack-irc.service
      - file: /etc/slack-irc.conf.json
    - require:
      - sls: nodejs
      - sls: npm
