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
readonly SCRIPT_VERSION="v2.1.0"
readonly CONNMON_VERSION="v2.1.0"
readonly SCRIPT_BRANCH="master"
readonly SCRIPT_REPO="https://raw.githubusercontent.com/jackyaz/""$SCRIPT_NAME""/""$SCRIPT_BRANCH"
readonly SCRIPT_CONF="/jffs/configs/$SCRIPT_NAME.config"
readonly SCRIPT_DIR="/jffs/scripts/$SCRIPT_NAME.d"
readonly SCRIPT_WEB_DIR="$(readlink /www/ext)/$SCRIPT_NAME"
readonly SHARED_DIR="/jffs/scripts/shared-jy"
readonly SHARED_REPO="https://raw.githubusercontent.com/jackyaz/shared-jy/master"
readonly SHARED_WEB_DIR="$(readlink /www/ext)/shared-jy"
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
		printf "\\e[1m$3%s: $2\\e[0m\\n\\n" "$SCRIPT_NAME"
	else
		printf "\\e[1m$3%s: $2\\e[0m\\n\\n" "$SCRIPT_NAME"
	fi
}

### Code for this function courtesy of https://github.com/decoderman- credit to @thelonelycoder ###
Firmware_Version_Check(){
	echo "$1" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'
}
############################################################################

