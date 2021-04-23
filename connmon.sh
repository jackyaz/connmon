#!/bin/sh

##############################################################
##                                                          ##
##     ___   ___   _ __   _ __   _ __ ___    ___   _ __     ##
##    / __| / _ \ | '_ \ | '_ \ | '_ ` _ \  / _ \ | '_ \    ##
##   | (__ | (_) || | | || | | || | | | | || (_) || | | |   ##
##    \___| \___/ |_| |_||_| |_||_| |_| |_| \___/ |_| |_|   ##
##                                                          ##
##            https://github.com/jackyaz/connmon            ##
##                                                          ##
##############################################################

##############        Shellcheck directives      #############
# shellcheck disable=SC2018
# shellcheck disable=SC2019
# shellcheck disable=SC2059
##############################################################

### Start of script variables ###
readonly SCRIPT_NAME="connmon"
readonly SCRIPT_VERSION="v2.11.1"
SCRIPT_BRANCH="develop"
SCRIPT_REPO="https://raw.githubusercontent.com/jackyaz/$SCRIPT_NAME/$SCRIPT_BRANCH"
readonly SCRIPT_DIR="/jffs/addons/$SCRIPT_NAME.d"
readonly SCRIPT_WEBPAGE_DIR="$(readlink /www/user)"
readonly SCRIPT_WEB_DIR="$SCRIPT_WEBPAGE_DIR/$SCRIPT_NAME"
readonly SHARED_DIR="/jffs/addons/shared-jy"
readonly SHARED_REPO="https://raw.githubusercontent.com/jackyaz/shared-jy/master"
readonly SHARED_WEB_DIR="$SCRIPT_WEBPAGE_DIR/shared-jy"
[ -z "$(nvram get odmpid)" ] && ROUTER_MODEL=$(nvram get productid) || ROUTER_MODEL=$(nvram get odmpid)
[ -f /opt/bin/sqlite3 ] && SQLITE3_PATH=/opt/bin/sqlite3 || SQLITE3_PATH=/usr/sbin/sqlite3
### End of script variables ###

### Start of output format variables ###
readonly CRIT="\\e[41m"
readonly ERR="\\e[31m"
readonly WARN="\\e[33m"
readonly PASS="\\e[32m"
readonly SETTING="\\e[1m\\e[36m"
### End of output format variables ###

# $1 = print to syslog, $2 = message to print, $3 = log level
# shellcheck disable=SC2059
Print_Output(){
	if [ "$1" = "true" ]; then
		logger -t "$SCRIPT_NAME" "$2"
	fi
	printf "\\e[1m${3}%s\\e[0m\\n\\n" "$2"
}

Firmware_Version_Check(){
	if nvram get rc_support | grep -qF "am_addons"; then
		return 0
	else
		return 1
	fi
}

### Code for these functions inspired by https://github.com/Adamm00 - credit to @Adamm ###
Check_Lock(){
	if [ -f "/tmp/$SCRIPT_NAME.lock" ]; then
		ageoflock=$(($(date +%s) - $(date +%s -r /tmp/$SCRIPT_NAME.lock)))
		if [ "$ageoflock" -gt 600 ]; then
			Print_Output true "Stale lock file found (>600 seconds old) - purging lock" "$ERR"
			kill "$(sed -n '1p' /tmp/$SCRIPT_NAME.lock)" >/dev/null 2>&1
			Clear_Lock
			echo "$$" > "/tmp/$SCRIPT_NAME.lock"
			return 0
		else
			Print_Output true "Lock file found (age: $ageoflock seconds) - ping test likely currently running" "$ERR"
			if [ -z "$1" ]; then
				exit 1
			else
				if [ "$1" = "webui" ]; then
					echo 'var connmonstatus = "LOCKED";' > /tmp/detect_connmon.js
					exit 1
				fi
				return 1
			fi
		fi
	else
		echo "$$" > "/tmp/$SCRIPT_NAME.lock"
		return 0
	fi
}

Clear_Lock(){
	rm -f "/tmp/$SCRIPT_NAME.lock" 2>/dev/null
	return 0
}

############################################################################

Set_Version_Custom_Settings(){
	SETTINGSFILE="/jffs/addons/custom_settings.txt"
	case "$1" in
		local)
			if [ -f "$SETTINGSFILE" ]; then
				if [ "$(grep -c "connmon_version_local" $SETTINGSFILE)" -gt 0 ]; then
					if [ "$2" != "$(grep "connmon_version_local" /jffs/addons/custom_settings.txt | cut -f2 -d' ')" ]; then
						sed -i "s/connmon_version_local.*/connmon_version_local $2/" "$SETTINGSFILE"
					fi
				else
					echo "connmon_version_local $2" >> "$SETTINGSFILE"
				fi
			else
				echo "connmon_version_local $2" >> "$SETTINGSFILE"
			fi
		;;
		server)
			if [ -f "$SETTINGSFILE" ]; then
				if [ "$(grep -c "connmon_version_server" $SETTINGSFILE)" -gt 0 ]; then
					if [ "$2" != "$(grep "connmon_version_server" /jffs/addons/custom_settings.txt | cut -f2 -d' ')" ]; then
						sed -i "s/connmon_version_server.*/connmon_version_server $2/" "$SETTINGSFILE"
					fi
				else
					echo "connmon_version_server $2" >> "$SETTINGSFILE"
				fi
			else
				echo "connmon_version_server $2" >> "$SETTINGSFILE"
			fi
		;;
	esac
}

Update_Check(){
	echo 'var updatestatus = "InProgress";' > "$SCRIPT_WEB_DIR/detect_update.js"
	doupdate="false"
	localver=$(grep "SCRIPT_VERSION=" "/jffs/scripts/$SCRIPT_NAME" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
	/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" | grep -qF "jackyaz" || { Print_Output true "404 error detected - stopping update" "$ERR"; return 1; }
	serverver=$(/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" | grep "SCRIPT_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
	if [ "$localver" != "$serverver" ]; then
		doupdate="version"
		Set_Version_Custom_Settings server "$serverver"
		echo 'var updatestatus = "'"$serverver"'";'  > "$SCRIPT_WEB_DIR/detect_update.js"
	else
		localmd5="$(md5sum "/jffs/scripts/$SCRIPT_NAME" | awk '{print $1}')"
		remotemd5="$(curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" | md5sum | awk '{print $1}')"
		if [ "$localmd5" != "$remotemd5" ]; then
			doupdate="md5"
			Set_Version_Custom_Settings server "$serverver-hotfix"
			echo 'var updatestatus = "'"$serverver-hotfix"'";'  > "$SCRIPT_WEB_DIR/detect_update.js"
		fi
	fi
	if [ "$doupdate" = "false" ]; then
		echo 'var updatestatus = "None";'  > "$SCRIPT_WEB_DIR/detect_update.js"
	fi
	echo "$doupdate,$localver,$serverver"
}

Update_Version(){
	if [ -z "$1" ]; then
		updatecheckresult="$(Update_Check)"
		isupdate="$(echo "$updatecheckresult" | cut -f1 -d',')"
		localver="$(echo "$updatecheckresult" | cut -f2 -d',')"
		serverver="$(echo "$updatecheckresult" | cut -f3 -d',')"
		
		if [ "$isupdate" = "version" ]; then
			Print_Output true "New version of $SCRIPT_NAME available - $serverver" "$PASS"
		elif [ "$isupdate" = "md5" ]; then
			Print_Output true "MD5 hash of $SCRIPT_NAME does not match - hotfix available - $serverver" "$PASS"
		fi
		
		if [ "$isupdate" != "false" ]; then
			printf "\\n\\e[1mDo you want to continue with the update? (y/n)\\e[0m  "
			read -r confirm
			case "$confirm" in
				y|Y)
					printf "\\n"
					Update_File shared-jy.tar.gz
					Update_File connmonstats_www.asp
					/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" -o "/jffs/scripts/$SCRIPT_NAME" && Print_Output true "$SCRIPT_NAME successfully updated"
					chmod 0755 "/jffs/scripts/$SCRIPT_NAME"
					Set_Version_Custom_Settings local "$serverver"
					Set_Version_Custom_Settings server "$serverver"
					Clear_Lock
					PressEnter
					exec "$0"
					exit 0
				;;
				*)
					printf "\\n"
					Clear_Lock
					return 1
				;;
			esac
		else
			Print_Output true "No updates available - latest is $localver" "$WARN"
			Clear_Lock
		fi
	fi
	
	if [ "$1" = "force" ]; then
		serverver=$(/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" | grep "SCRIPT_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
		Print_Output true "Downloading latest version ($serverver) of $SCRIPT_NAME" "$PASS"
		Update_File shared-jy.tar.gz
		Update_File connmonstats_www.asp
		/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" -o "/jffs/scripts/$SCRIPT_NAME" && Print_Output true "$SCRIPT_NAME successfully updated"
		chmod 0755 "/jffs/scripts/$SCRIPT_NAME"
		Set_Version_Custom_Settings local "$serverver"
		Set_Version_Custom_Settings server "$serverver"
		Clear_Lock
		if [ -z "$2" ]; then
			PressEnter
			exec "$0"
		elif [ "$2" = "unattended" ]; then
			exec "$0" postupdate
		fi
		exit 0
	fi
}

Update_File(){
	if [ "$1" = "connmonstats_www.asp" ]; then
		tmpfile="/tmp/$1"
		Download_File "$SCRIPT_REPO/$1" "$tmpfile"
		if ! diff -q "$tmpfile" "$SCRIPT_DIR/$1" >/dev/null 2>&1; then
			if [ -f "$SCRIPT_DIR/$1" ]; then
				Get_WebUI_Page "$SCRIPT_DIR/$1"
				sed -i "\\~$MyPage~d" /tmp/menuTree.js
				rm -f "$SCRIPT_WEBPAGE_DIR/$MyPage" 2>/dev/null
			fi
			Download_File "$SCRIPT_REPO/$1" "$SCRIPT_DIR/$1"
			Print_Output true "New version of $1 downloaded" "$PASS"
			Mount_WebUI
		fi
		rm -f "$tmpfile"
	elif [ "$1" = "shared-jy.tar.gz" ]; then
		if [ ! -f "$SHARED_DIR/$1.md5" ]; then
			Download_File "$SHARED_REPO/$1" "$SHARED_DIR/$1"
			Download_File "$SHARED_REPO/$1.md5" "$SHARED_DIR/$1.md5"
			tar -xzf "$SHARED_DIR/$1" -C "$SHARED_DIR"
			rm -f "$SHARED_DIR/$1"
			Print_Output true "New version of $1 downloaded" "$PASS"
		else
			localmd5="$(cat "$SHARED_DIR/$1.md5")"
			remotemd5="$(curl -fsL --retry 3 "$SHARED_REPO/$1.md5")"
			if [ "$localmd5" != "$remotemd5" ]; then
				Download_File "$SHARED_REPO/$1" "$SHARED_DIR/$1"
				Download_File "$SHARED_REPO/$1.md5" "$SHARED_DIR/$1.md5"
				tar -xzf "$SHARED_DIR/$1" -C "$SHARED_DIR"
				rm -f "$SHARED_DIR/$1"
				Print_Output true "New version of $1 downloaded" "$PASS"
			fi
		fi
	else
		return 1
	fi
}

