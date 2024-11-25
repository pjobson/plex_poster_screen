# Plex Poster Screen

## Introduction

This project displays media from whatever is playing in PLEX on
a small screen under my TV.  When nothing is playing, it plays
media which has already been downloaded.

You'll need a basic understanding of Linux and an interest in
doing dumb stuff with old junk.  These aren't instructions
as to how to do this, it is more of a summary of how I did
it.

Yes, I'm happy to chat with you about your stuff and your projects.
No, I'm not willing to answer angry messages about how my crappy
scripts don't work for you, I have zero tollerance for this and
I will report bad behavior to github abuse.

## Thanks / Inspired By

This project was mostly inspired by these two projects.

* [@lukehagar](https://github.com/lukehagar) who put together the
[Plex API](https://plexapi.dev/Intro).
* sassanix from Reddit who made an
[NFC](https://simplyexplained.com/blog/how-i-built-an-nfc-movie-library-for-my-kids/)
controlled Plex Server.

## Basic Concept

There are two computers: Frame PC and Plex Server.

There's two folders on the Frame PC, one which is **active** and
one which is **archive**.  The Plex Server will periodically check
what is playing via the API.

If a TV Show or Movie is playing, it will automatically download
media from the Plex API, then push it to the active folder, then
restart the `feh` script on the Frame PC.

If nothing is playing, it will move whatever is in the active
folder into the archive folder, then restart the `feh` script.

The `feh` script checks the active folder, if empty, it uses
the archive folder.

The project was built mainly with low budget stuff laying around
my house.

Finally, yes, I am mostly terrible at writing BASH scripts. If
you want to clean up my crap, I will accept pull requests.

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

    Frame
    -----
    - generic shadow box from local art store
    - ¼-inch Foam Core
    - black velvet fabric
    - 3M spray glue
    - Kapton tape

## Basic Setup

Install your Linux operating system with auto-login enabled and
setup SSH, so you can get into the unit without having to use
the tiny screen.

I leave my display on standard view and just turn it 90-degrees.

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
11. I covered the back of my monitor with Kapton tape,
    you can use a plastic film and tape. Just make sure it is isolated
    from the motherboard.
12. Install right-angle cables into screen.
13. Install the motherboard, you'll have to figure out how to mount
    yours, I made a bracket out of some of the foam core.
14. Make a hole in the back of the board of the shadow box.
    I put mine near the power button, so I can reach in and turn
    it off or on.
15. Run the power cable through the hole, plug it in and turn it on.

## Plex Server

The Plex Server has a cronjob which runs every 3 minutes.

    */3 * * * * /home/pjobson/bin/push-posters-to-stantz.sh >/dev/null 2>&1

This is called `push-posters-to-stantz.sh` on mine, because my Frame
is named `stantz`.

You'll need to edit this file changing:

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

On my setup, I

## Poster Screen

    feh_startup.sh

### `crontab`

    */15 * * * * /home/pjobson/bin/feh_startup.sh >/dev/null 2>&1
