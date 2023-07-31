#!/bin/bash

username=""
password=""
vaultkv=""

kvflag=false
userflag=false
passflag=false

usage () { echo "Usage: $0 [ -k vaultkvpath ] [ -u username -p password ]" 1>&2 ; }

options=':k:u:p:h'
while getopts $options option
do
    case "$option" in
        k  ) vaultkv="${OPTARG}"; kvflag="true";;
        u  ) username="${OPTARG}"; userflag="true";;
        p  ) password="${OPTARG}"; passflag="true";;
        h  ) usage; exit;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

if  [ $kvflag == "true" ]
then
    myusername="`vault kv get -field username  $vaultkv`"
    mypass="`vault kv get -field password  $vaultkv | mkpasswd -s -m sha-512`"
elif [ $userflag == "true" ] && [ $passflag == "true" ]
then
    myusername="${username}"
    mypass="`echo ${password} | mkpasswd -s -m sha-512`"
else
     echo "missing parameter username need password"
     usage
     exit
fi

sed -i "/username:/c\    username: $myusername \#your username" ../cdrom/user-data
sed -i "/password:/c\    password: \"$mypass\"" ../cdrom/user-data