Validate_Number(){
	if [ "$1" -eq "$1" ] 2>/dev/null; then
		return 0
	else
		return 1
	fi
}

Validate_IP(){
	if expr "$1" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
		for i in 1 2 3 4; do
			if [ "$(echo "$1" | cut -d. -f$i)" -gt 255 ]; then
				Print_Output false "Octet $i ($(echo "$1" | cut -d. -f$i)) - is invalid, must be less than 255" "$ERR"
				return 1
			fi
		done
	else
		Print_Output false "$1 - is not a valid IPv4 address, valid format is 1.2.3.4" "$ERR"
		return 1
	fi
}

Validate_Domain(){
	if ! nslookup "$1" >/dev/null 2>&1; then
		Print_Output false "$1 cannot be resolved by nslookup, please ensure you enter a valid domain name" "$ERR"
		return 1
	else
		return 0
	fi
}

Conf_FromSettings(){
	SETTINGSFILE="/jffs/addons/custom_settings.txt"
	TMPFILE="/tmp/connmon_settings.txt"
	if [ -f "$SETTINGSFILE" ]; then
		if [ "$(grep "connmon_" $SETTINGSFILE | grep -v "version" -c)" -gt 0 ]; then
			Print_Output true "Updated settings from WebUI found, merging into $SCRIPT_CONF" "$PASS"
			cp -a "$SCRIPT_CONF" "$SCRIPT_CONF.bak"
			grep "connmon_" "$SETTINGSFILE" | grep -v "version" > "$TMPFILE"
			sed -i "s/connmon_//g;s/ /=/g" "$TMPFILE"
			while IFS='' read -r line || [ -n "$line" ]; do
				SETTINGNAME="$(echo "$line" | cut -f1 -d'=' | awk '{ print toupper($1) }')"
				SETTINGVALUE="$(echo "$line" | cut -f2 -d'=')"
				sed -i "s~$SETTINGNAME=.*~$SETTINGNAME=$SETTINGVALUE~" "$SCRIPT_CONF"
			done < "$TMPFILE"
			grep 'connmon_version' "$SETTINGSFILE" > "$TMPFILE"
			sed -i "\\~connmon_~d" "$SETTINGSFILE"
			mv "$SETTINGSFILE" "$SETTINGSFILE.bak"
			cat "$SETTINGSFILE.bak" "$TMPFILE" > "$SETTINGSFILE"
			rm -f "$TMPFILE"
			rm -f "$SETTINGSFILE.bak"
			
			ScriptStorageLocation "$(ScriptStorageLocation check)"
			Create_Symlinks
			
			if AutomaticMode check; then
				Auto_Cron delete 2>/dev/null
				Auto_Cron create 2>/dev/null
			else
				Auto_Cron delete 2>/dev/null
			fi
			Generate_CSVs
			
			Print_Output true "Merge of updated settings from WebUI completed successfully" "$PASS"
		else
			Print_Output false "No updated settings from WebUI found, no merge into $SCRIPT_CONF necessary" "$PASS"
		fi
	fi
}

Create_Dirs(){
	if [ ! -d "$SCRIPT_DIR" ]; then
		mkdir -p "$SCRIPT_DIR"
	fi
	
	if [ ! -d "$SCRIPT_STORAGE_DIR" ]; then
		mkdir -p "$SCRIPT_STORAGE_DIR"
	fi
	
	if [ ! -d "$CSV_OUTPUT_DIR" ]; then
		mkdir -p "$CSV_OUTPUT_DIR"
	fi
	
	if [ ! -d "$SHARED_DIR" ]; then
		mkdir -p "$SHARED_DIR"
	fi
	
	if [ ! -d "$SCRIPT_WEBPAGE_DIR" ]; then
		mkdir -p "$SCRIPT_WEBPAGE_DIR"
	fi
	
	if [ ! -d "$SCRIPT_WEB_DIR" ]; then
		mkdir -p "$SCRIPT_WEB_DIR"
	fi
}

Create_Symlinks(){
	rm -rf "${SCRIPT_WEB_DIR:?}/"* 2>/dev/null
	
	ln -s /tmp/detect_connmon.js "$SCRIPT_WEB_DIR/detect_connmon.js" 2>/dev/null
	ln -s /tmp/ping-result.txt "$SCRIPT_WEB_DIR/ping-result.htm" 2>/dev/null
	ln -s "$SCRIPT_STORAGE_DIR/connstatstext.js" "$SCRIPT_WEB_DIR/connstatstext.js" 2>/dev/null
	ln -s "$SCRIPT_STORAGE_DIR/lastx.htm" "$SCRIPT_WEB_DIR/lastx.htm" 2>/dev/null
	
	ln -s "$SCRIPT_CONF" "$SCRIPT_WEB_DIR/config.htm" 2>/dev/null
	
	ln -s "$CSV_OUTPUT_DIR" "$SCRIPT_WEB_DIR/csv" 2>/dev/null
	
	if [ ! -d "$SHARED_WEB_DIR" ]; then
		ln -s "$SHARED_DIR" "$SHARED_WEB_DIR" 2>/dev/null
	fi
}

Conf_Exists(){
	if [ -f "$SCRIPT_CONF" ]; then
		dos2unix "$SCRIPT_CONF"
		chmod 0644 "$SCRIPT_CONF"
		sed -i -e 's/"//g' "$SCRIPT_CONF"
		
		if grep -q "SCHEDULESTART" "$SCRIPT_CONF"; then
			if ! grep -q "AUTOMATED" "$SCRIPT_CONF"; then
				echo "AUTOMATED=true" >> "$SCRIPT_CONF"
			fi
			if ! grep -q "SCHDAYS" "$SCRIPT_CONF"; then
				echo "SCHDAYS=*" >> "$SCRIPT_CONF"
			fi
			echo "SCHHOURS=*" >> "$SCRIPT_CONF"
			PINGFREQUENCY=$(grep "PINGFREQUENCY" "$SCRIPT_CONF" | cut -f2 -d"=")
			echo "SCHMINS=*/$PINGFREQUENCY" >> "$SCRIPT_CONF"
			sed -i '/SCHEDULESTART/d;/SCHEDULEEND/d;/PINGFREQUENCY/d;' "$SCRIPT_CONF"
		fi
		if grep -q "OUTPUTDATAMODE" "$SCRIPT_CONF"; then
			sed -i '/OUTPUTDATAMODE/d;' "$SCRIPT_CONF"
		fi
		if ! grep -q "DAYSTOKEEP" "$SCRIPT_CONF"; then
			echo "DAYSTOKEEP=30" >> "$SCRIPT_CONF"
		fi
		if ! grep -q "LASTXRESULTS" "$SCRIPT_CONF"; then
			echo "LASTXRESULTS=10" >> "$SCRIPT_CONF"
		fi
		return 0
	else
		{ echo "PINGSERVER=8.8.8.8"; echo "OUTPUTTIMEMODE=unix"; echo "STORAGELOCATION=jffs"; echo "PINGDURATION=60"; echo "AUTOMATED=true"; echo "SCHDAYS=*"; echo "SCHHOURS=*"; echo "SCHMINS=*/3"; echo "DAYSTOKEEP=30"; echo "LASTXRESULTS=10"; } > "$SCRIPT_CONF"
		return 1
	fi
}

PingServer(){
	case "$1" in
		update)
			while true; do
				ScriptHeader
				printf "\\n\\e[1mCurrent ping destination: %s\\e[0m\\n\\n" "$(PingServer check)"
				printf "1.    Enter IP Address\\n"
				printf "2.    Enter Domain\\n"
				printf "\\ne.    Go back\\n"
				printf "\\n\\e[1mChoose an option:\\e[0m  "
				read -r pingoption
				case "$pingoption" in
					1)
						while true; do
							printf "\\n\\e[1mPlease enter an IP address, or enter e to go back:\\e[0m  "
							read -r ipoption
							if [ "$ipoption" = "e" ]; then
								break
							fi
							if Validate_IP "$ipoption"; then
								sed -i 's/^PINGSERVER.*$/PINGSERVER='"$ipoption"'/' "$SCRIPT_CONF"
								break
							fi
						done
					;;
					2)
						while true; do
							printf "\\n\\e[1mPlease enter a domain name, or enter e to go back:\\e[0m  "
							read -r domainoption
							if [ "$domainoption" = "e" ]; then
								break
							fi
							if Validate_Domain "$domainoption"; then
								sed -i 's/^PINGSERVER.*$/PINGSERVER='"$domainoption"'/' "$SCRIPT_CONF"
								break
							fi
						done
					;;
					e)
						printf "\\n"
						break
					;;
					*)
						printf "\\nPlease choose a valid option\\n\\n"
					;;
				esac
			done
		;;
		check)
			PINGSERVER=$(grep "PINGSERVER" "$SCRIPT_CONF" | cut -f2 -d"=")
			echo "$PINGSERVER"
		;;
	esac
}

PingDuration(){
	case "$1" in
		update)
			pingdur=0
			exitmenu=""
			ScriptHeader
			while true; do
				printf "\\n\\e[1mPlease enter the desired test duration (10-60 seconds):\\e[0m  "
				read -r pingdur_choice
				
				if [ "$pingdur_choice" = "e" ]; then
					exitmenu="exit"
					break
				elif ! Validate_Number "$pingdur_choice"; then
					printf "\\n\\e[31mPlease enter a valid number (10-60)\\e[0m\\n"
				else
					if [ "$pingdur_choice" -lt 10 ] || [ "$pingdur_choice" -gt 60 ]; then
						printf "\\n\\e[31mPlease enter a number between 10 and 60\\e[0m\\n"
					else
						pingdur="$pingdur_choice"
						printf "\\n"
						break
					fi
				fi
			done
			
			if [ "$exitmenu" != "exit" ]; then
				sed -i 's/^PINGDURATION.*$/PINGDURATION='"$pingdur"'/' "$SCRIPT_CONF"
				return 0
			else
				printf "\\n"
				return 1
			fi
		;;
		check)
			PINGDURATION=$(grep "PINGDURATION" "$SCRIPT_CONF" | cut -f2 -d"=")
			echo "$PINGDURATION"
		;;
	esac
}

DaysToKeep(){
	case "$1" in
		update)
			daystokeep=30
			exitmenu=""
			ScriptHeader
			while true; do
				printf "\\n\\e[1mPlease enter the desired number of days\\nto keep data for (30-365 days):\\e[0m  "
				read -r daystokeep_choice
				
				if [ "$daystokeep_choice" = "e" ]; then
					exitmenu="exit"
					break
				elif ! Validate_Number "$daystokeep_choice"; then
					printf "\\n\\e[31mPlease enter a valid number (30-365)\\e[0m\\n"
				else
					if [ "$daystokeep_choice" -lt 30 ] || [ "$daystokeep_choice" -gt 365 ]; then
						printf "\\n\\e[31mPlease enter a number between 30 and 365\\e[0m\\n"
					else
						daystokeep="$daystokeep_choice"
						printf "\\n"
						break
					fi
				fi
			done
			
			if [ "$exitmenu" != "exit" ]; then
				sed -i 's/^DAYSTOKEEP.*$/DAYSTOKEEP='"$daystokeep"'/' "$SCRIPT_CONF"
				return 0
			else
				printf "\\n"
				return 1
			fi
		;;
		check)
			DAYSTOKEEP=$(grep "DAYSTOKEEP" "$SCRIPT_CONF" | cut -f2 -d"=")
			echo "$DAYSTOKEEP"
		;;
	esac
}