### Code for these functions inspired by https://github.com/Adamm00 - credit to @Adamm ###
Check_Lock(){
	if [ -f "/tmp/$SCRIPT_NAME.lock" ]; then
		ageoflock=$(($(date +%s) - $(date +%s -r /tmp/$SCRIPT_NAME.lock)))
		if [ "$ageoflock" -gt 60 ]; then
			Print_Output "true" "Stale lock file found (>60 seconds old) - purging lock" "$ERR"
			kill "$(sed -n '1p' /tmp/$SCRIPT_NAME.lock)" >/dev/null 2>&1
			Clear_Lock
			echo "$$" > "/tmp/$SCRIPT_NAME.lock"
			return 0
		else
			Print_Output "true" "Lock file found (age: $ageoflock seconds) - ping test likely currently running" "$ERR"
			if [ -z "$1" ]; then
				exit 1
			else
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

Update_Version(){
	if [ -z "$1" ]; then
		doupdate="false"
		localver=$(grep "SCRIPT_VERSION=" /jffs/scripts/"$SCRIPT_NAME" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
		/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" | grep -qF "jackyaz" || { Print_Output "true" "404 error detected - stopping update" "$ERR"; return 1; }
		serverver=$(/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" | grep "SCRIPT_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
		if [ "$localver" != "$serverver" ]; then
			doupdate="version"
		else
			localmd5="$(md5sum "/jffs/scripts/$SCRIPT_NAME" | awk '{print $1}')"
			remotemd5="$(curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" | md5sum | awk '{print $1}')"
			if [ "$localmd5" != "$remotemd5" ]; then
				doupdate="md5"
			fi
		fi
		
		if [ "$doupdate" = "version" ]; then
			Print_Output "true" "New version of $SCRIPT_NAME available - updating to $serverver" "$PASS"
		elif [ "$doupdate" = "md5" ]; then
			Print_Output "true" "MD5 hash of $SCRIPT_NAME does not match - downloading updated $serverver" "$PASS"
		fi
		
		Update_File "connmonstats_www.asp"
		Update_File "chartjs-plugin-zoom.js"
		Update_File "chartjs-plugin-annotation.js"
		Update_File "hammerjs.js"
		Update_File "moment.js"
		Modify_WebUI_File
		
		if [ "$doupdate" != "false" ]; then
			/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" -o "/jffs/scripts/$SCRIPT_NAME" && Print_Output "true" "$SCRIPT_NAME successfully updated"
			chmod 0755 /jffs/scripts/"$SCRIPT_NAME"
			Clear_Lock
			exit 0
		else
			Print_Output "true" "No new version - latest is $localver" "$WARN"
			Clear_Lock
		fi
	fi
	
	case "$1" in
		force)
			serverver=$(/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" | grep "SCRIPT_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
			Print_Output "true" "Downloading latest version ($serverver) of $SCRIPT_NAME" "$PASS"
			Update_File "connmonstats_www.asp"
			Update_File "chartjs-plugin-zoom.js"
			Update_File "chartjs-plugin-annotation.js"
			Update_File "hammerjs.js"
			Update_File "moment.js"
			Modify_WebUI_File
			/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" -o "/jffs/scripts/$SCRIPT_NAME" && Print_Output "true" "$SCRIPT_NAME successfully updated"
			chmod 0755 /jffs/scripts/"$SCRIPT_NAME"
			Clear_Lock
			exit 0
		;;
	esac
}
############################################################################

Update_File(){
	if [ "$1" = "connmonstats_www.asp" ]; then
		tmpfile="/tmp/$1"
		Download_File "$SCRIPT_REPO/$1" "$tmpfile"
		if ! diff -q "$tmpfile" "$SCRIPT_DIR/$1" >/dev/null 2>&1; then
			Print_Output "true" "New version of $1 downloaded" "$PASS"
			mv "$SCRIPT_DIR/$1" "$SCRIPT_DIR/$1.old"
			Mount_CONNMON_WebUI
		fi
		rm -f "$tmpfile"
	elif [ "$1" = "chartjs-plugin-zoom.js" ] || [ "$1" = "chartjs-plugin-annotation.js" ] || [ "$1" = "moment.js" ] || [ "$1" =  "hammerjs.js" ]; then
		tmpfile="/tmp/$1"
		Download_File "$SHARED_REPO/$1" "$tmpfile"
		if [ ! -f "$SHARED_DIR/$1" ]; then
			touch "$SHARED_DIR/$1"
		fi
		if ! diff -q "$tmpfile" "$SHARED_DIR/$1" >/dev/null 2>&1; then
			Print_Output "true" "New version of $1 downloaded" "$PASS"
			Download_File "$SHARED_REPO/$1" "$SHARED_DIR/$1"
		fi
		rm -f "$tmpfile"
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
			Print_Output "false" "$formatted - $2 is not a number" "$ERR"
		fi
		return 1
	fi
}

Validate_IP(){
	if expr "$1" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
		for i in 1 2 3 4; do
			if [ "$(echo "$1" | cut -d. -f$i)" -gt 255 ]; then
				Print_Output "false" "Octet $i ($(echo "$1" | cut -d. -f$i)) - is invalid, must be less than 255" "$ERR"
				return 1
			fi
		done
	else
		Print_Output "false" "$1 - is not a valid IPv4 address, valid format is 1.2.3.4" "$ERR"
		return 1
	fi
}

Validate_Domain(){
	if ! nslookup "$1" >/dev/null 2>&1; then
		Print_Output "false" "$1 cannot be resolved by nslookup, please ensure you enter a valid domain name" "$ERR"
		return 1
	else
		return 0
	fi
}

Create_Dirs(){
	if [ ! -d "$SCRIPT_DIR" ]; then
		mkdir -p "$SCRIPT_DIR"
	fi
	
	if [ ! -d "$SHARED_DIR" ]; then
		mkdir -p "$SHARED_DIR"
	fi
	
	if [ ! -d "$SCRIPT_WEB_DIR" ]; then
		mkdir -p "$SCRIPT_WEB_DIR"
	fi
	
	if [ ! -d "$SHARED_WEB_DIR" ]; then
		mkdir -p "$SHARED_WEB_DIR"
	fi
}

Create_Symlinks(){
	rm -f "$SCRIPT_WEB_DIR/"* 2>/dev/null
	
	ln -s "$SCRIPT_DIR/connstatsdatadaily.js" "$SCRIPT_WEB_DIR/connstatsdatadaily.js" 2>/dev/null
	ln -s "$SCRIPT_DIR/connstatsdataweekly.js" "$SCRIPT_WEB_DIR/connstatsdataweekly.js" 2>/dev/null
	ln -s "$SCRIPT_DIR/connstatsdatamonthly.js" "$SCRIPT_WEB_DIR/connstatsdatamonthly.js" 2>/dev/null
	
	ln -s "$SCRIPT_DIR/connstatstext.js" "$SCRIPT_WEB_DIR/connstatstext.js" 2>/dev/null
	
	ln -s "$SHARED_DIR/chartjs-plugin-zoom.js" "$SHARED_WEB_DIR/chartjs-plugin-zoom.js" 2>/dev/null
	ln -s "$SHARED_DIR/chartjs-plugin-annotation.js" "$SHARED_WEB_DIR/chartjs-plugin-annotation.js" 2>/dev/null
	ln -s "$SHARED_DIR/hammerjs.js" "$SHARED_WEB_DIR/hammerjs.js" 2>/dev/null
	ln -s "$SHARED_DIR/moment.js" "$SHARED_WEB_DIR/moment.js" 2>/dev/null
}

Conf_Exists(){
	if [ -f "$SCRIPT_CONF" ]; then
		dos2unix "$SCRIPT_CONF"
		chmod 0644 "$SCRIPT_CONF"
		sed -i -e 's/"//g' "$SCRIPT_CONF"
		return 0
	else
		echo "PINGSERVER=8.8.8.8" > "$SCRIPT_CONF"
		return 1
	fi
}

ShowPingServer(){
	PINGSERVER=$(grep "PINGSERVER" "$SCRIPT_CONF" | cut -f2 -d"=")
	echo "$PINGSERVER"
}

SetPingServer(){
	while true; do
		ScriptHeader
		printf "\\n\\e[1mCurrent ping destination: %s\\e[0m\\n\\n" "$(ShowPingServer)"
		printf "1.    Enter IP Address\\n"
		printf "2.    Enter Domain\\n"
		printf "\\ne.    Go back\\n"
		printf "\\n\\e[1mChoose an option:\\e[0m    "
		read -r "pingoption"
		case "$pingoption" in
			1)
				while true; do
					printf "\\n\\e[1mPlease enter an IP address, or enter e to go back:\\e[0m    "
					read -r "ipoption"
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
					read -r "domainoption"
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
}

Auto_ServiceEvent(){
	case $1 in
		create)
			if [ -f /jffs/scripts/service-event ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/service-event)
				# shellcheck disable=SC2016
				STARTUPLINECOUNTEX=$(grep -cx "/jffs/scripts/$SCRIPT_NAME generate"' "$1" "$2" &'' # '"$SCRIPT_NAME" /jffs/scripts/service-event)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/service-event
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					# shellcheck disable=SC2016
					echo "/jffs/scripts/$SCRIPT_NAME generate"' "$1" "$2" &'' # '"$SCRIPT_NAME" >> /jffs/scripts/service-event
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/service-event
				echo "" >> /jffs/scripts/service-event
				# shellcheck disable=SC2016
				echo "/jffs/scripts/$SCRIPT_NAME generate"' "$1" "$2" &'' # '"$SCRIPT_NAME" >> /jffs/scripts/service-event
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
				STARTUPLINECOUNTEX=$(grep -cx "/jffs/scripts/$SCRIPT_NAME startup"' # '"$SCRIPT_NAME" /jffs/scripts/services-start)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/services-start
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					echo "/jffs/scripts/$SCRIPT_NAME startup"' # '"$SCRIPT_NAME" >> /jffs/scripts/services-start
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/services-start
				echo "" >> /jffs/scripts/services-start
				echo "/jffs/scripts/$SCRIPT_NAME startup"' # '"$SCRIPT_NAME" >> /jffs/scripts/services-start
				chmod 0755 /jffs/scripts/services-start
			fi
		;;
		delete)
			if [ -f /jffs/scripts/services-start ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/services-start)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/services-start
				fi
			fi
		;;
	esac
}

