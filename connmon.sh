#!/bin/sh

############################################################
##                                                        ##
##   ___   ___   _ __   _ __   _ __ ___    ___   _ __     ##
##  / __| / _ \ | '_ \ | '_ \ | '_ ` _ \  / _ \ | '_ \    ##
## | (__ | (_) || | | || | | || | | | | || (_) || | | |   ##
##  \___| \___/ |_| |_||_| |_||_| |_| |_| \___/ |_| |_|   ##
##                                                        ##
##          https://github.com/jackyaz/connmon            ##
##                                                        ##
############################################################

### Start of script variables ###
readonly SCRIPT_NAME="connmon"
readonly SCRIPT_VERSION="v2.8.6"
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
### End of output format variables ###

# $1 = print to syslog, $2 = message to print, $3 = log level
Print_Output(){
	if [ "$1" = "true" ]; then
		logger -t "$SCRIPT_NAME" "$2"
		printf "\\e[1m${3}%s: ${2}\\e[0m\\n\\n" "$SCRIPT_NAME"
	else
		printf "\\e[1m${3}${2}\\e[0m\\n\\n"
	fi
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
					if [ "$SCRIPT_VERSION" != "$(grep "connmon_version_local" /jffs/addons/custom_settings.txt | cut -f2 -d' ')" ]; then
						sed -i "s/connmon_version_local.*/connmon_version_local $SCRIPT_VERSION/" "$SETTINGSFILE"
					fi
				else
					echo "connmon_version_local $SCRIPT_VERSION" >> "$SETTINGSFILE"
				fi
			else
				echo "connmon_version_local $SCRIPT_VERSION" >> "$SETTINGSFILE"
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
	if [ -z "$1" ] || [ "$1" = "unattended" ]; then
		updatecheckresult="$(Update_Check)"
		isupdate="$(echo "$updatecheckresult" | cut -f1 -d',')"
		localver="$(echo "$updatecheckresult" | cut -f2 -d',')"
		serverver="$(echo "$updatecheckresult" | cut -f3 -d',')"
		
		if [ "$isupdate" = "version" ]; then
			Print_Output true "New version of $SCRIPT_NAME available - updating to $serverver" "$PASS"
		elif [ "$isupdate" = "md5" ]; then
			Print_Output true "MD5 hash of $SCRIPT_NAME does not match - downloading updated $serverver" "$PASS"
		fi
		
		Update_File shared-jy.tar.gz
		
		if [ "$isupdate" != "false" ]; then
			Update_File connmonstats_www.asp
			
			/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" -o "/jffs/scripts/$SCRIPT_NAME" && Print_Output true "$SCRIPT_NAME successfully updated"
			chmod 0755 /jffs/scripts/"$SCRIPT_NAME"
			Clear_Lock
			if [ -z "$1" ]; then
				exec "$0" setversion
			elif [ "$1" = "unattended" ]; then
				exec "$0" setversion unattended
			fi
			exit 0
		else
			Print_Output true "No new version - latest is $localver" "$WARN"
			Clear_Lock
		fi
	fi
	
	if [ "$1" = "force" ]; then
		serverver=$(/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" | grep "SCRIPT_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
		Print_Output true "Downloading latest version ($serverver) of $SCRIPT_NAME" "$PASS"
		Update_File connmonstats_www.asp
		Update_File shared-jy.tar.gz
		/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" -o "/jffs/scripts/$SCRIPT_NAME" && Print_Output true "$SCRIPT_NAME successfully updated"
		chmod 0755 /jffs/scripts/"$SCRIPT_NAME"
		Clear_Lock
		if [ -z "$2" ]; then
			exec "$0" setversion
		elif [ "$2" = "unattended" ]; then
			exec "$0" setversion unattended
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
	if [ "$2" -eq "$2" ] 2>/dev/null; then
		return 0
	else
		formatted="$(echo "$1" | sed -e 's/|/ /g')"
		if [ -z "$3" ]; then
			Print_Output false "$formatted - $2 is not a number" "$ERR"
		fi
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
				sed -i "s/$SETTINGNAME=.*/$SETTINGNAME=$SETTINGVALUE/" "$SCRIPT_CONF"
			done < "$TMPFILE"
			grep 'connmon_version' "$SETTINGSFILE" > "$TMPFILE"
			sed -i "\\~connmon_~d" "$SETTINGSFILE"
			mv "$SETTINGSFILE" "$SETTINGSFILE.bak"
			cat "$SETTINGSFILE.bak" "$TMPFILE" > "$SETTINGSFILE"
			rm -f "$TMPFILE"
			rm -f "$SETTINGSFILE.bak"
			
			ScriptStorageLocation "$(ScriptStorageLocation check)"
			Create_Symlinks
			
			Auto_Cron create
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
	ln -s "$SCRIPT_STORAGE_DIR/connjs.js" "$SCRIPT_WEB_DIR/connjs.js" 2>/dev/null
	
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
		if [ "$(wc -l < "$SCRIPT_CONF")" -eq 1 ]; then
			echo "OUTPUTDATAMODE=raw" >> "$SCRIPT_CONF"
		fi
		if [ "$(wc -l < "$SCRIPT_CONF")" -eq 2 ]; then
			echo "OUTPUTTIMEMODE=unix" >> "$SCRIPT_CONF"
		fi
		if [ "$(wc -l < "$SCRIPT_CONF")" -eq 3 ]; then
			echo "STORAGELOCATION=jffs" >> "$SCRIPT_CONF"
		fi
		if [ "$(wc -l < "$SCRIPT_CONF")" -eq 4 ]; then
			{ echo "PINGDURATION=60"; echo "PINGFREQUENCY=3"; } >> "$SCRIPT_CONF"
		fi
		if [ "$(wc -l < "$SCRIPT_CONF")" -eq 6 ]; then
			{ echo "SCHEDULESTART=0"; echo "SCHEDULEEND=23"; } >> "$SCRIPT_CONF"
		fi
		return 0
	else
		{ echo "PINGSERVER=8.8.8.8"; echo "OUTPUTDATAMODE=raw"; echo "OUTPUTTIMEMODE=unix"; echo "STORAGELOCATION=jffs"; echo "PINGDURATION=60"; echo "PINGFREQUENCY=3"; echo "SCHEDULESTART=0"; echo "SCHEDULEEND=23"; } > "$SCRIPT_CONF"
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
				printf "\\n\\e[1mChoose an option:\\e[0m    "
				read -r pingoption
				case "$pingoption" in
					1)
						while true; do
							printf "\\n\\e[1mPlease enter an IP address, or enter e to go back:\\e[0m    "
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
							printf "\\n\\e[1mPlease enter a domain name, or enter e to go back:\\e[0m    "
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

PingFrequency(){
	case "$1" in
		update)
			pingfreq=0
			exitmenu=""
			ScriptHeader
			while true; do
				printf "\\n\\e[1mPlease enter the desired test frequency (every 1-30 minutes):\\e[0m    "
				read -r pingfreq_choice
				
				if [ "$pingfreq_choice" = "e" ]; then
					exitmenu="exit"
					break
				elif ! Validate_Number "" "$pingfreq_choice" silent; then
					printf "\\n\\e[31mPlease enter a valid number (1-30)\\e[0m\\n"
				else
					if [ "$pingfreq_choice" -lt 1 ] || [ "$pingfreq_choice" -gt 30 ]; then
						printf "\\n\\e[31mPlease enter a number between 1 and 30\\e[0m\\n"
					else
						pingfreq="$pingfreq_choice"
						printf "\\n"
						break
					fi
				fi
			done
			
			if [ "$exitmenu" != "exit" ]; then
				sed -i 's/^PINGFREQUENCY.*$/PINGFREQUENCY='"$pingfreq"'/' "$SCRIPT_CONF"
				Auto_Cron create
				return 0
			else
				printf "\\n"
				return 1
			fi
		;;
		check)
			PINGFREQUENCY=$(grep "PINGFREQUENCY" "$SCRIPT_CONF" | cut -f2 -d"=")
			echo "$PINGFREQUENCY"
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
				printf "\\n\\e[1mPlease enter the desired test duration (10-60 seconds):\\e[0m    "
				read -r pingdur_choice
				
				if [ "$pingdur_choice" = "e" ]; then
					exitmenu="exit"
					break
				elif ! Validate_Number "" "$pingdur_choice" silent; then
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
			pingfrequency="$(PingFrequency check)"
			
			# shellcheck disable=SC2063
			STARTUPLINECOUNTEX=$(cru l | grep "$SCRIPT_NAME" | grep -c "*/$pingfrequency")
			if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
				SCHEDULESTART=$(grep "SCHEDULESTART" "$SCRIPT_CONF" | cut -f2 -d"=")
				SCHEDULEEND=$(grep "SCHEDULEEND" "$SCRIPT_CONF" | cut -f2 -d"=")
				
				if [ "$SCHEDULESTART" -lt "$SCHEDULEEND" ]; then
					cru a "$SCRIPT_NAME" "*/$pingfrequency $SCHEDULESTART-$SCHEDULEEND * * * /jffs/scripts/$SCRIPT_NAME generate"
				else
					cru a "$SCRIPT_NAME" "*/$pingfrequency $SCHEDULESTART-23,0-$SCHEDULEEND * * * /jffs/scripts/$SCRIPT_NAME generate"
				fi
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

