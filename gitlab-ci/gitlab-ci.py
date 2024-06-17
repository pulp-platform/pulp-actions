#!/usr/bin/env python3
#
# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Paul Scheffler <paulsc@iis.ee.ethz.ch>
# Nils Wistoff <nwistoff@iis.ee.ethz.ch>

import os
import sys
import time
import requests
import urllib.parse


def main(sha: str, token: str, domain: str, repo: str, api_version: str,
         retry_count: int, retry_period: int, poll_count: int, poll_period: int):
    # Derive pipeline request URL. We want only pipelines with our SHA in descending ID (creation)
    # order, so the most recent pipeline matching our SHA is the first in the list.
    pipelines = f'https://{domain}/api/{api_version}/projects/{urllib.parse.quote_plus(repo)}/pipelines?sha={sha}&order_by=id&sort=desc'

    # Wait for pipeline to spawn
    for i in range(1, retry_count+1):
        response = requests.get(pipelines, headers={'PRIVATE-TOKEN': token}).json()
        if 'error' in response:
            print(f'Gitlab API Error: \'{response["error"]}\', '
                  f'description: \'{response["error_description"] if "error_description" in response else "<no description>"}\', '
                  f'scope: \'{response["scope"] if "scope" in response else "<no scope>"}\'')
            return 4
        if len(response):
            if not isinstance(response, list):
                print(f'Error: received non-list response: {response}')
                return 5
            break
        else:
            print(f'[{i*retry_period}s] No pipeline yet for SHA {sha}')
            time.sleep(retry_period)
    else:
        print(f'[{retry_count*retry_period}s] Pipeline spawn timeout')
        return 2

    # Wait for pipeline to complete
    for i in range(1, poll_count+1):
        response = requests.get(pipelines, headers={'PRIVATE-TOKEN': token}).json()
        if 'error' in response:
            print(f'Gitlab API Error: \'{response["error"]}\', '
                  f'description: \'{response["error_description"] if "error_description" in response else "<no description>"}\', '
                  f'scope: \'{response["scope"] if "scope" in response else "<no scope>"}\'')
            return 4
        pipeline = response[0]
        if pipeline['status'] == 'success':
            print(f'[{i*poll_period}s] Pipeline success! See {pipeline["web_url"]}')
            return 0
        elif pipeline['status'] in ('failed', 'canceled', 'skipped'):
            print(f'[{i*poll_period}s] Pipeline failure! See {pipeline["web_url"]}')
            return 1
        print(f'[{i*poll_period}s] Pipeline status: {pipeline["status"]}')
        time.sleep(poll_period)
    else:
        print(f'[{poll_count*poll_period}s] Pipeline completion timeout! See {pipeline["web_url"]}')
        return 3


if __name__ == '__main__':
    sys.exit(main(*(int(a) if a.isdigit() else a for a in sys.argv[1:])))