Auto_Cron(){
	case $1 in
		create)
			STARTUPLINECOUNT=$(cru l | grep -c "$SCRIPT_NAME")
			if [ "$STARTUPLINECOUNT" -gt 0 ]; then
				cru d "$SCRIPT_NAME"
			fi
			
			STARTUPLINECOUNTDAILY=$(cru l | grep -c "$SCRIPT_NAME_daily")
			STARTUPLINECOUNTWEEKLY=$(cru l | grep -c "$SCRIPT_NAME_weekly")
			STARTUPLINECOUNTMONTHLY=$(cru l | grep -c "$SCRIPT_NAME_monthly")
			
			if [ "$STARTUPLINECOUNTDAILY" -eq 0 ]; then
				cru a "$SCRIPT_NAME""_daily" "*/5 * * * * /jffs/scripts/$SCRIPT_NAME generate daily"
			fi
			if [ "$STARTUPLINECOUNTWEEKLY" -eq 0 ]; then
				cru a "$SCRIPT_NAME""_weekly" "2 * * * * /jffs/scripts/$SCRIPT_NAME generate weekly"
			fi
			if [ "$STARTUPLINECOUNTMONTHLY" -eq 0 ]; then
				cru a "$SCRIPT_NAME""_monthly" "3 */3 * * * /jffs/scripts/$SCRIPT_NAME generate monthly"
			fi
		;;
		delete)
			STARTUPLINECOUNT=$(cru l | grep -c "$SCRIPT_NAME")
			if [ "$STARTUPLINECOUNT" -gt 0 ]; then
				cru d "$SCRIPT_NAME"
			fi
			
			STARTUPLINECOUNTDAILY=$(cru l | grep -c "$SCRIPT_NAME_daily")
			STARTUPLINECOUNTWEEKLY=$(cru l | grep -c "$SCRIPT_NAME_weekly")
			STARTUPLINECOUNTMONTHLY=$(cru l | grep -c "$SCRIPT_NAME_monthly")
			
			if [ "$STARTUPLINECOUNTDAILY" -gt 0 ]; then
				cru d "$SCRIPT_NAME""_daily"
			fi
			if [ "$STARTUPLINECOUNTWEEKLY" -gt 0 ]; then
				cru d "$SCRIPT_NAME""_weekly"
			fi
			if [ "$STARTUPLINECOUNTMONTHLY" -gt 0 ]; then
				cru d "$SCRIPT_NAME""_monthly"
			fi
		;;
	esac
}

