-------------------
Eye Tracking System
-------------------

Structure of Eye Tracking System
-----------------------------------


Input File containing raw eye tracking data is required in order to store information into NWB Structure
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

+---------------+---------------------------------------------------------------------+
|      File     |                       Description                                   |
+===============+=====================================================+===============+
|               | Raw eye tracking data in txt format                                 |
|  ``*``.txt    |                                                                     |
|               | 			      					      |
|               | 			      			                      |
|		| Example file's name: 2022-7-12;11-27-49.txt			      |		      
+---------------+---------------------------------------------------------------------+



NWB Structure Storing processed Eye Tracking Data
------------------------------------------

Layer1:
-----
Processed Eye Tracking data, along with other types of data, are stored inside nwb.processing:
``nwb.processing``

.. image:: figures/systemdlc_layer1.png


Layer2:
-----
The ProcessingModule inside nwb.processing named EyeTrackingInfo is where we stored processed eye tracking data.
You can find a description and a nwbdatainterface inside.
``nwb.processing.get('EyeTrackingInfo')``

.. image:: figures/systemeyetracking_layer2.png


Layer3:
----- 
``nwb.processing.get('EyeTrackingInfo').nwbdatainterface``

.. image:: figures/systemeyetracking_layer3.png


Layer4:
----- 
This EyeTracking object contains a set of spatialseries objects.
``nwb.processing.get('EyeTrackingInfo').nwbdatainterface.get('EyeTrackingPos')``

.. image:: figures/systemeyetracking_layer4.png


Layer5:
----- 
Get the set of spatialseries objects with the command below.
``nwb.processing.get('EyeTrackingInfo').nwbdatainterface.get('EyeTrackingPos').spatialseries``

.. image:: figures/systemeyetracking_layer5.png


Layer6:
----- 
Inside the set of spatialseries objects, we stored processed eye tracking data inside the spatialseries object named 'eyeTracking'.
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
