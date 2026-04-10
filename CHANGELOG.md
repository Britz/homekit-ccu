Changelog for 0.0.16:
====================

* Fixed Rega timeout causing full server crash — unhandledRejection now logged without process exit
* Added .catch() to all Rega Promise chains (fetchAllDevices, fetchRooms, hazDatapoint, setValue, setVariable, getVariableValue, runProgram, auth checks) — Rega errors no longer crash the server
* Rega requests are now serialised via a module-level queue — prevents socket hang-ups when Apple Home or the wizard triggers concurrent Rega calls
* Rega script() now retries up to 3 times with 5s delay on transient failures; ping uses 0 retries with 5s timeout
* pingRega uses a short 5s timeout; unexpected Rega responses are now logged verbatim
* getValue() now fires events on cache hits — fixes registerAddressForEventProcessingAtAccessory needing ignoreCache=true workaround
* Fixed compatibleObjects IPC handler not calling sendObjects() — UI now updates when device list is loaded
* Removed npm registry version check — was always failing (package not public) and logging noise on every UI load
* Fixed console() typo (should be console.log) in configurationsrv shutdown handler
* Removed empty NotFound RPC handler, unused getValue()/callback param in setVariable, empty init() method
* addon rc.d script refactored: unified install/uninstall/start/stop functions, proper stop before reinstall on update
* update_script: on reinstall removes old package so postinstall runs with the new tgz, then restarts service
* uninstall: uses do_stop() instead of undefined $PSPID; pgrep pattern fixed; -r flag on xargs prevents error with no matches

Changelog for 0.0.15:
====================

* Renamed project from hap-homematic to homekit-ccu
* npm package is now bundled in the addon tar — no public registry access required at install time
* Version is now derived from package.json as the single source of truth (addon_installer/VERSION removed)
* Node.js version is now shown alongside the addon version in CCU System Control
* Fixed OpenCCU compatibility issues
* Rega communication: added request queue (serializes concurrent requests to single-threaded Rega) and automatic retry with exponential backoff
* Improved error handling: added unhandledRejection handler, .catch() on all Promise chains in CCU/RPC/config layers
* Removed dead code: empty init() method, unused RPC NotFound handler, obsolete _index.js (2034 lines)
* Removed npm registry version check — config UI no longer requires internet access
* Fixed console() typo in configuration service
* Addon installer: safer process killing (xargs -r, error suppression), proper service stop/reinstall on update
* Build script: pre-build cleanup removes stale tarballs
* Lighttpd proxy config: reorganized with section comments and explicit ssl.engine per socket

Changelog for 0.0.64:
====================

* OpenCCU compatibility
* Config UI is now proxied through lighttpd (ports 9874 HTTP, 49874 HTTPS) — fixes firewall and iframe issues on OpenCCU
* Addon firewall ports (9874, 49874) are automatically opened/closed on install/uninstall
* Dynamic XML-RPC port remapping for OpenCCU internal daemon ports (32001/32010/39292 → 2001/2010/9292)
* Node.js preinstall check — automatically downloads Node.js 20 if missing or too old
* Minimum Node.js version bumped to >= 20
* Removed vulnerable `ip` npm package (CVE-2024-29415), replaced with built-in Node.js modules
* Fixed `serialize-javascript` prototype pollution vulnerability via dependency override
* Fixed TotalConsumption Eve characteristic (UInt16 → FLOAT) for correct energy readings
* Fixed welcome wizard reopening after completion
* Fixed empty API response parsing error
* Optional basic auth for XML-RPC connections in remote mode (`-U`/`-P` CLI options)
* Config server bind address adapts to local vs remote mode
* Improved error handling for RPC init and translation file loading

Changelog for 0.0.63:
====================

* Just one BugFix (in some cases the ui will not get devices from core)

Changelog for 0.0.62:
====================

* mostly bugfixes
* added HmIP-BSL Lights
* added variable based Light sensor


Changelog for 0.0.61:
====================

* added HmIP-DLD
* a backup file name will now contain the current date in the name
* some bugfixes

Changelog for 0.0.60:

* fixed the admin changelog bug
* added HmIP-SCTH230
* fixed var trigger helper generator
* fixed a crash that may occur when there are multiple service UUIDs in one instance
* temp sensor for HmIP-SRD is now optional
* added HomeMaticVariableBinarySwitchAccessory to use variables as other than switches (Fan / Lightbulb ...)
* added voltage level for MULTI_MODE_INPUT_TRANSMITTER

Changelog for 0.0.59:
=====================

* added HM-ES-TX-WM
* DIMMER are now available as Homekit FANs
* added HmIP-STE2-PCB
* first Test HmIP-HDM1
* Bug fixes
* introducing some fresh new bugs


Changelog for 0.0.58:
=====================

* Bug Fixes for Thermometer and Weather Station
* added HmIP-DSD-PCB
* auto refresh for cached ccu data on at the point the user loads the ui
* added HmIP-SRD


Changelog for 0.0.57:
=====================

