#!/bin/bash

echo "TODO"

#list_files() {
#	while read hash message; do
#		clear
#		echo $hash $message
#		git ls-tree --name-only -r $hash
#		sleep 1
#	done <<< $(git log --oneline $commit_range)
#}
#
#remove_files() {
#	rm_command='git ls-files -ic --exclude-from=/tmp/files_to_remove |'
#	rm_command+='xargs -r git rm --cached --ignore-unmatch'
#	#command="if [[ $condition ]]; then $rm_command; fi"
#
#	git filter-branch --force --index-filter "$rm_command" -- ${commit:---all} > /dev/null
#}
#
#while getopts :r:c:f:m:p:lh arg; do
#	case $arg in
#		r) repo_directory=${OPTARG%/};;
#		f) file_to_remove=${OPTARG#$repo_directory/};;
#		c) commit=$OPTARG;;
#		l) list=true;;
#		h)
#			cat <<- EOF
#				Usage:
#
#				-r <repo_directory>
#					Repo which history we want to modify
#
#				-c <commit>
#					Specific commit which will be the starting point for given operation,
#					if omitted, script will consider starting from beginning of the history
#			EOF
#	esac
#done
#
#[[ ! -d $repo_directory ]] &&
#	echo "No such directory: $repo_directory, exiting.." && exit 1
#
#cd $repo_directory
#
#[[ $list ]] &&
#	list_files && exit
#
#[[ $commit ]] &&
#	commit=${commit%..*}..HEAD
#
#cp .gitignore /tmp/files_to_remove
#
#if [[ $commit ]]; then
#	while read branch; do
#		git checkout $branch > /dev/null
#		remove_files
#	done <<< $(git branch | cut -c 3-)
#else
#	echo "removing file(s).."
#	remove_files
#fi