Download_File(){
	/usr/sbin/curl -fsL --retry 3 "$1" -o "$2"
}

Get_spdMerlin_UI(){
	if [ -f /www/AdaptiveQoS_ROG.asp ]; then
		echo "AdaptiveQoS_ROG.asp"
	else
		echo "AiMesh_Node_FirmwareUpgrade.asp"
	fi
}

Mount_CONNMON_WebUI(){
	umount /www/Advanced_Feedback.asp 2>/dev/null
	
	if [ ! -f "$SCRIPT_DIR/connmonstats_www.asp" ]; then
		Download_File "$SCRIPT_REPO/connmonstats_www.asp" "$SCRIPT_DIR/connmonstats_www.asp"
	fi
	
	mount -o bind "$SCRIPT_DIR/connmonstats_www.asp" "/www/Advanced_Feedback.asp"
}

Modify_WebUI_File(){
	### menuTree.js ###
	umount /www/require/modules/menuTree.js 2>/dev/null
	tmpfile=/tmp/menuTree.js
	cp "/www/require/modules/menuTree.js" "$tmpfile"
	
	if [ -f "/jffs/scripts/uiDivStats" ]; then
		sed -i '/{url: "Advanced_MultiSubnet_Content.asp", tabName: /d' "$tmpfile"
		sed -i '/"Tools_OtherSettings.asp", tabName: "Other Settings"/a {url: "Advanced_MultiSubnet_Content.asp", tabName: "Diversion Statistics"},' "$tmpfile"
		sed -i '/retArray.push("Advanced_MultiSubnet_Content.asp");/d' "$tmpfile"
	fi
	
	sed -i '/{url: "Advanced_Feedback.asp", tabName: /d' "$tmpfile"
	sed -i '/"Tools_OtherSettings.asp", tabName: "Other Settings"/a {url: "Advanced_Feedback.asp", tabName: "Uptime Monitoring"},' "$tmpfile"
	sed -i '/retArray.push("Advanced_Feedback.asp");/d' "$tmpfile"
	
	if [ -f "/jffs/scripts/spdmerlin" ]; then
		sed -i '/{url: "'"$(Get_spdMerlin_UI)"'", tabName: /d' "$tmpfile"
		sed -i '/"Tools_OtherSettings.asp", tabName: "Other Settings"/a {url: "'"$(Get_spdMerlin_UI)"'", tabName: "SpeedTest"},' "$tmpfile"
		sed -i '/retArray.push("'"$(Get_spdMerlin_UI)"'");/d' "$tmpfile"
	fi
	
	if [ -f "/jffs/scripts/ntpmerlin" ]; then
		sed -i '/"Tools_OtherSettings.asp", tabName: "Other Settings"/a {url: "Feedback_Info.asp", tabName: "NTP Daemon"},' "$tmpfile"
	fi
	
	if [ -f /jffs/scripts/custom_menuTree.js ]; then
		mv /jffs/scripts/custom_menuTree.js "$SHARED_DIR/custom_menuTree.js"
	fi
	
	if [ ! -f "$SHARED_DIR/custom_menuTree.js" ]; then
		cp "$tmpfile" "$SHARED_DIR/custom_menuTree.js"
	fi
	
	if ! diff -q "$tmpfile" "$SHARED_DIR/custom_menuTree.js" >/dev/null 2>&1; then
		cp "$tmpfile" "$SHARED_DIR/custom_menuTree.js"
	fi
	
	rm -f "$tmpfile"
	
	mount -o bind "$SHARED_DIR/custom_menuTree.js" "/www/require/modules/menuTree.js"
	### ###
	
	### start_apply.htm ###
	umount /www/start_apply.htm 2>/dev/null
	tmpfile=/tmp/start_apply.htm
	cp "/www/start_apply.htm" "$tmpfile"
	
	if [ -f "/jffs/scripts/uiDivStats" ]; then
		sed -i -e '/else if(current_page.indexOf("Feedback") != -1){/i else if(current_page.indexOf("Advanced_MultiSubnet_Content.asp") != -1){'"\\r\\n"'parent.showLoading(restart_time, "waiting");'"\\r\\n"'setTimeout(function(){ getXMLAndRedirect();}, restart_time*1000);'"\\r\\n"'}' "$tmpfile"
	fi
	
	sed -i -e '/else if(current_page.indexOf("Feedback") != -1){/i else if(current_page.indexOf("Advanced_Feedback.asp") != -1){'"\\r\\n"'parent.showLoading(restart_time, "waiting");'"\\r\\n"'setTimeout(function(){ getXMLAndRedirect();}, restart_time*1000);'"\\r\\n"'}' "$tmpfile"
	
	if [ -f /jffs/scripts/spdmerlin ]; then
		sed -i -e '/else if(current_page.indexOf("Feedback") != -1){/i else if(current_page.indexOf("'"$(Get_spdMerlin_UI)"'") != -1){'"\\r\\n"'parent.showLoading(restart_time, "waiting");'"\\r\\n"'setTimeout(function(){ getXMLAndRedirect();}, restart_time*1000);'"\\r\\n"'}' "$tmpfile"
	fi
	
	if [ -f /jffs/scripts/ntpmerlin ]; then
		sed -i -e '/else if(current_page.indexOf("Feedback") != -1){/i else if(current_page.indexOf("Feedback_Info.asp") != -1){'"\\r\\n"'parent.showLoading(restart_time, "waiting");'"\\r\\n"'setTimeout(function(){ getXMLAndRedirect();}, restart_time*1000);'"\\r\\n"'}' "$tmpfile"
	fi
	
	if [ -f /jffs/scripts/custom_start_apply.htm ]; then
		mv /jffs/scripts/custom_start_apply.htm "$SHARED_DIR/custom_start_apply.htm"
	fi
	
	if [ ! -f "$SHARED_DIR/custom_start_apply.htm" ]; then
		cp "/www/start_apply.htm" "$SHARED_DIR/custom_start_apply.htm"
	fi
	
	if ! diff -q "$tmpfile" "$SHARED_DIR/custom_start_apply.htm" >/dev/null 2>&1; then
		cp "$tmpfile" "$SHARED_DIR/custom_start_apply.htm"
	fi
	
	rm -f "$tmpfile"
	
	mount -o bind "$SHARED_DIR/custom_start_apply.htm" /www/start_apply.htm
	### ###
}

