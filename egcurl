#!/usr/bin/env python
#
# Copyright 2013 Akamai Technologies, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import sys
if sys.version_info[0] >= 3:
     # python3
     from urllib import parse
else:
     # python2.7
     import urlparse as parse

import argparse
import json
import logging
import os
import re
import subprocess
from pprint import pformat

# data handling
# only handles -d/--data/--data-ascii/--data-binary
# no name
# only one entry, no repeats
# can handle @

logging.basicConfig()
log = logging.getLogger(__name__)

class MockRequest:
    def __init__(self, data_ascii, data_binary, headers, method, url):
        self.body = self.get_data(data_ascii, data_binary)
        log.info("body: %s", self.body)
        self.headers= headers or {}
        self.method = method
        self.url = url

    def get_data(self, data_ascii, data_binary):
        data = ''
        if data_ascii:
            data = data_ascii
        elif data_binary:
            data = data_binary
        # only hash POST for now
        if data and data.startswith("@"):
            data_file = data.lstrip("@")
            try:
                if not os.path.isfile(data_file):
                    raise Exception('%s is not a file' %(data_file))
                filesize = os.stat(data_file).st_size
                # read the file content, and assign to data
                with open(data_file, "r") as f:
                    data = f.read()
                    if data_ascii:
                        data = ''.join(data.splitlines())
                    return data
            except IOError:
                raise
        return data

    def register_hook(self, ignoredA, ignoredB):
        return

def get_config(edgerc_filename, egconf_filename, section):
    if os.path.isfile(os.path.expanduser(egconf_filename)):
        configs = _parse_egcurl(egconf_filename)
        if section in configs:
            logging.warning("Using configuraton from deprecated egconfig file '%s'. Please migrate to ~/.edgerc.", egconf_filename)
            config = configs[section]
            return config

    config = _parse_edgerc(os.path.expanduser(edgerc_filename), section)
    return config

def _parse_edgerc(file, section):
    if not os.path.isfile(file):
        return None
    edgerc = EdgeRc(file)
    config = {
        "access_token": edgerc.get(section, 'access_token'),
        "client_token": edgerc.get(section, 'client_token'),
        "host": edgerc.get(section, 'host'),
        "max-body": edgerc.getint(section, 'max-body'),
        "secret": edgerc.get(section, 'client_secret'),
        "signed-header": edgerc.get(section, 'headers_to_sign')
    }

    # The EdgeRc library ensures the whole file must be valid. If host is empty then there's no config found.
    if config['host'] is None:
        return None

    return config

def _parse_egcurl(file):
    configs = {}
    with open(file, "r") as f:
        current_section = None
        for line in f.readlines():
            if re.match("^\\s*($|#|;)", line): continue

            m = re.match("^\\s*\\[(.+?)\\]\\s*$", line)
            if m:
                current_section = m.group(1)
                continue

            config = {
                "access_token": None,
                "client_token": None,
                "host": None,
                "max-body": None,
                "secret": None,
                "signed-header": []
            }
            _parse_fields(config, line)
            if config["max-body"]:
                config["max-body"] = int(config["max-body"])
            else:
                config["max-body"] = 131072

            if None in config.values():
                log.warning("Bad config line in section '%s': %s", current_section, line)
            else:
                configs[current_section] = config

    return configs

def _parse_fields(config, line):
    fields = line.split()
    for field in fields:
        log.debug("Config Field: [%s]", field)

        match = re.match("^([^:]+):(.+)$", field)
        if not match:
            log.error("Config line: [%s] has invalid field [%s].", line, field)
            return

        key = match.group(1)
        value = match.group(2)
        log.debug("Config Key: [%s] Value: [%s]", key, value)

        if key not in config.keys():
            log.error("Config line: [%s] has nonexistent variable [%s].", line, key)
            return

        if type(config[key]) == list:
            config[key].append(value)
        elif not config[key]:
            config[key] = value
        else:
            log.error("Config line: [%s] has duplicate variable [%s].", line, key)
            break

