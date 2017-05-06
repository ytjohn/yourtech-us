---
ID: 64
post_title: postgresql hstore is easy to compare
author: ytjohn
post_date: 2015-08-23 00:32:56
post_excerpt: ""
layout: post
permalink: >
  http://devblog.yourtech.us/2015/08/23/postgresql-hstore-is-easy-to-compare-2/
published: true
---
hstore is an option key=&gt;value column type that's been around in postgresql for a long time. I was looking at it for a project where I want to compare "new data" to old, so I can approve it. There is a <code>hstore-hstore</code> option that compares two hstore collections and shows the differences.

In reality, an hstore column looks like text. It's just in a format that postgresql understands.

Here, we have an existing record with some network information.

<pre><code>hs1=# select id, data::hstore from d1 where id = 3;
 id |                          data                          
----+--------------------------------------------------------
  3 | "ip"=&gt;"192.168.219.2", "fqdn"=&gt;"hollaback.example.com"
(1 row)
</code></pre>

Let's say I submitted a form with slightly changed network information. I can do a select statement to get the differences.

<pre><code>hs1=# select id, hstore('"ip"=&gt;"192.168.219.2", "fqdn"=&gt;"hollaback01.example.com"')-data from d1 where id =3;
 id |             ?column?              
----+-----------------------------------
  3 | "fqdn"=&gt;"hollaback01.example.com"
(1 row)
</code></pre>

This works just as well if we're adding a new key.

<pre><code>hs1=# select id, hstore('"ip"=&gt;"192.168.219.2", "fqdn"=&gt;"hollaback01.example.com", "netmask"=&gt;"255.255.255.0"')-data from d1 where id =3;
 id |                           ?column?                            
----+---------------------------------------------------------------
  3 | "fqdn"=&gt;"hollaback01.example.com", "netmask"=&gt;"255.255.255.0"
(1 row)
</code></pre>

This information could be displayed on a confirmation page. Ideally, a proposed dataset would be placed somewhere, and a page could be rendered on the fly showing any changes an approval would create within the database.

Then we can update with the newly submitted form.

<pre><code>hs1=# update d1 set data = data || hstore('"ip"=&gt;"192.168.219.2", "fqdn"=&gt;"hollaback01.example.com", "netmask"=&gt;"255.255.255.0"') where id = 3;
UPDATE 3

hs1=# select id, data::hstore from d1 where id = 3; id |                                         data                                         
----+--------------------------------------------------------------------------------------
  3 | "ip"=&gt;"192.168.219.2", "fqdn"=&gt;"hollaback01.example.com", "netmask"=&gt;"255.255.255.0"
(1 row)

</code></pre>

Note that if I wanted to delete a key instead of just setting it to NULL, that would be a separate operation.

<pre><code>update d1 SET data = delete(data, 'ip') where id = 3;
UPDATE 1
</code></pre>

http://stormatics.com/howto-handle-key-value-data-in-postgresql-the-hstore-contrib/