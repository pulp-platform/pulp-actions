#!/usr/bin/env bash
#
# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nils Wistoff <nwistoff@iis.ee.ethz.ch>

# Check for existing bender installation
if [ -x "$(command -v bender)" ]; then
  if [[ "${{ inputs.version }}" = "" ]] || [[ "$(bender --version)" = "bender ${{ inputs.version }}" ]]; then
    echo "bender-install: $(bender --version) already installed."
    exit 0
  else
    echo "bender-install: bender ${{ inputs.version }} requested but $(bender --version) is already installed. Aborting."
    exit 1
  fi
fi

# Install bender
sudo mkdir -p /tools/bender && sudo chmod 777 /tools/bender
cd /tools/bender && curl --proto '=https' --tlsv1.2 -sSf https://pulp-platform.github.io/bender/init | bash -s -- ${{ inputs.version }}
echo "PATH=/tools/bender:$PATH" >> ${GITHUB_ENV}
