# EdgeGrid for cURL

This library implements an Authentication handler for HTTP requests using the [Akamai EdgeGrid Authentication](https://techdocs.akamai.com/developer/docs/authenticate-with-edgegrid) scheme for cURL.

`egcurl` is a simple Python-based command wrapper around the traditional [cURL](https://curl.se) command to sign requests for Akamai OPEN APIs. The script intercepts a subset of cURL command arguments to produce a request signature. Then it uses cURL to make the API call with all the original arguments and the computed request signature.

> **Note:** There is now a simpler command line tool available, httpie. You don't need to be familiar with cURL to use httpie. It's available on the [httpie-edgegrid](https://github.com/akamai-open/httpie-edgegrid) GitHub repository or by running this command:

```
pip install httpie-edgegrid
```

The examples and guides on the [developer portal](https://techdocs.akamai.com/home/page/apis) are moving to this new tool, thus consider using it for your API calls.

## Install

1. Install [Python 2.7](https://www.python.org/downloads/) or newer. If you're running GNU/Linux or macOS X, you probably already have it.
   
2. Install [cURL](https://curl.se/download.html). The script expects to find it in your path.
   
3. Install edgegrid-python to sign your requests by running:
   
   ````pip install edgegrid-python````
   
4. Clone this repository and then execute `egcurl` directly from the cloned repository.

## Authentication

We provide authentication credentials through an API client. Requests to the API are signed with a timestamp and are executed immediately.

1. [Create authentication credentials](https://techdocs.akamai.com/developer/docs/set-up-authentication-credentials).
   
2. Place your credentials in an EdgeGrid resource file, `.edgerc`, under a heading of `[default]` at your local home directory or the home directory of a web-server user.
   
   ```
   [default]
    client_secret = C113nt53KR3TN6N90yVuAgICxIRwsObLi0E67/N8eRN=
    host = akab-h05tnam3wl42son7nktnlnnx-kbob3i3v.luna.akamaiapis.net
    access_token = akab-acc35t0k3nodujqunph3w7hzp7-gtm6ij
    client_token = akab-c113ntt0k3n4qtari252bfxxbsl-yvsdj
   ```
   
3. Use `egcurl` to sign your requests along with and `--eg-edgerc` argument to point to the path of your `.edgerc` configuration file and an `--eg-section` argument to specify the credentials' section header.
   
   ```shell
   egcurl --eg-edgerc ~/.edgerc --eg-section default --request GET
   ```

### `~/.egcurl` configuration

`egcurl` supports an older non-standard configuration file, specified by `--eg-config`. If you use this argument or if the `~/.egcurl` file exists, this configuration file will be consulted first to retrieve your client configuration. If the file doesn't exist or the section isn't found, `egcurl` will look for the client configuration in your `~/.edgerc` file automatically.

The older `~/.egcurl` configuration is **deprecated**. Support for this file and format will be removed on or shortly after 2017-05-01. You can easily convert an older `~/.egcurl` configuration to an `~/.edgerc` with the `convert_egcurl.pl` script. For example:

```
$ ./convert_egcurl.pl < ~/.egcurl > ~/.edgerc
$ mv ~/.egcurl ~/.egcurl-backup
```

## Use

To use the library, provide the credential's section header of your `.edgerc` file and the appropriate endpoint information.

The `host` segment of the url will be automatically replaced with the host indicated by the selected configuration section.

```shell
egcurl --eg-edgerc ~/.edgerc --eg-section default --request GET \
     --url https://$host/identity-management/v3/user-profile \
     --header 'accept: application/json'
```

### Query string parameters

When entering query parameters, you can first save them as variables and then pass them in the url after a question mark ("?") at the end of the main URL path.

```shell
authGrants=true
notifications=true
actions=true

egcurl --eg-edgerc ~/.edgerc --eg-section default --request GET \
     --url 'https://$host/identity-management/v3/user-profile?authGrants=$authGrants&notifications=$notifications&actions=$actions' \
     --header 'accept: application/json'
```

### Headers

Enter request headers in the `--header` argument.

> **Note:** You don't need to include the `Content-Type` and `Content-Length` headers. The authentication layer adds these values.

```shell
egcurl --eg-edgerc ~/.edgerc --eg-section default --request GET \
     --url https://$host/identity-management/v3/user-profile \
     --header 'accept: application/json'
```

### Body data

Provide the request body as an object in the `--data` argument.

```shell
egcurl --eg-edgerc ~/.edgerc --eg-section default --request PUT \
     --url https://$host/identity-management/v3/user-profile/basic-info \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
  "contactType": "Billing",
  "country": "USA",
  "firstName": "John",
  "lastName": "Smith",
  "preferredLanguage": "English",
  "sessionTimeOut": 30,
  "timeZone": "GMT",
  "phone": "3456788765"
}'
```

### Debug

Use the `--eg-verbose` argument to enable debugging and get additional information on the HTTP request and response.

```Shell
egcurl --eg-verbose --eg-edgerc ~/.edgerc --eg-section default --request GET \
     --url https://$host/identity-management/v3/user-profile \
     --header 'accept: application/json'
```

## Command line

`egcurl` is a wrapper around the traditional cURL command, thus it supports nearly all arguments for cURL.

### Arguments

`egcurl` has these optional non-standard arguments available:

| Argument | Description |
| --------- | ----------- |
| `--eg-edgerc <FILE>` | Location of your `.edgerc` configuration file. |
| `--eg-section <SECTION>` | The credential's section header of your `.edgerc` configuration file. |
|`--eg-json` | Automatically applies JSON pretty-format to the response.|
|`--eg-verbose` | Increases logging verbosity. Can be repeated to further increase verbosity. |


> **Note:** `egcurl` doesn't support these arguments:
>
> -  `-F`, `--form`, `--form-string`
> - `--data-urlencode`
> - `-G`, `--get`

### Limitations

There're several things you need to take into account when specifying the request data for POST requests.

- The POST requests support only `-d`, `--data` and `--data-ascii` for ascii data and `--data-binary` for binary data.
   
- You can use only one data option on the same command line.
   
- If the data starts with the `@` character, the rest is treated as the name of the file to read the data from. You can specify only one file on the same command line.

### Help

Use `./egcurl --help` to get detailed information on `egcurl` and the available arguments.

```shell
$ ./egcurl --help
usage: egcurl [-h] [-H HEADER] [--eg-edgerc EG_EDGERC | --eg-config EG_CONFIG]
              [--eg-json] [--eg-section EG_SECTION] [--eg-verbose]
              [-d DATA | --data-binary DATA_BINARY] [-X {DELETE,GET,PATCH,POST,PUT}]
              url

Akamai {OPEN} API utility for signed API requests with cURL.

positional arguments:
  url                   Request URL

optional arguments:
  -h, --help            show this help message and exit
  -H HEADER, --header HEADER
                        HTTP headers to pass on to cURL (repeatable)
  --eg-edgerc EG_EDGERC
                        Location of EdgeRc configuration ini file.
  --eg-config EG_CONFIG
                        Location of older configuration file (DEPRECATED).
  --eg-json             Automatically apply JSON pretty-format to the response.
  --eg-section EG_SECTION
                        Section of the config file for the desired OPEN API credentials.
  --eg-verbose          Enable verbose logging output (repeat for even more)
  -d DATA, --data DATA, --data-ascii DATA
                        ASCII data content for POST body
  --data-binary DATA_BINARY
                        binary data content for POST body
  -X {DELETE,GET,PATCH,POST,PUT}, --method {DELETE,GET,PATCH,POST,PUT}, --request {DELETE,GET,PATCH,POST,PUT}
                        HTTP method for the request

Several arguments above as well as any unlisted arguments are passed on to cURL,
starting with unlisted arguments followed by URL. The <url> argument should always be
the first item starting with "https://". The URL hostname will automatically be replaced
with the one specified by the selected configuration section.
```


## Bugs

This tool indirectly uses pyOpenSSL for Python < 3 via [EdgeGrid for Python](https://github.com/akamai/AkamaiOPEN-edgegrid-python/), which is used to produce request signatures. macOS includes a very old version of it (0.13.1) by default, which is incompatible with EdgeGrid for Python. 

If you're using macOS and are incorrectly receiving an instruction to run `pip install edgegrid-python`, the issue is likely that your pyOpenSSL dependency is too old and needs to be upgraded.

Run this command to fix the problem:

```
pip install -U pyOpenSSL
```

> **Note:** DO NOT RUN THIS COMMAND AS ROOT. It's not possible to upgrade the system installation of pyOpenSSL on macOS. Attempting to upgrade it will fail with inexplicable errors.

## Reporting issues

To report an issue or make a suggestion, create a new [GitHub issue](https://github.com/akamai/edgegrid-curl/issues).

## License

Copyright 2024 Akamai Technologies, Inc. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.