#!/usr/bin/bash
#
# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nils Wistoff <nwistoff@iis.ee.ethz.ch>

set -e

RESULT=0
for FILE in $(bender script -n flist | sed "/^\+\S*$/d")
do
	[ ! -f "$FILE" ] && { echo "bender-up-to-date: $FILE not found."; RESULT=1; }
done
exit $RESULT
