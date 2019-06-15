# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "gitolite/map.jinja" import gitolite with context %}

gitolite_install__pkg:
  pkg.installed:
    - pkgs: {{ gitolite.pkgs | tojson }}