LastXResults(){
	case "$1" in
		update)
			lastxresults=10
			exitmenu=""
			ScriptHeader
			while true; do
				printf "\\n\\e[1mPlease enter the desired number of results\\nto display in the WebUI (1-100):\\e[0m  "
				read -r lastx_choice
				
				if [ "$lastx_choice" = "e" ]; then
					exitmenu="exit"
					break
				elif ! Validate_Number "$lastx_choice"; then
					printf "\\n\\e[31mPlease enter a valid number (1-100)\\e[0m\\n"
				else
					if [ "$lastx_choice" -lt 1 ] || [ "$lastx_choice" -gt 100 ]; then
						printf "\\n\\e[31mPlease enter a number between 1 and 100\\e[0m\\n"
					else
						lastxresults="$lastx_choice"
						printf "\\n"
						break
					fi
				fi
			done
			
			if [ "$exitmenu" != "exit" ]; then
				sed -i 's/^LASTXRESULTS.*$/LASTXRESULTS='"$lastxresults"'/' "$SCRIPT_CONF"
				Generate_LastXResults
				return 0
			else
				printf "\\n"
				return 1
			fi
		;;
		check)
			LASTXRESULTS=$(grep "LASTXRESULTS" "$SCRIPT_CONF" | cut -f2 -d"=")
			echo "$LASTXRESULTS"
		;;
	esac
}

Auto_ServiceEvent(){
	case $1 in
		create)
			if [ -f /jffs/scripts/service-event ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/service-event)
				# shellcheck disable=SC2016
				STARTUPLINECOUNTEX=$(grep -cx "/jffs/scripts/$SCRIPT_NAME service_event"' "$@" & # '"$SCRIPT_NAME" /jffs/scripts/service-event)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/service-event
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					# shellcheck disable=SC2016
					echo "/jffs/scripts/$SCRIPT_NAME service_event"' "$@" & # '"$SCRIPT_NAME" >> /jffs/scripts/service-event
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/service-event
				echo "" >> /jffs/scripts/service-event
				# shellcheck disable=SC2016
				echo "/jffs/scripts/$SCRIPT_NAME service_event"' "$@" & # '"$SCRIPT_NAME" >> /jffs/scripts/service-event
				chmod 0755 /jffs/scripts/service-event
			fi
		;;
		delete)
			if [ -f /jffs/scripts/service-event ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/service-event)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/service-event
				fi
			fi
		;;
	esac
}

Auto_Startup(){
	case $1 in
		create)
			if [ -f /jffs/scripts/services-start ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/services-start)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/services-start
				fi
			fi
			if [ -f /jffs/scripts/post-mount ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/post-mount)
				STARTUPLINECOUNTEX=$(grep -cx "/jffs/scripts/$SCRIPT_NAME startup"' "$@" & # '"$SCRIPT_NAME" /jffs/scripts/post-mount)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/post-mount
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					echo "/jffs/scripts/$SCRIPT_NAME startup"' "$@" & # '"$SCRIPT_NAME" >> /jffs/scripts/post-mount
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/post-mount
				echo "" >> /jffs/scripts/post-mount
				echo "/jffs/scripts/$SCRIPT_NAME startup"' "$@" & # '"$SCRIPT_NAME" >> /jffs/scripts/post-mount
				chmod 0755 /jffs/scripts/post-mount
			fi
		;;
		delete)
			if [ -f /jffs/scripts/services-start ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/services-start)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/services-start
				fi
			fi
			if [ -f /jffs/scripts/post-mount ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/post-mount)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/post-mount
				fi
			fi
		;;
	esac
}

Auto_Cron(){
	case $1 in
		create)
			STARTUPLINECOUNT=$(cru l | grep -c "$SCRIPT_NAME")
			
			if [ "$STARTUPLINECOUNT" -eq 0 ]; then
				CRU_DAYNUMBERS="$(grep "SCHDAYS" "$SCRIPT_CONF" | cut -f2 -d"=" | sed 's/Sun/0/;s/Mon/1/;s/Tues/2/;s/Wed/3/;s/Thurs/4/;s/Fri/5/;s/Sat/6/;')"
				CRU_HOURS="$(grep "SCHHOURS" "$SCRIPT_CONF" | cut -f2 -d"=")"
				CRU_MINUTES="$(grep "SCHMINS" "$SCRIPT_CONF" | cut -f2 -d"=")"
				
				cru a "$SCRIPT_NAME" "$CRU_MINUTES $CRU_HOURS * * $CRU_DAYNUMBERS /jffs/scripts/$SCRIPT_NAME generate"
			fi
		;;
		delete)
			STARTUPLINECOUNT=$(cru l | grep -c "$SCRIPT_NAME")
			if [ "$STARTUPLINECOUNT" -gt 0 ]; then
				cru d "$SCRIPT_NAME"
			fi
		;;
	esac
}

Download_File(){
	/usr/sbin/curl -fsL --retry 3 "$1" -o "$2"
}

Get_WebUI_Page(){
	MyPage="none"
	for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
		page="/www/user/user$i.asp"
		if [ -f "$page" ] && [ "$(md5sum < "$1")" = "$(md5sum < "$page")" ]; then
			MyPage="user$i.asp"
			return
		elif [ "$MyPage" = "none" ] && [ ! -f "$page" ]; then
			MyPage="user$i.asp"
		fi
	done
}

### function based on @dave14305's FlexQoS webconfigpage function ###
Get_WebUI_URL(){
	urlpage=""
	urlproto=""
	urldomain=""
	urlport=""
	
	urlpage="$(sed -nE "/$SCRIPT_NAME/ s/.*url\: \"(user[0-9]+\.asp)\".*/\1/p" /tmp/menuTree.js)"
	if [ "$(nvram get http_enable)" -eq 1 ]; then
		urlproto="https"
	else
		urlproto="http"
	fi
	if [ -n "$(nvram get lan_domain)" ]; then
		urldomain="$(nvram get lan_hostname).$(nvram get lan_domain)"
	else
		urldomain="$(nvram get lan_ipaddr)"
	fi
	if [ "$(nvram get ${urlproto}_lanport)" -eq 80 ] || [ "$(nvram get ${urlproto}_lanport)" -eq 443 ]; then
		urlport=""
	else
		urlport=":$(nvram get ${urlproto}_lanport)"
	fi
	
	if echo "$urlpage" | grep -qE "user[0-9]+\.asp"; then
		echo "${urlproto}://${urldomain}${urlport}/${urlpage}" | tr "A-Z" "a-z"
	else
		echo "WebUI page not found"
	fi
}
### ###

### locking mechanism code credit to Martineau (@MartineauUK) ###
Mount_WebUI(){
	Print_Output true "Mounting WebUI tab for $SCRIPT_NAME" "$PASS"
	LOCKFILE=/tmp/addonwebui.lock
	FD=386
	eval exec "$FD>$LOCKFILE"
	flock -x "$FD"
	Get_WebUI_Page "$SCRIPT_DIR/connmonstats_www.asp"
	if [ "$MyPage" = "none" ]; then
		Print_Output true "Unable to mount $SCRIPT_NAME WebUI page, exiting" "$CRIT"
		flock -u "$FD"
		return 1
	fi
	cp -f "$SCRIPT_DIR/connmonstats_www.asp" "$SCRIPT_WEBPAGE_DIR/$MyPage"
	echo "$SCRIPT_NAME" > "$SCRIPT_WEBPAGE_DIR/$(echo $MyPage | cut -f1 -d'.').title"
	
	if [ "$(uname -o)" = "ASUSWRT-Merlin" ]; then
		if [ ! -f /tmp/index_style.css ]; then
			cp -f /www/index_style.css /tmp/
		fi
		
		if ! grep -q '.menu_Addons' /tmp/index_style.css ; then
			echo ".menu_Addons { background: url(ext/shared-jy/addons.png); }" >> /tmp/index_style.css
		fi
		
		umount /www/index_style.css 2>/dev/null
		mount -o bind /tmp/index_style.css /www/index_style.css
		
		if [ ! -f /tmp/menuTree.js ]; then
			cp -f /www/require/modules/menuTree.js /tmp/
		fi
		
		sed -i "\\~$MyPage~d" /tmp/menuTree.js
		
		if ! grep -q 'menuName: "Addons"' /tmp/menuTree.js ; then
			lineinsbefore="$(( $(grep -n "exclude:" /tmp/menuTree.js | cut -f1 -d':') - 1))"
			sed -i "$lineinsbefore"'i,\n{\nmenuName: "Addons",\nindex: "menu_Addons",\ntab: [\n{url: "javascript:var helpwindow=window.open('"'"'/ext/shared-jy/redirect.htm'"'"')", tabName: "Help & Support"},\n{url: "NULL", tabName: "__INHERIT__"}\n]\n}' /tmp/menuTree.js
		fi
		
		sed -i "/url: \"javascript:var helpwindow=window.open('\/ext\/shared-jy\/redirect.htm'/i {url: \"$MyPage\", tabName: \"$SCRIPT_NAME\"}," /tmp/menuTree.js
		
		umount /www/require/modules/menuTree.js 2>/dev/null
		mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
	fi
	flock -u "$FD"
	Print_Output true "Mounted $SCRIPT_NAME WebUI page as $MyPage" "$PASS"
}

AutomaticMode(){
	case "$1" in
		enable)
			sed -i 's/^AUTOMATED.*$/AUTOMATED=true/' "$SCRIPT_CONF"
			Auto_Cron create 2>/dev/null
		;;
		disable)
			sed -i 's/^AUTOMATED.*$/AUTOMATED=false/' "$SCRIPT_CONF"
			Auto_Cron delete 2>/dev/null
		;;
		check)
			AUTOMATED=$(grep "AUTOMATED" "$SCRIPT_CONF" | cut -f2 -d"=")
			if [ "$AUTOMATED" = "true" ]; then return 0; else return 1; fi
		;;
	esac
}

TestSchedule(){
	case "$1" in
		update)
			sed -i 's/^SCHDAYS.*$/SCHDAYS='"$(echo "$2" | sed 's/0/Sun/;s/1/Mon/;s/2/Tues/;s/3/Wed/;s/4/Thurs/;s/5/Fri/;s/6/Sat/;')"'/' "$SCRIPT_CONF"
			sed -i 's~^SCHHOURS.*$~SCHHOURS='"$3"'~' "$SCRIPT_CONF"
			sed -i 's~^SCHMINS.*$~SCHMINS='"$4"'~' "$SCRIPT_CONF"
			
			Auto_Cron delete 2>/dev/null
			Auto_Cron create 2>/dev/null
		;;
		check)
			SCHDAYS=$(grep "SCHDAYS" "$SCRIPT_CONF" | cut -f2 -d"=")
			SCHHOURS=$(grep "SCHHOURS" "$SCRIPT_CONF" | cut -f2 -d"=")
			SCHMINS=$(grep "SCHMINS" "$SCRIPT_CONF" | cut -f2 -d"=")
			echo "$SCHDAYS|$SCHHOURS|$SCHMINS"
		;;
	esac
}