WriteData_ToJS(){
	{
	echo "var $3;"
	echo "$3 = [];"; } >> "$2"
	contents="$3"'.unshift('
	while IFS='' read -r line || [ -n "$line" ]; do
		if echo "$line" | grep -q "NaN"; then continue; fi
		datapoint="{ x: moment.unix(""$(echo "$line" | awk 'BEGIN{FS=","}{ print $1 }' | awk '{$1=$1};1')""), y: ""$(echo "$line" | awk 'BEGIN{FS=","}{ print $2 }' | awk '{$1=$1};1')"" }"
		contents="$contents""$datapoint"","
	done < "$1"
	contents=$(echo "$contents" | sed 's/.$//')
	contents="$contents"");"
	printf "%s\\r\\n\\r\\n" "$contents" >> "$2"
}

WriteStats_ToJS(){
	echo "function $3(){" > "$2"
	html='document.getElementById("'"$4"'").innerHTML="'
	while IFS='' read -r line || [ -n "$line" ]; do
		html="$html""$line""\\r\\n"
	done < "$1"
	html="$html"'"'
	printf "%s\\r\\n}\\r\\n" "$html" >> "$2"
}

#$1 fieldname $2 tablename $3 frequency (hours) $4 length (days) $5 outputfile $6 sqlfile
WriteSql_ToFile(){
	{
		echo ".mode csv"
		echo ".output $5"
	} >> "$6"
	COUNTER=0
	timenow="$(date '+%s')"
	until [ $COUNTER -gt "$((24*$4/$3))" ]; do
		echo "select $timenow - ((60*60*$3)*($COUNTER)),IFNULL(avg([$1]),'NaN') from $2 WHERE ([Timestamp] >= $timenow - ((60*60*$3)*($COUNTER+1))) AND ([Timestamp] <= $timenow - ((60*60*$3)*$COUNTER));" >> "$6"
		COUNTER=$((COUNTER + 1))
	done
}

