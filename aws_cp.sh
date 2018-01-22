#!/bin/bash
CURDATE=`date +%y%m%d-%H%MA`
LOCKFILE=/tmp/aws_cp.lck
JOBID=JID4508ea21-9723-4f53-8bc8-72da78dfe647
FOLDER=pdf_data_vol_013

if [ ! -e $LOCKFILE ]; then
        touch $LOCKFILE

        echo "==========" >> /snowball_scripts/aws_cp_out/aws_cp_"$JOBID"_"$FOLDER"_$CURDATE.log

        echo Copying "$JOBID"/"$FOLDER" to Snowball >> /snowball_scripts/aws_cp_out/aws_cp_"$JOBID"_"$FOLDER"_$CURDATE.log

        echo "==========" >> /snowball_scripts/aws_cp_out/aws_cp_"$JOBID"_"$FOLDER"_$CURDATE.log

        echo "Begin" `date` >> /snowball_scripts/aws_cp_out/aws_cp_"$JOBID"_"$FOLDER"_$CURDATE.log

        aws s3 cp /snowball_stage/ s3://snowball-s3-data --only-show-errors --recursive --profile snowballEdge --endpoint http://172.26.120.21:8080 &>> /snowball_scripts/aws_cp_out/aws_cp_"$JOBID"_"$FOLDER"_$CURDATE.log

        echo Contents of s3://snowball-s3-data/"$JOBID"/"$FOLDER/" >> /snowball_scripts/aws_cp_out/aws_cp_"$JOBID"_"$FOLDER"_$CURDATE.log

        aws s3 ls  s3://snowball-s3-data/"$JOBID/$FOLDER/" --profile snowballEdge --endpoint http://172.26.120.21:8080 >> /snowball_scripts/aws_cp_out/aws_cp_"$JOBID"_"$FOLDER"_$CURDATE.log

        echo "Completed" `date` >> /snowball_scripts/aws_cp_out/aws_cp_"$JOBID"_"$FOLDER"_$CURDATE.log

        echo "==========" >> /snowball_scripts/aws_cp_out/aws_cp_"$JOBID"_"$FOLDER"_$CURDATE.log

        /snowball_scripts/snowball-client-linux-1.0.1-167/bin/snowballEdge  status -i 172.26.120.21 -m /snowball_scripts/opmga-j1/JID4508ea21-9723-4f53-8bc8-72da78dfe647_manifest.bin -u 0bc96-dc75d-a9565-c7141-745c0 >> /snowball_scripts/aws_cp_out/aws_cp_"$JOBID"_"$FOLDER"_$CURDATE.log

        echo "==========" >> /snowball_scripts/aws_cp_out/aws_cp_"$JOBID"_"$FOLDER"_$CURDATE.log

        rm $LOCKFILE

else

        echo "Lockfile exists, exiting." >> /snowball_scripts/aws_cp_out/aws_cp_"$JOBID"_"$FOLDER"_$CURDATE.log

fi