ScriptStorageLocation(){
	case "$1" in
		usb)
			sed -i 's/^STORAGELOCATION.*$/STORAGELOCATION=usb/' "$SCRIPT_CONF"
			mkdir -p "/opt/share/$SCRIPT_NAME.d/"
			mv "/jffs/addons/$SCRIPT_NAME.d/csv" "/opt/share/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/jffs/addons/$SCRIPT_NAME.d/config" "/opt/share/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/jffs/addons/$SCRIPT_NAME.d/config.bak" "/opt/share/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/jffs/addons/$SCRIPT_NAME.d/connstatstext.js" "/opt/share/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/jffs/addons/$SCRIPT_NAME.d/lastx.htm" "/opt/share/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/jffs/addons/$SCRIPT_NAME.d/connstats.db" "/opt/share/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/jffs/addons/$SCRIPT_NAME.d/.indexcreated" "/opt/share/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/jffs/addons/$SCRIPT_NAME.d/.newcolumns" "/opt/share/$SCRIPT_NAME.d/" 2>/dev/null
			SCRIPT_CONF="/opt/share/$SCRIPT_NAME.d/config"
			ScriptStorageLocation load
		;;
		jffs)
			sed -i 's/^STORAGELOCATION.*$/STORAGELOCATION=jffs/' "$SCRIPT_CONF"
			mkdir -p "/jffs/addons/$SCRIPT_NAME.d/"
			mv "/opt/share/$SCRIPT_NAME.d/csv" "/jffs/addons/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/opt/share/$SCRIPT_NAME.d/config" "/jffs/addons/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/opt/share/$SCRIPT_NAME.d/config.bak" "/jffs/addons/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/opt/share/$SCRIPT_NAME.d/connstatstext.js" "/jffs/addons/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/opt/share/$SCRIPT_NAME.d/lastx.htm" "/jffs/addons/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/opt/share/$SCRIPT_NAME.d/connstats.db" "/jffs/addons/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/opt/share/$SCRIPT_NAME.d/.indexcreated" "/jffs/addons/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/opt/share/$SCRIPT_NAME.d/.newcolumns" "/jffs/addons/$SCRIPT_NAME.d/" 2>/dev/null
			SCRIPT_CONF="/jffs/addons/$SCRIPT_NAME.d/config"
			ScriptStorageLocation load
		;;
		check)
			STORAGELOCATION=$(grep "STORAGELOCATION" "$SCRIPT_CONF" | cut -f2 -d"=")
			echo "$STORAGELOCATION"
		;;
		load)
			STORAGELOCATION=$(grep "STORAGELOCATION" "$SCRIPT_CONF" | cut -f2 -d"=")
			if [ "$STORAGELOCATION" = "usb" ]; then
				SCRIPT_STORAGE_DIR="/opt/share/$SCRIPT_NAME.d"
			elif [ "$STORAGELOCATION" = "jffs" ]; then
				SCRIPT_STORAGE_DIR="/jffs/addons/$SCRIPT_NAME.d"
			fi
			
			CSV_OUTPUT_DIR="$SCRIPT_STORAGE_DIR/csv"
		;;
	esac
}

OutputTimeMode(){
	case "$1" in
		unix)
			sed -i 's/^OUTPUTTIMEMODE.*$/OUTPUTTIMEMODE=unix/' "$SCRIPT_CONF"
			Generate_CSVs
		;;
		non-unix)
			sed -i 's/^OUTPUTTIMEMODE.*$/OUTPUTTIMEMODE=non-unix/' "$SCRIPT_CONF"
			Generate_CSVs
		;;
		check)
			OUTPUTTIMEMODE=$(grep "OUTPUTTIMEMODE" "$SCRIPT_CONF" | cut -f2 -d"=")
			echo "$OUTPUTTIMEMODE"
		;;
	esac
}

WritePlainData_ToJS(){
	inputfile="$1"
	outputfile="$2"
	shift;shift
	i=0
	for var in "$@"; do
		i=$((i+1))
		{
			echo "var $var;"
			echo "$var = [];"
			echo "${var}.unshift('$(awk -v i=$i '{printf t $i} {t=","}' "$inputfile" | sed "s~,~\\',\\'~g")');"
			echo
		} >> "$outputfile"
	done
}

WriteStats_ToJS(){
	echo "function $3(){" > "$2"
	html='document.getElementById("'"$4"'").innerHTML="'
	while IFS='' read -r line || [ -n "$line" ]; do
		html="${html}${line}\\r\\n"
	done < "$1"
	html="$html"'"'
	printf "%s\\r\\n}\\r\\n" "$html" >> "$2"
}

#$1 fieldname $2 tablename $3 frequency (hours) $4 length (days) $5 outputfile $6 outputfrequency $7 sqlfile $8 timestamp
WriteSql_ToFile(){
	timenow="$8"
	maxcount="$(echo "$3" "$4" | awk '{printf ((24*$2)/$1)}')"
	
	if ! echo "$5" | grep -q "day"; then
		{
			echo ".mode csv"
			echo ".headers on"
			echo ".output ${5}_${6}.htm"
			echo "SELECT '$1' Metric, Min(strftime('%s',datetime(strftime('%Y-%m-%d %H:00:00',datetime([Timestamp],'unixepoch'))))) Time, IFNULL(Avg([$1]),'NaN') Value FROM $2 WHERE ([Timestamp] >= strftime('%s',datetime($timenow,'unixepoch','-$maxcount hour'))) GROUP BY strftime('%m',datetime([Timestamp],'unixepoch')),strftime('%d',datetime([Timestamp],'unixepoch')),strftime('%H',datetime([Timestamp],'unixepoch')) ORDER BY [Timestamp] DESC;"
		} >> "$7"
	else
		{
			echo ".mode csv"
			echo ".headers on"
			echo ".output ${5}_${6}.htm"
			echo "SELECT '$1' Metric, Min(strftime('%s',datetime([Timestamp],'unixepoch','start of day'))) Time, IFNULL(Avg([$1]),'NaN') Value FROM $2 WHERE ([Timestamp] > strftime('%s',datetime($timenow,'unixepoch','start of day','+1 day','-$maxcount day'))) GROUP BY strftime('%m',datetime([Timestamp],'unixepoch')),strftime('%d',datetime([Timestamp],'unixepoch')) ORDER BY [Timestamp] DESC;"
		} >> "$7"
	fi
}

Generate_LastXResults(){
	{
		echo ".mode csv"
		echo ".output /tmp/conn-lastx.csv"
		echo "SELECT [Timestamp],[Ping],[Jitter],[LineQuality],[PingTarget],[PingDuration] FROM connstats ORDER BY [Timestamp] DESC LIMIT $(LastXResults check);"
	} > /tmp/conn-lastx.sql
	"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/conn-lastx.sql
	rm -f /tmp/conn-lastx.sql
	#sed -i 's/,,/,null,/g;s/,/ /g;s/"//g;' /tmp/conn-lastx.csv
	rm -f "$SCRIPT_STORAGE_DIR/connjs.js"
	mv /tmp/conn-lastx.csv "$SCRIPT_STORAGE_DIR/lastx.htm"
}

Run_PingTest(){
	if [ ! -f /opt/bin/xargs ]; then
		Print_Output true "Installing findutils from Entware"
		opkg update
		opkg install findutils
	fi
	#shellcheck disable=SC2009
	if [ -n "$PPID" ]; then
		ps | grep -v grep | grep -v $$ | grep -v "$PPID" | grep -i "$SCRIPT_NAME" | grep generate | awk '{print $1}' | xargs kill -9 >/dev/null 2>&1
	else
		ps | grep -v grep | grep -v $$ | grep -i "$SCRIPT_NAME" | grep generate | awk '{print $1}' | xargs kill -9 >/dev/null 2>&1
	fi
	Create_Dirs
	Conf_Exists
	Auto_Startup create 2>/dev/null
	if AutomaticMode check; then Auto_Cron create 2>/dev/null; else Auto_Cron delete 2>/dev/null; fi
	Auto_ServiceEvent create 2>/dev/null
	ScriptStorageLocation load
	Create_Symlinks
	
	pingfile=/tmp/pingresult.txt
	resultfile=/tmp/ping-result.txt
	printf "" > "$resultfile"
	
	echo 'var connmonstatus = "InProgress";' > /tmp/detect_connmon.js
	
	Print_Output false "$(PingDuration check) second ping test to $(PingServer check) starting..." "$PASS"
	if ! Validate_IP "$(PingServer check)" >/dev/null 2>&1 && ! Validate_Domain "$(PingServer check)" >/dev/null 2>&1; then
		Print_Output true "$(PingServer check) not valid, aborting test. Please correct ASAP" "$ERR"
		echo 'var connmonstatus = "InvalidServer";' > /tmp/detect_connmon.js
		Clear_Lock
		return 1
	fi
	
	stoppedqos="false"
	if [ "$(nvram get qos_enable)" -eq 1 ] && [ "$(nvram get qos_type)" -eq 1 ]; then
		for ACTION in -D -A ; do
			iptables "$ACTION" OUTPUT -p icmp -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
			iptables -t mangle "$ACTION" OUTPUT -p icmp -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
			iptables -t mangle "$ACTION" POSTROUTING -p icmp -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
			stoppedqos="true"
		done
	elif [ "$(nvram get qos_enable)" -eq 1 ] && [ "$(nvram get qos_type)" -ne 1 ] && [ -f /tmp/qos ]; then
		/tmp/qos stop >/dev/null 2>&1
		stoppedqos="true"
	elif [ "$(nvram get qos_enable)" -eq 0 ] && [ -f /jffs/addons/cake-qos/cake-qos ]; then
		/jffs/addons/cake-qos/cake-qos stop >/dev/null 2>&1
		stoppedqos="true"
	fi
	
	ping -w "$(PingDuration check)" "$(PingServer check)" > "$pingfile"
	
	if [ "$stoppedqos" = "true" ]; then
		if [ "$(nvram get qos_enable)" -eq 1 ] && [ "$(nvram get qos_type)" -eq 1 ]; then
			iptables -D OUTPUT -p icmp -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
			iptables -t mangle -D OUTPUT -p icmp -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
			iptables -t mangle -D POSTROUTING -p icmp -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
		elif [ "$(nvram get qos_enable)" -eq 1 ] && [ "$(nvram get qos_type)" -ne 1 ] && [ -f /tmp/qos ]; then
			/tmp/qos start >/dev/null 2>&1
		elif [ "$(nvram get qos_enable)" -eq 0 ] && [ -f /jffs/addons/cake-qos/cake-qos ]; then
			/jffs/addons/cake-qos/cake-qos start >/dev/null 2>&1
		fi
	fi
	
	ScriptStorageLocation load
	
	PREVPING=0
	TOTALDIFF=0
	COUNTER=1
	PINGLIST="$(grep seq= "$pingfile")"
	PINGCOUNT="$(echo "$PINGLIST" | sed '/^\s*$/d' | wc -l)"
	DIFFCOUNT="$((PINGCOUNT - 1))"
	if [ "$PINGCOUNT" -gt 0 ]; then
		until [ "$COUNTER" -gt "$PINGCOUNT" ]; do
			CURPING=$(echo "$PINGLIST" | sed -n "$COUNTER"p | cut -f4 -d"=" | cut -f1 -d" ")
			
			if [ "$COUNTER" -gt 1 ]; then
				DIFF="$(echo "$CURPING" "$PREVPING" | awk '{printf "%4.3f\n",$1-$2}')"
				NEG="$(echo "$DIFF" 0 | awk '{ if ($1 < $2) print "neg"; else print "pos"}')"
				if [ "$NEG" = "neg" ]; then DIFF="$(echo "$DIFF" "-1" | awk '{printf "%4.3f\n",$1*$2}')"; fi
				TOTALDIFF="$(echo "$TOTALDIFF" "$DIFF" | awk '{printf "%4.3f\n",$1+$2}')"
			fi
			PREVPING="$CURPING"
			COUNTER=$((COUNTER + 1))
		done
	fi
	
	TZ=$(cat /etc/TZ)
	export TZ
	
	timenow=$(date +"%s")
	timenowfriendly=$(date +"%c")
	
	ping=0
	jitter=0
	linequal=0
	
	if [ "$PINGCOUNT" -gt 1 ]; then
		ping="$(tail -n 1 "$pingfile"  | cut -f4 -d"/")"
		jitter="$(echo "$TOTALDIFF" "$DIFFCOUNT" | awk '{printf "%4.3f\n",$1/$2}')"
		linequal="$(echo 100 "$(tail -n 2 "$pingfile" | head -n 1 | cut -f3 -d"," | awk '{$1=$1};1' | cut -f1 -d"%")" | awk '{printf "%4.3f\n",$1-$2}')"
	fi
	
	Process_Upgrade
	
	{
	echo "CREATE TABLE IF NOT EXISTS [connstats] ([StatID] INTEGER PRIMARY KEY NOT NULL,[Timestamp] NUMERIC NOT NULL,[Ping] REAL NOT NULL,[Jitter] REAL NOT NULL,[LineQuality] REAL NOT NULL,[PingTarget] TEXT NOT NULL,[PingDuration] NUMERIC);"
	echo "INSERT INTO connstats ([Timestamp],[Ping],[Jitter],[LineQuality],[PingTarget],[PingDuration]) values($timenow,$ping,$jitter,$linequal,'$(PingServer check)',$(PingDuration check));"
	} > /tmp/connmon-stats.sql
	"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
	
	echo "DELETE FROM [connstats] WHERE [Timestamp] < strftime('%s',datetime($timenow,'unixepoch','-$(DaysToKeep check) day'));" > /tmp/connmon-stats.sql
	"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
	rm -f /tmp/connmon-stats.sql
	
	echo 'var connmonstatus = "GenerateCSV";' > /tmp/detect_connmon.js
	
	Generate_CSVs
	
	echo "Stats last updated: $timenowfriendly" > "/tmp/connstatstitle.txt"
	WriteStats_ToJS /tmp/connstatstitle.txt "$SCRIPT_STORAGE_DIR/connstatstext.js" SetConnmonStatsTitle statstitle
	Print_Output false "Test results - Ping $ping ms - Jitter - $jitter ms - Line Quality $linequal %" "$PASS"
	
	{
		printf "Ping test result\\n"
		printf "\\nPing %s ms - Jitter - %s ms - Line Quality %s %%\\n" "$ping" "$jitter" "$linequal"
	} >> "$resultfile"
	
	rm -f "$pingfile"
	rm -f /tmp/connstatstitle.txt
	echo 'var connmonstatus = "Done";' > /tmp/detect_connmon.js
}

