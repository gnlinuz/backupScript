#gnBackup

Welcome to gnBackup script
This is a simple script, to  backup  your  files and folders where it 
simply uses tar command to tarball your files, zipping them, and then
splitting  them in to  chunks  of  2GB  (default) file size.  You can
backup  files  NOW  or  have  a  schedule  (full/incremental)  backup 
NOTE: because this  script  uses crontab for the user you are running
the script any  other  crontab  schedule  will  be cleared !! You can
backup your current crontab schedule in a file (cronBackup.cron) from 
the main menu.
This  project  is  still   under   development,  which  is  an  early
release  but fully  operational.  So far it has been tested on RedHat 
and centOS without problems. Please fill free to test it and have fun. 
