#! /usr/bin/env bash
#
# Based on scripts from Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Usage: DISTRIBUTION=<distro> VERSION=<version> ROLE=<rolename> ./tests/docker-tests.sh
#
# Creates a Docker container for the specified Linux distribution and version,
# available at https://hub.docker.com/r/msaf1980/ansible-testing/; runs a syntax
# check; applies this role to the container using a test playbook; and,
# finally, runs an idempotence test.
#
# Environment variables DISTRIBUTION and VERSION must be set outside of the
# script.
#
# EXAMPLES
#
# $ DISTRIBUTION=centos VERSION=7 ./tests/docker-tests.sh
# $ DISTRIBUTION=debian VERSION=9 ./tests/docker-tests.sh
# $ DISTRIBUTION=ubuntu VERSION=18.04 ./tests/docker-tests.sh
#

[ -z "${1}" ] && opt="" || opt="${1}"

readonly script_dir=$( dirname "${BASH_SOURCE[0]}" )

. ${script_dir}/docker-tools || exit 1

start_container || exit 1
main_file="${id_file}"
main_id="${id}"

#exec_container ${main_id} ${role_dir}/lint.sh

exec_container ${main_id} ${role_dir}/tests/workarounds.sh || exit 1

run_syntax_check ${main_id} ${role_dir}/tests/test.yml
if [ "${opt}" == "--no-firewalld" ]; then
  # Workaround for bug with start firewalld
  run_test_playbook ${main_id} ${role_dir}/tests/test-nofirewalld.yml
else
  run_test_playbook ${main_id} ${role_dir}/tests/test.yml
fi

run_test_playbook ${main_id} ${role_dir}/tests/test-default.yml

run_idempotence_test ${main_id} ${role_dir}/tests/test-idempotence.yml

#exec_container ${main_id} ${role_dir}/tests/functional-tests.sh || exit 1

cleanup_container ${main_file}
