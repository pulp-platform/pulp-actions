#!/usr/bin/env python3
#
# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

import sys
from mako.template import Template


def main(out_file: str, match_regex, license: str, exclude_paths: str = '') -> int:
    exclude_list = exclude_paths.strip().split()
    exclude_str = ', '.join(f"'{e}'" for e in exclude_list)
    config = f'''{{
        licence: \'\'\'{license}\'\'\'
        match_regex: "{str(bool(match_regex)).lower()}"
        exclude_paths: [ {exclude_str} ]
    }}'''
    print(f'Generated linter config:\n\n{config}')
    with open(out_file, 'w+') as f:
        f.write(config)
    return 0


if __name__ == '__main__':
    sys.exit(main(*sys.argv[1:]))
