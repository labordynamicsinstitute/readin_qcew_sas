#!/bin/bash 
PATH=/bin:/usr/bin:$PATH
if [[ -z $1 ]] 
then
 echo "$0 start"
 exit 1
fi

URL=http://www.bls.gov/cew/data/files
RELPATH=../../raw/qcew/
start=1990
end=$(date +%Y)
#let end=( $end -1 )

echo "Processing files from $URL"
echo " start=$start"
echo " end  =$end"
which seq
for year in $(seq $start $end)
do
  localfile=${year}.all.enb.zip
  remotefile=${year}_all_enb.zip
  remotepath=${URL}/${year}/enb/

  if [[ -f $RELPATH/$localfile ]]
  then
	echo "  Skipping $year: file already present"
  else
        wget -O $RELPATH/$localfile $remotepath/$remotefile
  fi
done

ALTURL=http://www.bls.gov/web/cewqtr
year=$(date +%Y)
remotefile=curr_yr_all_enb.zip
localfile=$remotefile
echo "Processing $year file from $ALTURL"
  if [[ -f $RELPATH/$localfile ]]
  then
        echo "  Skipping $year: file already present"
  else
        wget -O $RELPATH/$localfile $ALTURL/$remotefile
  fi
echo "Done"
