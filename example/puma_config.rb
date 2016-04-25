#!/usr/bin/env puma

# This option is crucial, otherwise puma would wait for all the clients to disconnect before accepting to restart
# If you run Pubsubstub as a standalone server 0 seconds is recomended since the clients will reconnect
# and receive the scrollback anyway.
#
# But if you run Pubsubstub as an embeded Rack application, you want this to consider what is a
# decent timeout for the application.

force_shutdown_after 0


# min, max thread. The max define how much conccurent clients you can handle.
# If all threads are occupied the client will be stuck. Make sure to configure this appropriately.
# If you run Pubsubstub as a standalone, the cost of each thread is really low, so you can easilly have this quite high.
threads 0, 16

# If you notice your standalone pubsubstub server is starving for CPU, you can run puma in multi-process mode.
# workers 2
