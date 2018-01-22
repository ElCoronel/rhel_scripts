#!/bin/bash
CURDATE=`date +%y%m%d-%H%MA`
LOCKFILE=/tmp/dd_merge.lck
JOBID=

exec &> >(tee /snowball_scripts/merge_out/dd_merge_$JOBID_$CURDATE.log)

if [ ! -e $LOCKFILE ]; then
        touch $LOCKFILE

        echo "Begin" `date`

        cat /snowball_split/$JOBID_data.img* | dd of=/dev/sdd

        echo "Completed" `date`

        rm $LOCKFILE

else

        echo "Lockfile exists, exiting."

fi

 >&2
exit