Generate_CSVs(){
	Process_Upgrade
	renice 15 $$
	OUTPUTTIMEMODE="$(OutputTimeMode check)"
	TZ=$(cat /etc/TZ)
	export TZ
	
	timenow=$(date +"%s")
	timenowfriendly=$(date +"%c")
	
	metriclist="Ping Jitter LineQuality"
	
	for metric in $metriclist; do
		{
			echo ".mode csv"
			echo ".headers on"
			echo ".output $CSV_OUTPUT_DIR/${metric}_raw_daily.htm"
			echo "SELECT '$metric' Metric,[Timestamp] Time,[$metric] Value FROM connstats WHERE ([Timestamp] >= strftime('%s',datetime($timenow,'unixepoch','-1 day'))) ORDER BY [Timestamp] DESC;"
		} > /tmp/connmon-stats.sql
		"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
		
		{
			echo ".mode csv"
			echo ".headers on"
			echo ".output $CSV_OUTPUT_DIR/${metric}_raw_weekly.htm"
			echo "SELECT '$metric' Metric,[Timestamp] Time,[$metric] Value FROM connstats WHERE ([Timestamp] >= strftime('%s',datetime($timenow,'unixepoch','-7 day'))) ORDER BY [Timestamp] DESC;"
		} > /tmp/connmon-stats.sql
		"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
		
		{
			echo ".mode csv"
			echo ".headers on"
			echo ".output $CSV_OUTPUT_DIR/${metric}_raw_monthly.htm"
			echo "SELECT '$metric' Metric,[Timestamp] Time,[$metric] Value FROM connstats WHERE ([Timestamp] >= strftime('%s',datetime($timenow,'unixepoch','-30 day'))) ORDER BY [Timestamp] DESC;"
		} > /tmp/connmon-stats.sql
		"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
		
		WriteSql_ToFile "$metric" connstats 1 1 "$CSV_OUTPUT_DIR/${metric}_hour" daily /tmp/connmon-stats.sql "$timenow"
		"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
		
		WriteSql_ToFile "$metric" connstats 1 7 "$CSV_OUTPUT_DIR/${metric}_hour" weekly /tmp/connmon-stats.sql "$timenow"
		"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
		
		WriteSql_ToFile "$metric" connstats 1 30 "$CSV_OUTPUT_DIR/${metric}_hour" monthly /tmp/connmon-stats.sql "$timenow"
		"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
		
		WriteSql_ToFile "$metric" connstats 24 1 "$CSV_OUTPUT_DIR/${metric}_day" daily /tmp/connmon-stats.sql "$timenow"
		"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
		
		WriteSql_ToFile "$metric" connstats 24 7 "$CSV_OUTPUT_DIR/${metric}_day" weekly /tmp/connmon-stats.sql "$timenow"
		"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
		
		WriteSql_ToFile "$metric" connstats 24 30 "$CSV_OUTPUT_DIR/${metric}_day" monthly /tmp/connmon-stats.sql "$timenow"
		"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
		
		rm -f "$CSV_OUTPUT_DIR/${metric}daily.htm"
		rm -f "$CSV_OUTPUT_DIR/${metric}weekly.htm"
		rm -f "$CSV_OUTPUT_DIR/${metric}monthly.htm"
	done
	
	rm -f /tmp/connmon-stats.sql
	Generate_LastXResults
	
	{
		echo ".mode csv"
		echo ".headers on"
		echo ".output $CSV_OUTPUT_DIR/CompleteResults.htm"
	} > /tmp/connmon-complete.sql
	echo "SELECT [Timestamp],[Ping],[Jitter],[LineQuality],[PingTarget],[PingDuration] FROM connstats WHERE ([Timestamp] >= strftime('%s',datetime($timenow,'unixepoch','-$(DaysToKeep check) day'))) ORDER BY [Timestamp] DESC;" >> /tmp/connmon-complete.sql
	"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-complete.sql
	rm -f /tmp/connmon-complete.sql
	
	dos2unix "$CSV_OUTPUT_DIR/"*.htm
	
	tmpoutputdir="/tmp/${SCRIPT_NAME}results"
	mkdir -p "$tmpoutputdir"
	mv "$CSV_OUTPUT_DIR/CompleteResults.htm" "$tmpoutputdir/CompleteResults.htm"
	
	if [ "$OUTPUTTIMEMODE" = "unix" ]; then
		find "$tmpoutputdir/" -name '*.htm' -exec sh -c 'i="$1"; mv -- "$i" "${i%.htm}.csv"' _ {} \;
	elif [ "$OUTPUTTIMEMODE" = "non-unix" ]; then
		for i in "$tmpoutputdir/"*".htm"; do
			awk -F"," 'NR==1 {OFS=","; print} NR>1 {OFS=","; $1=strftime("%Y-%m-%d %H:%M:%S", $1); print }' "$i" > "$i.out"
		done
		
		find "$tmpoutputdir/" -name '*.htm.out' -exec sh -c 'i="$1"; mv -- "$i" "${i%.htm.out}.csv"' _ {} \;
		rm -f "$tmpoutputdir/"*.htm
	fi
	
	mv "$tmpoutputdir/CompleteResults.csv" "$CSV_OUTPUT_DIR/CompleteResults.htm"
	rm -f "$CSV_OUTPUT_DIR/connmondata.zip"
	rm -rf "$tmpoutputdir"
	renice 0 $$
}

# shellcheck disable=SC2012
Reset_DB(){
	SIZEAVAIL="$(df -P -k "$SCRIPT_STORAGE_DIR" | awk '{print $4}' | tail -n 1)"
	SIZEDB="$(ls -l "$SCRIPT_STORAGE_DIR/connstats.db" | awk '{print $5}')"
	if [ "$SIZEDB" -gt "$SIZEAVAIL" ]; then
		Print_Output true "Database size exceeds available space. $(ls -lh "$SCRIPT_STORAGE_DIR/connstats.db" | awk '{print $5}')B is required to create backup." "$ERR"
		return 1
	else
		Print_Output true "Sufficient free space to back up database, proceeding..." "$PASS"
		if ! cp -a "$SCRIPT_STORAGE_DIR/connstats.db" "$SCRIPT_STORAGE_DIR/connstats.db.bak"; then
			Print_Output true "Database backup failed, please check storage device" "$WARN"
		fi
		
		echo "DELETE FROM [connstats];" > /tmp/connmon-stats.sql
		"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
		rm -f /tmp/connmon-stats.sql
		
		Print_Output true "Database reset complete" "$WARN"
	fi
}

Process_Upgrade(){
	rm -f "$SCRIPT_STORAGE_DIR/.tableupgraded"
	if [ ! -f "$SCRIPT_STORAGE_DIR/.indexcreated" ]; then
		renice 15 $$
		Print_Output true "Creating database table indexes..." "$PASS"
		echo "CREATE INDEX idx_time_ping ON connstats (Timestamp,Ping);" > /tmp/connmon-upgrade.sql
		while ! "$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-upgrade.sql >/dev/null 2>&1; do
			:
		done
		echo "CREATE INDEX idx_time_jitter ON connstats (Timestamp,Jitter);" > /tmp/connmon-upgrade.sql
		while ! "$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-upgrade.sql >/dev/null 2>&1; do
			:
		done
		echo "CREATE INDEX idx_time_linequality ON connstats (Timestamp,LineQuality);" > /tmp/connmon-upgrade.sql
		while ! "$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-upgrade.sql >/dev/null 2>&1; do
			:
		done
		rm -f /tmp/connmon-upgrade.sql
		touch "$SCRIPT_STORAGE_DIR/.indexcreated"
		Print_Output true "Database ready, continuing..." "$PASS"
		renice 0 $$
	fi
	if [ ! -f "$SCRIPT_STORAGE_DIR/.newcolumns" ]; then
		echo "ALTER TABLE connstats ADD COLUMN PingTarget [TEXT] NOT NULL DEFAULT '';" > /tmp/connmon-upgrade.sql
		while ! "$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-upgrade.sql >/dev/null 2>&1; do
			:
		done
		echo "ALTER TABLE connstats ADD COLUMN PingDuration [NUMERIC];" > /tmp/connmon-upgrade.sql
		while ! "$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-upgrade.sql >/dev/null 2>&1; do
			:
		done
		rm -f /tmp/connmon-upgrade.sql
		touch "$SCRIPT_STORAGE_DIR/.newcolumns"
	fi
	if [ ! -f "$SCRIPT_STORAGE_DIR/lastx.htm" ]; then
		Generate_LastXResults
	fi
}

