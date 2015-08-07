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
# ssrpm-enroll-script installer

include /usr/local/share/luggage/luggage.make

TITLE=ssrpm-enroll-script
REVERSE_DOMAIN=edu.purchase
PAYLOAD=\
	ssrpm-enroll-script.bash \
	pack-Library-LaunchAgents-edu.purchase.ssrpm-enroll-script.plist
PACKAGE_VERSION=1.0

pack-ssrpm-enroll-script.sh: l_etc_hooks
	@sudo ${CP} ssrpm-enroll-script.sh ${WORK_D}/etc/hooks
	@sudo chown root:wheel ${WORK_D}/etc/hooks/ssrpm-enroll-script.bash
	@sudo chmod 755 ${WORK_D}/etc/hooks/ssrpm-enroll-script.bash