Generate_Charts(){
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Conf_Exists
	Create_Dirs
	Create_Symlinks
	
	case $1 in
		daily)
			{
				echo ".mode csv"
				echo ".output /tmp/connmon-pingdaily.csv"
				echo "select [Timestamp],[Ping] from connstats WHERE [Timestamp] >= (strftime('%s','now') - 86400);"
				echo ".output /tmp/connmon-jitterdaily.csv"
				echo "select [Timestamp],[Jitter] from connstats WHERE [Timestamp] >= (strftime('%s','now') - 86400);"
				echo ".output /tmp/connmon-qualitydaily.csv"
				echo "select [Timestamp],[Packet_Loss] from connstats WHERE [Timestamp] >= (strftime('%s','now') - 86400);"
			} > /tmp/connmon-stats.sql
			
			"$SQLITE3_PATH" "$SCRIPT_DIR/connstats.db" < /tmp/connmon-stats.sql
			
			rm -f "$SCRIPT_DIR/connstatsdatadaily.js"
			WriteData_ToJS "/tmp/connmon-pingdaily.csv" "$SCRIPT_DIR/connstatsdatadaily.js" "DataPingDaily"
			WriteData_ToJS "/tmp/connmon-jitterdaily.csv" "$SCRIPT_DIR/connstatsdatadaily.js" "DataJitterDaily"
			WriteData_ToJS "/tmp/connmon-qualitydaily.csv" "$SCRIPT_DIR/connstatsdatadaily.js" "DataQualityDaily"
		;;
		weekly)
			WriteSql_ToFile "Ping" "connstats" 1 7 "/tmp/connmon-pingweekly.csv" "/tmp/connmon-stats.sql"
			WriteSql_ToFile "Jitter" "connstats" 1 7 "/tmp/connmon-jitterweekly.csv" "/tmp/connmon-stats.sql"
			WriteSql_ToFile "Packet_Loss" "connstats" 1 7 "/tmp/connmon-qualityweekly.csv" "/tmp/connmon-stats.sql"
			
			"$SQLITE3_PATH" "$SCRIPT_DIR/connstats.db" < /tmp/connmon-stats.sql
			
			rm -f "$SCRIPT_DIR/connstatsdataweekly.js"
			WriteData_ToJS "/tmp/connmon-pingweekly.csv" "$SCRIPT_DIR/connstatsdataweekly.js" "DataPingWeekly"
			WriteData_ToJS "/tmp/connmon-jitterweekly.csv" "$SCRIPT_DIR/connstatsdataweekly.js" "DataJitterWeekly"
			WriteData_ToJS "/tmp/connmon-qualityweekly.csv" "$SCRIPT_DIR/connstatsdataweekly.js" "DataQualityWeekly"
		;;
		monthly)
			WriteSql_ToFile "Ping" "connstats" 3 30 "/tmp/connmon-pingmonthly.csv" "/tmp/connmon-stats.sql"
			WriteSql_ToFile "Jitter" "connstats" 3 30 "/tmp/connmon-jittermonthly.csv" "/tmp/connmon-stats.sql"
			WriteSql_ToFile "Packet_Loss" "connstats" 3 30 "/tmp/connmon-qualitymonthly.csv" "/tmp/connmon-stats.sql"
			
			"$SQLITE3_PATH" "$SCRIPT_DIR/connstats.db" < /tmp/connmon-stats.sql
			
			rm -f "$SCRIPT_DIR/connstatsdatamonthly.js"
			WriteData_ToJS "/tmp/connmon-pingmonthly.csv" "$SCRIPT_DIR/connstatsdatamonthly.js" "DataPingMonthly"
			WriteData_ToJS "/tmp/connmon-jittermonthly.csv" "$SCRIPT_DIR/connstatsdatamonthly.js" "DataJitterMonthly"
			WriteData_ToJS "/tmp/connmon-qualitymonthly.csv" "$SCRIPT_DIR/connstatsdatamonthly.js" "DataQualityMonthly"
		;;
		all)
			Generate_Charts daily
			Generate_Charts weekly
			Generate_Charts monthly
		;;
	esac
	
	rm -f "/tmp/connmon-"*".csv"
	rm -f "/tmp/connmon-stats.sql"
}