Shortcut_Script(){
	case $1 in
		create)
			if [ -d /opt/bin ] && [ ! -f "/opt/bin/$SCRIPT_NAME" ] && [ -f "/jffs/scripts/$SCRIPT_NAME" ]; then
				ln -s "/jffs/scripts/$SCRIPT_NAME" /opt/bin
				chmod 0755 "/opt/bin/$SCRIPT_NAME"
			fi
		;;
		delete)
			if [ -f "/opt/bin/$SCRIPT_NAME" ]; then
				rm -f "/opt/bin/$SCRIPT_NAME"
			fi
		;;
	esac
}

PressEnter(){
	while true; do
		printf "Press enter to continue..."
		read -r key
		case "$key" in
			*)
				break
			;;
		esac
	done
	return 0
}

ScriptHeader(){
	clear
	printf "\\n"
	printf "\\e[1m##############################################################\\e[0m\\n"
	printf "\\e[1m##     ___   ___   _ __   _ __   _ __ ___    ___   _ __     ##\\e[0m\\n"
	printf "\\e[1m##    / __| / _ \ | '_ \ | '_ \ | '_   _ \  / _ \ | '_ \    ##\\e[0m\\n"
	printf "\\e[1m##   | (__ | (_) || | | || | | || | | | | || (_) || | | |   ##\\e[0m\\n"
	printf "\\e[1m##    \___| \___/ |_| |_||_| |_||_| |_| |_| \___/ |_| |_|   ##\\e[0m\\n"
	printf "\\e[1m##                                                          ##\\e[0m\\n"
	printf "\\e[1m##                  %s on %-11s                  ##\\e[0m\\n" "$SCRIPT_VERSION" "$ROUTER_MODEL"
	printf "\\e[1m##                                                          ##\\e[0m\\n"
	printf "\\e[1m##            https://github.com/jackyaz/connmon            ##\\e[0m\\n"
	printf "\\e[1m##                                                          ##\\e[0m\\n"
	printf "\\e[1m##############################################################\\e[0m\\n"
	printf "\\n"
}

MainMenu(){
	AUTOMATIC_ENABLED=""
	if AutomaticMode check; then AUTOMATIC_ENABLED="${PASS}Enabled"; else AUTOMATIC_ENABLED="${ERR}Disabled"; fi
	TEST_SCHEDULE="$(TestSchedule check)"
	if [ "$(echo "$TEST_SCHEDULE" | cut -f2 -d'|' | grep -c "/")" -gt 0 ] && [ "$(echo "$TEST_SCHEDULE" | cut -f3 -d'|')" -eq 0 ]; then
		TEST_SCHEDULE_MENU="Every $(echo "$TEST_SCHEDULE" | cut -f2 -d'|' | cut -f2 -d'/') hours"
	elif [ "$(echo "$TEST_SCHEDULE" | cut -f3 -d'|' | grep -c "/")" -gt 0 ] && [ "$(echo "$TEST_SCHEDULE" | cut -f2 -d'|')" = "*" ]; then
		TEST_SCHEDULE_MENU="Every $(echo "$TEST_SCHEDULE" | cut -f3 -d'|' | cut -f2 -d'/') minutes"
	else
		TEST_SCHEDULE_MENU="Hours: $(echo "$TEST_SCHEDULE" | cut -f2 -d'|')    -    Minutes: $(echo "$TEST_SCHEDULE" | cut -f3 -d'|')"
	fi
	
	if [ "$(echo "$TEST_SCHEDULE" | cut -f1 -d'|')" = "*" ]; then
		TEST_SCHEDULE_MENU2="Days of week: All"
	else
		TEST_SCHEDULE_MENU2="Days of week: $(echo "$TEST_SCHEDULE" | cut -f1 -d'|')"
	fi
	
	printf "WebUI for %s is available at:\\n${SETTING}%s\\e[0m\\n\\n" "$SCRIPT_NAME" "$(Get_WebUI_URL)"
	printf "1.    Check connection now\\n\\n"
	printf "2.    Set preferred ping server\\n      Currently: ${SETTING}%s\\e[0m\\n\\n" "$(PingServer check)"
	printf "3.    Set ping test duration\\n      Currently: ${SETTING}%ss\\e[0m\\n\\n" "$(PingDuration check)"
	printf "4.    Toggle automatic ping tests\\n      Currently: \\e[1m$AUTOMATIC_ENABLED\\e[0m\\n\\n"
	printf "5.    Set schedule for automatic ping tests\\n      ${SETTING}%s\\n      %s\\e[0m\\n\\n" "$TEST_SCHEDULE_MENU" "$TEST_SCHEDULE_MENU2"
	printf "6.    Toggle time output mode\\n      Currently ${SETTING}%s\\e[0m time values will be used for CSV exports\\n\\n" "$(OutputTimeMode check)"
	printf "7.    Set number of ping test results to show in WebUI\\n      Currently: ${SETTING}%s results will be shown\\e[0m\\n\\n" "$(LastXResults check)"
	printf "8.    Set number of days data to keep in database\\n      Currently: ${SETTING}%s days data will be kept\\e[0m\\n\\n" "$(DaysToKeep check)"
	printf "s.    Toggle storage location for stats and config\\n      Current location is ${SETTING}%s\\e[0m \\n\\n" "$(ScriptStorageLocation check)"
	printf "u.    Check for updates\\n"
	printf "uf.   Update %s with latest version (force update)\\n\\n" "$SCRIPT_NAME"
	printf "r.    Reset %s database / delete all data\\n\\n" "$SCRIPT_NAME"
	printf "e.    Exit %s\\n\\n" "$SCRIPT_NAME"
	printf "z.    Uninstall %s\\n" "$SCRIPT_NAME"
	printf "\\n"
	printf "\\e[1m##############################################################\\e[0m\\n"
	printf "\\n"
	
	while true; do
		printf "Choose an option:  "
		read -r menu
		case "$menu" in
			1)
				printf "\\n"
				if Check_Lock menu; then
					Run_PingTest
					Clear_Lock
				fi
				PressEnter
				break
			;;
			2)
				printf "\\n"
				PingServer update
				PressEnter
				break
			;;
			3)
				printf "\\n"
				PingDuration update
				PressEnter
				break
			;;
			4)
				printf "\\n"
				if AutomaticMode check; then
					AutomaticMode disable
				else
					AutomaticMode enable
				fi
				break
			;;
			5)
				printf "\\n"
				Menu_EditSchedule
				PressEnter
				break
			;;
			6)
				printf "\\n"
				if [ "$(OutputTimeMode check)" = "unix" ]; then
					OutputTimeMode non-unix
				elif [ "$(OutputTimeMode check)" = "non-unix" ]; then
					OutputTimeMode unix
				fi
				break
			;;
			7)
				printf "\\n"
				LastXResults update
				PressEnter
				break
			;;
			8)
				printf "\\n"
				DaysToKeep update
				PressEnter
				break
			;;
			s)
				printf "\\n"
				if [ "$(ScriptStorageLocation check)" = "jffs" ]; then
					ScriptStorageLocation usb
					Create_Symlinks
				elif [ "$(ScriptStorageLocation check)" = "usb" ]; then
					ScriptStorageLocation jffs
					Create_Symlinks
				fi
				break
			;;
			u)
				printf "\\n"
				if Check_Lock menu; then
					Update_Version
					Clear_Lock
				fi
				PressEnter
				break
			;;
			uf)
				printf "\\n"
				if Check_Lock menu; then
					Update_Version force
					Clear_Lock
				fi
				PressEnter
				break
			;;
			r)
				printf "\\n"
				if Check_Lock menu; then
					Menu_ResetDB
					Clear_Lock
				fi
				PressEnter
				break
			;;
			e)
				ScriptHeader
				printf "\\n\\e[1mThanks for using %s!\\e[0m\\n\\n\\n" "$SCRIPT_NAME"
				exit 0
			;;
			z)
				while true; do
					printf "\\n\\e[1mAre you sure you want to uninstall %s? (y/n)\\e[0m  " "$SCRIPT_NAME"
					read -r confirm
					case "$confirm" in
						y|Y)
							Menu_Uninstall
							exit 0
						;;
						*)
							break
						;;
					esac
				done
			;;
			*)
				printf "\\nPlease choose a valid option\\n\\n"
			;;
		esac
	done
	
	ScriptHeader
	MainMenu
}

Check_Requirements(){
	CHECKSFAILED="false"
	
	if [ "$(nvram get jffs2_scripts)" -ne 1 ]; then
		nvram set jffs2_scripts=1
		nvram commit
		Print_Output true "Custom JFFS Scripts enabled" "$WARN"
	fi
	
	if [ ! -f /opt/bin/opkg ]; then
		Print_Output true "Entware not detected!" "$ERR"
		CHECKSFAILED="true"
	fi
	
	if ! Firmware_Version_Check; then
		Print_Output true "Unsupported firmware version detected" "$ERR"
		Print_Output true "$SCRIPT_NAME requires Merlin 384.15/384.13_4 or Fork 43E5 (or later)" "$ERR"
		CHECKSFAILED="true"
	fi
	
	if [ "$CHECKSFAILED" = "false" ]; then
		Print_Output true "Installing required packages from Entware" "$PASS"
		opkg update
		opkg install sqlite3-cli
		opkg install findutils
		return 0
	else
		return 1
	fi
}

Menu_Install(){
	Print_Output true "Welcome to $SCRIPT_NAME $SCRIPT_VERSION, a script by JackYaz"
	sleep 1
	
	Print_Output true "Checking your router meets the requirements for $SCRIPT_NAME"
	
	if ! Check_Requirements; then
		Print_Output true "Requirements for $SCRIPT_NAME not met, please see above for the reason(s)" "$CRIT"
		PressEnter
		Clear_Lock
		rm -f "/jffs/scripts/$SCRIPT_NAME" 2>/dev/null
		exit 1
	fi
	
	Create_Dirs
	Conf_Exists
	Set_Version_Custom_Settings local "$SCRIPT_VERSION"
	Set_Version_Custom_Settings server "$SCRIPT_VERSION"
	ScriptStorageLocation load
	Create_Symlinks
	
	Update_File connmonstats_www.asp
	Update_File shared-jy.tar.gz
	
	Auto_Startup create 2>/dev/null
	if AutomaticMode check; then Auto_Cron create 2>/dev/null; else Auto_Cron delete 2>/dev/null; fi
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_Script create
	Run_PingTest
	
	Clear_Lock
}

