## Gemini PDA First Impressions
 
I received my Gemini PDA/Phone a couple days ago. Basically, this is an android smartphone in a clamshell design with a physical keyboard. The makers also fully support rooting, custom roms, and dual booting into linux.

Goals for this device:

1. I was partially hoping to use it as my primary phone. However, the screen is not visible when closed, and the device lacks a decent camera. Becoming the primary phone would require some sacrifice.
 
2. Use it for amateur radio. Under android I can run APRSDroid, and under linux I can run fldigi and CHIRP for programming.

3. Possibly do some programming in GO, while on the go. With Termux android app, I can install Git, ssh keys, vim, and golang. I've compiled go code on another android phone and ran the resulting binary, so this should be totally possible. 

4. Write blog posts on the move.


## Initial Impressions

### Annoyances

Let me get all the initial annoyances and unresolved problems out of the way first:
 
1. During setup, the keyboard layout was not Enlish(US). The 2 key has the @ sign, but shif+2 provided a double quote ("). Having encountered this with raspberry pis, I knew what the issue was, but had to do some work to get around the setup screen and find a place to set the gemini keyboard to English(US).
 
2. Invoking a soft keyboard like lastpass or gboard causes the physical keyboard to revert to the UK layout.
 
3. The colon and semicolon are not to the right of the L. You have to press Fn + \ for colon and Fn + K for semi-colon. Several other keys are in odd spots, and the priority is almost certaintly based on a UK layout. For instance, the period is where I expect the comma to be and the up arrow is where I expect the period to be. Often while ending a sentence, I end up one line above (or the beginning of a line). A UK person may love this layout, and I know every small keyboard has to deviate, but these deviations are really messing me up.  Ie, the keyboard is just familiar enough to get some speed, but that comfort makes it easierto make mistakes. I am hoping that in the future, we can get blank keycaps and software to remap all they keys.

4. I took a verizon sim out of my work iphone and it doesn't entirely work. This might be either Apple or Verizon's fault though. I can receive but not make calls, and send but not receive sms  messages. The same sim in my ZTE axon works fine.  VoLTE 4G data wors fine though. I will have to research this further. Others have had issues with dropped calls on VoLTE and this might be related. Honestly though, I didn't even expect the verizon sim to work at all.

### Likes

Now what do I like about this phone? Keep in mind I have only tried the Android side and have not set it up for dual boot linux yet.
 
First off, the keyboard. Despite my complaint above, I can still type pretty quick on the keyboard and I get faster as I go. I am writing this post using gemini keyboard. As long as I avoid punctuation, I can type without much in the way of errors. Like I said, if there became a way to remap keys so that I could change where punctuation lives, I think I could really grow to love the keyboard even more. I would imagine the community would rally around this and provide a collection of keyboard layouts. Since this is a personal device of unique form factor, it doesn't have to be as uniform as desktop/laptop keyboards would be.

Along with the keyboard is the screen space freed up by not having the soft keyboard pop up. Things like JuiceSSH, Termux, and spreadsheets become much more usable. Caveat: Vim is kind of usable, but with the odd placement of the colon, I am a bit hindered. 

Holding the phone with one hand and typing with the other has not been an issue. If you rotate the screen portrait, the phone holds like a book, which is nice in its own way.

I was able to use a tablet mount to mount the phone on my dash and run aprsdroid. This is not unique to the gemini because I used to do this with my old phone and with a Nexus 7. However, the fit and placement of this device with its fold out keyboard works out better than a tablet ever did, and better than a laptop would be able to do. With my USB-C cable, I could potentially place a hub out of reach and connect to other devices in the car.

Overall, I find myself reaching for this Gemini more than my main phone. The main phone provides picture taking, calls, and signal/sms messaging. I do everything else on the gemini.

## Mixed

With Termux, I was able to install git, go, vim, and setup an ssh key. I was able to rsync files from my laptop and compile a project I am working on. 

Then I decided to try and setup the filesystem so I could edit code using an android gui app and compile it within termux. Getting the file shared worked, but then I ran into problems. Pretty much any repo I cloned into `/storage/emulated /0/<wherever>` would run into permission problems. Similarily, rsyncing files from termux's home directory into main storage had issues. It was all mostly with dot files, such as those under `.git/`. 

I decided to stick with the main storage, but even there I was not able to compile hugo. Hugo requires a package called "mage" to build it, and mage kept trying and failing to create a lockfile. 

This puts my dream of writing go on the go in doubt. Some basic stuff worked, but I am going to keep running into android filessytem issues. However, I might have better luck booted into linux.

## Final Thoughts

I have been pretty pleased with this phone so far. I thought about switching the sim cards to make this a primary phone, and I may still do so. I also thought about carrying aro und the Gemini and an action camera like a GoPro. However, one thought that keeps coming up is the times I plan to dual boot into Linux. During that time, the phone will be unavaiable. So it might be better to maintain this as a standalone pockettop.  Even in this capacity, I think it will be a better fit than the GDP Pocket, another device I was looking at. For day2day mobile usage, an android device (or chromeos device) is much friendlier than a windows tablet or a tiny linux. But being able to boot into linux for specific tasks is a big win. If I can share files between android and linux, that will truly put the icing on the cake.