### locking mechanism code credit to Martineau (@MartineauUK) ###
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
		echo "${urlproto}://${urldomain}${urlport}/${urlpage}"
	else
		echo "Not found"
	fi
}
### ###

Mount_WebUI(){
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
	echo "connmon" > "$SCRIPT_WEBPAGE_DIR/$(echo $MyPage | cut -f1 -d'.').title"
	
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
			sed -i "$lineinsbefore"'i,\n{\nmenuName: "Addons",\nindex: "menu_Addons",\ntab: [\n{url: "ext/shared-jy/redirect.htm", tabName: "Help & Support"},\n{url: "NULL", tabName: "__INHERIT__"}\n]\n}' /tmp/menuTree.js
		fi
		
		if ! grep -q "javascript:window.open('/ext/shared-jy/redirect.htm'" /tmp/menuTree.js ; then
			sed -i "s~ext/shared-jy/redirect.htm~javascript:window.open('/ext/shared-jy/redirect.htm','_blank')~" /tmp/menuTree.js
		fi
		sed -i "/url: \"javascript:window.open('\/ext\/shared-jy\/redirect.htm'/i {url: \"$MyPage\", tabName: \"connmon\"}," /tmp/menuTree.js
		
		umount /www/require/modules/menuTree.js 2>/dev/null
		mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
	fi
	flock -u "$FD"
	Print_Output true "Mounted $SCRIPT_NAME WebUI page as $MyPage" "$PASS"
}

