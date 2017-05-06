# yourtech-us
YourTech.us website content

This works by using the [wp-github-sync] plugin. Any markdown file I commit to 
this repo will kick off a webhook at [yourtech.us].  Depending on the markdown frontmatter,
it will either get added to the web site as a page or a post. After the file is added, the plugin will
update the frontmatter, then rename to the file to live under the respective [_pages] or [_posts] directory.

Additionally, if I create or modify content through the wordpress gui, the plugin will update the github repository,
either adding or modifying a file as appropriate.

Because of the renaming, I found it's best to write new content under the git branch `source` and then creating a PR
 and merging to `master`. This ensures that none of the content I wrote locally is modified by the plugin. 

[yourtech.us]: https://www.yourtech.us
[wp-github-sync]: https://wordpress.org/plugins/wp-github-sync/
[frontmatter]: https://jekyllrb.com/docs/frontmatter/


I made a modification to my theme to include a link back to github for each individual post.

```$html

       <a class="btn btn-secondary btn-sm" 
       href="<?php echo( get_the_github_view_url() ); ?>" 
       title="View on Github">
            <i class="fa fa-github" aria-hidden="true"></i>
        </a>
        
```
