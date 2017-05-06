---
post_title: postgresql hstore is easy to compare
author: ytjohn
post_date: 2015-08-23 00:32:56
post_excerpt: ""
layout: post
permalink: >
  http://devblog.yourtech.us/2015/08/23/postgresql-hstore-is-easy-to-compare/
published: true
---
<p>hstore is an option key=&gt;value column type that's been around in postgresql for a long time. I was looking at it for a project where I want to compare "new data" to old, so I can approve it. There is a <code>hstore-hstore</code> option that compares two hstore collections and shows the differences.</p>
<p>In reality, an hstore column looks like text. It's just in a format that postgresql understands.</p>
<p>Here, we have an existing record with some network information.</p>
<pre><code>hs1=# select id, data::hstore from d1 where id = 3;
 id |                          data                          
----+--------------------------------------------------------
  3 | "ip"=&gt;"192.168.219.2", "fqdn"=&gt;"hollaback.example.com"
(1 row)
</code></pre>
<p>Let's say I submitted a form with slightly changed network information. I can do a select statement to get the differences.</p>
<pre><code>hs1=# select id, hstore('"ip"=&gt;"192.168.219.2", "fqdn"=&gt;"hollaback01.example.com"')-data from d1 where id =3;
 id |             ?column?              
----+-----------------------------------
  3 | "fqdn"=&gt;"hollaback01.example.com"
(1 row)
</code></pre>
<p>This works just as well if we're adding a new key.</p>
<pre><code>hs1=# select id, hstore('"ip"=&gt;"192.168.219.2", "fqdn"=&gt;"hollaback01.example.com", "netmask"=&gt;"255.255.255.0"')-data from d1 where id =3;
 id |                           ?column?                            
----+---------------------------------------------------------------
  3 | "fqdn"=&gt;"hollaback01.example.com", "netmask"=&gt;"255.255.255.0"
(1 row)
</code></pre>
<p>This information could be displayed on a confirmation page. Ideally, a proposed dataset would be placed somewhere, and a page could be rendered on the fly showing any changes an approval would create within the database.</p>
<p>Then we can update with the newly submitted form.</p>
<pre><code>hs1=# update d1 set data = data || hstore('"ip"=&gt;"192.168.219.2", "fqdn"=&gt;"hollaback01.example.com", "netmask"=&gt;"255.255.255.0"') where id = 3;
UPDATE 3

hs1=# select id, data::hstore from d1 where id = 3; id |                                         data                                         
----+--------------------------------------------------------------------------------------
  3 | "ip"=&gt;"192.168.219.2", "fqdn"=&gt;"hollaback01.example.com", "netmask"=&gt;"255.255.255.0"
(1 row)

</code></pre>
<p>Note that if I wanted to delete a key instead of just setting it to NULL, that would be a separate operation.</p>
<pre><code>update d1 SET data = delete(data, 'ip') where id = 3;
UPDATE 1
</code></pre>
<p>http://stormatics.com/howto-handle-key-value-data-in-postgresql-the-hstore-contrib/</p>
