Lab 6.4: Convert a BIG-IQ Service Catalog Application Service to a Legacy Application Service
---------------------------------------------------------------------------------------------

.. note:: Estimated time to complete: **10 minutes**

The original Application Templates on BIG-IQ (introduced in v6.0) provided a graphical UI that allowed administrators to easily templatize and deploy applications.
However, this initial implementation of Application Templates on BIG-IQ was not compatible with AS3. Those templates are called on BIG-IQ "Service Catalog Templates".

F5 highly recommend to use AS3 Application Templates over the original Application Templates as they are not being enhanced going forward.

If you have existing application services deployed with the original Application Templates (*BIG-IQ Service Catalog*), 
you could either translate and re-deploy it using AS3 or convert it to an Legacy Application Service on BIG-IQ.

More information is also available on the following knowledge article https://support.f5.com/csp/article/K87924313.

In this lab, we are going to convert the BIG-IQ Service Catalog Application Service called ``site36.example.com`` under ``IT Apps`` to a Legacy Application Service.

.. include:: /accesslab.rst

Tasks
^^^^^

1. Connect via ``SSH`` to the **BIG-IQ CM** and create the following python script which will be used later on::

    vi /home/admin/f5_remove_app_tags.py

.. code-block:: python

    #!/usr/bin/env python

    import requests
    import json
    import argparse

    class Cleanup:
        def get_arguments(self):
            parser = argparse.ArgumentParser(description='Remove Tags from Config tab in BIG-IQ.')
            parser.add_argument("--configSetName", type=str, help="The Application Service ConfigSet name.")

            return parser.parse_args()


        def delete_tags(self, configSetName):
            url = 'http://localhost:8100/shared/index/config?$filter=tags/value%20eq%20%27' + str(configSetName) + '%27+and+kind+ne+%27cm:global:tasks:snapshot-config:snapshottaskstate%27&$select=kind,selfLink&$orderby=kind'
            response = requests.get(url)
            jData = json.loads(response.content)

            if(response.ok):
                print("The response contains {0} properties".format(len(jData['items'])))
                print("\n")
                for item in jData['items']:
                    itemUri = item['selfLink'].replace('https://localhost/mgmt', 'http://localhost:8100')
                    itemResponse = requests.get(itemUri, auth=('admin', ''))
                    itemData = json.loads(itemResponse.content)
                    print(item['selfLink'])
                    tags = itemData['tags']
                    for i in xrange(len(tags)):
                        if tags[i]["name"] == "BIGIQ_configSetName":
                            tags.pop(i)
                            break

                    for i in xrange(len(tags)):
                        if tags[i]["name"] == "BIGIQ_templateResourceName":
                            tags.pop(i)
                            break

                    itemData['generation'] = 0
                    itemData['lastUpdateMicros'] = 0
                    data = {"tags":tags}
                    patchRequest = requests.patch(itemUri, data=json.dumps(data), auth=('admin', ''))
                    print(patchRequest)

            else:

                response.raise_for_status()


        def main(self):
            args = self.get_arguments()
            print(args)
            self.delete_tags(args.configSetName)

    if __name__ == "__main__":

        cleanup = Cleanup()
        cleanup.main()

.. note:: `How to Use the vi Editor`_
.. _How to Use the vi Editor: https://www.cs.colostate.edu/helpdocs/vi.html

2. The first step is to force-delete the Application Service on the BIG-IQ, execute the following command from BIG-IQ CLI::

    restcurl -X POST /cm/global/tasks/force-delete -d '{"configSetName": "site36.example.com"}'

You can follow the force-delete task by running the following command (replace the correct id at the end of the URL)::

     restcurl /cm/global/tasks/force-delete/f838bf4d-a8f0-4317-b59b-ced48b901dff

.. warning:: The following AS3 Force-Delete API will force the delete of the service catalog application from the BIG-IQ only. 
             This API cannot remove the related objects from the BIG-IP. Using this API is not recommended except for certain recovery cases that 
             require the forced removal of an application from the BIG-IQ only.

3. Due to a known issue which does not remove the tags on the objects deployed with a Service Catalog template, we need to remove them with the previously created python script, execute from BIG-IQ::

    cd /home/admin/
    chmod +x f5_remove_app_tags.py
    ./f5_remove_app_tags.py --configSetName site36.example.com

4. Navigate to the Device tab click under services for both **BOS-vBIGIP01.termmarc.com** and **BOS-vBIGIP02.termmarc.com** and re-discover and re-import the LTM module on the BIG-IP.

5. Follow steps described in `Lab 6.1`_ to re-create the Application Service ``site36.example.com`` in BIG-IQ dashboard.

.. _Lab 6.1: ./lab1.html

+----------------------------------------------------------------------------------+
| Application properties:                                                          |
+----------------------------------------------------------------------------------+
| * Grouping = Existing Application                                                |
| * Application Name = ``IT_Apps``                                                 |
+----------------------------------------------------------------------------------+
| Application Service Method properties:                                           |
+----------------------------------------------------------------------------------+
| Select: Using Existing Device Configuration                                      |
+----------------------------------------------------------------------------------+
| General Properties:                                                              |
+----------------------------------------------------------------------------------+
| * Application Service Name = ``site36.example.com``                              |
| * Target = ``BOS-vBIGIP01.termmarc.com``                                         |
| * Application Service Type = ``HTTP + TCP``                                      |
+----------------------------------------------------------------------------------+
| Virtual Servers: ``virtual - 10.1.10.136``                                       |
+----------------------------------------------------------------------------------+

6. Follow steps described in `Lab 6.3`_ assign the ``site36.example.com`` Manager role to **Paula** so she can access it in her BIG-IQ dashboard.

.. _Lab 6.3: ./lab3.html