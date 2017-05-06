---

post_title: Backing up with duplicity and Amazon S3
author: ytjohn
post_date: 2009-10-26 16:00:00
post_excerpt: ""
layout: post
permalink: >
  http://devblog.yourtech.us/2009/10/26/backing-up-with-duplicity-and-amazon-s3/
published: true
---
<a href="http://duplicity.nongnu.org/" title="http://duplicity.nongnu.org/">Duplicity</a> is a great little backup tool that can do incremental
backups to a variety of different servers (ftp, scp, and Amazon S3).

<h2><a href="http://www.yourtech.us/2009/10/editor-content.html?cs=utf-8">The Install</a></h2>

I am installing on a Centos 5 system which uses the yum tool. I also
have the <a href="http://rpmforge.net/">http://rpmforge.net/</a>repository enabled. I need that for
librsync and librsync-devel which provides rsync capabilities when the
remote file details are not available (like in FTP). <br />
All of these requirements are found on the <a href="http://duplicity.nongnu.org/" title="http://duplicity.nongnu.org/">duplicity</a> main
page.   </br>

<pre><code>yum install librsync librsync-devel# GnuPG for python (stable, hasn't changed in years)
wget http://internap.dl.sourceforge.net/sourceforge/py-gnupg/GnuPGInterface-0.3.2.tar.gz
tar -xzf GnuPGInterface-0.3.2.tar.gz
cd GnuPGInterface-0.3.2
python setup.py installcd ..
# boto for python (Python S3 interface -- active development, check version #)
wget http://boto.googlecode.com/files/boto-1.1c.tar.gz
tar -xzvf boto-1.1c.tar.gz
cd boto-1.1c
python setup.py installcd ..
# duplicity (active development, check version #)
tar -xzf duplicity-0.4.10.tar.gz 
cd duplicity-0.4.10
python setup.py install
cd ..
</code></pre>

Make sure duplicity works by running the command "duplicity" <br />
You should see something like this (and not errors about GnuPG
instances).   </br>

<pre><code>[root@serv02 ~]# duplicity 
Command line error: Expected 2 args, got 0
Enter 'duplicity --help' for help screen.
</code></pre>

<h2><a href="http://www.yourtech.us/2009/10/editor-content.html?cs=utf-8">Make your gpg keys</a></h2>

Do this as the user that you'll be running the backup as - it makes
things easier. If you have your own existing keys and know how to import
them, you can skip this step. Otherwise, we'll create a key just for
encrypting the backups before sending them to our backup server (in case
of rogue system admins at Amazon).

<pre><code>[root@serv02 ~]# gpg --gen-keygpg 
(GnuPG) 1.2.6; Copyright (C) 2004 Free Software Foundation, Inc.This program comes with ABSOLUTELY NO WARRANTY.This is free software, and you are welcome to redistribute itunder certain conditions. See the file COPYING for details.
gpg: failed to create temporary file `/home/ytjohn/.gnupg/.#lk0x9d199d8.serv02.example.com.12823': No such file or directory
gpg: /home/ytjohn/.gnupg: directory created
gpg: new configuration file `/home/ytjohn/.gnupg/gpg.conf' created
gpg: WARNING: options in `/home/ytjohn/.gnupg/gpg.conf' are not yet active during this run
gpg: keyring `/home/ytjohn/.gnupg/secring.gpg' created
gpg: keyring `/home/ytjohn/.gnupg/pubring.gpg' created
Please select what kind of key you want: 
  (1) DSA and ElGamal (default) 
  (2) DSA (sign only) 
  (4) RSA (sign only)
Your selection? 1
DSA keypair will have 1024 bits.
About to generate a new ELG-E keypair.
              minimum keysize is  768 bits
              default keysize is 1024 bits
    highest suggested keysize is 2048 bits
What keysize do you want? (1024) 2048
Requested keysize is 2048 bits
Please specify how long the key should be valid.
         0 = key does not expire
      &lt;n&gt;  = key expires in n days
      &lt;n&gt;w = key expires in n weeks
      &lt;n&gt;m = key expires in n months
      &lt;n&gt;y = key expires in n years
Key is valid for? (0) 0
Key does not expire at all
Is this correct (y/n)? y                        
You need a User-ID to identify your key; the software constructs the user id
from Real Name, Comment and Email Address in this form:    "Heinrich Heine (Der Dichter) &lt;heinrichh@duesseldorf.de&gt;"
Real name: Backup Key
Email address: anything@example.com
Comment: Backup key for duplicity  
You selected this USER-ID:           "Backup Key (Backup key for duplicity) &lt;anything@example.com&gt;"
Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
You need a Passphrase to protect your secret key.
</code></pre>

At this point, let me interrupt and talk about the Passphrase. You can
make this anything, but I would recommend avoiding special characters
(especially dealing with \&lt;&gt; ' " \ ` ) that might be interpreted by
your system shell. I generated a 15 character password <a href="http://www.freepasswordgenerator.com/" title="http://www.freepasswordgenerator.com/">online</a> using
only numbers, letters, and LETTERS. You will need to keep track of the
password - you will need it later when you write the backup script.

