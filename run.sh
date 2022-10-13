#!/bin/bash
while true
do
	curl --silent "http://192.168.1.254" |\
		/root/.cargo/bin/htmlq --text '#frame_div > table:nth-child(6) td.bt_border:not(:first-child):not(:nth-child(5)):not(:nth-child(6))' |\
		sed 's/$/,/g' |\
		xargs -n3 |\
		grep "192.168" |\
		sed 's/,$//g' > results.latest
		cat results.latest | sed 's/.*, \(.*\),.*/\1/g' > macaddresses.latest
		if [ -f "macaddresses.old" ]; then
			joined=$(diff macaddresses.old macaddresses.latest -U 0 | grep '^+[^+]' | sed 's/^+//g')
			for mac in $joined
			do
				details=$(cat results.latest | grep "$mac")
				IFS=", " read name mac ip <<< "$details"
				if [ "$name" == "flichub" ] ; then
					echo "Ignoring flichub change as they're noisy"
					continue
				fi
				echo "$name ($mac) joined"
				curl --silent -X POST "https://loganne.l42.eu/events" --data "{
					\"type\": \"deviceJoined\",
					\"source\": \"lucos_lanscan\",
					\"humanReadable\": \"$name ($mac) joined the Local Area Network\",
					\"device\": {
						\"hostname\": \"$name\",
						\"ip_address\": \"$ip\",
						\"mac_addresss\": \"$mac\"
					}
				}" -H "Content-Type: application/json"
			done
			left=$(diff macaddresses.old macaddresses.latest -U 0 | grep '^-[^-]' | sed 's/^-//g')
			for mac in $left
			do
				details=$(cat results.old | grep "$mac")
				IFS=", " read name mac ip <<< "$details"
				if [ "$name" == "flichub" ] ; then
					echo "Ignoring flichub change as they're noisy"
					continue
				fi
				echo "$name ($mac) left"
				curl --silent -X POST "https://loganne.l42.eu/events" --data "{
					\"type\": \"deviceJoined\",
					\"source\": \"lucos_lanscan\",
					\"humanReadable\": \"$name ($mac) left the Local Area Network\",
					\"device\": {
						\"hostname\": \"$name\",
						\"ip_address\": \"$ip\",
						\"mac_addresss\": \"$mac\"
					}
				}" -H "Content-Type: application/json"
			done
		fi
		cp results.latest results.old
		cp macaddresses.latest macaddresses.old
	sleep 10
done