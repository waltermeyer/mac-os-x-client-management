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
# First-Boot Post-Image Settings Installer

include /usr/local/share/luggage/luggage.make

TITLE=Purchase-Startup-Settings
REVERSE_DOMAIN=edu.purchase
PAYLOAD=\
	pack-startupsettings.sh \
	pack-Library-LaunchDaemons-edu.purchase.startupsettings.plist \
	pack-cupsd.conf
PACKAGE_VERSION=1.1

pack-startupsettings.sh: l_etc_hooks
	@sudo ${CP} startupsettings.sh ${WORK_D}/etc/hooks
	@sudo chown root:wheel ${WORK_D}/etc/hooks/startupsettings.sh
	@sudo chmod 755 ${WORK_D}/etc/hooks/startupsettings.sh

l_cups: l_etc
	@sudo mkdir ${WORK_D}/etc/cups
	@sudo chown root:_lp ${WORK_D}/etc/cups
	@sudo chmod 755 ${WORK_D}/etc/cups

pack-cupsd.conf: l_cups
	@sudo ${CP} cupsd.conf ${WORK_D}/etc/cups
	@sudo chown root:_lp ${WORK_D}/etc/cups/cupsd.conf
	@sudo chmod 644 ${WORK_D}/etc/cups/cupsd.conf
