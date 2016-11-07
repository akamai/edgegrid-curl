# edgegrid-curl

Python-based command wrapper for cURL to sign requests for Akamai OPEN APIs.

egcurl is a simple wrapper around cURL to help with calls to Akamai OPEN APIs. The script intercepts a subset of curl command arguments in order to produce a request signature, then uses curl to make the API call with all the original arguments plus the computed request signature.

Note that there is now a simpler command line utility, httpie, which doesn't depend on you already knowing how to use cURL. It is available [here](https://github.com/akamai-open/httpie-edgegrid) or by calling

```
pip install httpie-edgegrid
```

The examples and guides on the developer portal are moving to this new tool, so please consider using it for your API calls.

## CHANGES
2016-11-07
* Add support for EdgeRc configuration files.

2016-08-25
* Use EdgeGridAuth to sign requests.
* Automatically use hostname specified by configuration section.

2016-06-01
* Use logging module for logging.
* Replace getopt argument parsing code with argparse (requires python 2.7+)

2014-05-13
* (GRID-231) A POST request body larger than the content hash max-body is allowed but only the first (max-body) bytes are used in the [Content hash aspect of the request signature](https://developer.akamai.com/stuff/Getting_Started_with_OPEN_APIs/Client_Auth.html).


## INSTALLATION

1. Install python 2.7 or newer. If you are running GNU/Linux or Mac OS X, you probably already have it.
2. Install curl. The script expects to find it in your path.
3. Install edgegrid-python. This is used to sign requests. (`pip install edgegrid-python`)
4. Clone this repository and then you can execute egcurl directly from the repository clone.


## CONFIGURATION

The EdgeGrid plugin relies on an `~/.edgerc` credentials file that needs to be created in your home directory and organized by [section] following the format below. Each [section] can contain a different credentials set allowing you to store all of your credentials in a single `~/.edgerc` file.

```
    [default]
    client_secret = xxxx
    host = xxxx # Note, don't include the https:// here
    access_token = xxxx
    client_token = xxxx
    max-body = xxxx

    [section1]
    client_secret = xxxx
    host = xxxx # Note, don't include the https:// here
    access_token = xxxx
    client_token = xxxx
    max-body = xxxx
```

Once you have the credentials set up you can use egcurl as well as other Akamai OPEN tools.

Use the `--eg-section` argument to specify which section from the configuration file contains the desired credentials for your API request.


## OLDER `~/.egcurl` CONFIGURATION

egcurl supports an older non-standard configuration file, specified by `--eg-config`. If this argument is used (or if `~/.egcurl` exists), this configuration file will be consulted first to retrieve your client configuration. If the file does not exist or the section is not found, egcurl will look for the client configuration in your `~/.edgerc` automatically.

The older `~/.egcurl` configuration is deprecated. Support for this file and format will be removed on or shortly after 2017-05-01. You can easily convert an olrder `~/.egcurl` configuration to an `~/.edgerc` with the `convert_egcurl.pl` script. For example:

```
$ ./convert_egcurl.pl < ~/.egcurl > ~/.edgerc
$ mv ~/.egcurl ~/.egcurl-backup
```


## COMMAND LINE

egcurl is a wrapper around the traditional curl command, so nearly all arguments for curl are supported.

There are three optional non-standard arguments available:

* `--eg-edgerc FILE`: Use `FILE` instead of `~/.edgerc` to read the configuration.
* `--eg-section SECTION`: Use section `SECTION` instead of section "default" in the configuration.
* `--eg-verbose`: Increase logging verbosity. Can be repeated to further increase verbosity.

These arguments are not supported:

* `-F`, `--form`, `--form-string`
* `--data-urlencode`
* `-G`, `--get`

There are several restrictions on specifying the request data for POST and PUT requests (currently only POST requests).

1. Only supports `-d`, `--data` and `--data-ascii` for ascii data and `--data-binary` for binary data.
2. Only one data option can be used on the same command line.
3. If the data starts with the `@` character, the rest is treated as the name of the file to read the data from. Only one file can be specified on the same command line.

The hostname segment of the url will be automatically replaced with the hostname indicated by the selected configuration section.

## USAGE

```
$ ./egcurl --help
usage: egcurl [-h] [-H HEADER] [--eg-edgerc EG_EDGERC | --eg-config EG_CONFIG]
              [--eg-section EG_SECTION] [--eg-verbose]
              [-d DATA | --data-binary DATA_BINARY] [-X {DELETE,GET,POST,PUT}]
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
  --eg-section EG_SECTION
                        Section of the config file for the desired OPEN API
                        credentials.
  --eg-verbose          Enable verbose logging output (repeat for even more)
  -d DATA, --data DATA, --data-ascii DATA
                        ASCII data content for POST body
  --data-binary DATA_BINARY
                        binary data content for POST body
  -X {DELETE,GET,POST,PUT}, --method {DELETE,GET,POST,PUT}
                        HTTP method for the request

Several arguments above as well as any unlisted arguments are passed on to
curl. The <url> argument should always be the final argument. The url hostname
will automatically be replaced with the one specified by the selected
configuration section.
```

## EXAMPLE

Here is an example `~/.edgerc` configuration:

```
[default]
access_token = akaa-ublu6mqdcqkjw5lz-542a56pcogddddow
client_secret = SOMESECRET
client_token = akaa-nev5k66unzize2gx-5uz4svbszp4ko5wq
host = akaa-u5x3btzf44hplb4q-6jrzwnvo7llch3po.luna.akamaiapis.net
max-body = 131072
```

Here is an example invocation:

```
egcurl -sSik 'https://luna.akamaiapis.net/billing-usage/v1/reportSources'
```
