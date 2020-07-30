Module 3: Automate device backups and archiving
================================================

BIG-IQ provides the ability to backup individual or groups of managed
devices on an ad-hoc or a scheduled basis. The admin can decide how long
to retain the backups on BIG-IQ and has the option of archiving a copy
of the UCS backup off to an external device for DR or deeper storage
purposes.

**BACKUPS & RESTORE**

- Talk about the ability to create scheduled or ad-hoc backups
- When creating a backup or backup schedule, you have the same options as you do when creating a backup on the BIG-IP (backup private keys and encrypt backup)
- The next section of the backup job specifies how long to retain a copy of the backup on the BIG-IQ:
- Never delete – retains the backup until someone specifically deletes it
- Delete the backup after N days - will delete the backup when that expiration date is reached
- Keep the last X backups – after the current backup completes, delete the oldest backup for this schedule
- Talk about the scheduling options
- Talk about the archive backup option – after a backup is brought to BIG-IQ, a copy of that backup can be archived off via SCP or SFTP to another server for DR or longer storage purposes.

.. toctree::
   :maxdepth: 1
   :glob:

   lab*