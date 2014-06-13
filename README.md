WordPress Backup
===============

This script is designed to backup any number of WordPress sites without the use of a plugin. 

Having this on the server level means that even if your site gets compromised or you lose the admin login you can still recover it.

You currently need two scripts downloaded to the server.

1. WordPressBackup.sh
2. Backup.profile

WordPressBackup.sh is the main script that does all the heavy lifting.
Backup.profile is what tells the script which directory to backup and how long to keep those backups.
