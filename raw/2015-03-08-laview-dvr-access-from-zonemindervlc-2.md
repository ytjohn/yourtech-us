---
ID: 66
post_title: LaView DVR access from zoneminder/vlc
author: ytjohn
post_date: 2015-03-08 13:40:39
post_excerpt: ""
layout: post
permalink: >
  http://devblog.yourtech.us/2015/03/08/laview-dvr-access-from-zonemindervlc-2/
published: true
---
Finally connected my DVR to the network. It's an LaView lv-d0404bs (4-ch dvr). I searched all over and couldn't find an rtsp url for this model. Finally, I did what I should have done, and opened the source of the web page.

I found this bit of code:     <code>var url = "rtsp://" + ip + ":" + port + "/H264?ch="+channelnum+"&amp;subtype=" + _type;</code>

Which translates to:

<code>rtsp://[IP]:554//H264?ch=[CAMERA]&amp;subtype=1</code>

I am not sure what the difference in sub-types is. Valid values are 0 &amp; 1, and they seem to have the same resolution. Sub-type 0 seems to scale to fill the window, whereas 1 starts off at a 4:3 aspect ratio.

<img alt="Camera03 Driveway" height="237" src="https://lh4.googleusercontent.com/-ae7Ji-npt38/VPxOI3oAkiI/AAAAAAAAXnY/tCtOITKq2hs/w852-h474/Screen%2BShot%2B2015-03-08%2Bat%2B9.25.33%2BAM.png" style="" width="426"/>