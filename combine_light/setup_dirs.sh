#!/bin/bash

infile=$1
in_path=$2
out_path=$3


myinput=`grep -o '^[^//]*' $infile`

instrument_name=`echo $myinput | jq '.instruments[0].name' | sed -e 's/^"//' -e 's/"$//'`


#### Find and set number of intrinsic light curves (Nin)
lc_in_type=`echo $myinput | jq '.point_source.variability.intrinsic.type' | sed -e 's/^"//' -e 's/"$//'`
if [ $lc_in_type = "custom" ]
then
    lc_in_file=${in_path}"input_files/"${instrument_name}"_LC_intrinsic.json"
else
    lc_in_file=${out_path}"output/"${instrument_name}"_LC_intrinsic.json"
fi
Nin=`cat $lc_in_file | jq ". | length"`




#### Find and set number of extrinsic light curves (Nex)
lc_ex_type=`echo $myinput | jq '.point_source.variability.extrinsic.type' | sed -e 's/^"//' -e 's/"$//'`
if [ $lc_ex_type = "custom" ]
then
    lc_ex_file=${in_path}"input_files/"${instrument_name}"_LC_extrinsic.json"
else
    lc_ex_file=${out_path}"output/"${instrument_name}"_LC_extrinsic.json"
fi
Nq=`cat $lc_ex_file | jq ". | length"`

for (( q=0; q<$Nq; q++ ))
do  
    len=`cat $lc_ex_file | jq ".[$q] | length"`
    if [ $len -gt 0 ]
    then
	Nex=$len
    fi
done


#### Loop and create mock directories, remove beforehand if they exist
for (( i=0; i<$Nin; i++ ))
do
    for (( j=0; j<$Nex; j++ ))
    do
	printf -v mock "mock_%04d_%04d" $i $j
	mydir=${out_path}$mock
	if [ -d "$mydir" ]
	then
	    rm -r $mydir
	fi
	mkdir $mydir
    done
done
