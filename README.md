# CuteProduction

Note: This is the OLD Qt 5 based branch and it is not in developed anymore.

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

Note: This is the branch that uses Qt 5.15 and will not be developed much further, please
consider using the Qt 6 branch in the future.

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
* Qt 5.15.x
* QtMQTT 5.15.x
* libcommuni
* QZXing (internal copy will be used on Windows)
