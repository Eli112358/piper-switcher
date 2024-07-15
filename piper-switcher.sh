#!/usr/bin/env bash
# set -xve

# getters

function get_active_profile() {
	ratbagctl "$DEVICE_ID" profile active get
}

function get_previous_profile_file() {
	if [[ -f "$PREV_PROFILE_FILE" ]]; then
		cat "$PREV_PROFILE_FILE"
		return
	fi
	echo ''
}

function get_profile() {
	echo "$SWITCHER_DIR/profiles/$1.profile"
}

# helpers

function activate_profile() {
	if [[ $(get_active_profile) == $1 ]]; then
		return
	fi
	ratbagctl "$DEVICE_ID" profile active set $1
	echo "Profile $1 in now active"
}

function check_edit_mode() {
	is_piper_running=false
	if [[ -n $(pgrep -x piper) ]]; then
		is_piper_running=true
	fi
	if [ $EDIT_MODE == $is_piper_running ]; then
		return
	fi
	if [ $is_piper_running == true ]; then
		echo "Entering edit mode"
		EDIT_MODE=true
		return
	fi
	echo "Exiting edit mode and exporting new profile"
	echo "# new profile" > $(get_profile new)
	ratbagctl "$DEVICE_ID" profile 2 get | grep '^Button: [0-9]* is mapped to ' >> $(get_profile new)
	EDIT_MODE=false
}

function parse_action() {
	echo $1 | awk -F'is mapped to ' '{print $2}' | sed -e 's/↓/+KEY_/' -e 's/↑/-KEY_/' -e 's/↕/KEY_/' | tr -d "'"
}

function parse_line() {
	if [[ $1 =~ ^# ]]; then
		profile_name="${1:2}"
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
	ratbagctl "$DEVICE_ID" profile 2 button $btn_num action set $(echo $action)
}

function load_profile() {
	while read line; do
		parse_line "$line"
	done < "$1"
	echo "$1" > $PREV_PROFILE_FILE
}

# main

function main() {
	sleep $SLEEP_TIME
	if [[ $EDIT_MODE_ENABLED ]]; then
		check_edit_mode
	fi
	if [ $EDIT_MODE == true ]; then
		return
	fi
	active_class="$(su $USER -c "export DISPLAY='$DISPLAY';xdotool getwindowfocus getwindowclassname")"
	if [[ "$active_class" == "$PREV_ACTIVE_CLASS" ]]; then
		return
	fi
	PREV_ACTIVE_CLASS="$active_class"
	if [[ "${PROFILE_CLASSES[$(get_active_profile)]}" == "$active_class" ]]; then
		return
	fi
	for (( i = 0; i < 3; i++ )); do
		if [[ "$active_class" == "${PROFILE_CLASSES[$i]}" ]]; then
			activate_profile $i
			return
		fi
	done
	profile_file="$(get_profile "$active_class")"
	if [[ ! -f "$profile_file" ]]; then
		return
	fi
	load_profile "$profile_file"
	PROFILE_CLASSES[2]="$active_class"
	activate_profile 2
}

# setup/init

SWITCHER_DIR=/etc/piper-switcher.d

source $SWITCHER_DIR/environment

EDIT_MODE=false
EDIT_MODE_ENABLED=true
PREV_ACTIVE_CLASS=''
PREV_PROFILE_FILE=$(get_profile previous)
PROFILE_CLASSES[2]="$(basename -s .profile $(get_previous_profile_file))"
SLEEP_TIME=1

# main loop

trap "echo Exited!; exit;" SIGINT SIGTERM
while true; do
	main | logger -t piper-switcher
done
