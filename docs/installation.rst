************
Installation
************

.. contents::

NWB Standardization Codes Installation 
--------------------------------------
#. Download the `NWB Standardization Codes`_.

	.. _NWB Standardization Codes: https://github.com/yangll0620/DataStorageAnalysisArchitecture

#. Change the folder name 'NMRCNWBStandardization-master' to 'NMRCNWBStandardization'

#. add path and subpath of NWB Standardization Codes into matlab::
	
	addpath(genpath('path/to/NWB Standardization Code'))

	savepath



MatNWB Toolboxe Installation
---------------------------

.. IMPORTANT::

	Please installed the following toolboxes before using NWB standardized processing codes.

.. _installmatnwb-label:

MatNWB 
^^^^^^

	MatNWB is the Matlab interface for reading and writing NWB file. To generate and use NWB structure, MatNWB should be inside the folder /util/. 

	#. Download the `MatNWB`_.

		.. _MatNWB: https://github.com/NeurodataWithoutBorders/matnwb 

	#. Change the folder name 'matnwb-master' to 'matnwb'

	#. From the Matlab command line, generate matlab m-files inside matnwb folder::

		generateCore('schema/core/nwb.namespace.yaml');

	#. Copy the folder matnwb into folder NMRCNWBStandardization/toolbox/ 
	
	
	#. add MatNWB path and its subpath to matlab