TestSchedule(){
	case "$1" in
		update)
			sed -i 's/^'"SCHEDULESTART"'.*$/SCHEDULESTART='"$2"'/' "$SCRIPT_CONF"
			sed -i 's/^'"SCHEDULEEND"'.*$/SCHEDULEEND='"$3"'/' "$SCRIPT_CONF"
			Auto_Cron delete 2>/dev/null
			Auto_Cron create 2>/dev/null
		;;
		check)
			SCHEDULESTART=$(grep "SCHEDULESTART" "$SCRIPT_CONF" | cut -f2 -d"=")
			SCHEDULEEND=$(grep "SCHEDULEEND" "$SCRIPT_CONF" | cut -f2 -d"=")
			echo "$SCHEDULESTART,$SCHEDULEEND"
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
			mv "/jffs/addons/$SCRIPT_NAME.d/connjs.js" "/opt/share/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/jffs/addons/$SCRIPT_NAME.d/connstats.db" "/opt/share/$SCRIPT_NAME.d/" 2>/dev/null
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
			mv "/opt/share/$SCRIPT_NAME.d/connjs.js" "/jffs/addons/$SCRIPT_NAME.d/" 2>/dev/null
			mv "/opt/share/$SCRIPT_NAME.d/connstats.db" "/jffs/addons/$SCRIPT_NAME.d/" 2>/dev/null
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

