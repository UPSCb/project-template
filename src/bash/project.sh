#!/bin/bash

# failsafe
set -eu -o pipefail
#set -x

# variables
ARGs=3
DO=0
PROJECTDIR=/mnt/ada/projects
MIGRATE=0

# shellcheck disable=SC2046
read -r -a KNOWNPIS <<< $(getent group | awk -F: '{if($3 >= 2007 && $3 < 3000){print $1}}' | grep -v u20 | xargs )
# shellcheck disable=SC2046
# shellcheck disable=SC2038
read -r -a KNOWNSPECIES <<< $(find "$PROJECTDIR" -mindepth 1 -maxdepth 1 -type d -exec basename "{}" \; | xargs )

# usage
export USAGETXT=\
"
Usage: $0 [options] <species> <pi> <project>

Purpose: The script will setup the directory structure

Options:
    -d do not just print, do
    -h print this message
    -m migrate an existing project to the new structure

Note:
    <SPECIES> is one of:
    ${KNOWNSPECIES[*]}

    <PI> is one of:
    ${KNOWNPIS[*]}
"

# helper function
# shellcheck disable=SC1091
source functions.sh

# handle the options
while getopts dhm option
do
        case "$option" in
        d) DO=1;;
        h) usage;;
        m) MIGRATE=1;;
		\?) ## unknown flag
		usage;;
        esac
done
shift $((OPTIND - 1))

# setup

# sanity
[[ ${ARGs} -gt 0 ]] && [[ $# -ne ${ARGs} ]] && abort "This script expects ${ARGs} arguments"

SPECIES=${1}
shift
[[ $(containsElement "${SPECIES}" "${KNOWNSPECIES[@]}") -eq 1 ]] && abort "Unknown species"

PI=${1}
shift
[[ $(containsElement ${PI} "${KNOWNPIS[@]}") -eq 1 ]] && abort "Unknown PI"

PROJECT=${1}
shift

[[ ${MIGRATE} -eq 1 ]] && [[ ! -d  ${PROJECTDIR}/${SPECIES}/${PI}/${PROJECT} ]] && abort "You have a typo in your species / PI / project name as it is only possible to migrate an existing project."

# cmds container
cmds=()

PROJECTDIR=${PROJECTDIR}/${SPECIES}
[[ ! -d ${PROJECTDIR} ]] && cmds+=("mkdir ${PROJECTDIR} && chmod 771 ${PROJECTDIR} && chmod g+s ${PROJECTDIR} && chgrp ${PI} ${PROJECTDIR}
")
PROJECTDIR=${PROJECTDIR}/${PI}
[[ ! -d ${PROJECTDIR} ]] && cmds+=("mkdir ${PROJECTDIR} && chmod 771 ${PROJECTDIR} && chmod g+s ${PROJECTDIR} && chgrp ${PI} ${PROJECTDIR}
")
PROJECTDIR=${PROJECTDIR}/${PROJECT}
[[ ! -d ${PROJECTDIR} ]] && cmds+=("mkdir ${PROJECTDIR}
")


[[ ${MIGRATE} -eq 0 ]] && cmds+=("mkdir ${PROJECTDIR}/backup && mkdir ${PROJECTDIR}/nobackup && mkdir ${PROJECTDIR}/raw
")

[[ ${MIGRATE} -eq 1 ]] && cmds+=("mkdir ${PROJECTDIR}/backup && mkdir ${PROJECTDIR}/nobackup && mkdir -p ${PROJECTDIR}/raw
")

[[ ${MIGRATE} -eq 0 ]] && cmds+=("chmod -R 771 ${PROJECTDIR} && chmod -R g+s ${PROJECTDIR} && chgrp -R ${PI} ${PROJECTDIR}
")

[[ ${MIGRATE} -eq 1 ]] && cmds+=("chmod 771 ${PROJECTDIR}/backup && chmod g+s ${PROJECTDIR}/backup && chgrp ${PI} ${PROJECTDIR}/backup
")

[[ ${MIGRATE} -eq 1 ]] && cmds+=("chmod 771 ${PROJECTDIR}/nobackup && chmod g+s ${PROJECTDIR}/nobackup && chgrp ${PI} ${PROJECTDIR}/nobackup
")

[[ ${MIGRATE} -eq 1 ]] && cmds+=("chmod 771 ${PROJECTDIR}/raw && chmod g+s ${PROJECTDIR}/raw && chgrp ${PI} ${PROJECTDIR}/raw
")

[[ ${MIGRATE} -eq 1 ]] && cmds+=("find ${PROJECTDIR} -mindepth 1 -maxdepth 1 ! -name backup -a ! -name raw -a ! -name nobackup -exec mv \"{}\" ${PROJECTDIR}/nobackup \;
")

# shellcheck disable=SC2086
if [ ${DO} -eq 1 ]; then
    for j in $(seq 0 $((${#cmds[@]} - 1))); do
        eval "${cmds[$j]}"
    done
else
    echo "${cmds[@]}"
fi