Menu_Startup(){
	if [ -z "$1" ]; then
		Print_Output true "Missing argument for startup, not starting $SCRIPT_NAME" "$WARN"
		exit 1
	elif [ "$1" != "force" ]; then
		if [ ! -f "$1/entware/bin/opkg" ]; then
			Print_Output true "$1 does not contain Entware, not starting $SCRIPT_NAME" "$WARN"
			exit 1
		else
			Print_Output true "$1 contains Entware, starting $SCRIPT_NAME" "$WARN"
		fi
	fi
	
	NTP_Ready
	
	Check_Lock
	
	if [ "$1" != "force" ]; then
		sleep 6
	fi
	
	Create_Dirs
	Conf_Exists
	ScriptStorageLocation load
	Create_Symlinks
	Auto_Startup create 2>/dev/null
	if AutomaticMode check; then Auto_Cron create 2>/dev/null; else Auto_Cron delete 2>/dev/null; fi
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_Script create
	Mount_WebUI
	
	Clear_Lock
}

Menu_EditSchedule(){
	exitmenu=""
	formattype=""
	crudays=""
	crudaysvalidated=""
	cruhours=""
	crumins=""
	
	while true; do
		printf "\\n\\e[1mPlease choose which day(s) to run ping test\\n(0-6 - 0 = Sunday, * for every day, or comma separated days):\\e[0m  "
		read -r day_choice
		
		if [ "$day_choice" = "e" ]; then
			exitmenu="exit"
			break
		elif [ "$day_choice" = "*" ]; then
			crudays="$day_choice"
			printf "\\n"
			break
		elif [ -z "$day_choice" ]; then
			printf "\\n\\e[31mPlease enter a valid number (0-6) or comma separated values\\e[0m\\n"
		else
			crudaystmp="$(echo "$day_choice" | sed "s/,/ /g")"
			crudaysvalidated="true"
			for i in $crudaystmp; do
				if echo "$i" | grep -q "-"; then
					if [ "$i" = "-" ]; then
						printf "\\n\\e[31mPlease enter a valid number (0-6)\\e[0m\\n"
						crudaysvalidated="false"
						break
					fi
					crudaystmp2="$(echo "$i" | sed "s/-/ /")"
					for i2 in $crudaystmp2; do
						if ! Validate_Number "$i2"; then
							printf "\\n\\e[31mPlease enter a valid number (0-6)\\e[0m\\n"
							crudaysvalidated="false"
							break
						elif [ "$i2" -lt 0 ] || [ "$i2" -gt 6 ]; then
							printf "\\n\\e[31mPlease enter a number between 0 and 6\\e[0m\\n"
							crudaysvalidated="false"
							break
						fi
					done
				elif ! Validate_Number "$i"; then
					printf "\\n\\e[31mPlease enter a valid number (0-6) or comma separated values\\e[0m\\n"
					crudaysvalidated="false"
					break
				else
					if [ "$i" -lt 0 ] || [ "$i" -gt 6 ]; then
						printf "\\n\\e[31mPlease enter a number between 0 and 6 or comma separated values\\e[0m\\n"
						crudaysvalidated="false"
						break
					fi
				fi
			done
			if [ "$crudaysvalidated" = "true" ]; then
				crudays="$day_choice"
				printf "\\n"
				break
			fi
		fi
	done
	
	if [ "$exitmenu" != "exit" ]; then
		while true; do
			printf "\\n\\e[1mPlease choose the format to specify the hour/minute(s)\\nto run ping test:\\e[0m\\n"
			printf "    1. Every X hours/minutes\\n"
			printf "    2. Custom\\n\\n"
			printf "Choose an option:  "
			read -r formatmenu
			
			case "$formatmenu" in
				1)
					formattype="everyx"
					printf "\\n"
					break
				;;
				2)
					formattype="custom"
					printf "\\n"
					break
				;;
				e)
					exitmenu="exit"
					break
				;;
				*)
					printf "\\n\\e[31mPlease enter a valid choice (1-2)\\e[0m\\n"
				;;
			esac
		done
	fi
	
	if [ "$exitmenu" != "exit" ]; then
		if [ "$formattype" = "everyx" ]; then
			while true; do
				printf "\\n\\e[1mPlease choose whether to specify every X hours or every X minutes\\nto run ping test:\\e[0m\\n"
				printf "    1. Hours\\n"
				printf "    2. Minutes\\n\\n"
				printf "Choose an option:  "
				read -r formatmenu
				
				case "$formatmenu" in
					1)
						formattype="hours"
						printf "\\n"
						break
					;;
					2)
						formattype="mins"
						printf "\\n"
						break
					;;
					e)
						exitmenu="exit"
						break
					;;
					*)
						printf "\\n\\e[31mPlease enter a valid choice (1-2)\\e[0m\\n"
					;;
				esac
			done
		fi
	fi
	
	if [ "$exitmenu" != "exit" ]; then
		if [ "$formattype" = "hours" ]; then
			while true; do
				printf "\\n\\e[1mPlease choose how often to run ping test\\n(every X hours, where X is 1-24):\\e[0m  "
				read -r hour_choice
				
				if [ "$hour_choice" = "e" ]; then
					exitmenu="exit"
					break
				elif ! Validate_Number "$hour_choice"; then
						printf "\\n\\e[31mPlease enter a valid number (1-24)\\e[0m\\n"
				elif [ "$hour_choice" -lt 1 ] || [ "$hour_choice" -gt 24 ]; then
					printf "\\n\\e[31mPlease enter a number between 1 and 24\\e[0m\\n"
				elif [ "$hour_choice" -eq 24 ]; then
					cruhours=0
					crumins=0
					printf "\\n"
					break
				else
					cruhours="*/$hour_choice"
					crumins=0
					printf "\\n"
					break
				fi
			done
		elif [ "$formattype" = "mins" ]; then
			while true; do
				printf "\\n\\e[1mPlease choose how often to run ping test\\n(every X minutes, where X is 1-30):\\e[0m  "
				read -r min_choice
				
				if [ "$min_choice" = "e" ]; then
					exitmenu="exit"
					break
				elif ! Validate_Number "$min_choice"; then
						printf "\\n\\e[31mPlease enter a valid number (1-30)\\e[0m\\n"
				elif [ "$min_choice" -lt 1 ] || [ "$min_choice" -gt 30 ]; then
					printf "\\n\\e[31mPlease enter a number between 1 and 30\\e[0m\\n"
				else
					crumins="*/$min_choice"
					cruhours="*"
					printf "\\n"
					break
				fi
			done
		fi
	fi
	
	if [ "$exitmenu" != "exit" ]; then
		if [ "$formattype" = "custom" ]; then
			while true; do
				printf "\\n\\e[1mPlease choose which hour(s) to run ping test\\n(0-23, * for every hour, or comma separated hours):\\e[0m  "
				read -r hour_choice
				
				if [ "$hour_choice" = "e" ]; then
					exitmenu="exit"
					break
				elif [ "$hour_choice" = "*" ]; then
					cruhours="$hour_choice"
					printf "\\n"
					break
				else
					cruhourstmp="$(echo "$hour_choice" | sed "s/,/ /g")"
					cruhoursvalidated="true"
					for i in $cruhourstmp; do
						if echo "$i" | grep -q "-"; then
							if [ "$i" = "-" ]; then
								printf "\\n\\e[31mPlease enter a valid number (0-23)\\e[0m\\n"
								cruhoursvalidated="false"
								break
							fi
							cruhourstmp2="$(echo "$i" | sed "s/-/ /")"
							for i2 in $cruhourstmp2; do
								if ! Validate_Number "$i2"; then
									printf "\\n\\e[31mPlease enter a valid number (0-23)\\e[0m\\n"
									cruhoursvalidated="false"
									break
								elif [ "$i2" -lt 0 ] || [ "$i2" -gt 23 ]; then
									printf "\\n\\e[31mPlease enter a number between 0 and 23\\e[0m\\n"
									cruhoursvalidated="false"
									break
								fi
							done
						elif echo "$i" | grep -q "/"; then
							cruhourstmp3="$(echo "$i" | sed "s/\*\///")"
							if ! Validate_Number "$cruhourstmp3"; then
								printf "\\n\\e[31mPlease enter a valid number (0-23)\\e[0m\\n"
								cruhoursvalidated="false"
								break
							elif [ "$cruhourstmp3" -lt 0 ] || [ "$cruhourstmp3" -gt 23 ]; then
								printf "\\n\\e[31mPlease enter a number between 0 and 23\\e[0m\\n"
								cruhoursvalidated="false"
								break
							fi
						elif ! Validate_Number "$i"; then
							printf "\\n\\e[31mPlease enter a valid number (0-23) or comma separated values\\e[0m\\n"
							cruhoursvalidated="false"
							break
						elif [ "$i" -lt 0 ] || [ "$i" -gt 23 ]; then
							printf "\\n\\e[31mPlease enter a number between 0 and 23 or comma separated values\\e[0m\\n"
							cruhoursvalidated="false"
							break
						fi
					done
					if [ "$cruhoursvalidated" = "true" ]; then
						if echo "$hour_choice" | grep -q "-"; then
							cruhours1="$(echo "$hour_choice" | cut -f1 -d'-')"
							cruhours2="$(echo "$hour_choice" | cut -f2 -d'-')"
							if [ "$cruhours1" -lt "$cruhours2" ]; then
								cruhours="$hour_choice"
							elif [ "$cruhours2" -lt "$cruhours1" ]; then
								cruhours="$cruhours1-23,0-$cruhours2"
							fi
						else
							cruhours="$hour_choice"
						fi
						printf "\\n"
						break
					fi
				fi
			done
		fi
	fi
	
	if [ "$exitmenu" != "exit" ]; then
		if [ "$formattype" = "custom" ]; then
			while true; do
				printf "\\n\\e[1mPlease choose which minutes(s) to run ping test\\n(0-59, * for every minute, or comma separated minutes):\\e[0m  "
				read -r min_choice
				
				if [ "$min_choice" = "e" ]; then
					exitmenu="exit"
					break
				elif [ "$min_choice" = "*" ]; then
					crumins="$min_choice"
					printf "\\n"
					break
				else
					cruminstmp="$(echo "$min_choice" | sed "s/,/ /g")"
					cruminsvalidated="true"
					for i in $cruminstmp; do
						if echo "$i" | grep -q "-"; then
							if [ "$i" = "-" ]; then
								printf "\\n\\e[31mPlease enter a valid number (0-23)\\e[0m\\n"
								cruminsvalidated="false"
								break
							fi
							cruminstmp2="$(echo "$i" | sed "s/-/ /")"
							for i2 in $cruminstmp2; do
								if ! Validate_Number "$i2"; then
									printf "\\n\\e[31mPlease enter a valid number (0-59)\\e[0m\\n"
									cruminsvalidated="false"
									break
								elif [ "$i2" -lt 0 ] || [ "$i2" -gt 59 ]; then
									printf "\\n\\e[31mPlease enter a number between 0 and 59\\e[0m\\n"
									cruminsvalidated="false"
									break
								fi
							done
						elif echo "$i" | grep -q "/"; then
							cruminstmp3="$(echo "$i" | sed "s/\*\///")"
							if ! Validate_Number "$cruminstmp3"; then
								printf "\\n\\e[31mPlease enter a valid number (0-30)\\e[0m\\n"
								cruminsvalidated="false"
								break
							elif [ "$cruminstmp3" -lt 0 ] || [ "$cruminstmp3" -gt 30 ]; then
								printf "\\n\\e[31mPlease enter a number between 0 and 30\\e[0m\\n"
								cruminsvalidated="false"
								break
							fi
						elif ! Validate_Number "$i"; then
							printf "\\n\\e[31mPlease enter a valid number (0-59) or comma separated values\\e[0m\\n"
							cruminsvalidated="false"
							break
						elif [ "$i" -lt 0 ] || [ "$i" -gt 59 ]; then
							printf "\\n\\e[31mPlease enter a number between 0 and 59 or comma separated values\\e[0m\\n"
							cruminsvalidated="false"
							break
						fi
					done
					
					if [ "$cruminsvalidated" = "true" ]; then
						if echo "$min_choice" | grep -q "-"; then
							crumins1="$(echo "$min_choice" | cut -f1 -d'-')"
							crumins2="$(echo "$min_choice" | cut -f2 -d'-')"
							if [ "$crumins1" -lt "$crumins2" ]; then
								crumins="$min_choice"
							elif [ "$crumins2" -lt "$crumins1" ]; then
								crumins="$crumins1-59,0-$crumins2"
							fi
						else
							crumins="$min_choice"
						fi
						printf "\\n"
						break
					fi
				fi
			done
		fi
	fi
	
	if [ "$exitmenu" != "exit" ]; then
		TestSchedule update "$crudays" "$cruhours" "$crumins"
		return 0
	else
		return 1
	fi
}

