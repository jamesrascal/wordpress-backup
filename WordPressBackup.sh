#!/bin/bash
# Author Roger Gentry (jamesrascal) - Host Kraken
# WP BACKUPS V1.7
# Build date 04/18/2014

#Adjust this to where you websites are stored.
FINDDIR=/home/

#Searches for the backup.profile in the web directory.
profile=$(find ${FINDDIR} -inname "*backup.profile" )

for backupprofile in $profile ; do
echo "********************************************************************";
echo "Using Profile: ${backupprofile}";
. $backupprofile
                if [ "${backupenabled}" = "1" ]; then
                                #BackupName Date and time
                                backupname=$(date +%m%d%y)
                                echo "Backing up WordPress site at ${wp_root}";
                                #Pulls Database info from WP-config
                                db_name=$(grep DB_NAME "${wp_root}/wp-config.php" | cut -f4 -d"'")
                                db_user=$(grep DB_USER "${wp_root}/wp-config.php" | cut -f4 -d"'")
                                db_pass=$(grep DB_PASSWORD "${wp_root}/wp-config.php" | cut -f4 -d"'")
                                table_prefix=$(grep table_prefix "${wp_root}/wp-config.php" | cut -f2 -d"'")

                                #Creates a Backup Directory
                                mkdir -p ${bulocation}/${user}/
                                mkdir -p ${bulocation}/${user}/${wpdomain}/

                                #Mysql Takes a Dump and compress the Home Directory
                                mysqldump -u ${db_user} -p${db_pass} ${db_name} > ${bulocation}/${user}/${wpdomain}/${backupname}.sql &&
                                tar zcPf ${bulocation}/${user}/${wpdomain}/${backupname}.tar.gz ${wp_root}

                                #Compresses the dump + Home Directory
                                tar zcPf ${bulocation}/${user}/${wpdomain}/WPBACKUP-${backupname}.tar.gz ${bulocation}/${user}/${wpdomain}/${backupname}.tar.gz ${bulocation}/${user}/${wpdomain}/${backupname}.sql

                                # Generates the Backup Size
                                FILENAME=${bulocation}/${user}/${wpdomain}/WPBACKUP-${backupname}.tar.gz
                                FILESIZE=$(du -h "$FILENAME")
                                echo "$FILESIZE"

                                #Removes the SQL dump and Home DIR to conserve space
                                rm -rf ${bulocation}/${user}/${wpdomain}/${backupname}.tar.gz ${bulocation}/${user}/${wpdomain}/${backupname}.sql

                                #Deletes any Backup older than X days
                              find ${bulocation}/${user}/${wpdomain}/ -type f -mtime +${keepdays} -exec rm {} \;
                fi
                if [ "${backupenabled}" = "0" ]; then
                                echo "Backups NOT enabled for ${wp_root}";
                fi
done
echo " ";
echo "********************************************************************";
echo "This script is licensed under GPL https://github.com/jamesrascal/wordpress-backup/";
echo "Run Date: $(date +%m%d%y%k%M)";
