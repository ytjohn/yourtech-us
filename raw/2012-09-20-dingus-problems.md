---
ID: 31
post_title: dingus problems
author: ytjohn
post_date: 2012-09-20 11:50:00
post_excerpt: ""
layout: post
permalink: >
  http://devblog.yourtech.us/2012/09/20/dingus-problems/
published: true
---
<p>Yesterday, I ran into a small, but confusing issue converting from markdown to html for a post. A markdown process will convert html in a code block to html escaped entities. That way, when you use the resulting html, your html example code doesn't get interpreted as html.</p>
<p>For example:</p>
<pre><code>&lt;p&gt;This is a &lt;strong&gt;strong&lt;/strong&gt; example.&lt;/p&gt;
</code></pre>
<p>Gets converted to:</p>
<pre><code>&lt;pre&gt;&lt;code&gt;&amp;lt;p&amp;gt;This is a &amp;lt;strong&amp;gt;strong&amp;lt;/strong&amp;gt; example.&amp;lt;/p&amp;gt;
&lt;/code&gt;&lt;/pre&gt;
</code></pre>
<p>In the "dingus" I made, this didn't appear to be happening. The above example rendered as:</p>
<pre><code>&lt;pre&gt;&lt;code&gt;This is a &lt;strong&gt;strong&lt;/strong&gt; example.&lt;/p&gt;&lt;/code&gt;&lt;/pre&gt;
</code></pre>
<p>Furthermore, it worked perfectly fine using the "official" php-markdown <a href="http://michelf.ca/projects/php-markdown/dingus/">dingus</a>. I was using their library, and it's incredibly simple to implement. After some digging, I discovered that in my dingus, the code was being converted properly in my preview section, but not in my HTML Source textarea. I was printing the same <code>$render</code> variable in both sections, but getting different results in my browser. </p>
<p>As it turns out, most html elements are "CDATA" and a textarea is "PCDATA". When all is said and done, this means that instead of needing to send &lt;, I need to send &amp;lt to the browser. Fortunately, php has a function called htmlspecialchars() that does this for me. For my HTML Output, I just needed to change <code>print $render</code> to <code>print htmlspecialchars($render)</code>.</p>
<p>20120920</p>