**********
TDT System 
**********

Structure of TDT System
-----------------------

Data are mainly stored in tdt.streams and tdt.epocs. 

* Streams standardized naming rules:

    * All data is stored using four capital letters, e.g. UDLP, DBSS and STPD.
    
    * Starting with capital letter U represents Utah array recordings, e.g. UDLP are utah array data recording in DLP.

    * Starting with capital letter U represent DBS recordings, e.g. DBSS are DBS recording in STN.

    * STPD, TASK and EYET represent startpad signal, 4-bit event task codes and eye tracking data. 

.. csv-table:: Table Title
    :file: tables/table_tdtField.csv
    :header-rows:1

* tdt field Description

.. table:: Each tdt field in details 
+-----------+-----------+--------------------------------------------------------------------+
| tdt field | sub-field | description                                                        |
+===========+===========+====================================================================+
|           | Cam1      |                                                                    |
|   epocs   +-----------+ Cam1/2: onset and offset time of each frame                        |
|           | Cam2      |                                                                    |
+-----------+-----------+--------------------------------------------------------------------+
|           | UDLP      | Utah array data recordings in dorsolateral prefrontal cortex (DLP) |
|           |           |                                                                    |
|           |           | [n_chns,  n_temporal]                                              |
|           +-----------+--------------------------------------------------------------------+
|           | UMCX      | Utah array data recordings in motor cortex (MC)                    |
|           |           |                                                                    |
|           |           | [n_chns,  n_temporal]                                              |
|           +-----------+--------------------------------------------------------------------+
|           | UPMC      | Utah array data recordings in premotor cortex (PMC)                |
| streams   |           |                                                                    |
|           |           | [n_chns,  n_temporal]                                              |
|           +-----------+--------------------------------------------------------------------+
|           | DBSS      | DBS recordins in STN                                               |
|           |           |                                                                    |
|           |           | [n_chns,  n_temporal]                                              |
|           +-----------+--------------------------------------------------------------------+
|           | DBSG      | DBS recordings in GP                                               |
|           |           |                                                                    |
|           |           | [n_chns,  n_temporal]                                              |
|           +-----------+--------------------------------------------------------------------+
|           | EYET      | x,y positions of eyes from eye tracking system                     |
|           |           |                                                                    |
|           |           | [2, n_temporal]                                                    |
|           +-----------+--------------------------------------------------------------------+
|           | TASK      | 4-bit event codes from GoNogo/COT task program.                    |
|           |           |                                                                    |
|           |           | [4,  n_temporal]                                                   |
|           +-----------+--------------------------------------------------------------------+
|           | STPD      | Startpad signal                                                    |
|           |           |                                                                    |
|           |           | [1,  n_temporal]                                                   |
+-----------+-----------+--------------------------------------------------------------------+
                                                          Example dataset: Barb-220324\Block-2


NWB Structure Storing TDT data
------------------------------

+---------------------------+------------------+--------------------------------------------+
| Stored in NWB.acquisition | Structure in tdt | Description                                |
+---------------------------+------------------+--------------------------------------------+
|         'tdt_neur'        |       Neur       | neural data                                |
+---------------------------+------------------+--------------------------------------------+
|         'tdt_stpd'        |       Stpd       | synchronization signal from the touch pad. |
+---------------------------+------------------+--------------------------------------------+
|                           |       EYEa       | x,y positions of eyes                      |
+         'tdt_eye'         +------------------+--------------------------------------------+
|                           |       EYEt       | sync data from eye tracking system         |
+---------------------------+------------------+--------------------------------------------+


Folder Naming for Storing TDT data
----------------------------------

All recorded raw tdt data should be stored under folder rawTDT with the subfolder structure like rawTDT\\animal-yymmdd\\Block-#.

Example folder structure:

rawTDT\\Barb-220324\\Block-1