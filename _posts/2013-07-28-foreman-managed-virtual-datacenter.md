---
post_title: Foreman managed virtual datacenter
author: ytjohn
post_date: 2013-07-28 15:00:00
post_excerpt: ""
layout: post
permalink: >
  http://devblog.yourtech.us/2013/07/28/foreman-managed-virtual-datacenter/
published: true
---
<p>Tags: foreman, puppet, libvirt, virsh
Summary: Setting up a virtual datacenter using virsh, foreman, and puppet.</p>
<p>I ordered the KS2 from  - $50/month, 3.4ghz, 16gb ram, and a 1TB software raid setup. My plan is to set this
up as a single server virtual datacenter. They also have the SP2 with twice the ram and storage for $90, but I figured I'd test out
the cheaper option first. I can always upgrade and migrate to a larger server later if I get into heavier usage. The prices are rather cheap and they have scripts that will automatically provision physical servers. </p>
<p>I had this installed with Centos 6. I tried first using the "ovh secure" kernel, but I could not get KVM working with that kernel, so I had it reinstalled with the "vendor" kernel. I allocated 20GB to "/" and the remainder (898GB) to "/data". </p>
<p>Installing kvm and libvirt is a simple yum command.</p>
<pre><code>yum install kvm libvirt python-virtinst qemu-kvm
</code></pre>
<p>Then, on my workstation, I installed <a href="http://virt-manager.org/">virt-manager</a>, which allowed me to graphically create and install virtual machines (I can do this by hand on the server, but virt-manager is a nice way to get started). The connection is done over ssh, so it will either ask for your username/password, or it can use ssh-key authentication (preferred).</p>
<p>I created <code>/data/isos</code> and <code>/data/vms</code> to hold my installation isos and virual machines respectively. The trick I had to work out is that I couldn't just add "/data" as a directory-based storage volume, I had to make one for isos and one for vms. I also found that the default directory (/var/lib/libvirt/images) is rather difficult to remove. I disabled it and removed it, but it showed back up later. When creating through the dialog, virt-manager wants to put your vm image in "default". </p>
<p>Creating a new virtual machine using virt-manager and a downloaded ubuntu 12.04 iso image (in /data/isos) was rather slick. I created a new volume in /data/vms, set the memory and cpu and started it. The default networking is a NAT'd network in the 192.168.122.x/24 network. As ovh only provides 3 IP addresses for free, I'm content to start with this network for testing, but I plan to move to a different subnet mask.</p>
<p>If I need to nat ports, the libvirt site has a useful page on <a href="http://wiki.libvirt.org/page/Networking#Forwarding_Incoming_Connections">forwarding incoming connections</a>.</p>
<pre><code>iptables -t nat -A PREROUTING -p tcp --dport HOST_PORT -j DNAT --to $GUESTIP:$GUESTPORT
iptables -I FORWARD -d $GUESTHOST/32 -p tcp -m state --state NEW -m tcp --dport $GUESTPORT -j ACCEPT
</code></pre>
<p>I have been reading some good things about <a href="http://theforeman.org/">The Formean</a>, and how you can <a href="http://engineering.yakaz.com/managing-an-infrastructure-datacenter-with-foreman-and-puppet.html">manage an infrastructure with it</a>, so my next real VM will be an install of foreman. This will hopefully let me setup an enviroment where I can build virtual machines and provision them automatically. I don't know (yet) if The Foreman will handle iptable rules on the host, but it seems to have the ability to call external scripts and be customized, so I should be able to provision NAT on the host when provisioning a new VM.</p>
<p>Foreman utilizes DHCP and PXE to install "bare metal" VMs, so we need a network without DHCP. Now, to create my non-dhcp managed nat, I copy the default network xml file and modify it with my new range and remove the dhcp address</p>
<pre><code>cd /usr/share/libvirt/networks
cp default.xml netmanaged.xml
</code></pre>
<p>Modified netmanaged.xml:</p>
<pre><code>&lt;network&gt;
  &lt;name&gt;managednat&lt;/name&gt;
  &lt;bridge name="virbr1" /&gt;
  &lt;forward/&gt;
  &lt;ip address="172.16.25.1" netmask="255.255.255.0"&gt;
  &lt;/ip&gt;
&lt;/network&gt;
</code></pre>
<p>It should show up with <code>virsh net-list --all</code> and I can activate it.</p>
<pre><code># virsh net-list --all
Name                 State      Autostart     Persistent
--------------------------------------------------
default              active     yes           yes
managednat           inactive   yes           yes
# virsh net-autostart managednat
Network managednat marked as autostarted

# virsh net-list --all
Name                 State      Autostart     Persistent
--------------------------------------------------
default              active     yes           yes
managednat           inactive   yes           yes

# virsh net-start managednat
Network managednat started

# virsh net-list --all
Name                 State      Autostart     Persistent
--------------------------------------------------
default              active     yes           yes
managednat           active     yes           yes
</code></pre>
<p>The gateway will be 172.16.25.1, and I will assign the IP 172.16.25.5 to my Foreman virtual machine, aptly called "builder".  Once the basic ubuntu machine is installed by hand (hopefully the last one we do in this environment), I'll want access to it. Ideally, this would be behind a firewall with vpn access, but I haven't got that far yet. So for now, I'll just setup some NAT for port 22 and 443.</p>
<pre><code>iptables -t nat -A PREROUTING -p tcp --dport 8122 -j DNAT --to 172.16.25.5:22
iptables -I FORWARD -d 172.16.25.5/32 -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 8143 -j DNAT --to 172.16.25.5:443
iptables -I FORWARD -d 172.16.25.5/32 -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
</code></pre>
<p>Using "foreman-installer" is the most recommended method, ensuring that we have current packages directly from theforeman.org. I've installed 12.04 LTS (precise), so it's fairly straightforward, though I modified slightly from <a href="http://theforeman.org/manuals/1.2/index.html#3.2ForemanInstaller">the installation documentation</a>. The original instruction rely on running as root.</p>
<pre><code># get some apt support programs 
sudo apt-get install python-software-properties

# add the deb.theforeman.org repository
sudo bash -c "echo deb http://deb.theforeman.org/ precise stable &gt; /etc/apt/sources.list.db/foreman.list"  
# add the key
wget -q http://deb.theforeman.org/foreman.asc -O- | sudo apt-key add -
# install the installer
sudo apt-get update &amp;&amp; sudo apt-get install foreman-installer

# run the installer
sudo ruby /usr/share/foreman-installer/generate_answers.rb
</code></pre>
<p>At this point, Foreman is running on port 443, or in my case "https://externalip:8143/". I can login with the username "admin" and the password "changeme".</p>
<p>I've been reading the manual more at this point, but I think my next step is to watch the video <a href="http://www.youtube.com/watch?v=eHjpZr3GB6s">Foreman Quickstart: unattendend installation</a>. If I can grok that (and it looks nicely step by step) I'll try and setup an unattended install. </p>
