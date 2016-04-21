#!/usr/bin/env puma

# This option is crucial, otherwise puma would wait for all the clients to disconnect before accepting to restart
# If you run Pubsubstub as a standalone server 0 seconds is recomended since the clients will reconnect
# and receive the scrollback anyway.
#
# But if you run Pubsubstub as an embeded Rack application, you want this to consider what is a
# decent timeout for the application.

force_shutdown_after 0


threads 0, 16