#!/bin/sh

echo "Welcome to foundation, please be patient, your installation is on its way.";

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root.";
	exit;
fi

ping_report=$(ping -c 1 8.8.8.8 2>&1 > /dev/null);

if [ -n "$ping_report" ]; then
	echo "Please connect yourself to a local network.";
	exit;
fi


