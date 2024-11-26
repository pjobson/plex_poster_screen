#!/bin/bash

export DISPLAY=:0.0

# crontab
#    */15 * * * * /home/pjobson/bin/feh_startup.sh >/dev/null 2>&1
# feh command
# feh -Z -z -D 20 -x --hide-pointer --recursive --randomize --geometry 800x480 /home/pjobson/Pictures/ai/

# If running kill it.
killall -q feh

NOW_PLAYING_PATH="/path/to/now/playing/images"
DEFAULT_PATH="/path/to/default/images"

PLEX_CNT=$(find $NOW_PLAYING_PATH -type f | wc -l)

if [[ "$PLEX_CNT" == 0 ]]; then
    feh \
        --randomize          \
        --auto-zoom          \
        --slideshow-delay 20 \
        --borderless         \
        --hide-pointer       \
        --recursive          \
        --geometry 800x480   \
        --fullscreen         \
        --no-menus           \
        $DEFAULT_PATH
else
    feh \
        --randomize          \
        --auto-zoom          \
        --slideshow-delay 20 \
        --borderless         \
        --hide-pointer       \
        --recursive          \
        --geometry 800x480   \
        --fullscreen         \
        --no-menus           \
        $NOW_PLAYING_PATH
fi
