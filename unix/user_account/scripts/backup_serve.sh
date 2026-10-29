#!/bin/bash

set -e

assert_directories() {
	local -r directories="${@}"
	local -r option="-d"

	assert_things ${directories}
}

assert_files() {
	local -r files="${@}"
	local -r option="-f"

	assert_things ${files}
}

assert_things() {
	local -r things="${@}"

	if [ -z "${option}" ] ; then
		echo ""
		echo "Implementation error."
		echo "Please set a value for local 'option' variable."
		echo "The following needs to be met:"
		echo "1) Set the value in a function calling this function."
		echo "2) Set the value before calling this function."
		echo ""
		exit 1
	fi

	for thing in ${things} ; do
		if [ ! ${option} "${thing}" ] ; then
			echo "Using option: ${option}, no such thing: ${thing}"
			exit 1
		fi
	done
}

main() {
	local -r classified_tar='classified.tar'
	local -r database_kdbx='Database.kdbx'
	local -r absolute_classified="${HOME}/my/classified"
	local -r absolute_database_kdbx="${HOME}/my/data/for_programs/keepass/${database_kdbx}"
	local -r absolute_share_http="${HOME}/my/share_http"

	echo "Asserting that prerequisites are met."

	# If missing, please create the directories in another script whose
	# purpose is to prepare the filesystem for use, after a Unix system
	# installation has been done, but no customization has been done.
	assert_directories             \
		${absolute_classified} \
		${absolute_share_http}

	# If missing, please deploy an initial copy of the files in another
	# script whose purpose is to prepare the filesystem for use, after a
	# Unix system installation has been done, but no customization has been
	# done.
	assert_files \
		${absolute_database_kdbx}

	pushd "${absolute_share_http}"

	echo "Creating copies of files to backup."
	tar --directory=${HOME}/my                          \
	    --create                                        \
	    --verbose                                       \
	    --file=${absolute_share_http}/${classified_tar} \
	    ./classified/

	cp --verbose                 \
	   ${absolute_database_kdbx} \
	   ./

	# TODO encrypt before serving. Can encrypt and have a shared secret on
	# source as well as destination host. No need for HTTPS certificates,
	# if done this way.
	echo "Serving copies of files being backed up."
	ip -4 -brief address show
	python3 -m http.server

	echo "Cleaning up copies."
	rm --verbose ./${database_kdbx}
	rm --verbose ./${classified_tar}

	popd # "${absolute_share_http}"
}

main "${@}"
