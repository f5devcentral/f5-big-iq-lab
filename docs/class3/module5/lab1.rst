Lab 5.1: TCP Analytics: how to add a user-provided key
------------------------------------------------------

In the BIG-IQ UI, go to Applications > Application Templates. Notice there are two different types of Templates
(AS3 Templates and Service Catalog Templates). AS3 Templates are the recommended templates for deploying new
application services. Service Catalog Templates while still supported, are not recommended for new environments.

In this lab you will utilize some of the new templates that have the TCP analytics profiles built in. Note the
**Import Templates** hyperlink in the top right hand corener of the page. This link will take you to the **f5devcentral/f5-big-iq**
repository on Github, where F5 will push new templates.  

Import AS3 template called ``AS3-F5-HTTP-lb-TCP-analytics-key-template-big-iq-default`` 

from https://github.com/f5devcentral/f5-big-iq and use switch template feature.
