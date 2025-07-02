#!/bin/bash

## BASIC services, always needed
/opt/Accellence/vimacc/bin/AccVimaccRoot &
/opt/Accellence/vimacc/bin/AccVimaccReportClient &

## Required services on management servers (central Video Config Servers)
/opt/Accellence/vimacc/bin/AccVimaccConfig &
/opt/Accellence/vimacc/bin/AccVimaccReportServer &

## Required services on Sub-Nodes, like remote location, standalon "NVRs", etc. - instead of Config Servers section above
#/opt/Accellence/vimacc/bin/AccVimaccConfigSlave &
#/opt/Accellence/vimacc/bin/AccVimaccConfigProxy &


## Recommended general services on management servers and Sub-Nodes
/opt/Accellence/vimacc/bin/AccVimaccSystemMonitor &
/opt/Accellence/vimacc/bin/AccVimaccEventManager &
/opt/Accellence/vimacc/bin/AccVimaccScheduler &
/opt/Accellence/vimacc/bin/AccVimaccAssembliesManager &
/opt/Accellence/vimacc/bin/AccVimaccControlInterface &
/opt/Accellence/vimacc/bin/AccVimaccSnmpAgent &
/opt/Accellence/vimacc/bin/AccVimaccEmailSender &


## Required manager for integration of License-/Encryption-Dongles - only when mapped correcty into docker environment
#/opt/Accellence/vimacc/bin/AccVimaccDongle &


## Manager for integration of HID-devices - only usable when devices mapped correctly into docker environment
/opt/Accellence/vimacc/bin/AccVimaccHIDController &


## Required services for device handling, streaming (audio & video), recording/playback/export & data integration
/opt/Accellence/vimacc/bin/AccVimaccInterface&
/opt/Accellence/vimacc/bin/AccVimaccServer &
/opt/Accellence/vimacc/bin/AccVimaccExport &
/opt/Accellence/vimacc/bin/AccVimaccIpAlarmReceiver &
/opt/Accellence/vimacc/bin/AccVimaccDigIOInterface &


## Recommended services in distributed architectures to be running on central side, to optimized network traffic from sub-nodes to clients.
/opt/Accellence/vimacc/bin/AccVimaccInterfaceProxy &
/opt/Accellence/vimacc/bin/AccVimaccPlaybackProxy &


## Required process for synchronization of recordings between several recording locations (e.g. vehicle to landside)
#/opt/Accellence/vimacc/bin/AccVimaccServerSync &


## Service for system integration to external systems
/opt/Accellence/vimacc/bin/AccVimaccRTSPServer &
/opt/Accellence/vimacc/bin/AccVimaccHttpServer &
/opt/Accellence/vimacc/bin/AccVimaccDisplayInterface &
/opt/Accellence/vimacc/bin/AccVimaccFtpAlarmReceiver &
/opt/Accellence/vimacc/bin/AccVimaccFtpUploader &
/opt/Accellence/vimacc/bin/AccVimaccSmsGateway &


## Additional analytics services, mostly requiring additional hardware performance, like high power CPUD or GPU access
/opt/Accellence/vimacc/bin/AccVimaccMotionDetector &
/opt/Accellence/vimacc/bin/AccVimaccLicensePlateDetector &
