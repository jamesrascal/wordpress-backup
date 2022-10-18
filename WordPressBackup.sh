#!/bin/bash
# Author Roger Gentry (jamesrascal) - Host Kraken
# WP BACKUPS V1.9
# Build date 07/14/2014

# Parse flags
quiet=0
while getopts ":hq" opt; do
        case ${opt} in
                h )
                        echo "Usage:"
                        echo "    WordPressBackup.sh -h       Display this help message."
                        echo "    WordPressBackup.sh -q       Run quietly-output only on errors."
                        exit 0
                ;;
                q )
                        quiet=1
                ;;
                \? )
                        echo "Invalid Option: -$OPTARG" 1>&2
                        exit 1
                ;;
        esac
done
shift $((OPTIND -1))

# Path where backup profiles are stored
FINDDIR=/home/centos/backups/profiles/

# Searches for the backup.profile 
profile=$(find ${FINDDIR} -wholename "*backup.profile" )

for backupprofile in $profile ; do
	if [ "${quiet}" = "0" ]; then
		echo "********************************************************************";
		echo "Using Profile: ${backupprofile}";
	fi
	. $backupprofile
                
	if [ "${backup_enabled}" = "1" ]; then
		wp_config=${wp_root}/wp-config.php
		# Verifing that wp-config is in the location
		if [ ! -f "$wp_config" ]; then
			echo "No WP-Config.php Found Attempting to find one";
			# Checks the directory above WP_root
			cd $wp_root
			wp_config=../wp-config.php

			# IF wp-configstill not found
			if [ ! -f "$wp_config" ]; then
				echo "FATAL ERROR: wp-config.php is missing from a readable state";
				echo "Does $wp_domain still work?";
			fi
		fi

		# Verifing wp_config exists
		if [ -f "$wp_config" ]; then
			# BackupName Date and time
			backupname=$(date +%Y-%m-%d)

			# Pulls Database info from WP-config
			db_name=$(grep DB_NAME "${wp_config}" | cut -f4 -d"'")
			db_user=$(grep DB_USER "${wp_config}" | cut -f4 -d"'")
			db_pass=$(grep DB_PASSWORD "${wp_config}" | cut -f4 -d"'")
			db_host=$(grep DB_HOST "${wp_config}" | cut -f4 -d"'")
			table_prefix=$(grep table_prefix "${wp_config}" | cut -f2 -d"'")

			# Which files & sub-directories to backup of the root directory
			if [ "${file_list}" = "" ]; then
				file_list_bckp=${wp_root}
			else
				files=(${file_list})
				file_list_absolute=""
				for i in "${!files[@]}"
				do
				        file_list_absolute="${file_list_absolute} ${wp_root}/${files[i]}";
				done
				file_list_bckp=${file_list_absolute}
			fi

			# Creates a Backup Directory if one does not exist.
			mkdir -p ${backup_location}/${user}/${wp_domain}/

			# Make Backup location the current directory
			cd ${backup_location}/${user}/${wp_domain}

			# MySQL Takes a Dump and compress the Home Directory
			if [ "${compressed_tar_file}" != false ]; then
				mysqldump -u ${db_user} --host ${db_host}  -p${db_pass} ${db_name} | gzip > ./${backupname}-DB.sql.gz &&
				tar zcPf ./${backupname}-FILES.tar.gz ${file_list_bckp}
				
				# Compresses the MySQL Dump and the Home Directory
				tar zcPf ./${wp_domain}-${backupname}.tar.gz ./${backupname}-FILES.tar.gz ./${backupname}-DB.sql.gz
				chmod 600 ./${wp_domain}-${backupname}.tar.gz

				# Generates the Backup Size
				#FILENAME=${backup_location}/${user}/${wp_domain}/${wp_domain}-${backupname}.tar.gz
				FILENAME=${wp_domain}-${backupname}.tar.gz
				FILESIZE=$(du -h "$FILENAME")
				if [ "${quiet}" = "0" ]; then
					echo "$FILESIZE"
				fi

				#Removes the SQL dump and Home DIR to conserve space
				rm -rf ./${backupname}-FILES.tar.gz ./${backupname}-DB.sql.gz

			else
				mysqldump -u ${db_user} --host ${db_host}  -p${db_pass} ${db_name} | gzip > ./${backupname}-DB.sql.gz &&
				tar -cPf ./${backupname}-FILES.tar ${file_list_bckp}

				# Generates the Backup files Size
				if [ "${quiet}" = "0" ]; then
					#FILENAME=${backup_location}/${user}/${wp_domain}/${backupname}-DB.sql.gz
					FILENAME=${backupname}-DB.sql.gz
					FILESIZE=$(du -h "$FILENAME")
					echo "$FILESIZE"

					#FILENAME=${backup_location}/${user}/${wp_domain}/${backupname}-FILES.tar
					FILENAME=${backupname}-FILES.tar
					FILESIZE=$(du -h "$FILENAME")
					echo "$FILESIZE"
				fi

			fi
			
			#Deletes any Backup older than X days
			find ${backup_location}/${user}/${wp_domain}/ -type f -mtime +${keepdays} -exec rm {} \;
		fi
	fi

	if [ "${backupenabled}" = "0" ]; then
		echo "Backups NOT enabled for ${wp_root}";
	fi
done

if [ "${quiet}" = "0" ]; then
	echo " ";
	echo "********************************************************************";
	echo "This script is licensed under GPL https://github.com/jamesrascal/wordpress-backup/";
	echo "Run Date: $(date +%Y-%m-%d-%k-%M)";
fi
