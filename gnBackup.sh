#!/bin/bash
# Purpose = (Full | Incremental) Backup's 
# Created on 10/10/2017
# Author = G.Nikolaidis
# Contact = gnlinuz@yahoo.com
# Version 1.01

# Sing bellow co-author
# Co-Author:
# Date altered:
# Your modification:
# Conatct = 

TIME=`date +%Y%m%d-%H%M%S`
DN=F                                      
IN=I
LISENCE="You can freely use/redistribute gnBackup, to anyone as
long as you want, under the terms  of  the GNU General
Public License  as   published by  the  Free  Software
Foundation or modify it as  long as you do  not  alter
this notice or the authors information. You can change
the original code, definitely improve it so to  become
a co-author of the script,  just  inform  all  of  the
authors and send  them  your  improved  script  so  to
maintain the version of it. Therefore add your contact
information and state your modifications so anyone has
the opportunity to contact the authors for bugs or so.
If you are just a user of it,
USE THIS SCRIPT AT YOUR OWN RISK !!  Authors  are  not
responsible for any  missuse  or any damage that might
happen. Have fun backing up!!\n"

RestoreData="to Restore...
goto your backup directory, find the file you want
to Restore and type the following command...
example:
cat I-20171018-195601.tar.gz_* | tar xzvf -
----------------------------------------------------------------
if you want to Restore it into a different directory
other than current, type the following command...
example:
cat I-20171018-195601.tar.gz_* | tar xzvf - -C /target/directory\n"

#FILENAME=dataBackup-$TIME.tar.gz                                
#DESDIR=/dataBackup                                                  
#cat F.backup.tar.gz_* | tar xzvf -

