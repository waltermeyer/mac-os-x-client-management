#
#   Copyright 2009 Joe Block <jpb@ApesSeekingKnowledge.net>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Munki First Boot Installer

include /usr/local/share/luggage/luggage.make

TITLE=Munki-First-Boot
REVERSE_DOMAIN=edu.purchase
PAYLOAD=\
	pack-munkifirstbootrun.sh \
	pack-munkifirstbootconfig.sh \
	pack-Library-LaunchDaemons-edu.purchase.munkifirstboot.plist \
	pack-Library-Preferences-ManagedInstalls.plist
PACKAGE_VERSION=1.1.2

pack-munkifirstbootrun.sh: l_private_etc_hooks
	@sudo ${CP} munkifirstbootrun.sh ${WORK_D}/private/etc/hooks/
	@sudo chown root:wheel ${WORK_D}/private/etc/hooks/munkifirstbootrun.sh
	@sudo chmod 750 ${WORK_D}/private/etc/hooks/munkifirstbootrun.sh

pack-munkifirstbootconfig.sh: l_private_etc_hooks
	@sudo ${CP} munkifirstbootconfig.sh ${WORK_D}/private/etc/hooks/
	@sudo chown root:wheel ${WORK_D}/private/etc/hooks/munkifirstbootconfig.sh
	@sudo chmod 750 ${WORK_D}/private/etc/hooks/munkifirstbootconfig.sh