* restore from backup will also restore the accessory infos for an existing homekit mapping
* new : reset of an instance
* added SIMPLE_SWITCH_RECEIVER to support garage door drives
* added all types of Keys as a Trigger for a Motion sensor
* support for HM-SwI-3-FM 
* support for HM-LC-DW-WM
* better HmIP-MOD-HO support
* BugFixes
* some fresh new Bugs


Changelog for 0.0.56:
=====================

* BugFixes

Changelog for 0.0.55:
=====================

* Bug fixes
* new Instances are now able to setup by using the qr code
* added some new device types


Changelog for 0.0.54:
=====================

* Bug Fixes
* customizable lock mode for Keymatic 
* CCU Temperature Chart 

Changelog for 0.0.53:
=====================

* fixed a problem that some installations are not able to create or edit devices anymore

Changelog for 0.0.51:
=====================

* worked on some timing issues

Changelog for 0.0.50:
=====================

* added multiple key device
* added http device
* fixed a bug in garage door


Changelog for 0.0.49:
=====================

* fixed a bug that some installations are not able to add new devices
* fixed a bug that special devices are not added anymore


Changelog for 0.0.48:
=====================

* bugfixes
* garage door datapoint now have selectors
* devices can be assigned to multiple hap instances

Changelog for 0.0.47:
=====================

* pimped dimmers
* garage door service has no onTime settings
* added variable based devices
* fixed some bugs


Changelog for 0.0.46:
=====================

* removed a bug in BROLL

Changelog for 0.0.45:
=====================

* eve thermo for HM-TC-IT-WM-W-EU
* fix for garage service
* some other bug fixes
* new problems new bugs 

Changelog for 0.0.44:
=====================

* flexible Alarm System
* Thermostats have not Off/Manu/Auto Modes
* Blinds with Slats
* some bugfixes
* even more new bugs


Changelog for 0.0.43:
=====================

* optional Co2 Variable for Thermometer
* some UI BugFixes
* alarm system will now send pushes
* other bug fixes
* introduced fresh new bugs

Changelog for 0.0.42:
=====================

* the welcome wizzard is back after a short visit at the beach 

Changelog for 0.0.41:
=====================

* changed WebUI to use WebSockets (beta)
* added Battery Indicators
* fixed evehistory for variables and ccu temp sensor
* fixed HmIP-MOD-HO

Changelog for 0.0.40:
=====================

* bugfix

Changelog for 0.0.39:
=====================

* some bug fixes and improvements 

Changelog for 0.0.38:
=====================

* Added a config backup
* Monitoring is now optional
* Bugfix for variables and programs with : in names
* Bugfix HmIP RadiatorThermostate
* Special device Garagedoor opener will now work with KEY devices
* Added HmIP-SWO-*
* Removed HmIP-ASIR support cause there is no need
* Fixed WinMatic


Changelog for 0.0.37:
=====================

* added optional ramp time for dimmers thanks to @comtel2000
* new hap instances will be named as HomeMatic .... (removed the _ ) thanks to @detLAN for researching this
* added a support dialog for new devices and issues


Changelog for 0.0.36:
=====================

* added HmIP-SWD

Changelog for 0.0.35:
=====================

* added HmIP-SWO-*
* added HmIP-STHO, 
* added HmIP-SRH
* added HmIP-SAM(Contact version)

Changelog for 0.0.34:
=====================

* Fix for Instances/Settings

Changelog for 0.0.33:
=====================

* some tweeks for the webUI

Changelog for 0.0.32:
=====================

* added sorting for webui lists
* implemented a nicer update button

Changelog for 0.0.31:
=====================

* only setup the monitor if system is not in debug and there was a pid file created by the launcher

Changelog for 0.0.30:
=====================

* homekit-ccu will install a config for the raspberrymatic monitoring service (if there is one)
* added variable based thermometers
* new special device which will show the ccu core temperature

Changelog for 0.0.29:
=====================

* WebUI Fixed Internals in left menu
* Fixed AlarmSystem (internal vs night mode)

Changelog for 0.0.28:
=====================

* prevent the system from crash on invalid GarageDoorSensors configuration
* changed State() to Value() for fetching data from ccu
* added JALOUSIE channel to blind accessories
* removed fault characteristics from leak sensor (there is no such datapoint)

Changelog for 0.0.27:
=====================

* changed a https client call - for backwards compatibility to old node8 version on ccu3 devices

Changelog for 0.0.26:
=====================

* added special devices
* fixed CCU startup bug
* added optional ccu authentication for configuration page
* added optional https transport for configuration page

Changelog for 0.0.25:
=====================

* Added IP Blinds

Changelog for 0.0.24:
=====================

* Added WinMatic
* Changed Plugin installer to prevent backing up all the stuff (RaspberryMatic Only)

Changelog for 0.0.23:
=====================

* Bugfix for devices with service configuration like devtype:channeltype
* added a testmode

Changelog for 0.0.22:
=====================

* the webUI is now able to show the changelog
* more interal logging


Changelog for 0.0.21:
=====================

* fixed a bug, which prevents the plugin from knowing about some smoke detectors
* added a listener, to "newDevice" event on the interface, so the plugin will query the ccu for new devices, as the are teached in the ccu
