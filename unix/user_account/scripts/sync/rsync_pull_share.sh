#!/bin/bash

readonly OPTIONS_LIVE=" \
--update \
--recursive \
--times \
--atimes \
--progress \
--delete"

readonly OPTIONS_DRYRUN="${OPTIONS_LIVE} --dry-run"

main() {
    local -r share_source="/home/${JUSTWORKS_TOOLBOX_USER}/share/"
    local -r share_destination="${HOME}/my/share/"

    local rsync_options=''

    if [ -z "${JUSTWORKS_TOOLBOX_USER}" ] ; then
	    echo "Please set a value for variable: JUSTWORKS_TOOLBOX_USER"
	    exit 1
    fi

    if [ "--live" == "${1}" ] ; then
        rsync_options="${OPTIONS_LIVE}"
    else
        rsync_options="${OPTIONS_DRYRUN}"
    fi

    rsync \
        ${rsync_options} \
        ${JUSTWORKS_TOOLBOX_USER}@toolbox.justworks.today:${share_source} \
        ${share_destination}
}

main ${@}
