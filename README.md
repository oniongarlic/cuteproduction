# CuteProduction

A very beta version of a video production helper for streaming. It can 
be used for example with ATEM Mini switchers for keying information to the video feed.

It can display various things on the output display, for example time,
timers (up/down), messages, chats like bubbles, video playback, video capture,
lower thirds, news ticker (supports RSS files).

It works best with 2-4 displays:

* one for control window
* one for the output features
* alpha channel output for masking (experimental)
* telepromt window

Current features:

* Separate control and output window
* Telepromt window
* Clock, Timers/Counters (Up/Down) (can aligned top/bottom/middle/left/right)
* Animated lower thirds with primary & secondary texts
* Import xml data to lower thirds list
* Message for talent
* News ticker, supports import of RSS XML files (align top/bottom)
* Media playback (video, images, audio)
* Experimental HyperDeck protocol support for triggering playback of media
* Video capture display (poor mans Picture in Picture)
* Support IRC as source for chat bubbles
* Green or black background for both chroma or luma keying