Menu_ResetDB(){
	printf "\\e[1m\\e[33mWARNING: This will reset the %s database by deleting all database records.\\n" "$SCRIPT_NAME"
	printf "A backup of the database will be created if you change your mind.\\e[0m\\n"
	printf "\\n\\e[1mDo you want to continue? (y/n)\\e[0m  "
	read -r confirm
	case "$confirm" in
		y|Y)
			printf "\\n"
			Reset_DB
		;;
		*)
			printf "\\n\\e[1m\\e[33mDatabase reset cancelled\\e[0m\\n\\n"
		;;
	esac
}

Menu_Uninstall(){
	Print_Output true "Removing $SCRIPT_NAME..." "$PASS"
	Auto_Startup delete 2>/dev/null
	Auto_Cron delete 2>/dev/null
	Auto_ServiceEvent delete 2>/dev/null
	Shortcut_Script delete
	
	LOCKFILE=/tmp/addonwebui.lock
	FD=386
	eval exec "$FD>$LOCKFILE"
	flock -x "$FD"
	Get_WebUI_Page "$SCRIPT_DIR/connmonstats_www.asp"
	if [ -n "$MyPage" ] && [ "$MyPage" != "none" ] && [ -f /tmp/menuTree.js ]; then
		sed -i "\\~$MyPage~d" /tmp/menuTree.js
		umount /www/require/modules/menuTree.js
		mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
		rm -rf "{$SCRIPT_WEBPAGE_DIR:?}/$MyPage"
	fi
	flock -u "$FD"
	rm -f "$SCRIPT_DIR/connmonstats_www.asp" 2>/dev/null
	
	printf "\\n\\e[1mDo you want to delete %s config and stats? (y/n)\\e[0m  " "$SCRIPT_NAME"
	read -r confirm
	case "$confirm" in
		y|Y)
			rm -rf "$SCRIPT_DIR" 2>/dev/null
			rm -rf "$SCRIPT_STORAGE_DIR" 2>/dev/null
		;;
		*)
			:
		;;
	esac
	
	SETTINGSFILE="/jffs/addons/custom_settings.txt"
	sed -i '/connmon_version_local/d' "$SETTINGSFILE"
	sed -i '/connmon_version_server/d' "$SETTINGSFILE"
	
	rm -rf "$SCRIPT_WEB_DIR" 2>/dev/null
	rm -f "/jffs/scripts/$SCRIPT_NAME" 2>/dev/null
	Clear_Lock
	Print_Output true "Uninstall completed" "$PASS"
}

NTP_Ready(){
	if [ "$(nvram get ntp_ready)" -eq 0 ]; then
		ntpwaitcount=0
		Check_Lock
		while [ "$(nvram get ntp_ready)" -eq 0 ] && [ "$ntpwaitcount" -lt 600 ]; do
			ntpwaitcount="$((ntpwaitcount + 30))"
			Print_Output true "Waiting for NTP to sync..." "$WARN"
			sleep 30
		done
		if [ "$ntpwaitcount" -ge 600 ]; then
			Print_Output true "NTP failed to sync after 10 minutes. Please resolve!" "$CRIT"
			Clear_Lock
			exit 1
		else
			Print_Output true "NTP synced, $SCRIPT_NAME will now continue" "$PASS"
			Clear_Lock
		fi
	fi
}

### function based on @Adamm00's Skynet USB wait function ###
Entware_Ready(){
	if [ ! -f /opt/bin/opkg ]; then
		Check_Lock
		sleepcount=1
		while [ ! -f /opt/bin/opkg ] && [ "$sleepcount" -le 10 ]; do
			Print_Output true "Entware not found, sleeping for 10s (attempt $sleepcount of 10)" "$ERR"
			sleepcount="$((sleepcount + 1))"
			sleep 10
		done
		if [ ! -f /opt/bin/opkg ]; then
			Print_Output true "Entware not found and is required for $SCRIPT_NAME to run, please resolve" "$CRIT"
			Clear_Lock
			exit 1
		else
			Print_Output true "Entware found, $SCRIPT_NAME will now continue" "$PASS"
			Clear_Lock
		fi
	fi
}
### ###

### function based on @dave14305's FlexQoS about function ###
Show_About(){
	cat <<EOF
About
  $SCRIPT_NAME is an internet connection monitoring tool for
  AsusWRT Merlin with charts for daily, weekly and monthly
  summaries.

License
  $SCRIPT_NAME is free to use under the GNU General Public License
  version 3 (GPL-3.0) https://opensource.org/licenses/GPL-3.0

Help & Support
  https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=18

Source code
  https://github.com/jackyaz/$SCRIPT_NAME
EOF
	printf "\\n"
}
### ###

### function based on @dave14305's FlexQoS show_help function ###
Show_Help(){
	cat <<EOF
Available commands:
  $SCRIPT_NAME about              explains functionality
  $SCRIPT_NAME update             checks for updates
  $SCRIPT_NAME forceupdate        updates to latest version (force update)
  $SCRIPT_NAME startup force      runs startup actions such as mount WebUI tab
  $SCRIPT_NAME install            installs script
  $SCRIPT_NAME uninstall          uninstalls script
  $SCRIPT_NAME generate           run ping test and save to database. also runs outputcsv
  $SCRIPT_NAME outputcsv          create CSVs from database, used by WebUI and export
  $SCRIPT_NAME enable             enable automatic ping tests
  $SCRIPT_NAME disable            disable automatic ping tests
  $SCRIPT_NAME develop            switch to development branch
  $SCRIPT_NAME stable             switch to stable branch
EOF
	printf "\\n"
}
### ###

if [ -f "/opt/share/$SCRIPT_NAME.d/config" ]; then
	SCRIPT_CONF="/opt/share/$SCRIPT_NAME.d/config"
	SCRIPT_STORAGE_DIR="/opt/share/$SCRIPT_NAME.d"
else
	SCRIPT_CONF="/jffs/addons/$SCRIPT_NAME.d/config"
	SCRIPT_STORAGE_DIR="/jffs/addons/$SCRIPT_NAME.d"
fi

CSV_OUTPUT_DIR="$SCRIPT_STORAGE_DIR/csv"

if [ -z "$1" ]; then
	NTP_Ready
	Entware_Ready
	if [ ! -f /opt/bin/sqlite3 ]; then
		Print_Output true "Installing required version of sqlite3 from Entware" "$PASS"
		opkg update
		opkg install sqlite3-cli
	fi
	Create_Dirs
	Conf_Exists
	ScriptStorageLocation load
	Create_Symlinks
	Auto_Startup create 2>/dev/null
	if AutomaticMode check; then Auto_Cron create 2>/dev/null; else Auto_Cron delete 2>/dev/null; fi
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_Script create
	Process_Upgrade
	ScriptHeader
	MainMenu
	exit 0
fi

case "$1" in
	install)
		Check_Lock
		Menu_Install
		exit 0
	;;
	startup)
		Menu_Startup "$2"
		exit 0
	;;
	generate)
		NTP_Ready
		Entware_Ready
		Check_Lock
		Run_PingTest
		Clear_Lock
		exit 0
	;;
	outputcsv)
		NTP_Ready
		Entware_Ready
		Check_Lock
		Generate_CSVs
		Clear_Lock
		exit 0
	;;
	enable)
		Entware_Ready
		AutomaticMode enable
		exit 0
	;;
	disable)
		Entware_Ready
		AutomaticMode disable
		exit 0
	;;
	service_event)
		if [ "$2" = "start" ] && [ "$3" = "$SCRIPT_NAME" ]; then
			rm -f /tmp/detect_connmon.js
			Check_Lock webui
			Run_PingTest
			Clear_Lock
			exit 0
		elif [ "$2" = "start" ] && [ "$3" = "${SCRIPT_NAME}config" ]; then
			Conf_FromSettings
			exit 0
		elif [ "$2" = "start" ] && [ "$3" = "${SCRIPT_NAME}checkupdate" ]; then
			Update_Check
			exit 0
		elif [ "$2" = "start" ] && [ "$3" = "${SCRIPT_NAME}doupdate" ]; then
			Update_Version force unattended
			exit 0
		fi
		exit 0
	;;
	update)
		Update_Version
		exit 0
	;;
	forceupdate)
		Update_Version force
		exit 0
	;;
	postupdate)
		Create_Dirs
		Conf_Exists
		ScriptStorageLocation load
		Create_Symlinks
		Auto_Startup create 2>/dev/null
		if AutomaticMode check; then Auto_Cron create 2>/dev/null; else Auto_Cron delete 2>/dev/null; fi
		Auto_ServiceEvent create 2>/dev/null
		Shortcut_Script create
		Process_Upgrade
		exit 0
	;;
	uninstall)
		Check_Lock
		Menu_Uninstall
		exit 0
	;;
	develop)
		SCRIPT_BRANCH="develop"
		SCRIPT_REPO="https://raw.githubusercontent.com/jackyaz/$SCRIPT_NAME/$SCRIPT_BRANCH"
		Update_Version force
		exit 0
	;;
	stable)
		SCRIPT_BRANCH="master"
		SCRIPT_REPO="https://raw.githubusercontent.com/jackyaz/$SCRIPT_NAME/$SCRIPT_BRANCH"
		Update_Version force
		exit 0
	;;
	about)
		ScriptHeader
		Show_About
		exit 0
	;;
	help)
		ScriptHeader
		Show_Help
		exit 0
	;;
	*)
		ScriptHeader
		Print_Output false "Command not recognised." "$ERR"
		Print_Output false "For a list of available commands run: $SCRIPT_NAME help"
		exit 1
	;;
esac
