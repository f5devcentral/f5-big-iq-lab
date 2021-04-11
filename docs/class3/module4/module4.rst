Module 4: Analytics for TCP based Applications (new 7.1)
========================================================

Prior releases of BIG-IQ supported detailed HTTP analytics which help admin's understand the health and 
performance of their HTTP based applications. Customers may have other types of applications within their
environment that utilize other protocols beyond HTTP or they may want additional TCP analytics for HTTP applications. A common request was to add analytics support for 
layer4/TCP based applications that are commonly used. BIG-IP is able to track very detailed analytics 
information for the TCP protocol and BIG-IQ v7.1 now exposes those analytics in both the **Application** and 
**Monitoring** dashboards.

TCP analytics are harvested from AVR on the BIG-IP in the same way that the HTTP analytics are 
(via an analytics profile). To utilize this feature the BIG-IP's must be running TMOS version 13.1.0.5 or 
later, and have AVR provisioned.

To make adoption of TCP analytics easier a couple of AS3 templates have been published that utilize these new TCP 
analytics profiles. You can go to the **f5devcentral/f5-big-iq** repository on Github below to see the new templates:

https://github.com/f5devcentral/f5-big-iq

In addition to supporting TCP analytics for applications deployed via AS3 (UI or API), the new Legacy/Brownfield
Application Service feature added in v7.1 also provides a TCP dashboard which can be enabled by adding the proper TCP analytics profile.

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
