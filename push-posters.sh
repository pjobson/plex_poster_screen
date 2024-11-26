#!/bin/bash

# crontab
# */3 * * * * /home/pjobson/bin/push-posters-to-stantz.sh >/dev/null 2>&1
#             ^ change this path to your path

SCREEN_WIDTH="800"
SCREEN_HEIGHT="480"
IMAGE_ROTATION="-90"

PLEX_TOKEN="YOUR_PLEX_TOKEN"
PLEX_HOST="PLEX_HOSTNAME_OR_IP_ADDRESS"
PLEX_USER="YOUR_PLEX_USERNAME"

LOCAL_PICS_PATH="/path/to/local/pics/storage"

REMOTE_SCREEN_HOSTNAME="SCREEN_HOSTNAME_OR_IP"
REMOTE_PICS_DEFAULT_PATH="/path/to/default/pics"
REMOTE_PICS_PLEX_PATH="/path/to/now/playing/pics"
REMOTE_BIN_PATH="/screen/bin/path"

plex_default () {
	# copy the folders in PLEX to FRAME
	ssh $REMOTE_SCREEN_HOSTNAME "/usr/bin/cp -rf ${REMOTE_PICS_PLEX_PATH}/* ${REMOTE_PICS_DEFAULT_PATH}/ 2>/dev/null || :"
	# remove all in PLEX folder in screen
	ssh $REMOTE_SCREEN_HOSTNAME "/usr/bin/rm -rf ${REMOTE_PICS_PLEX_PATH}/*"
	ssh $REMOTE_SCREEN_HOSTNAME "${REMOTE_BIN_PATH}/feh_startup.sh" &
	exit
}

##############################################
# Is plex playing?
IS_PLAYING=$(curl -s -H "accept: application/json" "http://${PLEX_HOST}:32400/status/sessions?X-Plex-Token=${PLEX_TOKEN}" | jq '.MediaContainer.size')

if [[ "$IS_PLAYING" == "0" ]]; then
	plex_default
fi

#############################################
# Get My Id
CMD="curl -s -H \"Accept: application/json\" \"http://${PLEX_HOST}:32400/accounts?X-Plex-Token=${PLEX_TOKEN}\" "
CMD+=" | jq '.MediaContainer.Account[] | select(.name == \""
CMD+="${PLEX_USER}\")'.id"

MY_USER_ID=$(eval "$CMD")

#############################################
# My Current Metadata Key
CMD="curl -s -H \"Accept: application/json\" \"http://${PLEX_HOST}:32400/status/sessions?X-Plex-Token=${PLEX_TOKEN}\" "
CMD+=" | jq '.MediaContainer.Metadata[] | select(.User.id == \""
CMD+="${MY_USER_ID}\")'"

JSON=$(eval "$CMD")

if [[ "$JSON" == "" ]]; then
	plex_default
fi

###########################################
# Is this porn?
# Some folks have porn on their plex
# they may not want it showing on their
# poster screen
IS_PR0N=$(echo $JSON | jq '.librarySectionTitle')

if [[ "$IS_PR0N" == "\"porn\"" ]]; then
	plex_default
fi

###########################################
# Is this an episode or movie?
EPISODE_OR_MOVIE=$(echo $JSON | jq '.type')

KEY=""
TITLE=""

if [[ "$EPISODE_OR_MOVIE" == "\"episode\"" ]]; then
	# if episode
	KEY=$(echo $JSON | jq '.grandparentKey')
	TITLE=$(echo $JSON | jq '.grandparentTitle')
elif [[ "$EPISODE_OR_MOVIE" == "\"movie\"" ]]; then
	# if movie
	KEY=$(echo $JSON | jq '.key')
	TITLE=$(echo $JSON | jq '.title')
fi

TITLE=$(echo $TITLE | tr -d '"')

if [[ "$KEY" == "" ]]; then
	plex_default
fi

####################################################
# Get All Posters
CMD="curl -s -H \"Accept: application/json\" \"http://${PLEX_HOST}:32400"
CMD+="${KEY}"
CMD+="/posters?X-Plex-Token=${PLEX_TOKEN}\" | jq '.MediaContainer.Metadata[] | .key'"

OUT=$(eval "$CMD")

declare -a POSTERS=(${OUT})

# If the show/movie path doesn't exist, make it
# and download images
if [[ ! -d "${LOCAL_PICS_PATH}/${TITLE}" ]]; then
	mkdir -p "${LOCAL_PICS_PATH}/${TITLE}"

	for poster in "${POSTERS[@]}"; do
		if [[ $poster == *"http"* ]]; then
			echo "Getting: ${poster}"
			CMD="wget --no-clobber --quiet --directory-prefix=\"${LOCAL_PICS_PATH}/${TITLE}/\" ${poster}"
			eval $CMD
		fi
	done

	SCREEN_WIDTH="${SCREEN_WIDTH}x"
	SCREEN_HEIGHT="x${SCREEN_HEIGHT}"

	# rotate image -90 degrees, resize to 800x* then *x480
	# The double resizing is for weird sized images
	find "${LOCAL_PICS_PATH}/${TITLE}" -type f -exec echo "Resizing: " {} \; -exec mogrify -verbose -rotate ${IMAGE_ROTATION} -resize ${SCREEN_WIDTH} -resize ${SCREEN_HEIGHT} {} \;
fi

ssh $REMOTE_SCREEN_HOSTNAME "/usr/bin/cp -rf ${REMOTE_PICS_PLEX_PATH}/* ${REMOTE_PICS_DEFAULT_PATH}/ 2>/dev/null || :"
ssh $REMOTE_SCREEN_HOSTNAME "/usr/bin/rm -rf ${REMOTE_PICS_PLEX_PATH}/*"
rsync -avh "${LOCAL_PICS_PATH}/${TITLE}" $REMOTE_SCREEN_HOSTNAME:${REMOTE_PICS_PLEX_PATH}/
ssh $REMOTE_SCREEN_HOSTNAME "${REMOTE_BIN_PATH}/feh_startup.sh" &
