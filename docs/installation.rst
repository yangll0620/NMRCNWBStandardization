************
Installation
************

.. contents::

NWB Standardization Codes Installation 
--------------------------------------
#. Download and unzip the `NMRCNWBStandardization`_ codes.

	.. _NMRCNWBStandardization: https://github.com/yangll0620/DataStorageAnalysisArchitecture

#. Change the folder name 'NMRCNWBStandardization-master' to 'NMRCNWBStandardization'.


MatNWB Toolbox Installation
----------------------------

.. IMPORTANT::

	Please installed the following toolboxes before using NWB standardized processing codes.

.. _installmatnwb-label:

MatNWB is the Matlab interface for reading and writing NWB file. To generate and use NWB structure, MatNWB should be inside the folder /util/. 

#. Download and unzip the `MatNWB`_.

	.. _MatNWB: https://github.com/NeurodataWithoutBorders/matnwb 

#. Change the folder name 'matnwb-master' to 'matnwb'

#. From the Matlab command line inside 'matnwb' folder, run the following code to generate matlab m-files ::

	generateCore('schema/core/nwb.namespace.yaml');

#. Copy the folder matnwb into folder NMRCNWBStandardization/toolbox/ 


Add Path
--------
add 'NMRCNWBStandardization' folder and its subfolders into matlab using either of the following two methods. 

#. On the Home tab, in the Environment section, click Set Path. Then click 'Add with Subfolders' in the 'Set Path' dialog box. 

	.. image:: figures/installation_setpath.PNG 

	Then select the 'NMRCNWBStandardization' folder and 'Select Folder' button in the 'Add to Path with Subfolders' dialog box. Finally click 'Save' in the 'Set Path' dialog box. Please refer to `here`_ if needed.
	
	.. image:: figures/installation_addtopath.PNG 

	.. _here: https://www.mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html

#. Run the following matlab codes, please change 'path/to/NWB Standardization Code' to your actual NMRCNWBStandardization path::
	
	addpath(genpath('path/to/NMRCNWBStandardization'))

	savepath