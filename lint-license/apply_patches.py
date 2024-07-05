#!/usr/bin/env python3
#
# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Luca Colagrande <colluca@iis.ee.ethz.ch>

import os
import argparse
from pathlib import Path


def main():
    # Argument parsing
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'repo',
        help='Path to Git repository to patch',
    )
    parser.add_argument(
        'patches',
        nargs='*',
        help='List of patches to apply')
    parser.add_argument(
        '--patch-dir',
        action='store',
        help='(Optional) Path to look for the patches in')
    args = parser.parse_args()
    patches = args.patches
    repo = args.repo
    patch_dir = args.patch_dir

    # Apply patches
    if patches:
        for patch in patches:
            patchfile = Path(patch)
            if patch_dir:
                patchfile = Path(patch_dir) / patchfile
            os.system(f'git -C {repo} am {patchfile}')


if __name__ == '__main__':
    main()
