#!/bin/bash
#
# Author : Basar Turgut <basar@trdlab.com>
# Homepage : http://www.trdlab.com
#
# Purpose : Script backups all repositories of a team from bitbucket using admin creds.
# Creates git bundles and tar the result named as date of usage.
#
# Usage : backup.sh [username] [password] [teamname]

mkdir backup

cd backup

date="$(date +%d_%m_%y)"

mkdir "$date"

cd "$date"

rm -Rf *

curl -u ${1}:${2} https://api.bitbucket.org/2.0/repositories/${3} --cacert /etc/ssl/certs/cacert.pem > repoinfo

for repo_name in `grep -oP '\"clone\": \[\{\"href\": \"[^}]*\"' repoinfo | cut -d \" -f6`
do
	echo 'Repo : '$repo_name
	git clone `echo $repo_name | cut -d@ -f1`:${2}@`echo $repo_name | cut -d@ -f2`
	cd `echo $repo_name | cut -d/ -f5 | cut -d. -f1`
	git bundle create ../`echo $repo_name | cut -d/ -f5 | cut -d. -f1`.bundle --all
	cd ..
	rm -Rf `echo $repo_name | cut -d/ -f5 | cut -d. -f1`
done

rm -f repoinfo

cd ..

rm -f "$date".tar

tar -cvf "$date".tar "$date"

rm -Rf $date