def get_parser():
    parser = argparse.ArgumentParser(description='Akamai {OPEN} API utility for signed API requests with cURL.',
                                     epilog='Several arguments above as well as any unlisted arguments are passed on to curl. The <url> argument should always be the final argument. The url hostname will automatically be replaced with the one specified by the selected configuration section.')
    parser.add_argument('-H', '--header',
                        action='append',
                        default = [],
                        help='HTTP headers to pass on to cURL (repeatable)')
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--eg-edgerc",
                        default=os.path.expanduser("~/.edgerc"),
                        help='Location of EdgeRc configuration ini file.')
    group.add_argument("--eg-config",
                        default=os.path.expanduser("~/.egcurl"),
                        help='Location of older configuration file (DEPRECATED).')
    parser.add_argument("--eg-json",
                       default=False,
                       help='Automatically apply JSON pretty-format to the response.',
                       action='store_true')
    parser.add_argument("--eg-section",
                        default = "default",
                        help='Section of the config file for the desired OPEN API credentials.')
    parser.add_argument('--eg-verbose',
                        default=False,
                        help='Enable verbose logging output (repeat for even more)',
                        action='count')
    group = parser.add_mutually_exclusive_group()
    group.add_argument('-d', '--data', '--data-ascii',
                        help='ASCII data content for POST body')
    group.add_argument('--data-binary',
                        help='binary data content for POST body')
    parser.add_argument('-X', '--method',
                        choices=['DELETE', 'GET', 'POST', 'PUT'],
                        help='HTTP method for the request',
                        default='GET')
    parser.add_argument('url',
                        help='Request URL')
    (args, args_unknown) = parser.parse_known_args()
    if args.eg_verbose == 1:
        log.setLevel(logging.INFO)
    elif args.eg_verbose >= 2:
        log.setLevel(logging.DEBUG)

    log.info('Parsed known arguments: %s', pformat(args))
    log.debug('Pass-through cURL arguments: %s', pformat(args_unknown))

    disallowed_parser = argparse.ArgumentParser()
    disallowed_parser.add_argument("-F")
    disallowed_parser.add_argument("--form")
    disallowed_parser.add_argument("--form-string")
    disallowed_parser.add_argument("--data-urlencode")
    disallowed_parser.add_argument("-G", "--get", default=None, action='store_true')
    (args_bad, args_remainder)  = disallowed_parser.parse_known_args(args_unknown)

    unacceptable = []
    for (key, val) in vars(args_bad).items():
        if val != None:
            unacceptable.append(key)

    if len(unacceptable) != 0:
        log.debug('Disallowed cURL arguments: %s', pformat(args_bad))
        parser.error("Unsupported cURL arguments found: " + ', '.join(unacceptable))

    return (args, args_unknown)

def main():
    (args, args_unknown) = get_parser()

    section = args.eg_section
    method = args.method
    data_ascii = args.data
    data_binary = args.data_binary
    url = args.url

    headers = {}
    if args.header:
        for header in args.header:
            header_field = header.strip()
            header_name, header_value = header_field.split(':')
            if header_name:
                header_name = header_name.strip()
            if not header_name:
                log.error("Invalid header value: %s", header_name)
                sys.exit(1)
            if header_value:
                header_value = header_value.strip()
            if header_value:
                headers[header_name.lower()] = header_value

    config = get_config(args.eg_edgerc, args.eg_config, section)

    if not config:
        raise ValueError("Config section was invalid or not found.")

    if 'host' in headers and headers['host'] != config['host']:
        raise ValueError("Host header does not match config host")

    if config['max-body'] == 8192:
        log.warning("The max-body value '8192' is likely incorrect. Signing POST requests may fail. Try removing that from your configuration.")

    segments = parse.urlsplit(url)
    if segments.netloc != config['host']:
        log.warning("Requested hostname '%s' will be replaced by config host '%s'", segments.netloc, config['host'])
        url = parse.urlunsplit(segments._replace(netloc = config['host']))

    # update the args with the signature
    log.info("Authorization config: %s", pformat(config))

    auth = EdgeGridAuth(
        access_token=config['access_token'],
        client_secret=config['secret'],
        client_token=config['client_token'],
        headers_to_sign=config['signed-header'],
        max_body=config['max-body']
    )

    r = MockRequest(data_ascii, data_binary, headers, method, url)
    auth(r)
    auth_header = r.headers['Authorization']
    log.info("Authorization header: %s", auth_header)

    curl_args = ([ 'curl', '-X', method, '-H', 'Authorization:' + auth_header, '-H', 'Expect:' ])
    for header in args.header:
        curl_args.extend([ '-H', header ])
    if args.data:
        curl_args.extend([ '--data', args.data ])
    if args.data_binary:
        curl_args.extend([ '--data-binary', args.data_binary ])
    curl_args.extend(args_unknown + [ url ])

    log.info("cURL command: %s", " ".join(curl_args))
    sys.stdout.flush()

    stdoutType = None
    if args.eg_json:
        stdoutType = subprocess.PIPE
    proc = subprocess.Popen(args = curl_args,
                            stderr = None,
                            stdout = stdoutType,
                            universal_newlines = True)

    if args.eg_json:
        json_stdout = proc.stdout.read()
        try:
            json_data = json.loads(json_stdout)
            print(json.dumps(json_data, sort_keys=True, indent=4, separators=(',', ': ')))
        except ValueError:
            if len(json_stdout) == 0:
                log.warning("Response was actually empty, not JSON.")
            else:
                log.error("Exception parsing JSON response! Raw value will be printed to STDOUT.")
                print(json_stdout)

    proc.wait()
    return proc.returncode

if __name__ == "__main__":
    try:
        from akamai.edgegrid import EdgeGridAuth
        from akamai.edgegrid import EdgeRc
    except ImportError:
        print("""
This tool has been updated to use the Akamai EdgeGrid for Python library
to sign requests. That library will need to be installed before you can
make a request.

Please run this command to install the required library:

pip install edgegrid-python""")
        sys.exit(1)

    sys.exit(main())
