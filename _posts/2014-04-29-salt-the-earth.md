---
post_title: Salt The Earth
author: ytjohn
post_date: 2014-04-29 22:10:00
post_excerpt: ""
layout: post
permalink: >
  http://devblog.yourtech.us/2014/04/29/salt-the-earth/
published: true
---
<h2>Learning Salt</h2>
<p>I am just beginning to read up on <a href="http://docs.saltstack.com/en/latest/topics/tutorials/walkthrough.html">SaltStack</a>, but I am really liking it. It has a number of things I like from Ansible (separation from code and state), the targeting abilities of mcollective, and the centralized control of Puppet/Chef. Salt can be run masterless, but in a master/minion configuration, it uses a message queue (0mq) to control minions and get information back. All messages in this queue are encrypted using keys on both the minion and the master. If you distribute this key, you can consume salt generated data in other programs.</p>
<p>Running commands across all minions could look lik this:</p>
<pre><code>salt '*' test.ping
salt '*' disk.percent
</code></pre>
<p>In these, test.ping and disk.percent are known as 'execution modules', which are essentially python modules that contain defined functions. For example, disk would be an 'execution module' and "percent" would be a function defined. Here, test.ping runs on all target hosts and returns "True"; disk.percent returns the percentage of disk usage on all minions.</p>
<p>You can also run ad-hoc commands.</p>
<pre><code>salt '*' cmd.run 'ls -l /etc'
</code></pre>
<p>Of course, you can target blocks of systems by hostname (<code>web*</code> will match web, web1, web02, webserver,..). Salt also has something called <a href="http://docs.saltstack.com/en/latest/topics/targeting/grains.html">Grains</a> which everyone else calls facts. You can target based on the grains, or use salt to provide a report based on the grains. The following command will return the number of cpus for every 64-bit cpu.</p>
<pre><code>salt -G 'cpuarch:x86_64' grains.item num_cpus
</code></pre>
<p>I <em>think</em> this would work as well:</p>
<pre><code>salt -G 'cpuarch:x86_64 and num_cpus:4' test.ping
</code></pre>
<p>If not, these would work (Compound match):</p>
<pre><code>salt -C 'G@cpuarch:x86_64 and G@num_cpus:4' test.ping
salt -c 'G@os:Ubuntu or G@os.Debian' test.ping
</code></pre>
<h2>Salt States</h2>
<p>In Puppet, your manifests and modules are very closely coupled in puppet code. In Ansible, they separate things into modules and "playbooks". These playbooks are yaml files detailing what modules and values for ansible to use. Salt follows this pattern as well, separating execution modules from states with "Salt States", aka SLS formulas (aka state modules).</p>
<p>A sample SLS formual for installing nginx would look like this:</p>
<pre><code>nginx:
  pkg:
    - installed
  service:
    - running
    - require:
      - pkg: nginx
</code></pre>
<p>Assuming you save that in the right spot (/srv/salt/nginx/init.sls), you can apply this state module to all servers starting with the name 'web'.</p>
<pre><code>salt 'web*' state.sls nginx
</code></pre>
<p>So with one tool, you can query a large amount of data from all your minions, move them to a specific state, run ad-hoc style modules, etc. This can also all be expanded by writing your own python modules. Also, I'm mostly interested in the ability to target modules and groups of hosts in one command, but it's worh noting that salt will do scheduling of jobs just like puppet and chef do.</p>
