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
#while getopts :r:c:f:m:p:lh arg; do
#	case $arg in
#		r) repo_directory=${OPTARG%/};;
#		c) commit=$OPTARG;;
#		m) new_commit_message="$OPTARG";;
#		p) pattern="$OPTARG";;
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
#
#				-m <new_commit_message>
#					The message that will replace all squashed commit messages
#
#				-p <pattern>
#					Pattern based on which commits will be squashed
#
#				-l
#					listing files in repo, mostly for purpose of testing
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
#if [[ $pattern ]]; then
#	commits_command="awk -i inplace '!/^(#|$)/ "
#	commits_command+="{ if(NR == 4) \$0 = \"${new_commit_message:-squashed commits}\"; "
#	commits_command+="else sub(\"^\", \"#\") } { print }'"
#
#	sequence_command="awk -i inplace '/$pattern/ { \$1 = \"s\" } { print }'"
#
#	GIT_EDITOR="$commits_command" \
#		GIT_SEQUENCE_EDITOR="$sequence_command" \
#		git rebase -i ${commit:--root} 2> /dev/null
#else
#	echo "No pattern specified, please provide a pattern.."
#fi
