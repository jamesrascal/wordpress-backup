WordPress Backup
===============

This lightweight script is designed to backup any number of WordPress sites without the use of a plugin. 

Features:

- Server Level Backups.
- Easy to intergrate RSync or FTP to transfer to remote server.
- Combines SQL Database and Only the WordPress files for easy restores.
- Can be set on a cron job.


There are 2 parts to this script:

1. WordPressBackup.sh
    - the main script that does all the heavy lifting.
2. Backup.profile
    - the configuration profile that manages the retention policy

How to use:

1. Download the script.
2. Copy and Modify the backup.profile.
3. Place backup.profile in the directory above your WordPress install or /home/username/
4. chmod +x WordPress-Backup
5. ./WordPress-Backup 
    Depending on where you put your backup.profile you may need to modify the main script's FINDDIR.