# *****************************************************************************************************************************
# ************************************************** FUNCTIONS ****************************************************************


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                                     main menu
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
start()
{
clear
echo
#echo -e '\E[36;40m'"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"; echo -e '\E[0m'
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "                  Backup your files or folders"
#echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
#echo " Backup script, splits large files into multiple chuncks of"
#echo " 2GB files to be easilly managed by most media"
#echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"; echo -e '\E[0m'
#for i in {1..3}
#do
#	sleep 1
#	echo -n .
#done
#clear
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " 1. Run a full backup now"
echo " 2. Schedule a backup (Full/Incremental)"
echo " 3. Dump/Backup MySQL/MariaDB"
echo " 4. Restore data/sql"
echo " 5. Check for schedule"
echo " 6. About the script"
echo " 7. Exit."
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo -e '\E[36;40m'" NOTE: keep in mind that  script  uses  crontab  for schedulling"
echo " therefore any prior  schedule that might exist will be removed."
echo " Before   schedule   a  backup,  select  from  within  the  menu"
echo " \"check for schedule\"    and     make    a    note    of     it"; echo -e '\E[0m' 
#cursor is off
tput civis 
#tput cnorm cursor is on again
read -n 1 -s selection;
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                          select multiple source file or folders
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
multySrc()
{
tput cnorm
FE="n"
mSrcPath=""
while [ $FE == "n" ]
do
        echo "-------------------------------------------------------------------"
	echo  -en '\E[36;40m'"Enter source folder or file (ex. /etc) "; read -r source_path; echo -e '\E[0m'
        if [ ! -d $source_path ];then
                echo -en '\E[31;40m'"The directory does not exist!! check your path or filename "; echo -e '\E[0m'
        else
                printf "OK source path is valid: "
		echo -en '\E[32;40m'"$source_path/"; echo -e '\E[0m'
                if [ "$mSrcPath" == "" ];then
			mSrcPath="$source_path"
		else
			mSrcPath="$mSrcPath $source_path"
		fi
		echo "-------------------------------------------------------------------"
		echo  -en '\E[36;40m'"would you like to add another folder (y/n)"; echo -e '\E[0m'
        	read -n 1 -s yn;
        	if [ ${#yn} -eq 0 ] || [ "$yn" == "y" ];then
               		FE="n"
		else
			FE="y"
        	fi
        fi
done
echo "-------------------------------------------------------------------"
printf "your selection is: "
echo -en '\E[36;40m'"$mSrcPath"; echo -e '\E[0m'
echo "-------------------------------------------------------------------"
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                         set destination, destination check 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
jobNow()
{
	tput cnorm
	FE="n"
while [ $FE == "n" ]
do
	printf "Now enter the destination folder (ex. /backup) "
	read -r dest_path

	if [[ $dest_path =~ .*/boot.* ]] || [[ $dest_path =~ .*/proc.* ]] || [[ $dest_path =~ .*/etc.* ]] || [[ $dest_path =~ .*/sys.* ]] || [[ $dest_path =~ .*/dev.* ]] || [[ "$dest_path" == "/" ]] \
		|| [[ "$dest_path" == "/var" ]] || [[ "$dest_path" == "/usr" ]] || [[ "$dest_path" == "/bin" ]] || [[ "$dest_path" == "/lib" ]] || [[ "$dest_path" == "/lib64" ]];then
		echo -en '\E[31;40m'"The directory you have selected is not appropriate for destination"; echo -e '\E[0m'
	else
		if [ ! -d $dest_path ];then
                	echo -en '\E[31;40m'"The directory does not exist!! check your path or filename "; echo -e '\E[0m'
        	else
                	echo "-------------------------------------------------------------------"
			printf "OK destination path looks good: "
			echo -en '\E[32;40m'"$dest_path/"; echo -e '\E[0m'
			FE="y"
		fi
	fi
done
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                                 set which program to follow
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
setDates()
{
	yn=n
	tput civis
while [[ $yn =~ [nN](o)* ]]
do
	echo "-------------------------------------------------------------------"
	echo -en '\E[36;40m'"Select schedule program for your backup."; echo -e '\E[0m'
	echo "-------------------------------------------------------------------"
	echo " 1. Inc - Mon-Fri, Full Sat."
	echo " 2. Inc - Mon-Sat, Full Sun."
	read -n 1 -s prg
	if [[ $prg =~ ^[a-zA-Z] ]]
	then
		echo -en '\E[31;40m'" valid values are 1,2"; echo -e '\E[0m'
	else
		if [ $prg -lt 1 ] || [ $prg -gt 2 ]
		then
			echo -en '\E[31;40m'" valid values are 1,2"; echo -e '\E[0m'
		else
			echo "-------------------------------------------------------------------"
			echo -en '\E[36;40m'"continue with your selection:> $prg < (y/n)"; echo -e '\E[0m'
        		read -n 1 -s yn;
			if [ "$yn" = $'\n' ];then
   				yn=y
			fi
		fi
	fi
done
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                                      set time to backup
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
setTime()
{
	yn=n
while [[ $yn =~ [nN](o)* ]]
do
	echo "-------------------------------------------------------------------"
	echo "Enter start backup time, valid values {0..23}"
	read T
	
	if [[ $T =~ ^[a-zA-Z] ]]
	then
		echo -en '\E[31;40m'" valid values are {0..23}"; echo -e '\E[0m'
	else
		if [ $T -lt 0 ] || [ $T -gt 23 ]
		then
			echo -en '\E[31;40m'" valid values are {0..23}"; echo -e '\E[0m'
		else
			echo -en '\E[36;40m'"continue with your selection:> $T < (y/n)"; echo -e '\E[0m'
                        read -n 1 -s yn;
			if [ "$yn" = $'\n' ];then
				yn=y
			fi
		fi
	fi
done 
yn=n
while [[ $yn =~ [nN](o)* ]]
do
	echo "-------------------------------------------------------------------"
        echo "Please enter minutes, valid values{00..59}"
	read M

        if [[ $M =~ ^[a-zA-Z] ]]
        then
                echo -en '\E[31;40m'" valid values are {0..59}"; echo -e '\E[0m'
        else
                if [ $M -lt 0 ] || [ $M -gt 59 ]
                then
                        echo -en '\E[31;40m'" valid values are {0..59}"; echo -e '\E[0m'
                else
                        echo -en '\E[36;40m'"continue with your selection:> $M < (y/n)"; echo -e '\E[0m'
                        read -n 1 -s yn;
			if [ "$yn" = $'\n' ];then
				yn=y
			fi
                fi
        fi
done
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                                   schedule backup job
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
schedule()
{
	multySrc
	read dummy
	jobNow
	setDates
	setTime
if [ $prg -eq 1 ];then
	fname=$DN-$TIME.tar.gz
	iname=$IN-$TIME.tar.gz
	touch /root/backup.cron
	echo $M $T "* * 6       (tar --listed-incremental=snap --level=0 -cvzf - $mSrcPath | split -b 2000m - "$dest_path"/"$DN"-\`date \"+\\%Y\\%m\\%d-\\%H\\%M\\%S\"\`.tar.gz_)" >/root/bkcF.cron " > /var/log/myBackup.log 2>&1"
	echo $M $T "* * 1-5     (tar --listed-incremental=snap  -cvzf - $mSrcPath | split -b 2000m - "$dest_path"/"$IN"-\`date \"+\\%Y\\%m\\%d-\\%H\\%M\\%S\"\`.tar.gz_)" >>/root/bkcF.cron "> /var/log/myBackup.log 2>&1"
	#echo $M $T "* * 6	tar --listed-incremental=snap --level=0 -cvzf" $dest_path"/"$DN"-\`date \"+\\%Y\\%m\\%d-\\%H\\%M\\%S\"\`.tar.gz" $mSrcPath>/root/bkcF.cron "> /var/log/myBackup.log 2>&1"
	#echo $M $T "* * 1-5     tar --listed-incremental=snap  -cvzf" $dest_path"/"$IN"-\`date \"+\\%Y\\%m\\%d-\\%H\\%M\\%S\"\`.tar.gz" $mSrcPath>>/root/bkcF.cron "> /var/log/myBackup.log 2>&1"
	crontab /root/bkcF.cron
fi	

if [ $prg -eq 2 ];then
	touch /root/backup.cron
	echo $M $T "* * 0       (tar --listed-incremental=snap --level=0 -cvzf - $mSrcPath | split -b 2000m - "$dest_path"/"$DN"-\`date \"+\\%Y\\%m\\%d-\\%H\\%M\\%S\"\`.tar.gz_)" >/root/bkcF.cron "> /var/log/myBackup.log 2>&1"
        echo $M $T "* * 1-6     (tar --listed-incremental=snap  -cvzf - $mSrcPath | split -b 2000m - "$dest_path"/"$IN"-\`date \"+\\%Y\\%m\\%d-\\%H\\%M\\%S\"\`.tar.gz_)" >>/root/bkcF.cron "> /var/log/myBackup.log 2>&1"
#	echo $M $T "* * 0       tar --listed-incremental=snap --level=0 -cvzf" $dest_path"/"$DN"-\`date \"+\\%Y\\%m\\%d-\\%H\\%M\\%S\"\`.tar.gz" $mSrcPath>/root/bkcF.cron "> /var/log/myBackup.log 2>&1"
#	echo $M $T "* * 1-6     tar --listed-incremental=snap  -cvzf" $dest_path"/"$IN"-\`date \"+\\%Y\\%m\\%d-\\%H\\%M\\%S\"\`.tar.gz" $mSrcPath>>/root/bkcF.cron "> /var/log/myBackup.log 2>&1"
	crontab /root/bkcF.cron
fi
tput cnorm
if [ $? -eq 0 ];then
	echo "-------------------------------------------------------------------"
	echo -en '\E[36;40m'"schedule is now active. Use crontab -l to check your schedule plan."; echo -e '\E[0m'
	echo -en '\E[36;40m'"after job runs, logs can be found at /var/logs/myBackup.log"; echo -e '\E[0m'
	echo "-------------------------------------------------------------------"
else
	echo "-------------------------------------------------------------------"
        echo -en '\E[31;40m'"something wend wrong exit code: $?"; echo -e '\E[0m'
        echo -en '\E[31;40m'"check the log file at /var/log/myBackup.log"; echo -e '\E[0m'
	echo "-------------------------------------------------------------------"
fi
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                                      MySQL MariaDB backup
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sqlBackup()
{
	echo
	echo "-------------------------------------------------------------------"
	echo " 1. dump/backup all databases"
	echo " 2. dump/backup specific database"
	echo " 3. exit"
	echo "-------------------------------------------------------------------"
	read -n 1 -s sqlSel;
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                                      Backup all databases
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
allSql()
{
	tput cnorm
	echo "-------------------------------------------------------------------"
	printf "Enter mySQL root user or any other superUser: "
	read -r sUser
	(mysqldump -u$sUser -p --all-databases | gzip > $dest_path/allDatabases$TIME.sql.gz) >/var/log/myBackup.log 2>&1
	if [ $? -eq 0 ];then
                echo "-------------------------------------------------------------------"
                echo -en '\E[36;40m'"Backup finished successfull...check the backup folder"; echo -e '\E[0m'
                echo -en '\E[36;40m'"log is available at /var/log/myBackup.log"; echo -e '\E[0m'
                echo "-------------------------------------------------------------------"
        else
                echo "-------------------------------------------------------------------"
                echo -en '\E[31;40m'"the backup did not executed properly, exit status is: $?"; echo -e '\E[0m'
                echo -en '\E[31;40m'"check the log file at /var/log/myBackup.log"; echo -e '\E[0m'
                echo "-------------------------------------------------------------------"
        fi
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                                      Backup one datatbase
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
oneDB()
{
	tput cnorm
	echo "-------------------------------------------------------------------"
	printf "Enter mySQL root user or any other superUser: "
	read -r sUser
	printf "Enter valid database name: "
	read -r dbName
	(mysqldump -u$sUser -p $dbName |gzip > $dest_path/$dbName$TIME.sql.gz) >/var/log/myBackup.log 2>&1
	if [ $? -eq 0 ];then
                echo "-------------------------------------------------------------------"
                echo -en '\E[36;40m'"Backup finished successfull...check the backup folder"; echo -e '\E[0m'
                echo -en '\E[36;40m'"log is available at /var/log/myBackup.log"; echo -e '\E[0m'
                echo "-------------------------------------------------------------------"
        else
                echo "-------------------------------------------------------------------"
                echo -en '\E[31;40m'"the backup did not executed properly, exit status is: $?"; echo -e '\E[0m'
                echo -en '\E[31;40m'"check the log file at /var/log/myBackup.log"; echo -e '\E[0m'
                echo "-------------------------------------------------------------------"
        fi
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                                      Restore Menu
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
restoreSel()
{
	clear
	echo
	echo "-------------------------------------------------------------------"
	echo " 1. Restore data"
	echo " 2. Restore all-databases MySQL/MariaDB"
	echo " 3. Restore one database MySQL/MariaDB"
	echo " 4. Exit"
	echo "-------------------------------------------------------------------"
	read -n 1 -s resSel;
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                                      Restore all databases
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
restoreAll()
{
	clear
	echo -e '\E[36;40m'"-------------------------------------------------------------------"
	echo "example:  /dataBackup/allDatabases20171027-171744.sql.gz"; echo -e '\E[0m'
	printf "Please enter the path and database backup name: "
        read -r dbName
	printf "Enter mySQL root user or any other superUser: "
        read -r sUser
	gunzip < $dbName | mysql -u$sUser -p
	if [ $? -eq 0 ];then
                echo "-------------------------------------------------------------------"
                echo -en '\E[36;40m'"Restore finished successfull..."; echo -e '\E[0m'
                echo "-------------------------------------------------------------------"
        else
                echo "-------------------------------------------------------------------"
                echo -en '\E[31;40m'"Restore did not executed properly, exit status is: $?"; echo -e '\E[0m'
                echo "-------------------------------------------------------------------"
        fi
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                                      Restore one datatbase
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
restoreOne()
{
	clear
	echo -e '\E[36;40m'"-------------------------------------------------------------------"
        echo "example:  /dataBackup/allDatabases20171027-171744.sql.gz"; echo -e '\E[0m'
        printf "Please enter the path and database backup name: "
        read -r dbName
        printf "Enter mySQL root user or any other superUser: "
        read -r sUser
	printf "Enter the database name that will be replaced: "
	read -r dbN
        gunzip < $dbName | mysql -u$sUser -p $dbN
	if [ $? -eq 0 ];then
                echo "-------------------------------------------------------------------"
                echo -en '\E[36;40m'"Restore finished successfull..."; echo -e '\E[0m'
                echo "-------------------------------------------------------------------"
        else
                echo "-------------------------------------------------------------------"
                echo -en '\E[31;40m'"Restore did not executed properly, exit status is: $?"; echo -e '\E[0m'
                echo "-------------------------------------------------------------------"
        fi
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                                 selection case
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

start

case $selection in
	1) 	clear
		echo "-------------------------------------------------------------------"
		echo -en '\E[36;40m'"Run a full backup now:"; echo -e '\E[0m'
		echo "-------------------------------------------------------------------"
	   	multySrc
		jobNow
		echo
		echo "Start backing up..."
	;;
	2) 	clear
		echo "-------------------------------------------------------------------"
                echo -en '\E[36;40m'"Schedule a backup:"; echo -e '\E[0m'
		echo "-------------------------------------------------------------------"
		schedule
	;;
	3)	clear
		sqlBackup
		if [ $sqlSel -eq 1 ]; then 
			jobNow
			allSql 
		fi
		if [ $sqlSel -eq 2 ]; then 
			jobNow
			oneDB 
		fi
		if [ $sqlSel -eq 3 ]; then
                	exit
                fi
	;;
	4)	restoreSel
		clear
		if [ $resSel -eq 1 ]; then
                        echo -e '\E[36;40m'"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
			printf "$RestoreData"
			echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"; echo -e '\E[0m'
                fi
		if [ $resSel -eq 2 ]; then
                        restoreAll
                fi
		if [ $resSel -eq 3 ]; then
                        restoreOne
                fi
		if [ $resSel -eq 4 ]; then
                        exit
                fi
	;;
	5)	clear
		echo
		crontab -l
	;;
	6)	clear
		echo -e '\E[36;40m'"+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo " Purpose = (Full | Incremental) Backup's"
		echo " Created on 10/10/2017"
		echo " Original Author = G.Nikolaidis"
		echo " Contact = gnlinuz@yahoo.com"
		echo " Version 1.01"
		echo " Sing bellow co-author"
		echo " Co-Author:"
		echo " Date altered:"
		echo " Your modification:"
		echo " Conatct = "
		echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		printf "$LISENCE"
		echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"; echo -e '\E[0m'
	;;
	7)	echo " sagionara..."
		tput cnorm
		exit 0
	;;
	*) echo " choose: {1|2|3|4|5|6|7} "
	   exit 1
	;;
esac

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                                     run job NOW
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if [ $selection -eq 1 ];then
	(tar -cvzf - $mSrcPath | split -b 2000M - $dest_path/$DN$TIME.tar.gz_) > /var/log/myBackup.log 2>&1

	if [ $? -eq 0 ];then
        	echo "-------------------------------------------------------------------"
        	echo -en '\E[36;40m'"Backup finished successfull...check the backup folder"; echo -e '\E[0m'
        	echo -en '\E[36;40m'"log is available at /var/log/myBackup.log"; echo -e '\E[0m'
        	echo "-------------------------------------------------------------------"
	else
        	echo "-------------------------------------------------------------------"
        	echo -en '\E[31;40m'"the backup did not executed properly, exit status is: $?"; echo -e '\E[0m'
        	echo -en '\E[31;40m'"check the log file at /var/log/myBackup.log"; echo -e '\E[0m'
        	echo "-------------------------------------------------------------------"
	fi

fi
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tput cnorm
# END OF SCRIPT
