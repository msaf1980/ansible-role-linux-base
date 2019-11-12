#!/bin/sh

RES=0

#yamllint . || RES=$?
ansible-lint -x 305,403,502 tests/test.yml || RES=$?

exit $RES



