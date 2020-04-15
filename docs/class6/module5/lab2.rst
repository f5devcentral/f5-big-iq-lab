Lab 5.2: Resolve conflicts in the silo
--------------------------------------
``Ça arrive bientôt זה בקרוב Viene pronto すぐに来る Sta arrivando presto قادم قريبا Coming soon 即將到來``

Are you interested to see a lab on this topic? `Open an issue on GitHub`_

.. _Open an issue on GitHub: https://github.com/f5devcentral/f5-big-iq-lab/issues

HTTP Profile: ``silo-lab-http-profile``

- BOS-vBIGIP01.termmarc.com, BOS-vBIGIP02.termmarc.com and SEA-vBIGIP01.termmarc.com

+--------------------------+----------+
| Allow Truncated Redirect | Enabled  |
+--------------------------+----------+
| Accept XFF               | Disabled |
+--------------------------+----------+
| Insert X-Forwarded-For   | Disabled |
+--------------------------+----------+

- SJC-vBIGIP01.termmarc.com

+--------------------------+----------+
| Allow Truncated Redirect | Disabled |
+--------------------------+----------+
| Accept XFF               | Enabled  |
+--------------------------+----------+
| Insert X-Forwarded-For   | Enabled  |
+--------------------------+----------+