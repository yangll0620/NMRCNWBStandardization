-------------------
Eye Tracking System
-------------------

Structure of Eye Tracking System
-----------------------------------


Input File is required for storing processed eye tracking data into NWB Structure
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

+---------------+---------------------------------------------------------------------+
|      File     |                       Description                                   |
+===============+=====================================================+===============+
|               | Processed eye tracking data in txt format                           |
|  ``*``.txt    |                                                                     |
|               | Can be read with function readcell() and readtable() in matlab      |
+---------------+---------------------------------------------------------------------+

After extracting TrialDataEye and FileInfoBlock using export_EYE2MAT.m, store useful information into NWB structure.

Notes:

* TrialDataEye 
  contains all eyetracking data across all timestamps

* FileInfoBlock 
  contains all descriptive information of the data
          



NWB Structure Storing processed Eye Tracking Data
------------------------------------------


Processed Eye Tracking data are stored as a SpatialSeries structure inside a set of spatialseries at:

``nwb.processing.get('EyeTrackingInfo').nwbdatainterface.get('EyeTrackingPos').spatialseries``

In order to get the spatialseries object, use the command:

``nwb.processing.get('EyeTrackingInfo').nwbdatainterface.get('EyeTrackingPos').spatialseries.get('eyeTracking')``

.. image:: figures/systemeyetracking_spatialseries.png

Notes:

* spatialseries.comments: 
          Data Type: character
	Appropriate column names for eye tracking data delimited with ``;``

* spatialseries.data: 
          Data Type: Double Array
 All eyetracking data across all timestamps
          
* spatialseries.starting_time_rate:
          Data Type: Double
  Number of timestamps recorded in one second
	

Structure inside nwb.processing
"""""""""""""""""""""""""""""""""""""""""""          

.. image:: figures/systemeyetracking_illustration.png
