#!/bin/bash


function ins() {
	np=('ssh' 'tor' 'whois' 'nmap' 'curl' 'sshpass' 'geoiplookup' 'torsocks')
	for i in "${np[@]}"; do
	 if (! command -v "$i" &> /dev/null); then
		if [ "$i" == 'geoiplookup' ]; then
			echo "$i not installed. installing $i"
			sudo apt-get install geoip-bin -y
		else
			echo "$i not installed. installing $i"
			sudo apt-get install "$i" -y
		fi
	 else
	     echo "$i is installed."
	 fi
	 done
 }

function anon() {
	. torsocks on
	check=$(curl -s https://check.torproject.org | grep -i congratulations)
	ip=$(curl -s -4 icanhazip.com)
	if [ -n "$check" ]; then
	 echo "$check"
	else 
	 echo "You are not anonymous. Exiting..."
	 echo "Country is: "
	 geoiplookup "$ip"
	 sudo service tor restart
	 exit 1
	 fi
	echo "$ip \nSpoofed Country"
	geoiplookup "$ip"
}

function sshcon() {
	read -p "Enter SSH Server username: " username
	read -p "Enter SSH Server IP: " ship
	read -sp "Enter SSH Server password - Empty if blank: " paswd
	sinfo=$(sshpass -p "$paswd" ssh -o StrictHostKeyChecking=no "$username"@"$ship" hostnamectl && uptime && h=curl -s -4 ifconfig.co && geoiplookup "$h")
	echo "$sinfo"
	echo "$sinfo" >> hostmachine.txt
	
	#whois
	for i in "${ar[@]}"; do 
		who=$(sshpass -p "$paswd" ssh -o StrictHostKeyChecking=no "$username"@"$ship" whois "$i")
		echo "$who"
		echo "$who" >> whoisdeets.txt
		done
	#nmap
	for i in "${ar[@]}"; do 
		nm=$(sshpass -p "$paswd" ssh -o StrictHostKeyChecking=no "$username"@"$ship" nmap -Pn "$i")
		echo "$nm"
		echo "$nm" >> nmapdeets.txt
		done
}

function targets() {
	echo "Enter target domains or IPs seperated by spaces: "
	read -ra ar
}

function logfile() {
	{ echo $(date)
	  echo "${ar[*]}"
	  echo "whois and nmap results saved to whoisdeets.txt and nmapdeets.txt"
  } >> remotelog.txt
}

ins
anon
targets
sshcon
logfile
