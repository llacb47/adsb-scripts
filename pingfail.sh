#!/bin/bash

trap "exit" INT TERM
trap "kill 0" EXIT

TEST1="10.0.0.1"
TEST2="10.0.0.209"
FAIL="no"

while sleep 300
do
	if ping $TEST1 -c1 -w5 >/dev/null || ping $TEST2 -c1 -w5 >/dev/null
	then
		FAIL="no"
	elif [[ "$FAIL" == yes ]]
	then
		if ! ping $TEST1 -c5 -w20 >/dev/null && ! ping $TEST2 -c5 -w20 >/dev/null
		then
            echo "$(date): Rebooting, could reach neither $TEST1 nor $TEST2" | tee -a /var/log/pingfail
            mkdir -p /run/systemd/system/reboot.target.d/
            cat > /run/systemd/system/reboot.target.d/fastreboot.conf <<"EOF"
[Unit]
JobTimeoutSec=60
JobTimeoutAction=reboot-force
EOF
            systemctl daemon-reload
            sync
            reboot
		fi
		FAIL="no"
	else
		FAIL="yes"
	fi
done
