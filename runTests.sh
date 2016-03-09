#!/bin/bash
clear

#Variables
EXE=PA5
RESULTCODE=0
EXPECTEDCODE=0
LOGRESULT=0


# Variables formatting the script color red/green for visibility
PATH=/bin:/usr/bin:

NONE='\e[0m'
RED='\e[0;31m';
GREEN='\e[0;32m';

#Building the source
cd ..
make buildTest
cd test
make

#Testing the files
echo ''
echo Testing files:
echo ''

for FILENAME in */ ;
do
	FILENAME=${FILENAME%%/}

	if [ "$FILENAME" != "CMakeFiles" ];
	then
		touch $FILENAME/expected_code.txt
		touch $FILENAME/result.txt
		touch $FILENAME/result_code.txt
		touch $FILENAME/log.txt

		EXPECTEDCODE=$(cat $FILENAME/expected_code.txt )

		#make a temp file for error logging
		touch $FILENAME/cout.txt
		>$FILENAME/cout.txt

		$EXE $FILENAME/input.txt $FILENAME/input2.txt $FILENAME/result.txt 2> cout.txt

		# result code handling...
		RESULTCODE=$?														#put result code into a variable.
		>$FILENAME/result_code.txt 											#clear result
		echo $RESULTCODE >> $FILENAME/result_code.txt 						#echo result code into file.

		LOGRESULT=$(cat $FILENAME/cout.txt)

		if [ "$EXPECTEDCODE" != "$RESULTCODE" ];
		then
			echo ''
			echo -e "${RED}Error: The return code of $FILENAME is not the what is expected.${NONE}" 1>&2
			echo -e "${RED}executed - $FILENAME - with return code [$RESULTCODE]${NONE}"

			if [ "$LOGRESULT" != "" ]; then
				echo -e "${RED}$LOGRESULT${NONE}"
		fi
		else
			if [ -f "$FILENAME/expected.txt" ];
			then
				./check $FILENAME/expected.txt $FILENAME/result.txt
				if [ "$?" != "0" ]; then
					echo ""
					echo -e "${RED}Error: The results of $FILENAME are different from what is expected${NONE}" 1>&2
					#exit 255
				fi
			fi

			echo -e "${GREEN}executed - $FILENAME - with return code [$RESULTCODE]${NONE}"
		fi



		#Delete empty logs
		if [ "$(cat $FILENAME/log.txt)" = "" ]; then
			rm $FILENAME/log.txt
		fi

		rm -f tempDelete.log.txt
	fi
done

echo ""
echo "Finished testing."
exit 0
