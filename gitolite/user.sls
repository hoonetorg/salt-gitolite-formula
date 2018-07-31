{% from "gitolite/map.jinja" import gitolite with context %}
{% for group, group_data in gitolite.groups.items() %}
gitolite_user__group_{{group}}:
  group.present:
    - name: {{group}}
    - gid: {{group_data.gid}}
    - system: True
    - require_in:
      - user: gitolite_user__user_{{group}}
{% endfor %}

{% for user, user_data in gitolite.users.items() %}
gitolite_user__user_{{user}}:
  user.present:
    - name: {{user}}
    - home: {{user_data.home}}
    - uid: {{user_data.uid}}
    - gid: {{gitolite.get('groups', {}).get(user,{}).get('gid', user_data.uid)}}
    - groups: {{user_data.groups|json}}
    - shell: {{user_data.shell}}
    - fullname: {{user_data.fullname}}
    - system: True
    - require_in:
      - file: gitolite_user__user_{{user}}

  file.directory:
    - name: {{user_data.home}}
    - user: {{user_data.uid}}
    - group: {{gitolite.get('groups', {}).get(user,{}).get('gid', user_data.uid)}}
    - mode: "{{ user_data.get('home_mode', '0750') }}"
    - require_in:
      - cmd: gitolite_user__finished

  {% if user_data.get('ssh_private_key', False) and user_data.get('ssh_private_key', False) and user_data.get('ssh_key_cipher', False) %}
gitolite_user__sshdir_{{ user }}:
  file.directory:
    - name: {{user_data.get('home')}}/.ssh
    - mode: "'0700'"
    - user: {{user}}
    - group: {{user}}
    - require:
      - file: gitolite_user__user_{{user}}

gitolite_user__sshprivkey_{{ user }}:
  file.managed:
    - name: {{user_data.get('home')}}/.ssh/id_{{user_data.get('ssh_key_cipher')}}
    - contents: {{user_data.get('ssh_private_key')|yaml_encode}}
    - mode: "'0600'"
    - user: {{user}}
    - group: {{user}}
    - require:
      - file: gitolite_user__sshdir_{{ user }}
    - require_in:
      - cmd: gitolite_user__finished

gitolite_user__sshpubkey_{{ user }}:
  file.managed:
    - name: {{user_data.get('home')}}/.ssh/id_{{user_data.get('ssh_key_cipher')}}.pub
    - contents: {{user_data.get('ssh_public_key')|yaml_encode}}
    - mode: "'0644'"
    - user: {{user}}
    - group: {{user}}
    - require:
      - file: gitolite_user__sshdir_{{ user }}
    - require_in:
      - cmd: gitolite_user__finished

  {% endif %}

{% endfor %}

gitolite_user__finished:
  cmd.run:
    - name: true
    - unless: true

