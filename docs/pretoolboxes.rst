-----------------------
Pre-installed Toolboxes
-----------------------

.. contents::

.. IMPORTANT::

	Please installed the following toolboxes before using NWB standardized processing codes.

.. _installmatnwb-label:

MatNWB 
------

	MatNWB is the Matlab interface for reading and writing NWB file. To generate and use NWB structure, MatNWB should be inside the folder /util/. 

	#. Download the `MatNWB`_ .

		.. _MatNWB: https://github.com/NeurodataWithoutBorders/matnwb

	#. From the Matlab command line, generate matlab m-files::

		generateCore('schema/core/nwb.namespace.yaml');

	#. Copy the folder matnwb into /util/


.. _installTDTMatSDK-label:

TDTMatlabSDK
------------

	TDTMatlabSDK is the Matlab TDT data import tool. TDTMatlabSDK should be inside the folder /util/ when converting tdt data to NWB structure.   

	#. Download the zipped `TDTMatlabSDK`_ tool.

		.. _TDTMatlabSDK: https://www.tdt.com/support/examples/TDTMatlabSDK.zip

	#. Extrac the zip files into /util/ folder