OutputDataMode(){
	case "$1" in
		raw)
			sed -i 's/^OUTPUTDATAMODE.*$/OUTPUTDATAMODE=raw/' "$SCRIPT_CONF"
			Generate_CSVs
		;;
		average)
			sed -i 's/^OUTPUTDATAMODE.*$/OUTPUTDATAMODE=average/' "$SCRIPT_CONF"
			Generate_CSVs
		;;
		check)
			OUTPUTDATAMODE=$(grep "OUTPUTDATAMODE" "$SCRIPT_CONF" | cut -f2 -d"=")
			echo "$OUTPUTDATAMODE"
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
	multiplier="$(echo "$3" | awk '{printf (60*60*$1)}')"
	
	{
		echo ".mode csv"
		echo ".headers on"
		echo ".output ${5}${6}.htm"
	} >> "$7"
	
	echo "SELECT '$1' Metric, Min([Timestamp]) Time, IFNULL(Avg([$1]),'NaN') Value FROM $2 WHERE ([Timestamp] >= $timenow - ($multiplier*$maxcount)) GROUP BY ([Timestamp]/($multiplier));" >> "$7"
}

Generate_LastXResults(){
	{
		echo ".mode csv"
		echo ".output /tmp/conn-lastx.csv"
	} > /tmp/conn-lastx.sql
	echo "SELECT [Timestamp],[Ping],[Jitter],[LineQuality] FROM connstats ORDER BY [Timestamp] DESC LIMIT 10;" >> /tmp/conn-lastx.sql
	"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/conn-lastx.sql
	sed -i 's/,,/,null,/g;s/,/ /g;s/"//g;' /tmp/conn-lastx.csv
	rm -f "$SCRIPT_STORAGE_DIR/connjs.js"
	WritePlainData_ToJS /tmp/conn-lastx.csv "$SCRIPT_STORAGE_DIR/connjs.js" DataTimestamp DataPing DataJitter DataLineQuality
	rm -f /tmp/conn-lastx.sql
	rm -f /tmp/conn-lastx.csv
}

Run_PingTest(){
	Create_Dirs
	Conf_Exists
	Set_Version_Custom_Settings local
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
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
	
	iptables -I OUTPUT -p icmp -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
	iptables -t mangle -I OUTPUT -p icmp -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
	iptables -t mangle -I POSTROUTING -p icmp -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
	ping -w "$(PingDuration check)" "$(PingServer check)" > "$pingfile"
	iptables -D OUTPUT -p icmp -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
	iptables -t mangle -D OUTPUT -p icmp -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
	iptables -t mangle -D POSTROUTING -p icmp -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
	
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
	
	{
	echo "CREATE TABLE IF NOT EXISTS [connstats] ([StatID] INTEGER PRIMARY KEY NOT NULL, [Timestamp] NUMERIC NOT NULL, [Ping] REAL NOT NULL,[Jitter] REAL NOT NULL,[LineQuality] REAL NOT NULL);"
	echo "INSERT INTO connstats ([Timestamp],[Ping],[Jitter],[LineQuality]) values($timenow,$ping,$jitter,$linequal);"
	} > /tmp/connmon-stats.sql
	"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
	
	echo "DELETE FROM [connstats] WHERE [Timestamp] < ($timenow - (86400*30));" > /tmp/connmon-stats.sql
	"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
	rm -f /tmp/connmon-stats.sql
	
	Generate_CSVs
	
	echo "Stats last updated: $timenowfriendly" > "/tmp/connstatstitle.txt"
	WriteStats_ToJS /tmp/connstatstitle.txt "$SCRIPT_STORAGE_DIR/connstatstext.js" SetConnmonStatsTitle statstitle
	echo 'var connmonstatus = "Done";' > /tmp/detect_connmon.js
	Print_Output false "Test results - Ping $ping ms - Jitter - $jitter ms - Line Quality $linequal %%" "$PASS"
	
	{
		printf "Ping test result\\n"
		printf "\\nPing %s ms - Jitter - %s ms - Line Quality %s %%\\n" "$ping" "$jitter" "$linequal"
	} >> "$resultfile"
	
	rm -f "$pingfile"
	rm -f /tmp/connstatstitle.txt
}