<pre><code>We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
+++++++++++++++++++++++++.+++++++++++++++++++++++++++++++++++..+++++.++
+++++++++++++..++++++++++.+++++++++++++++..++++++++++++++++++++++++++++
++.&gt;+++++..............................................................
.......................................................................
......+++++
gpg: /home/ytjohn/.gnupg/trustdb.gpg: trustdb created
public and secret key created and signed.key marked as ultimately

     trusted.pub  1024D/53F0891A 2008-04-08 
     Backup Key (Backup key for duplicity) &lt;anything@example.com&gt;
     Key fingerprint = 135A 1533 5C94 3A58 5398  7467 98A0 C424 5BF0 8C2E
     sub  2048g/630FAA4F 2008-04-08
</code></pre>

We see our key ID is 53F0891A - make a note of this for the backup
script.

<h2><a href="http://www.yourtech.us/2009/10/editor-content.html?cs=utf-8">The backup script</a></h2>

Essentially, what we want is a script that you just run and it will
perform the backup for you. For my purposes, I want to backup to
Amazon's Simple Storage Service (<a href="http://s3.amazonaws.com/" title="http://s3.amazonaws.com/">s3</a>). To do this, you will need to
sign up for the service (no cost to signup, just pay for space/bandwidth
used) and get the AWS/AWS secret keys (think of them like
username/passwords). <br />
The following script will backup a directory called /mnt/backups to an
Amazon bucket called j123backup (the bucket name must be unique between
all Amazon S3 users). Please note that while you can use the same script
and gpg keys on multiple servers (or have multiple backup scripts on the
same server backing up different directories), you will want to make a
separate bucket for each different source backup.   </br>

<pre><code>#!/bin/bash
# Export some ENV variables so you don't have to type anything
export AWS_ACCESS_KEY_ID=accesskeyexport AWS_SECRET_ACCESS_KEY=secretkey
# GPG passphrase we used earlier
export PASSPHRASE=123456789012345
GPG_KEY=53F0891A
# The source of your backup
SOURCE=/mnt/backup
# The destination
# Note that the bucket need not exist
# but does need to be unique amongst all
# Amazon S3 users. So, choose wisely. 
DEST=s3+http://j123backup
# You can of course change your destination to an ftp or# scp (ssh copy) server:
#DEST=scp://backupuser@backup.example.com/backups
duplicity \
    --encrypt-key=${GPG_KEY} \
    --sign-key=${GPG_KEY} \
    ${SOURCE} ${DEST} 
# this is an example of backing up multiple 
# directories at once and excluding others:
## duplicity \
#     --encrypt-key=${GPG_KEY} \
#     --sign-key=${GPG_KEY} \
#     --include=/home \
#     --include=/var/www/html \
#     --exclude=/var/www/html/cache/* \
#     ${SOURCE} ${DEST} # Reset the ENV variables. Don't need them sitting around
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export PASSPHRASE=
</code></pre>

As a final note, you can definitely point your backup at another
destination such as ftp or scp. I later ended up choosing an scp server
over Amazon S3.--<br />
Backing up with duplicity and Amazon S3 By YourTech John on October 26,
2009 7:00 AM</br>
