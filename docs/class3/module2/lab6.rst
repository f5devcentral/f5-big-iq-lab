Lab 2.6: Troubleshooting Security (massive attack)
--------------------------------------------------
Connect as **larry**

1. Larry disable the Web Application Security for ``templates-default`` ASM Policy.

Go to Configuration > SECURITY > Web Application Security > Policies, select ``templates-default`` ASM Policy.

Go to POLICY PROPERTIES > General Properties and check **Automatic** is set for the Learning Mode.

.. image:: ../pictures/module2/img_module2_lab6_1a.png
  :align: center
  :scale: 50%

Go to POLICY BUILDING > Settings and check **Automatic** is set for the Learning Mode, and Auto-Deploy Policy set to **Real Time**.

.. image:: ../pictures/module2/img_module2_lab6_1b.png
  :align: center
  :scale: 50%

.. note:: The intent for the initial release 6.0 was to be able to push a basic (negative only) security policy that can provide a basic level of protection for most applications. For 6.0, it is recommended that learning shouldn’t be enabled with app templates – it should be a fundamental policy.

.. list-table:: Default ASM Policy details ``templates-default``
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

|

2. Update the Enforcement Mode to ``Blocking``

Go to POLICY PROPERTIES > General Properties

.. image:: ../pictures/module2/img_module2_lab6_2.png
  :align: center
  :scale: 50%

|

Save and Close.

Connect as **paula**

Select ``site36.example.com``

1. Paula enforce the policy: APPLICATION SERVICES > Security > CONFIGURATION tab > click on ``Start Blocking``

.. image:: ../pictures/module2/img_module2_lab6_3.png
  :align: center
  :scale: 50%

|

.. note:: The Enforcement Mode is controlled by the Application owner, the Host Name of the application (FQDN) will be configured in the ASM Policy to enforce it (or not)

.. image:: ../pictures/module2/img_module2_lab6_3a.png
  :align: center
  :scale: 50%

2. Connect on the *Ubuntu Lamp Server* server and launch the following command:

``# /home/f5/scripts/generate_http_bad_traffic.sh``

3. Check the various Security Analytics: Illegal Transactions, All Transactions and Violations.

.. image:: ../pictures/module2/img_module2_lab6_4.png
  :align: center
  :scale: 50%

4. Stop the bad traffic script, connect on the *Ubuntu Lamp Server* server and ``CTRL+C``.
