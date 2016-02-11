## 0.4.1 - 2016/02/11
### Features
* Puppet 4.x support (#18)

### Fixes
* Better tests (#9, #19)

## 0.4.0 - 2016/02/09
### Features
* Ability to disable Marathon's syslog logging (#16)

### Changes
* Marathon service now restarted when package is changed (#15 - @felixb)

### Fixes
* Owner and group set for `mesos::property` config resources (#17)

## 0.3.0 - 2016/01/29
### Features
* CentOS/RHEL 7 support (#12 - @felixb)
* Support management of Mesos authentication secret (#13 - @felixb)

### Fixes
* `deric/mesos` updated to 0.6.5 - ensure `apt-get update` runs before installing (#11)
* README instructions updated/fixed (#11)

## 0.2.0 - 2016/01/14
### Fixes
* Refactored install process to better ensure resource dependency ordering (#8)

## 0.1.1 - 2016/01/12
**Initial release -- KNOWN ISSUES*
