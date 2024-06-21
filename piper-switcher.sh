#!/usr/bin/env bash
# set -xve

SWITCHER_DIR=/etc/piper-switcher.d
EDIT_MODE_ENABLED=true
SLEEP_TIME=1

source $SWITCHER_DIR/environment

BROWSER_CLASS="Vivaldi-stable"
DESKTOP_CLASS="plasmashell"

function get_profile() {
	echo "$SWITCHER_DIR/profiles/$1.profile"
}

EDIT_MODE=false
PREV_ACTIVE_CLASS=''
PREV_PROFILE_FILE=$(get_profile previous)

function get_active_profile() {
	ratbagctl $DEVICE_ID profile active get
}

function parse_action() {
	echo $1 | awk -F'is mapped to ' '{print $2}' | sed -e 's/↓/+KEY_/' -e 's/↑/-KEY_/' -e 's/↕/KEY_/' | tr -d "'"
}

function parse_line() {
	if [[ $1 =~ ^# ]]; then
		profile_name=${1:2}
		echo "Loading profile $profile_name ..."
		return
	fi
	btn_num=$(echo $1 | cut -d " " -f 2)
	action=$(parse_action "$1")
	if [[ $action == UNKNOWN ]]; then
		return
	fi
	if [[ ! $action =~ ^button && ! $action =~ ^macro ]]; then
		action="special $action"
	fi
	ratbagctl $DEVICE_ID profile 2 button $btn_num action set $(echo $action)
}

function load_profile() {
	if [[ -f $PREV_PROFILE_FILE ]]; then
		prev_profile=$(cat $PREV_PROFILE_FILE)
	fi
	if [[ $prev_profile == $1 ]]; then
		return
	fi
	while read line; do
		parse_line "$line"
	done < $1
	echo $1 > $PREV_PROFILE_FILE
}

function activate_profile() {
	if [[ $(get_active_profile) == $1 ]]; then
		return
	fi
	ratbagctl $DEVICE_ID profile active set $1
	echo "Profile $1 in now active"
}

function check_edit_mode() {
	if [[ -n $(pgrep -x "piper") ]]; then
		EDIT_MODE=true
	elif [ $EDIT_MODE == true ]; then
		echo "Exiting edit mode and exporting new profile"
		echo "# new profile" > $(get_profile new)
		ratbagctl $DEVICE_ID profile 2 get | grep '^Button: [0-9]* is mapped to ' >> $(get_profile new)
		EDIT_MODE=false
	fi
}

function main() {
	sleep $SLEEP_TIME
	if [[ $EDIT_MODE_ENABLED ]]; then
		check_edit_mode
	fi
	if [ $EDIT_MODE == true ]; then
		return
	fi
	active_class=$(su $USER -c "export DISPLAY='$DISPLAY';xdotool getwindowfocus getwindowclassname")
	if [[ $active_class == $PREV_ACTIVE_CLASS ]]; then
		return
	fi
	PREV_ACTIVE_CLASS=$active_class
	profile_file=$(get_profile $active_class)
	if [[ $active_class =~ ^steam_app_ ]]; then
		profile_file=$(get_profile steam/${active_class:10})
	fi
	if [[ $active_class == $DESKTOP_CLASS ]]; then
		activate_profile 0
	elif [[ $active_class == $BROWSER_CLASS ]]; then
		activate_profile 1
	elif [[ -f $profile_file ]]; then
		load_profile "$profile_file"
		activate_profile 2
	fi
}

trap "echo Exited!; exit;" SIGINT SIGTERM
while true; do
	main | logger -t piper-switcher
done