Process_Upgrade(){
	if [ ! -f "$SCRIPT_STORAGE_DIR/.tableupgraded" ]; then
		{
			echo "ALTER TABLE connstats RENAME COLUMN [Packet_Loss] TO [LineQuality];"
		} > /tmp/conn-stats.sql
		"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/conn-stats.sql >/dev/null 2>&1
		touch "$SCRIPT_STORAGE_DIR/.tableupgraded"
	fi
	rm -f /tmp/conn-stats.sql
}

Generate_CSVs(){
	OUTPUTDATAMODE="$(OutputDataMode check)"
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
			echo ".output $CSV_OUTPUT_DIR/${metric}daily.htm"
			echo "SELECT '$metric' Metric,[Timestamp] Time,[$metric] Value FROM connstats WHERE [Timestamp] >= ($timenow - 86400);"
		} > /tmp/connmon-stats.sql
		"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
		rm -f /tmp/connmon-stats.sql
		
		if [ "$OUTPUTDATAMODE" = "raw" ]; then
			{
				echo ".mode csv"
				echo ".headers on"
				echo ".output $CSV_OUTPUT_DIR/${metric}weekly.htm"
				echo "SELECT '$metric' Metric,[Timestamp] Time,[$metric] Value FROM connstats WHERE [Timestamp] >= ($timenow - 86400*7);"
			} > /tmp/connmon-stats.sql
			"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
			rm -f /tmp/connmon-stats.sql
			
			{
				echo ".mode csv"
				echo ".headers on"
				echo ".output $CSV_OUTPUT_DIR/${metric}monthly.htm"
				echo "SELECT '$metric' Metric,[Timestamp] Time,[$metric] Value FROM connstats WHERE [Timestamp] >= ($timenow - 86400*30);"
			} > /tmp/connmon-stats.sql
			"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
			rm -f /tmp/connmon-stats.sql
		elif [ "$OUTPUTDATAMODE" = "average" ]; then
			WriteSql_ToFile "$metric" connstats 1 7 "$CSV_OUTPUT_DIR/$metric" weekly /tmp/connmon-stats.sql "$timenow"
			"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
			rm -f /tmp/connmon-stats.sql
			
			WriteSql_ToFile "$metric" connstats 3 30 "$CSV_OUTPUT_DIR/$metric" monthly /tmp/connmon-stats.sql "$timenow"
			"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/connstats.db" < /tmp/connmon-stats.sql
			rm -f /tmp/connmon-stats.sql
		fi
	done
	
	rm -f /tmp/connmon-stats.sql
	Generate_LastXResults
	
	{
		echo ".mode csv"
		echo ".headers on"
		echo ".output $CSV_OUTPUT_DIR/CompleteResults.htm"
	} > /tmp/connmon-complete.sql
	echo "SELECT [Timestamp],[Ping],[Jitter],[LineQuality] FROM connstats WHERE [Timestamp] >= ($timenow - 86400*30) ORDER BY [Timestamp] DESC;" >> /tmp/connmon-complete.sql
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
	printf "\\e[1m############################################################\\e[0m\\n"
	printf "\\e[1m##   ___   ___   _ __   _ __   _ __ ___    ___   _ __     ##\\e[0m\\n"
	printf "\\e[1m##  / __| / _ \ | '_ \ | '_ \ | '_   _ \  / _ \ | '_ \    ##\\e[0m\\n"
	printf "\\e[1m## | (__ | (_) || | | || | | || | | | | || (_) || | | |   ##\\e[0m\\n"
	printf "\\e[1m##  \___| \___/ |_| |_||_| |_||_| |_| |_| \___/ |_| |_|   ##\\e[0m\\n"
	printf "\\e[1m##                                                        ##\\e[0m\\n"
	printf "\\e[1m##                  %s on %-9s                   ##\\e[0m\\n" "$SCRIPT_VERSION" "$ROUTER_MODEL"
	printf "\\e[1m##                                                        ##\\e[0m\\n"
	printf "\\e[1m##          https://github.com/jackyaz/connmon            ##\\e[0m\\n"
	printf "\\e[1m##                                                        ##\\e[0m\\n"
	printf "\\e[1m############################################################\\e[0m\\n"
	printf "\\n"
}

