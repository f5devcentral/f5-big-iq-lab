Module 1: Advanced Web Application Firewall (WAF) on BIG-IQ
===========================================================

In this class, we will review the Advanced Web Application Firewall (WAF) in BIG-IQ.

.. list-table:: Details on default ASM Policy ``templates-default`` available in BIG-IQ.
   :header-rows: 0

   * - Data Guard:
		      * Protect credit card numbers
		      * Protect U.S. Social Security numbers
		      * Mask sensitive data
   * - Brute Force Attack Prevention:
		      * default policy
   * - Headers:
      		* methods allow GET/HEAD/POST
      		* HTTP headers \*/authorization/referer check signatures, referer Perform Normalization
      		* Cookies * allow
      		* Redirection Protection allow
      		* Character Set (list of allow/disallow)
   * - URLs:
      		* HTTP * allow
      		* Web Sockets * allow
      		* Character Set (list of allow/disallow)
   * - FILE TYPES:
      		* Allow file types *
      		* Disallowed file types => list (e.g. bak, bat, bkp ...)
   * - CONTENT PROFILES:
      		* JSON (list of allow/disallow)
      		* Plain Text (list of allow/disallow)
      		* XML (list of allow/disallow)
   * - PARAMETERS:
      		* Parameters: * user inputs Attack Signatures enabled
      		* SensitiveParameters: password
   * - Attack Signatures Configuration: enabled
   * - Attack Signatures: numbers enabled
   * - Sessions and logins: disabled

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
