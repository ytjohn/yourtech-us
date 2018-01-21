---
ID: 571
post_title: Enable linux serial console
author: ytjohn
post_date: 2018-01-19 12:40:36
post_excerpt: ""
layout: post
permalink: >
  https://www.yourtech.us/2018/enable-linux-serial-console
published: true
---
## Serial port console

This is how to get serial port console working on a Ubuntu 16.04 (or any systemd based OS) and how to access it with idrac/ssh.


To get serial port working on a running system:

```
systemctl enable serial-getty@ttyS0.service
systemctl start serial-getty@ttyS0.service
```

**Update Grub:**

To get serial console during boot up, including the grub menu:

Go ahead and edit `/etc/default/grub` 

```
GRUB_CMDLINE_LINUX_DEFAULT=&quot;splash quiet&quot;
GRUB_CMDLINE_LINUX=&quot;console=tty0&quot;
GRUB_TERMINAL=&quot;console serial&quot;
# also, it takes so long to boot a server, adding 10
# second to the grub menu is more good than harm
GRUB_TIMEOUT=10
```

**Access it via idrac**

```
ssh &lt;idrac-ip&gt; console com2
```


#yourtech-dailies