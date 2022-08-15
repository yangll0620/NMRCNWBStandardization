-------------------
Deep Lab Cut System
-------------------

Structure of Deep Lab Cut System
-----------------------------------


Input File is required for storing processed DLC data into NWB Structure
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

+---------------+---------------------------------------------------------------------+
|      File     |                       Description                                   |
+===============+=====================================================+===============+
|               | Processed DLC data in csv format                                    |
|  ``*``.csv    |                                                                     |
|               | Can be read with function readcell() and readtable() in matlab      |
+---------------+---------------------------------------------------------------------+


NWB Structure Storing processed Deep Lab Cut Data
------------------------------------------


Processed DLC data in ``*``.csv file
"""""""""""""""""""""""""""""""""""""""""""

Processed DLC XY position data are stored as a SpatialSeries structure inside nwb.processing
In order to get the spatialseries object containing processed dlc data from camera-1 from this recording, use the command below:

.. image:: figures/systemdlc_spatialseries.png
https://github.com/guanjingyi/NMRCNWBStandardization/blob/master/docs/figures/systemdlc_spatialseries.png


.. image:: figures/systemma_marker.PNG


