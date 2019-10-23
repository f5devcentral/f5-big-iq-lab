Lab 4.3: BIG-IQ Analytics and Splunk
------------------------------------

**Prerequisites Splunk**

- This demo is using a instance of Splunk running in a `container`_.
- An `HTTP Event Collector`_ listening on port 8088 to receive JSON events has been configured.

.. _container: https://hub.docker.com/r/splunk/splunk/
.. _HTTP Event Collector: https://dev.splunk.com/enterprise/docs/dataapps/httpeventcollector/

**Custom script to export BIG-IQ analytics and send them over to Splunk**

Setup a script in the cron table on a Linux machine where the container runs to fetch the BIG-IQ analytics data using the API in 7.0 every X min

POST /mgmt/ap/query/v1/tenants/default/products/local-traffic/metric-query => JSON result file with the analytics requested

The event in JSON format are received every minute with the analytics requested (in the example transactions)

Built a Slunk Dashboard based on the JSON values of the events collects (in this example the transactions)

``index = "main" |table _time,result.result{}.transactions$avg-count-per-sec | rename result.result{}.transactions$avg-count-per-sec as transactions | spath``
