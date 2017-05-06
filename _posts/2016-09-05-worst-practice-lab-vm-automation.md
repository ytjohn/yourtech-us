---
post_title: Worst Practice Lab VM Automation
author: ytjohn
post_date: 2016-09-05 21:53:22
post_excerpt: ""
layout: post
permalink: >
  http://devblog.yourtech.us/2016/09/05/worst-practice-lab-vm-automation/
published: true
---
<h1>Worst Practice Lab VM Automation</h1>
<p>I've started the process of switching my lab over from unmanaged to ansible. I've used Puppet and Salt quite extensively through work, but after a handful of false starts with the lab, I think ansible is the way to go.g his is a series of what
many (including myself) would consider "worst practices", but are more along the lines of "rapid iteration". The goal here
is to get something working in a short period of time, without spending hours, days, or weeks researching best practices.
This is instead something someone can put together on a Sunday afternoon, in between chasing after a 3 year old.</p>
<p>These are a handful of manual steps, each of which could be easily automated once you determine your "starting point". </p>
<p><em>Background:</em> When I clone a VM in proxmox, it comes up with the hostname "xenial-template". I should be able to do something like I do with cloud-init under kvm, but I haven't gotten that far under the proxmox setup. Additionally, these hosts are not in dns until they are entered into the freeipa server. Joining a client to IPA will automatically create the entry. So the first thing I need to do to any VM is to set the hostname, fqdn, and then register it with IPA.  My template
has a user called "yourtech", which I can use to login and configure the VM.</p>
<p>First, create an ansible vault password file: <code>echo secret&gt; ~/.vault_pass.txt</code>. Next, create an and inventory directory and setup an encrypted <code>group_vars/all</code>.</p>
<pre><code>mkdir -p inventory/group_vars
touch inventory/group_vars/all
</code></pre>
<p>Add some common variables to <code>all</code>:</p>
<pre><code>---
ansible_ssh_user: yourtech
ansible_ssh_pass: secret
ansible_sudo_pass: secret
freeipaclient_server: dc01.lab.ytnoc.net
freeipaclient_domain: lab.ytnoc.net
freeipaclient_enroll_user: admin
freeipaclient_enroll_pass: supersecret
</code></pre>
<p>Then encrypt it: <code>ansible-vault --vault-password-file=~/.vault_pass.txt encrypt inventory/group_vars/all</code></p>
<h2>Generate inventory files.</h2>
<p>With the following script, I can run <code>./add-new.sh example 192.168.0.121</code>. If ansible failes, then I need to 
troubleshoot. A better approach would be to add these entries into a singular inventory file, or better yet,
a database, providing a constantly updated and dynamic inventory. Put that on the later pile.</p>
<pre><code>#!/usr/bin/env bash

NEWNAME=$1
IP=$2
DOMAIN=lab.ytnoc.net
FQDN="${NEWNAME}.${DOMAIN}"
ANSIBLE_VAULT_PASSFILE=~/.vault_pass.txt
BASEDIR=~/projects/ytlab/inventory
FILENAME="${BASEDIR}/${NEWNAME}"
LINE="${FQDN} ansible_host=${IP}"

export ANSIBLE_HOST_KEY_CHECKING=False

echo ${LINE} &gt; ${FILENAME}

echo "Removing any prior host keys"
ssh-keygen -R ${NEWNAME}
ssh-keygen -R ${FQDN}
ssh-keygen -R ${IP}

echo "${FILENAME} created, testing"
ansible --vault-password-file ${ANSIBLE_VAULT_PASSFILE} -i ${FILENAME} ${FQDN} -m ping -vvvv
</code></pre>
<h1>Let's go to work.</h1>
<p>At this point, I should have a working inventory file for a single host and I've validated that ansible can
connect. Granted, I haven't tested <code>sudo</code>, but in my situation, I'm pretty sure that will work. But I haven't
actually done anything with the VM. It's still just this default template.</p>
<h2>FQDN</h2>
<p>Ansible provides a module to set the hostname, but does not modify <code>/etc/hosts</code> to get the FQDN resolving. As with 
many things, I'm not the first to encounter this, so I found a premade role <a href="https://github.com/holms/ansible-fqdn.git">holms/ansible-fqdn</a>.</p>
<pre><code>mkdir roles
cd roles
git clone https://github.com/holms/ansible-fqdn.git fqdn
</code></pre>
<p>This role will read <code>inventory_hostname</code> for fqdn, and <code>inventory_hostname_short</code> for hostname. You can override
this, but these are perfect defaults based on my script above.</p>
<h2>FreeIPA</h2>
<p>Once again, we're saved by the Internet. <a href="https://github.com/alvaroaleman/ansible-freeipa-client.git">alvaroaleman/ansible-freeipa-client</a> is an already designed role that installs the necessary freeipa packages and runs the
ipa-join commands.</p>
<pre><code># assuming still in roles
git clone https://github.com/alvaroaleman/ansible-freeipa-client.git freeipa
</code></pre>
<p>The values this module needs just happens to perfectly match the freeipa_* variables I put in my <code>all</code> file earlier. I
think that's just amazing luck.</p>
<h2>Make a playbook.</h2>
<p>I call mine <code>bootstrap.yml</code>.  </p>
<pre><code>---
- hosts: all
  become: yes
  roles:
     - fqdn
     - freeipa