Generate_Stats(){
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Conf_Exists
	Create_Dirs
	Create_Symlinks
	
	pingfile=/tmp/pingresult.txt
	
	Print_Output "false" "30 second ping test to $(ShowPingServer) starting..." "$PASS"
	if ! Validate_IP "$(ShowPingServer)" >/dev/null 2>&1 && ! Validate_Domain "$(ShowPingServer)" >/dev/null 2>&1; then
		Print_Output "true" "$(ShowPingServer) not valid, aborting test. Please correct ASAP" "$ERR"
		Clear_Lock
		return 1
	fi
	
	iptables -I OUTPUT -t mangle -p icmp -j MARK --set-mark 0x40090001
	ping -w 30 "$(ShowPingServer)" > "$pingfile"
	iptables -D OUTPUT -t mangle -p icmp -j MARK --set-mark 0x40090001
	
	PREVPING=0
	TOTALDIFF=0
	COUNTER=1
	PINGLIST="$(grep seq= "$pingfile")"
	PINGCOUNT="$(echo "$PINGLIST" | wc -l)"
	DIFFCOUNT="$((PINGCOUNT - 1))"
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
	
	TZ=$(cat /etc/TZ)
	export TZ
	
	ping="$(tail -n 1 "$pingfile"  | cut -f4 -d"/")"
	jitter="$(echo "$TOTALDIFF" "$DIFFCOUNT" | awk '{printf "%4.3f\n",$1/$2}')"
	pktloss="$(echo "100" "$(tail -n 2 "$pingfile" | head -n 1 | cut -f3 -d"," | awk '{$1=$1};1' | cut -f1 -d"%")" | awk '{printf "%4.3f\n",$1-$2}')"
	
	{
	echo "CREATE TABLE IF NOT EXISTS [connstats] ([StatID] INTEGER PRIMARY KEY NOT NULL, [Timestamp] NUMERIC NOT NULL, [Ping] REAL NOT NULL,[Jitter] REAL NOT NULL,[Packet_Loss] REAL NOT NULL);"
	echo "INSERT INTO connstats ([Timestamp],[Ping],[Jitter],[Packet_Loss]) values($(date '+%s'),$ping,$jitter,$pktloss);"
	} > /tmp/connmon-stats.sql
	
	"$SQLITE3_PATH" "$SCRIPT_DIR/connstats.db" < /tmp/connmon-stats.sql
	
	echo "Internet Uptime Monitoring generated on $(date +"%c")" > "/tmp/connstatstitle.txt"
	WriteStats_ToJS "/tmp/connstatstitle.txt" "$SCRIPT_DIR/connstatstext.js" "SetConnmonStatsTitle" "statstitle"
	Print_Output "false" "Test results - Ping $ping ms - Jitter - $jitter ms - Line Quality $pktloss %%" "$PASS"
	
	rm -f "$pingfile"
	rm -f "/tmp/connmon-stats.sql"
	rm -f "/tmp/connstatstitle.txt"
}

Shortcut_connmon(){
	case $1 in
		create)
			if [ -d "/opt/bin" ] && [ ! -f "/opt/bin/$SCRIPT_NAME" ] && [ -f "/jffs/scripts/$SCRIPT_NAME" ]; then
				ln -s /jffs/scripts/"$SCRIPT_NAME" /opt/bin
				chmod 0755 /opt/bin/"$SCRIPT_NAME"
			fi
		;;
		delete)
			if [ -f "/opt/bin/$SCRIPT_NAME" ]; then
				rm -f /opt/bin/"$SCRIPT_NAME"
			fi
		;;
	esac
}

PressEnter(){
	while true; do
		printf "Press enter to continue..."
		read -r "key"
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
	printf "1.    Check connection now\\n\\n"
	printf "2.    Set preferred ping server\\n      Currently: %s\\n\\n" "$(ShowPingServer)"
	printf "u.    Check for updates\\n"
	printf "uf.   Update %s with latest version (force update)\\n\\n" "$SCRIPT_NAME"
	printf "e.    Exit %s\\n\\n" "$SCRIPT_NAME"
	printf "z.    Uninstall %s\\n" "$SCRIPT_NAME"
	printf "\\n"
	printf "\\e[1m############################################################\\e[0m\\n"
	printf "\\n"
	
	while true; do
		printf "Choose an option:    "
		read -r "menu"
		case "$menu" in
			1)
				printf "\\n"
				if Check_Lock "menu"; then
					Menu_GenerateStats
				fi
				PressEnter
				break
			;;
			2)
				printf "\\n"
				Menu_SetPingServer
				PressEnter
				break
			;;
			u)
				printf "\\n"
				if Check_Lock "menu"; then
					Menu_Update
				fi
				PressEnter
				break
			;;
			uf)
				printf "\\n"
				if Check_Lock "menu"; then
					Menu_ForceUpdate
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
					read -r "confirm"
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
		Print_Output "true" "Custom JFFS Scripts enabled" "$WARN"
	fi
	
	if [ ! -f "/opt/bin/opkg" ]; then
		Print_Output "true" "Entware not detected!" "$ERR"
		CHECKSFAILED="true"
		return 1
	fi
	
	if [ "$(Firmware_Version_Check "$(nvram get buildno)")" -lt "$(Firmware_Version_Check 384.11)" ] && [ "$(Firmware_Version_Check "$(nvram get buildno)")" -ne "$(Firmware_Version_Check 374.43)" ]; then
		Print_Output "true" "Older Merlin firmware detected - $SCRIPT_NAME requires 384.11 or later for sqlite3 support" "$WARN"
		Print_Output "true" "Installing sqlite3-cli from Entware..." "$WARN"
		opkg update
		opkg install sqlite3-cli
	elif [ "$(Firmware_Version_Check "$(nvram get buildno)")" -eq "$(Firmware_Version_Check 374.43)" ]; then
		Print_Output "true" "John's fork detected - unsupported" "$ERR"
		CHECKSFAILED="true"
		return 1
	fi
		
	if [ "$CHECKSFAILED" = "false" ]; then
		return 0
	else
		return 1
	fi
}

