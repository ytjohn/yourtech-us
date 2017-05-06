---
ID: 95
post_title: Securing Apache2
author: ytjohn
post_date: 2010-01-02 16:00:00
post_excerpt: ""
layout: post
permalink: >
  http://devblog.yourtech.us/2010/01/02/securing-apache2/
published: true
---
A client wanted to make files available available to the web browser
from within their LAN and a handful of static IPs without requiring any
sort of username or password.  This is the web equivalent of a shared,
read only folder.  This is no big issue, you can create an .htaccess
file like so:

<blockquote>
<strong>Order deny,allow<br />
Deny from all<br />
Allow from 10.10.0.1/16<br />
Allow from 127.0.0.1/32<br />
Allow from 1.1.1.1/32</br></br></br></br></strong>
</blockquote>

However, they would also like to access it from a remote location with a
username and password.

First, we need to create a password file.  In the old days, you would
use "AuthType Basic", but a more secure method is the Digest method.  To
use this, you must have the auth_digest module loaded into your Apache
configuration.  If you are running a Debian or Ubuntu version, you can
do this by executing "<strong>sudo a2enmod auth_digest</strong>".  Using digest
authentication prevents your username and password from being sent in
the clear (however, I always recommend that any site requiring
authentication should utilize https).

Next,  you create your htdigest file:

<blockquote>
<strong>htdigest -c .htdigest *authname username</strong>*
</blockquote>

When prompted, you would enter a password for <em>username</em>.

Finally, you need to modify your .htaccess file to allow either method:

<blockquote>
<strong>Order deny,allow<br />
Deny from all<br />
AuthName "authname"<br />
AuthType Digest<br />
AuthUserFile /var/www/.htpasswd<br />
require valid-userAllow from 10.10.0.1/16<br />
Allow from 127.0.0.1/32<br />
Allow from 1.1.1.1/32<br />
Satisfy Any</br></br></br></br></br></br></br></br></strong> 
</blockquote>

Now, a user can come from the 10.10.x.x network, localhost, or 1.1.1.1
without requiring authentication.  If they later come from an
unrecognized IP, they can enter their username and password and be
granted access.

--<br />
Securing Apache2 by IP or Username By YourTech John on January 2, 2010
8:40 AM</br>