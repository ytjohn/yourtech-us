---
ID: 29
post_title: New Static Site
author: ytjohn
post_date: 2013-03-24 16:00:00
post_excerpt: ""
layout: post
permalink: >
  http://devblog.yourtech.us/2013/03/24/new-static-site/
published: true
---
<p>I had mentioned previously that I had taken up <a href="http://www.yourtech.us/blog/feeds/rss/%7Cfilename%7Cmarkdown-blogging.md">markdown blogging</a>. At that time, I was writing my post in markdown, converting it to HTML, and then injecting it into <a href="http://www.blogger.com">blogger</a>. This last week, I have done a good bit of work to convert my site to a "static site" using <a href="http://www.getpelican.com/">Pelican</a>. A static site is made up entirely of static files - no database, no php includes, just your basic collection of html, javascript, css, and images. I write content in Markdown on my laptop. I develop my theme locally as well. Then I run "make html" and pelican will process my configuration file, my content, and my theme to generate all of the pages, posts, archive pages, and various rss feeds. The end result is a directory full of files that can be dropped onto pretty much any webserver.</p>
<p>There were a few hic-cups. Many of my older pages were not originally written in markdown, but rather using whatever CMS editor I had at the time. Pelican has an import feature, but some things got lost in translation. Any preformated code blocks had to be re-created manually (amusingly enough, copying and pasting from the old web page into vim, then indenting them properly).</p>
<p>The biggest loss is a search engine. A CMS like Wordpress or a hosted solution like Blogger stores your content in a database and provides a search interface to that content. With static pages, not so much. Most of the web gets around this using Google's <a href="http://www.google.com/cse">CSE</a>, which I am trying as well. As of yet, almost nothing appears to be indexing on this page. If this continues, I will setup a stanadlone search engine that simply indexes the pages on this site. <strong>(<strong>UPDATE</strong>: Google has a nice fresh index of the website, covering everything except this page I wrote yesterday.)</strong> I'm still researching possibilities on that. Ten years ago, <a href="http://www.htdig.org/">ht://dig</a> was the premier application to use, but development on that seems to have stopped in 2004. <a href="http://www.sphider.eu/">Sphider</a> looks like a good product, but again, development stopped in 2007. Small search engine development seems to have dropped off significantly with the rise of Google's popularity. </p>
<p>A copy of the website content and theme can be tracked on <a href="http://www.github.com/ytjohn/ytwebsite">github</a>. </p>