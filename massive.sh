#!/bin/bash

# This is an script to shutdown multiple servers (massive).

input=$1

if [ -z "$input" ];then
	echo "Missing parameter. Please provide a text file."
	exit 1
fi

if [ -f $input ];
then
   echo "File $input exists."
   if [ -s $input ] ; then
		echo "$input has data."
	else
		echo "$input is empty."
		exit 1
	fi
else
   echo "File $input does not exist."
   exit 1
fi

#filename='peptides.txt'
filelines=`cat $input`

echo Start

for line in $filelines ; do
    echo $line

    ping $line -c 1 -q > /dev/null 2>&1
    if [ "$?" -eq "0" ]; then
    	echo "Se puede llegar."
    	pn=2222   #default port number
    	nc -z $line $pn
    	if [ "$?" -eq "1" ]; then
    		pn=22
    	fi
    	echo "$line is visible on port $pn"
    	# login and shut down
    	echo ""
    	echo "shutting down $line ..."
    	ssh root@$line -p$pn -q /sbin/init 0
    	if [ "$?" -eq "0" ]; then
    		echo ""
    		echo "Shutdown signal sent to $line"
    		echo "pinging $line, will pass to the next one when it stops responding."
    		resping=0
    		var=0
    		while [ $resping -eq 0 ]; do
    			ping $line -c 1 -q > /dev/null 2>&1
    			resping=$?
    			sleep 2
    			var=$((var+1))
    			echo $var
    		done
    		echo "$line is not responding, going to next IP."
    	else
    		echo "An error ocurred when trying to bring it down. Please check."
    	fi
    else
    	echo "***No se puede llegar.***"
    fi
    echo "next..."
done
echo "Done!"