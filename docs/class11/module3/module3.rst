Module 3: DDoS Monitoring and Dashboard
=======================================

Goal:

In this lab, we will generate attack traffic to the *BOS* BIG-IP being managed by BIG-IQ 6.1 with DCDs. When BIG-IP is configured to send DoS logs to the DCD, BIG-IQ can display a near real time DoS Dashbaord for visibility and analysis.   

Reviewing the DDoS Monitoring Dashboard:

- Protection Summary: Global view of high level Attacks, Devices, and Protected Objects
- DNS Overview: Dashboard for protecting DNS based services which includes details on DNS Traffic, stats, counters
- DNS Analysis: Dashboard for DNS DoS analysis including TPS, query types, and Geo Data when available
- HTTP Analysis: Dashboard for HTTP DoS analysis including TPS, query types, and Geo Data when available
- Network Analysis: Dashboard for Network based DoS analysis including Event types, DoS attack Types, and Geo Data when available
- Attack History: Listing of attacks in reverse chronological order

In addition to the Dashboards, there are other ways of extracting and reporting on data. 

- The Reports tab allows for creating reports from BIG-IPs, which are issued on demand and the data pushed from BIG-IP (HTTPS must be allowed *into* the BIG-IQ from the BIG-IPs)
- The Events->DoS tab provides search/listing and filtering on individual Event logs sent to BIG-IQ on various DoS and protocol logs. 

.. toctree::
   :maxdepth: 1
   :glob:

   lab*

