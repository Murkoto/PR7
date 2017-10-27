#!/bin/bash
> temp
> signals
total_line=$(cat lyric | awk '{print NR}' | tail -n 1)
cat lyric | awk 'NR==1' >> temp
current_line=0

function sendSignal() {
        echo  "PID1 $$" >> signals
        PID=$(cat signals | grep "PID2" | awk '{print $2}')
	kill -SIGUSR1 $PID 2> /dev/null
	sleep 1
}

function waitSignal() {
	while true; do
		if [ $current_line -gt $total_line ];
			then
				return
		fi
		echo "..."
		sleep 1
	done
}

function singing1() {
	if [ $current_line -gt  $total_line ];
		then
			return
	fi
	
	while true; do
		turn=$(tail -n 1 temp| awk -F '$' '{print $1}')
		current_line=$(cat temp | awk '{print NR}' | tail -n 1)
		
		if [ -n $turn ]; then
			
			if [ $turn -eq 1 ]; then
				tail -n 1 temp | awk -F '$' '{print $2}'
			fi		

			if [ $turn -eq 2 ]; then
				sendSignal
				return
			fi
		else
			echo "..."
		fi		
		

		sleep 1
		((current_line+=1))
		cat lyric | awk 'NR=="'$current_line'"' >> temp
	done
}

trap singing1 SIGUSR1
sendSignal
waitSignal
