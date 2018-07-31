# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "gitolite/map.jinja" import gitolite with context %}

/tmp/gitolite.yaml:
  file.managed:
    - contents: |
        {{gitolite|yaml(False)|indent(8)}}