MainMenu(){
	TEST_SCHEDULE="$(TestSchedule check)"
	TEST_SCHEDULE_MENU="Start: $(echo "$TEST_SCHEDULE" | cut -f1 -d',')    -    End: $(echo "$TEST_SCHEDULE" | cut -f2 -d',')"
	printf "1.    Check connection now\\n\\n"
	printf "2.    Set preferred ping server\\n      Currently: %s\\n\\n" "$(PingServer check)"
	printf "3.    Set ping test duration\\n      Currently: %ss\\n\\n" "$(PingDuration check)"
	printf "4.    Set ping test frequency\\n      Currently: Every %s minutes\\n\\n" "$(PingFrequency check)"
	printf "5.    Set time range for ping tests\\n      %s\\n\\n" "$TEST_SCHEDULE_MENU"
	printf "6.    Toggle data output mode\\n      Currently \\e[1m%s\\e[0m values will be used for weekly and monthly charts\\n\\n" "$(OutputDataMode check)"
	printf "7.    Toggle time output mode\\n      Currently \\e[1m%s\\e[0m time values will be used for CSV exports\\n\\n" "$(OutputTimeMode check)"
	printf "s.    Toggle storage location for stats and config\\n      Current location is \\e[1m%s\\e[0m \\n\\n" "$(ScriptStorageLocation check)"
	printf "u.    Check for updates\\n"
	printf "uf.   Update %s with latest version (force update)\\n\\n" "$SCRIPT_NAME"
	printf "r.    Reset %s database / delete all data\\n\\n" "$SCRIPT_NAME"
	printf "e.    Exit %s\\n\\n" "$SCRIPT_NAME"
	printf "z.    Uninstall %s\\n" "$SCRIPT_NAME"
	printf "\\n"
	printf "\\e[1m############################################################\\e[0m\\n"
	printf "\\n"
	
	while true; do
		printf "Choose an option:    "
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
				PingFrequency update
				PressEnter
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
				if [ "$(OutputDataMode check)" = "raw" ]; then
					OutputDataMode average
				elif [ "$(OutputDataMode check)" = "average" ]; then
					OutputDataMode raw
				fi
				break
			;;
			7)
				printf "\\n"
				if [ "$(OutputTimeMode check)" = "unix" ]; then
					OutputTimeMode non-unix
				elif [ "$(OutputTimeMode check)" = "non-unix" ]; then
					OutputTimeMode unix
				fi
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
					printf "\\n\\e[1mAre you sure you want to uninstall %s? (y/n)\\e[0m\\n" "$SCRIPT_NAME"
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
	Set_Version_Custom_Settings local
	ScriptStorageLocation load
	Create_Symlinks
	
	Update_File connmonstats_www.asp
	Update_File shared-jy.tar.gz
	
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
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
	Set_Version_Custom_Settings local
	ScriptStorageLocation load
	Create_Symlinks
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_Script create
	Mount_WebUI
	
	Clear_Lock
}

