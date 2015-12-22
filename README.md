OwncloudUpgrade
===============

This is a shell script that completely automates the owncloud upgrade process.

**Attention:** Yet, it is necessary to activate all non-default Owncloud apps manually after running this upgrade. Owncloud will have no apps enabled after the upgrade.

Requirements
------------

  * bash
  * curl
  * sudo
  * rsync
  * tr
  * mysqldump *(optional)*

Usage
-----

Run the script to upgrade your owncloud instance. The script expects the version number as only parameter.
The syntax must be the same as in the download link, i.e. *8.2.2*.

License
-------

Copyright 2015 Pascal Wichmann

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.


----------------------------

Scripts and documentation written by Pascal Wichmann, copyright (c) 2015
