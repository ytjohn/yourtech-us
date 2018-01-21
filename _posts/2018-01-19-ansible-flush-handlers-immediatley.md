---
ID: 574
post_title: Ansible Flush Handlers Immediatley
author: ytjohn
post_date: 2018-01-19 15:30:43
post_excerpt: ""
layout: post
permalink: >
  https://www.yourtech.us/2018/ansible-flush-handlers-immediatley
published: true
---

## ansible flush handlers

In ansible playbooks, handlers (such as to restart a service) normally happen at the end of a run. 
If you need ansible to run a handler between two tasks, there is "flush_handlers".

```
  - name: flush handlers
    meta: flush_handlers
```