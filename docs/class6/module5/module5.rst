Module 5: LTM conflict resolution: silo in BIG-IQ (new 7.1)
===========================================================

**[New 7.1.0]**

When importing a BIG-IP device's services, BIG-IQ compares the objects in 
its working configuration to the objects in the BIG-IP device's current configuration.

If BIG-IQ finds the same type of object with the same name but different parameters, 
it notifies you of the conflict. 

Starting with BIG-IQ 7.1, you can now import conflicting devices into a “silo” on BIG-IQ.

Think of this as a quarantine area that doesn’t impact the rest of BIG-IQ and allows 
you to rename the configuration objects on BIG-IP using BIG-IQ.

Once all of the conflicting objects that need to remain unique have been renamed, 
the device can be imported fully into BIG-IQ.

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
