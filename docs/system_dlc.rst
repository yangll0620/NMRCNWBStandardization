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

Processed DLC XY position data are stored as a SpatialSeries structure.
