**********
TDT System 
**********

Structure of TDT System
-----------------------


+-----------+-----------+-------+------+------------------------------------+---------------+
| tdt filed | sub-field | chair | gait |             description            |unified in tdt |
+===========+===========+=======+======+====================================+===============+
|           |   .Cam1   |  yes  |  yes |                                    | Cam1          |
+           +-----------+-------+------+ | Cam1/2:  onset and offset time   +---------------+
|   .epocs  |   .Cam2   |   no  |  yes | | of each frame                    | Cam2          |
+           +-----------+-------+------+------------------------------------+---------------+
|           |   .Spd\_  |   no  |  yes | | Spd\_: onset  and  offset  time  | Spdg          |
|           |           |       |      | | of gait mat                      |               |
+-----------+-----------+-------+------+------------------------------------+---------------+
|           |           |       |      | BUGG: store the neural data        |               |
|           |           |       |      |                                    |               |
|           |   .BUGG   |  yes  |  yes | [n_chns,  n_temporal]              | Neur          |
|           |           |       |      |                                    |               |
|           |           |       |      | start_time = 0                     |               |
+           +-----------+-------+------+------------------------------------+---------------+
|           |           |       |      | x,y positions of eyes              |               |
|           |           |       |      |                                    |               |
|           |   .EYEa   |  yes  |  no  | [2, n_temporal]                    | EYEa          |
|           |           |       |      |                                    |               |
| .steams   |           |       |      | start_time = 9.5367e-07            |               |
+           +-----------+-------+------+------------------------------------+---------------+
|           |           |       |      | sync data from eye tracking system |               |
|           |           |       |      |                                    |               |
|           |   .EYEt   |  yes  |  no  | [1, n_temporal]                    | EYEt          |
|           |           |       |      |                                    |               |
|           |           |       |      | start_time = 9.5367e-07            |               |
+           +-----------+-------+------+------------------------------------+---------------+
|           |           |       |      | | Stpd: synchronization signal     |               |
|           |           |       |      | | from the touch pad.              |               |
|           |   .Stpd   |  yes  |  no  |                                    | Stpd          |
|           |           |       |      | [1, n_temporal]                    |               |
|           |           |       |      |                                    |               |
|           |           |       |      | start_time = 9.5367e-07            |               |
+           +-----------+-------+------+------------------------------------+---------------+
|           |           |       |      | For what?                          |               |
|           |           |       |      |                                    |               |
|           |   .Para   |  yes  |  no  | [4,  n_temporal]                   | Para          |
|           |           |       |      |                                    |               |
|           |           |       |      | start_time = 9.5367e-07            |               |
+-----------+-----------+-------+------+------------------------------------+---------------+

Example dataset:

* setup-chair: Bug-190111 -> Block-1

* setup-gait: Bug-181130 -> Block-1


NWB Structure Storing TDT data
------------------------------

