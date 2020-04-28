Module 6: Visibility for Legacy applications in the Applications tab (new 7.1)
==============================================================================

**[New 7.1.0]**

In BIG-IQ v6.0 F5 introduced the Application dashboards which provided customers deep insights into their
application health and performance. The dashboards have been well received by F5 customers as they provide
an easy way to drill into a specific application to see how it's performing or to troubleshoot an issue 
related to that application. Unfortunately to take advantage of the new dashboards existing applications would 
need to be re-deployed using one of the many application templates. This meant that the Application dashboards would 
only be relevant to newer applications that are deployed and not to the many legacy/brownfield applications
that already exist. 

While many customers are eager to move towards templated configurations to simplify their environments, they 
may not have been in a position to re-deploy their current applications just to gain the per-application views
provided in the new dashboards. They are still able to get Analytics under the **Monitoring** tab, but the Analytics
are presented in a more aggregated fashion vs. the per-application views in the **Application** dashboard.

In BIG-IQ v7.1, an admin can now add “legacy” (or “brownfield”) applications into the Application dashboard 
without having to re-deploy the application using a template. The Legacy applications will provide the same
analytic views as those applications deployed via a template, however the configuration sections are read-only, 
except for enable, disable, force-offline operations for Pools and Virtual Servers.

For more information about requirements and recommendations for creating a BIG-IQ Application Service with existing device configurations, please consult `K02142132`_.

.. _K02142132: https://support.f5.com/csp/article/K02142132

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
