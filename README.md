# CuteProduction

A very beta version of a video production helper for streaming. It can 
be used for example with ATEM Mini switchers for keying information to the video feed.

It can display various things on the output display, for example time,
timers (up/down), messages, chats like bubbles, video playback, video capture,
lower thirds, news ticker/panel (supports RSS files).

It works best with 2-4 displays:

* one for control window
* one for the output features
* alpha channel output for masking (experimental)
* teleprompt window

Note: Master is branch is now Qt 6.5 based.

>>>>>>> 89db99f4011b0afe119e80d7d834318a61df4e83
Current features:

* Separate control and output/mask windows
* Telepromt window
* Clock, Timers/Counters (Up/Down) (can aligned top/bottom/middle/left/right)
* Animated lower thirds with primary & secondary texts
* Import xml data to lower thirds list
* Message for talent
* News display (ticker/panel), supports import of RSS XML files/urls (align top/bottom)
* Media playback (video, images, audio)
* Experimental HyperDeck protocol support for triggering playback of media
* Video capture display (poor mans Picture in Picture)
* Chat bubbles left/right with various sources (IRC, MQTT) for the data
* Green or black background for both chroma or luma keying
* MQTT support
* QR Code display
* News panel can display QR Code with URL of news item

Planned features:
* Mastodon feed support
* ATEM Protocol integration
* Stream Deck support

Build requirements:
* Qt 6.5.x
* QtMQTT 6.5.x
* libcommuni qt6 branch
* QZXing (internal copy will be used on Windows)
