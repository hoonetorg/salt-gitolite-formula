# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "gitolite/map.jinja" import gitolite with context %}

gitolite_config__file_projects.list:
  file.managed:
    - name: {{gitolite.get('users', {}).get('git', {}).get('home')}}/projects.list
    - user: git
    - group: git
    - mode: "'0640'"

gitolite_config__file_ssh_admin_key_pub:
  file.managed:
    - name: {{gitolite.get('users', {}).get('git', {}).get('home')}}/{{ gitolite.get('ssh_admin_key_pub', {}).get('name', 'ssh_admin_key') }}.pub
    - contents: {{gitolite.get('ssh_admin_key_pub', {}).get('content')|yaml_encode}}
    - user: git
    - group: git
    - mode: "'0600'"
    - require:
      - file: gitolite_config__file_projects.list


gitolite_config__{{ gitolite.conffile }}:
  file.managed:
    - name: {{gitolite.get('users', {}).get('git', {}).get('home')}}/{{ gitolite.conffile }}
    - source: salt://gitolite/files/configtempl.jinja
    - template: jinja
    - context:
      confdict: {{gitolite|json}}
    - mode: "'0600'"
    - user: git
    - group: git
    - require:
      - file: gitolite_config__file_projects.list


gitolite_config__firstsetupcommand:
  cmd.run:
    - name: gitolite setup -pk {{gitolite.get('users', {}).get('git', {}).get('home')}}/{{ gitolite.get('ssh_admin_key_pub', {}).get('name', 'ssh_admin_key') }}.pub
    - cwd: {{gitolite.get('users', {}).get('git', {}).get('home')}}
    - runas: git
    - creates: {{gitolite.get('users', {}).get('git', {}).get('home')}}/.gitolite/conf/gitolite.conf
    - require:
      - file: gitolite_config__file_ssh_admin_key_pub
      - file: gitolite_config__{{ gitolite.conffile }}

{% for hook, hook_data in gitolite.get('hooks', {}).items() %}
gitolite_config__hook_{{ hook }}:
  file.managed:
    - name: {{gitolite.get('users', {}).get('git', {}).get('home')}}/.gitolite/hooks/common/{{hook}}
    - contents: {{hook_data|yaml_encode}}
    - user: git
    - group: git
    - mode: "'0755'"
    - require:
      - cmd: gitolite_config__firstsetupcommand
    - watch_in:
      - cmd: gitolite_config__setupcommand
{% endfor %}

gitolite_config__setupcommand:
  cmd.wait:
    - name: gitolite setup
    - cwd: {{gitolite.get('users', {}).get('git', {}).get('home')}}
    - runas: git
    - require:
      - cmd: gitolite_config__firstsetupcommand
