#!/bin/bash
#
# Author : Basar Turgut <basar@trdlab.com>
# Homepage : http://www.trdlab.com
# License : BSD http://en.wikipedia.org/wiki/BSD_license
# Copyright (c) 2016, TRDLab
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Purpose : Script backups all repositories of a team from bitbucket using admin creds.
# Creates git bundles and tar the result named as date of usage.
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
