************
Installation
************

.. contents::

NWB Standardization Codes Installation 
--------------------------------------
#. Download the `NWB Standardization Codes`_.

	.. _NWB Standardization Codes: https://github.com/yangll0620/DataStorageAnalysisArchitecture

#. add path and subpath of NWB Standardization Codes into matlab::
	
	addpath(genpath('path/to/NWB Standardization Code'))



Used Toolboxes Installation
---------------------------

.. IMPORTANT::

	Please installed the following toolboxes before using NWB standardized processing codes.

.. _installmatnwb-label:

MatNWB 
^^^^^^

	MatNWB is the Matlab interface for reading and writing NWB file. To generate and use NWB structure, MatNWB should be inside the folder /util/. 

	#. Download the `MatNWB`_.

		.. _MatNWB: https://github.com/NeurodataWithoutBorders/matnwb

	#. From the Matlab command line, generate matlab m-files::

		generateCore('schema/core/nwb.namespace.yaml');

	#. Copy the folder matnwb-master into folder toolbox/ 
	
	
	#. add MatNWB path and its subpath to matlab


.. _installTDTMatSDK-label:

TDTMatlabSDK
^^^^^^^^^^^^

	TDTMatlabSDK is the Matlab TDT data import tool. TDTMatlabSDK should be inside the folder /util/ when converting tdt data to NWB structure.   

	#. Download the zipped `TDTMatlabSDK`_ tool.

		.. _TDTMatlabSDK: https://www.tdt.com/support/examples/TDTMatlabSDK.zip

	#. Extrac the zip files into folder toolbox/ 
	
	
	#. add TDTMatlabSDK path and its subpath to matlab