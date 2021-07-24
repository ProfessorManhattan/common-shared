#!/usr/bin/env bash

# @file .common/scripts/ansible/vault.sh
# @brief Used by a pre-commit hook to ensure that files that end with 'vault.yml' in Ansible projects are encrypted

. "./.common/scripts/log.sh"

set -e

STATUS=0
for FILE in $@; do
  head -1 "$FILE" | grep --quiet '^\$ANSIBLE_VAULT;' || {
    if [ -s "$FILE" ]; then
      error "'$FILE' is not encrypted. All files matching '**/*vault.yml' should be encrypted by 'ansible-vault'."
      STATUS=1
    else
      warn "'$FILE' is not encrypted but is empty"
    fi
  }
done

exit $STATUS