Menu_EditSchedule(){
	exitmenu="false"
	starthour=""
	endhour=""
	ScriptHeader
	
	while true; do
		printf "\\n\\e[1mPlease enter a start hour (0-23):\\e[0m\\n"
		read -r hour
		
		if [ "$hour" = "e" ]; then
			exitmenu="exit"
			break
		elif ! Validate_Number "" "$hour" silent; then
			printf "\\n\\e[31mPlease enter a valid number (0-23)\\e[0m\\n"
		else
			if [ "$hour" -lt 0 ] || [ "$hour" -gt 23 ]; then
				printf "\\n\\e[31mPlease enter a number between 0 and 23\\e[0m\\n"
			else
				starthour="$hour"
				printf "\\n"
				break
			fi
		fi
	done
	
	if [ "$exitmenu" != "exit" ]; then
		while true; do
			printf "\\n\\e[1mPlease enter an end hour (0-23):\\e[0m\\n"
			read -r hour
			
			if [ "$hour" = "e" ]; then
				exitmenu="exit"
				break
			elif ! Validate_Number "" "$hour" silent; then
				printf "\\n\\e[31mPlease enter a valid number (0-23)\\e[0m\\n"
			else
				if [ "$hour" -lt 0 ] || [ "$hour" -gt 23 ]; then
					printf "\\n\\e[31mPlease enter a number between 0 and 23\\e[0m\\n"
				else
					endhour="$hour"
					printf "\\n"
					break
				fi
			fi
		done
	fi
	
	if [ "$exitmenu" != "exit" ]; then
		TestSchedule update "$starthour" "$endhour"
	fi
}

Menu_ResetDB(){
	printf "\\e[1m\\e[33mWARNING: This will reset the %s database by deleting all database records.\\n" "$SCRIPT_NAME"
	printf "A backup of the database will be created if you change your mind.\\e[0m\\n"
	printf "\\n\\e[1mDo you want to continue? (y/n)\\e[0m\\n"
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
	
	Clear_Lock
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
	
	printf "\\n\\e[1mDo you want to delete %s config and stats? (y/n)\\e[0m\\n" "$SCRIPT_NAME"
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
	
	SETTINGSFILE=/jffs/addons/custom_settings.txt
	sed -i '/connmon_version_local/d' "$SETTINGSFILE"
	sed -i '/connmon_version_server/d' "$SETTINGSFILE"
	
	rm -rf "$SCRIPT_WEB_DIR" 2>/dev/null
	rm -f "/jffs/scripts/$SCRIPT_NAME" 2>/dev/null
	Clear_Lock
	Print_Output true "Uninstall completed" "$PASS"
}

NTP_Ready(){
	if [ "$(nvram get ntp_ready)" -eq 0 ]; then
		ntpwaitcount="0"
		Check_Lock
		while [ "$(nvram get ntp_ready)" -eq 0 ] && [ "$ntpwaitcount" -lt 300 ]; do
			ntpwaitcount="$((ntpwaitcount + 1))"
			if [ "$ntpwaitcount" -eq 60 ]; then
				Print_Output true "Waiting for NTP to sync..." "$WARN"
			fi
			sleep 1
		done
		if [ "$ntpwaitcount" -ge 300 ]; then
			Print_Output true "NTP failed to sync after 5 minutes. Please resolve!" "$CRIT"
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
	Set_Version_Custom_Settings local
	ScriptStorageLocation load
	Create_Symlinks
	Process_Upgrade
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_Script create
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
	service_event)
		if [ "$2" = "start" ] && [ "$3" = "$SCRIPT_NAME" ]; then
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
		Update_Version unattended
		exit 0
	;;
	forceupdate)
		Update_Version force unattended
		exit 0
	;;
	setversion)
		Set_Version_Custom_Settings local
		Set_Version_Custom_Settings server "$SCRIPT_VERSION"
		if [ -z "$2" ]; then
			exec "$0"
		else
			Create_Dirs
			Conf_Exists
			ScriptStorageLocation load
			Create_Symlinks
			Process_Upgrade
			Auto_Startup create 2>/dev/null
			Auto_Cron create 2>/dev/null
			Auto_ServiceEvent create 2>/dev/null
			Shortcut_Script create
		fi
		exit 0
	;;
	checkupdate)
		Update_Check
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
	*)
		echo "Command not recognised, please try again"
		exit 1
	;;
esac
