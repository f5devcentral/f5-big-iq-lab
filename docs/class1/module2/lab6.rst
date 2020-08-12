Lab 2.6: Enable/Disable Enhanced Analytics via API for AS3 apps on BIG-IQ
-------------------------------------------------------------------------

.. note:: Estimated time to complete: **5 minutes**

.. include:: /accesslab.rst

Tasks
^^^^^

Using Postman, you can turn Enhanced Analytics on/off directly by updating below attributes within your AS3 declaration:

.. code-block:: JSON
   :linenos:

    "statsProfile": {
         "class": "Analytics_Profile",
         "collectClientSideStatistics": true/false,
         "collectGeo": true/false,
         "collectMethod": true/false,
         "collectOsAndBrowser": true/false,
         "collectSubnet": true/false,
         "collectUrl": true/false,
         "collectIp": true/false,

          ...
    }

.. note:: For more details on the Analytics profile, look at the `AS3 schema`_.

.. _AS3 schema: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#analytics-profile