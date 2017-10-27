#gnBackup

Welcome to gnBackup script.
To  run  this  script (chmod 755  gnBackup) and just type  ./gnBackup
This  is  a  simple  script,  to  backup  your  files and folders. It 
simply uses tar command to tarball your files, zipping them, and then
splitting  them   in   to    chunks    of  2GB   file  size.  You can
backup  files  NOW  or  have  a  schedule  (full/incremental)  backup 
NOTE: because this  script  uses crontab for the user you are running
the script,  existing  crontab  schedule  will  be cleared !! You can
backup your current crontab schedule in a file (cronBackup.cron) by 
typing the following command crontab -l > cronBackup.cron. 
You can dump  backup  one (MySQL/MariaDB)  database or  all databases
You can also Restore  one (MySQL/MariaDB)  database or  all databases  
This  project  is  still   under   development, but fully functional.
So far it has been  tested  on  RedHat  and  centOS without problems. 
Please fill free to test it and have fun!
