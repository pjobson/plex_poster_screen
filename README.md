# Plex Poster Screen

![Night of the Living Dead](https://github.com/pjobson/plex_poster_screen/blob/main/pics/NOTLD%20-%20Full%201.jpg?raw=true "Night of the Living Dead" =250x)

Pics: https://github.com/pjobson/plex_poster_screen/tree/main/pics

## Introduction

This project displays media from whatever is playing in PLEX on
a small screen under my TV. When nothing is playing, it shows
media that has already been downloaded.

You'll need a basic understanding of Linux and an interest in
doing quirky stuff with old hardware. These aren't instructions
on how to do this—it's more of a summary of how I did it.

Yes, I'm happy to chat with you about your ideas and projects.
No, I'm not willing to respond to angry messages about how my
scripts don't work for you. I have zero tolerance for this and
will report bad behavior to GitHub abuse.

## Thanks / Inspired By

This project was mostly inspired by these two projects.

* [@lukehagar](https://github.com/lukehagar) who put together the
[Plex API](https://plexapi.dev/Intro).
* sassanix from Reddit who made an
[NFC](https://simplyexplained.com/blog/how-i-built-an-nfc-movie-library-for-my-kids/)
controlled Plex Server.

## Basic Concept

There are two computers: Frame PC and Plex Server.

There are two folders on the Frame PC: one **active** and one
**archive**. The Plex Server periodically checks what is playing
via the API.

If a TV show or movie is playing, it will automatically download
media from the Plex API, push it to the active folder, and
restart the `feh` script on the Frame PC.

If nothing is playing, it will move whatever is in the active
folder into the archive folder, then restart the `feh` script.

The `feh` script checks the active folder. If it's empty, it
uses the archive folder.

This project was built mostly with low-budget items I had lying
around my house.

Finally, yes, I am mostly terrible at writing BASH scripts. If
you want to clean up my mess, I will gladly accept pull requests.

## Frame PC

    Motherboard
    -----------
    - Kodlix AP42 which was from a fanless BeeLink mini PC
    - Intel Pentium N4200 4-cores @ 2.5GHz
    - Intel Apollo Lake [HD Graphics 505]
    - 4GB DDR3 @ 1600 MHz (soldered)
    - Intel Corporation Wireless 3165

    Screen
    ------
    - Generic RPi 7-inch 800x480 IPS LCD powered by USB.

    Drives
    ------
    - Dogfish SATA SSD 128G
    - Integrated NCard MMC 64GB

    Cables
    ------
    - Flat Slim FPV HDMI Right-Angle to Straight HDMI
    - Flat Slim FPV USB Micro Right Angle to Straight USB A
    - MHF4 IPEX Antennas

    Frame
    -----
    - generic shadow box from local art store
    - ¼-inch Foam Core
    - black velvet fabric
    - 3M spray glue
    - 3M heavy duty double sided tape
    - Piece of stiff plastic.

## Basic Setup

Install your Linux operating system with auto-login enabled and
setup SSH, so you can get into the unit without having to use
the tiny screen.

You'll want to add your user's ssh key from your Plex Server into
your Frame PC.

    ssh-copy-id -i ~/.ssh/id_rsa.pub frame_pc_ip_address

I leave my display on standard view and just rotate it 90-degrees.

### Frame PC

* `feh`

Yes, aside from your base system, that's it!

### Plex Server

* `imagemagick`
* `curl`
* `jq`
* `wget`
* `rsync`

## Assembly

1. Cut the foam core to size of your shadow box.
2. Cut out center of foam core to the size of your monitor.
3. Spray foam core with glue.
4. Lay velvet over foam core.
5. Press with a large book for several minutes until dry.
6. Cut out velvet as needed, wrapping around edges of foam core.
7. Clean inside glass of shadow box.
8. Install foam core velvet side to the glass.
9. Clean the monitor.
10. Install the monitor into the foam core.
11. I used some Sugru to hold the monitor in place.
12. Install right-angle cables into screen.
13. I used a bit of thin scrap plastic to isolate the motherboard
    from the screen, so it wouldn't short.
14. Install the motherboard, I 3M taped it to the backboard of the
    shadowbox.
15. Install the antennas on the motherboard.
16. Make a hole in the backboard of the shadow box.
    I put mine near the power button, so I can reach in and turn
    it off or on.
17. Run your power cable and antennas through the backboard hole.
18. Plug it in and turn it on.

## Plex Server

The Plex Server has a cronjob which runs as my user every 3 minutes.

    */3 * * * * /home/pjobson/bin/push-posters.sh >/dev/null 2>&1
               #^ change this path

This is called `push-posters.sh`.

You'll need to edit this file changing:

* `SCREEN_WIDTH` - Your screen width.
* `SCREEN_HEIGHT` - Your screen height.
* `IMAGE_ROTATION` - Direction to rotate poster.
* `PLEX_TOKEN` - [Your Plex Token](https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/)
* `PLEX_HOST` - Name of your plex server or it's IP address
* `PLEX_USER` - Your Plex username
* `LOCAL_PICS_PATH` - A path where you want the script to save the
  Plex posters to on your Plex Server.  I currently have 6446
  images which are 652MB.
* `REMOTE_PICS_DEFAULT_PATH` - This is the fallback path which `feh`
  will play random images of stuff you've viewed.
* `REMOTE_PICS_PLEX_PATH` - This is the active playing folder.
* `REMOTE_BIN_PATH` - This is the location where your `feh_startup.sh`
  script will be stored.

**Note:** The `REMOTE_PICS_PLEX_PATH` shouldn't be a subdirectory
of `REMOTE_PICS_DEFAULT_PATH`.  My configuration is:

    SCREEN_WIDTH="800"
    SCREEN_HEIGHT="480"
    IMAGE_ROTATION="-90"

    LOCAL_PICS_PATH="/dvr/media/pictures/PLEX"

    REMOTE_SCREEN_HOSTNAME="stantz"
    REMOTE_PICS_DEFAULT_PATH="/home/pjobson/Pictures/FRAME"
    REMOTE_PICS_PLEX_PATH="/home/pjobson/Pictures/PLEX"
    REMOTE_BIN_PATH="/home/pjobson/bin"

I have a seperate drive mounted to: `/home/pjobson/Pictures`

    /dev/sda1 on /home/pjobson/Pictures type ext4 (rw,relatime)

## Frame PC

The Frame PC has a cronjob for my user which runs every 3 minutes.

    */15 * * * * /home/pjobson/bin/feh_startup.sh >/dev/null 2>&1
                #^ change this path

I also have a cronjob which runs as root every 6 hours to reboot
the screen.

    0 */6 * * * reboot >/dev/null 2>&1

You'll need to edit this file changing:

* `NOW_PLAYING_PATH` - Path to your actively playing media folder.
* `DEFAULT_PATH` - Path to your default archived folder.

**Note:** The `NOW_PLAYING_PATH` shouldn't be a subdirectory
of `DEFAULT_PATH`.  My configuration is:

    NOW_PLAYING_PATH="/home/pjobson/Pictures/PLEX"
    DEFAULT_PATH="/home/pjobson/Pictures/DEFAULT"
