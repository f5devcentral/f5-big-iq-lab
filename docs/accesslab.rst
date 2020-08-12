Lab environment access
^^^^^^^^^^^^^^^^^^^^^^

You will find 2 ways to access the different systems in this lab.
   - From the Jump Host:
      From the lab environment, launch an remove desktop session to access the Ubuntu Desktop. 
      To do this, in your lab deployment, click on the *ACCESS* button of the **Ubuntu Lamp Server** system and click on
      *noVNC*. The password is ``purple123``.
      
      You can also use *XRDP*, click on the resolution that works for your laptop. 
      When the RDP session launches showing *Session: Xorg*, simply click *OK*, no credentials are needed.

      .. note:: Modern laptops with higher resolutions you might want to use 1440x900 and once XRDP is launched Zoom to 200%

      |udf_ubuntu_rdp_vnc|

   - Going directly to the BIG-IQ CM or BIG-IP TMUI or WEB SHELL/SSH
      To access the BIG-IQ directly, click on the ACCESS button under **BIG-IQ CM**
      and select TMUI. The credentials to access the BIG-IQ TMUI are ``david/david`` and ``paula/paula`` as directed in the labs.

      |udf_bigiq_tmui|

      .. note:: You can also click on *DETAILS* on each component to see the credentials (login/password)

      To ssh into a system, you can click on WEB SHELL or SSH (you will need your ssh keys setup in the lab environment for SSH).

.. |udf_ubuntu_rdp_vnc| image:: /pictures/udf_ubuntu_rdp_vnc.png
   :scale: 60%

.. |udf_bigiq_tmui| image:: /pictures/udf_bigiq_tmui.png
   :scale: 60%
