#!/usr/bin/env python3
#
# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

import sys
from mako.template import Template

def main(match_regex, license: str, exclude_paths: str = ''):
    print(f'''
{{
    licence: \'\'\'{license}\'\'\',
    match_regex: "{str(bool(match_regex)).lower()}"
    exclude_paths: [ {exclude_paths.replace("\n", ",").strip()} ],
}}
    ''')

if __name__ == '__main__':
    sys.exit(main(*sys.argv[1:]))
