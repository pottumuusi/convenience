#!/bin/bash

# This script writes most recent versions of files, that are wanted to be
# backed up, to the filesystem of the computer that is running this script.
#
# The files present in the filesystem after executing this script, are
# considered to be a backup of the files whose copies were downloaded from
# another computer.

set -e

download_files_to_backup() {
	local -r server_port='8000'

	echo "Downloading most recent copies of files to backup."

	wget http://${server_ip}:${server_port}/${database_kdbx}
	wget http://${server_ip}:${server_port}/${classified_tar}
}

backup_password_database() {
	local -r database_bak="Database.bak"
	local -r absolute_database_bak="${HOME}/my/data/for_programs/keepass/${database_bak}"
	local -r absolute_database_kdbx="${HOME}/my/data/for_programs/keepass/${database_kdbx}"

	if diff ./${database_kdbx} ${absolute_database_kdbx} 2> /dev/null ; then
		echo ""
		echo "Skipping password database backup."
		echo "Previous primary database is identical to new database."
		echo ""

		return
	fi

	echo "Backing up password database."

	cp --verbose \
		${absolute_database_kdbx} \
		${absolute_database_bak}
	mv --verbose ./${database_kdbx} ${HOME}/my/data/for_programs/keepass/
}

backup_classified_files() {
	echo "Backing up classified files."

	rm --verbose   \
	   --recursive \
	   --force     \
	   ${HOME}/my/classified/

	tar --directory=${HOME}/my \
	    --extract              \
	    --verbose              \
	    --file=/tmp/${classified_tar}
}

# Quirks
#
# 1)
# ---
# Variable declared local in calling function can be accessed in called
# function.
#
# See:
# https://www.gnu.org/software/bash/manual/html_node/Shell-Functions.html
# or
# `man bash`
# ---
main() {
	local -r server_ip="${1}"

	# Quirk 1 - start

	local -r classified_tar="classified.tar"
	local -r database_kdbx="Database.kdbx"

	# Quirk 1 - end

	local -r temporary_directory="$(mktemp -d)"

	if [ -z "${server_ip}" ] ; then
		echo "Server IP not provided as first argument."
		exit 1
	fi

	pushd ${temporary_directory}

	download_files_to_backup
	backup_password_database
	backup_classified_files

	popd # ${temporary_directory}

	echo "Cleaning up temporary files."

	rm --verbose --recursive ./${temporary_directory}
}

main "${@}"
