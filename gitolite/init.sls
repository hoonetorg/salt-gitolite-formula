# -*- coding: utf-8 -*-
# vim: ft=sls

include:
  - gitolite.user
  - gitolite.install
  - gitolite.config

extend:
  gitolite_install__pkg:
    pkg:
      - require:
        - cmd: gitolite_user__finished
  gitolite_config__file_projects.list:
    file:
      - require:
        - pkg: gitolite_install__pkg

