
A Tiny World (28 Juni 2009)
============================
By: ippa@rubylicio.us / ippa @ #freenode
Entry for RubyWeeknd #3 [http://rubygame.org/forums/viewtopic.php?f=8&t=38]
Win32 Download: http://ippa.se/a_tiny_world.exe
OSX Download: http://ippa.se/a_tiny_world_intel_mac.zip



Game
====
Crush the minis and their world! 
Bonus for fancy kicks. Don't get bitten in the legs!
Move legs with Arrows. Kick with Space.


Thoughts
========
72 hours was abit long, I wasted 1-2 days in the sun and still started to get bored :p.
48 hours is probably enough.

Chipmunk-tweaking, especially syncing gfx to chipmunk-shapes, was hell and took alot of time.
I need to make a lib that solves this better and automaticly. Preferable via SVG-files.

Win32 Deployment with Ocra [http://github.com/larsch/ocra/tree/master] is cool.

I can't seem to find the perfect way of organizing levels... rubycode? singletonclass? yaml-files?

Actually taking time to work on alot of (easy) details, like simple bloodsplatter and various soundFX, really adds to the final experience.


Requires
========
Gosu: http://www.libgosu.org/
- "gem install gosu"

Chipmunk: http://wiki.slembcke.net/main/published/Chipmunk
- You'll need edge from http://code.google.com/p/chipmunk-physics/

Texplay: http://banisterfiend.wordpress.com/2008/08/23/texplay-an-image-manipulation-tool-for-ruby-and-gosu/
- 0.1.4.5 works
