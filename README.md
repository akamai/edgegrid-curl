# edgegrid-curl

Python-based command wrapper for cURL to sign requests for Akamai OPEN APIs.

Note that there is now a simpler command line utility, httpie, which uses the same authentication mechanism as our language signing libraries.  It is available [here](https://github.com/akamai-open/httpie-edgegrid) or by calling 

```
pip install httpie-edgegrid
```

The examples and guides on the developer portal are moving to this new tool, so please consider using it for your API calls.

## CHANGES
2016-06-01
* Use logging module for logging.
* Replace getopt argument parsing code with argparse (requires python 2.7+)

2014-05-13
* (GRID-231) A POST request body larger than the content hash max-body is allowed but only the first (max-body) bytes are used in the [Content hash aspect of the request signature](https://developer.akamai.com/stuff/Getting_Started_with_OPEN_APIs/Client_Auth.html).


## SUMMARY

egcurl is a simple wrapper around cURL to help with calling Akamai OPEN APIs. The script examines a subset of curl command arguments in order to produce a request signature, then uses curl to make the API call with all the original arguments plus the computed request signature.

egcurl requires Python 2.x where x >= 7 on a \*nix platform. It depends on curl to make API calls.


## CONFIGURATION

The parameters and credentials for signing the requests are configured with a configuration file, by default .egcurl in your home directory. The command line can also specify the configuration file to use.

The configuration is divided into sections with names in brackets. By default, egcurl looks up configurations in the section name "default", but the command line can override that.

Lines starting with "`#`" are comments and ignored.

Within each section, the entries are checked until the first match is found. If no match is found, an error is returned.

The only currently supported match is based on the host, for example,

```
host:akaa-51eeae4527df90cd-c2200ed3b0d10909.luna-dev.akamaiapis.net
```

The signing parameters are specified as name:value pairs on the same line following the host value, separated with a space. The supported parameters are:

* client_token: for specifying the client token obtained from the client provisioning process
* access_token: for specifying the access token obtained from the client authorization process
* secret: for specifying the client secret that is associated with the client token
* max-body: for specifying the maximum allowed size in bytes of the request body, for POST and PUT requests. This value is provided by the API service provider.
* signed-header: for specifying the ordered list of request headers to be included in the request signature. This is also provided by the API service provider. This parameter is optional if no header is needed in the signature.


## COMMAND LINE

egcurl is a wrapper around the traditional curl command, so nearly all arguments for curl are supported.

There are three optional arguments available:

* `--eg-config FILE`: Use `FILE` instead of `~/.egcurl` to read the configuration.
* `--eg-section SECTION`: Use section `SECTION` instead of section "default" in the configuration.
* `--eg-verbose`: Print which line from the configuration matched the request, the actual arguments to be sent to curl, and perhaps other debugging information.

These arguments are not supported:

* `-F`, `--form`, `--form-string`
* `--data-urlencode`
* `-G`, `--get`

There are several restrictions on specifying the request data for POST and PUT requests (currently only POST requests).

1. Only supports "`-d`", "`--data`" and "`--data-ascii`" for ascii data and "`--data-binary`" for binary data.
2. Only one data option can be used on the same command line.
3. If the data starts with the letter "`@`", the rest is treated as the name of the file to read the data from. Only one file can be specified on the same command line.

## USAGE

```
$ ./egcurl --help
usage: egcurl [-h] [-H HEADER] [--eg-config EG_CONFIG]
              [--eg-section EG_SECTION] [--eg-verbose]
              [-d DATA | --data-binary DATA_BINARY] [-X {DELETE,GET,POST,PUT}]
              url

Akamai OPEN API utility for signed API requests with cURL.

positional arguments:
  url                   Request URL

optional arguments:
  -h, --help            show this help message and exit
  -H HEADER, --header HEADER
                        HTTP headers to pass on to cURL (repeatable)
  --eg-config EG_CONFIG
                        Location of configuration ini file.
  --eg-section EG_SECTION
                        Section of the config file for the desired OPEN API
                        credentials.
  --eg-verbose          Enable verbose logging output
  -d DATA, --data DATA, --data-ascii DATA
                        ASCII data content for POST body
  --data-binary DATA_BINARY
                        binary data content for POST body
  -X {DELETE,GET,POST,PUT}, --method {DELETE,GET,POST,PUT}
                        HTTP method for the request

Several arguments above as well as any unlisted arguments are passed on to
curl. The <url> argument should always be the final argument.
```

## EXAMPLE

Here is an example configuration:

```
[default]
host:akaa-u5x3btzf44hplb4q-6jrzwnvo7llch3po.luna.akamaiapis.net client_token:akaa-nev5k66unzize2gx-5uz4svbszp4ko5wq access_token:akaa-ublu6mqdcqkjw5lz-542a56pcogddddow secret:SOMESECRET max-body:2048
```

Here is an example invocation:

```
egcurl -sSik 'https://akaa-u5x3btzf44hplb4q-6jrzwnvo7llch3po.luna.akamaiapis.net/billing-usage/v1/reportSources'
```