Menu_Install(){
	Print_Output "true" "Welcome to $SCRIPT_NAME $SCRIPT_VERSION, a script by JackYaz"
	sleep 1
	
	Print_Output "true" "Checking your router meets the requirements for $SCRIPT_NAME"
	
	if ! Check_Requirements; then
		Print_Output "true" "Requirements for $SCRIPT_NAME not met, please see above for the reason(s)" "$CRIT"
		PressEnter
		Clear_Lock
		rm -f "/jffs/scripts/$SCRIPT_NAME" 2>/dev/null
		exit 1
	fi
	
	opkg update
	
	Create_Dirs
	Create_Symlinks
	Conf_Exists
	
	Update_File "chartjs-plugin-zoom.js"
	Update_File "chartjs-plugin-annotation.js"
	Update_File "hammerjs.js"
	Update_File "moment.js"
	
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_connmon create
	Mount_CONNMON_WebUI
	Modify_WebUI_File
	Menu_GenerateStats
	
	Clear_Lock
}

Menu_Startup(){
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_connmon create
	Create_Dirs
	Create_Symlinks
	Mount_CONNMON_WebUI
	Modify_WebUI_File
	Clear_Lock
}

Menu_GenerateStats(){
	Generate_Stats
	Generate_Charts all
	Clear_Lock
}

Menu_SetPingServer(){
	SetPingServer
}

Menu_Update(){
	Update_Version
	Clear_Lock
}

Menu_ForceUpdate(){
	Update_Version force
	Clear_Lock
}

Menu_Uninstall(){
	Print_Output "true" "Removing $SCRIPT_NAME..." "$PASS"
	Auto_Startup delete 2>/dev/null
	Auto_Cron delete 2>/dev/null
	Auto_ServiceEvent delete 2>/dev/null
	while true; do
		printf "\\n\\e[1mDo you want to delete %s config and stats? (y/n)\\e[0m\\n" "$SCRIPT_NAME"
		read -r "confirm"
		case "$confirm" in
			y|Y)
				rm -f "/jffs/configs/connmon.config" 2> /dev/null
				break
			;;
			*)
				break
			;;
		esac
	done
	Shortcut_connmon delete
	umount /www/Advanced_Feedback.asp 2>/dev/null
	sed -i '/{url: "Advanced_Feedback.asp", tabName: "Uptime Monitoring"}/d' "$SHARED_DIR/custom_menuTree.js"
	umount /www/require/modules/menuTree.js 2>/dev/null
	
	if [ ! -f "/jffs/scripts/ntpmerlin" ] && [ ! -f "/jffs/scripts/spdmerlin" ]; then
		rm -f "$SHARED_DIR/custom_menuTree.js" 2>/dev/null
	else
		mount -o bind "$SHARED_DIR/custom_menuTree.js" "/www/require/modules/menuTree.js"
	fi
	rm -f "$SCRIPT_DIR/connmonstats_www.asp" 2>/dev/null
	rm -f "/jffs/scripts/$SCRIPT_NAME" 2>/dev/null
	Clear_Lock
	Print_Output "true" "Uninstall completed" "$PASS"
}

if [ -z "$1" ]; then
	Create_Dirs
	Create_Symlinks
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_connmon create
	Clear_Lock
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
		Check_Lock
		Menu_Startup
		exit 0
	;;
	generate)
		if [ "$2" = "start" ] && [ "$3" = "$SCRIPT_NAME" ]; then
			Check_Lock
			Menu_GenerateStats
		elif [ -n "$2" ] && [ -z "$3" ]; then
			Check_Lock
			if [ "$2" = "daily" ]; then
				Generate_Stats
			fi
			Generate_Charts "$2"
			Clear_Lock
		elif [ -z "$2" ] && [ -z "$3" ]; then
			Check_Lock
			Menu_GenerateStats
		fi
		exit 0
	;;
	update)
		Check_Lock
		Menu_Update
		exit 0
	;;
	forceupdate)
		Check_Lock
		Menu_ForceUpdate
		exit 0
	;;
	uninstall)
		Check_Lock
		Menu_Uninstall
		exit 0
	;;
	*)
		Check_Lock
		echo "Command not recognised, please try again"
		Clear_Lock
		exit 1
	;;
esac