</code></pre>
<h2>Execute</h2>
<p>Let's run our playbook against host "pgdb02"</p>
<p><code>ansible-playbook -i inventory/pgdb02 --vault-password-file=~/.vault_pass.txt bootstrap.yml</code></p>
<p><em>Output:</em></p>
<pre><code>ytjohn@corp5510l:~/projects/ytlab$ ansible-playbook -i inventory/pgdb02 --vault-password-file=~/.vault_pass.txt base.yml

PLAY ***************************************************************************

TASK [setup] *******************************************************************
ok: [pgdb02.lab.ytnoc.net]

TASK [fqdn : fqdn | Configure Debian] ******************************************

TASK [fqdn : fqdn | Configure Redhat] ******************************************
skipping: [pgdb02.lab.ytnoc.net]

TASK [fqdn : fqdn | Configure Linux] *******************************************
included: /home/ytjohn/projects/ytlab/roles/fqdn/tasks/linux.yml for pgdb02.lab.ytnoc.net

TASK [fqdn : Set Hostname with hostname command] *******************************
changed: [pgdb02.lab.ytnoc.net]

TASK [fqdn : Re-gather facts] **************************************************
ok: [pgdb02.lab.ytnoc.net]

TASK [fqdn : Build hosts file (backups will be made)] **************************
changed: [pgdb02.lab.ytnoc.net]

TASK [fqdn : restart hostname] *************************************************
ok: [pgdb02.lab.ytnoc.net]

TASK [fqdn : fqdn | Configure Windows] *****************************************
skipping: [pgdb02.lab.ytnoc.net]

TASK [freeipa : Assert supported distribution] *********************************
ok: [pgdb02.lab.ytnoc.net]

TASK [freeipa : Assert required variables] *************************************
ok: [pgdb02.lab.ytnoc.net]

TASK [freeipa : Import variables] **********************************************
ok: [pgdb02.lab.ytnoc.net]

TASK [freeipa : Set DNS server] ************************************************
skipping: [pgdb02.lab.ytnoc.net]

TASK [freeipa : Update apt cache] **********************************************
ok: [pgdb02.lab.ytnoc.net]

TASK [freeipa : Install required packages] *************************************
 changed: [pgdb02.lab.ytnoc.net] =&gt; (item=[u'freeipa-client', u'dnsutils'])

TASK [freeipa : Check if host is enrolled] *************************************
ok: [pgdb02.lab.ytnoc.net]

TASK [freeipa : Enroll host in domain] *****************************************
changed: [pgdb02.lab.ytnoc.net]

TASK [freeipa : Include Ubuntu specific tasks] *********************************
included: /home/ytjohn/projects/ytlab/roles/freeipa/tasks/ubuntu.yml for pgdb02.lab.ytnoc.net

TASK [freeipa : Enable mkhomedir] **********************************************
changed: [pgdb02.lab.ytnoc.net]

TASK [freeipa : Enable sssd sudo functionality] ********************************
changed: [pgdb02.lab.ytnoc.net]

RUNNING HANDLER [freeipa : restart sssd] ***************************************
changed: [pgdb02.lab.ytnoc.net]

RUNNING HANDLER [freeipa : restart ssh] ****************************************
changed: [pgdb02.lab.ytnoc.net]

PLAY RECAP *********************************************************************
pgdb02.lab.ytnoc.net       : ok=18   changed=8    unreachable=0    failed=0   
</code></pre>
<h1>Recap</h1>
<p>Essentially, we created a rather basic inventory generator script, we encrypted some
credentials into a variables file using ansible-vault, and we downloaded some roles
"off the shelf" and executed them both with a single "bootstrap" playbook. </p>
<p>If I was doing this for work, I would first create at least one Vagrant VM and work through
an entire development cycle. I would probably rewrite these roles I downloaded to make them
more flexible and variable driven. </p>
<p>In case you got lost where these files go:</p>
<pre><code>.
├── add-new.sh
├── bootstrap.yml
├── inventory
│   ├── group_vars
│   │   ├── all
│   ├── pgdb01
│   ├── pgdb02
│   └── sstorm01
└── roles
    ├── fqdn
    └── freeipa
</code></pre>
