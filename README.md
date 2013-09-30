edgegrid-curl
=============

Python based command line tool which simplies EdgeGrid Client Authentication


==SUMMARY

egcurl is a curl-like tool for invoking APIs that are carried on the Akamai EdgeGrid network. It adds the EdgeGrid signature to a normal curl request.  
egcurl requires Python 2.x where x >= 6 on a *nix platform.


==CONFIGURATION

The parameters and credentials for signing the requests are configured with a configuration file, by default .egcurl in your home directory. The command line can also specify the configuration file to use.

The configuration is divided into sections with names in brackets. By default, egcurl looks up configurations in the section name "default", but the command line can override that.

Lines starting with "#" are comments and ignored.

Within each section, the entries are checked until the first match is found. If no match is found, an error is returned.

The only currently supported match is based on the host, for example,

host:akaa-51eeae4527df90cd-c2200ed3b0d10909.luna-dev.akamaiapis.net

The signing parameters are specified as name:value pairs on the same line following the host value, separated with a space. The supported parameters are:

* client_token: for specifying the client token obtained from the client provisioning process
* access_token: for specifying the access token obtained from the client authorization process
* secret: for specifying the client secret that is associated with the client token
* max-body: for specifying the maximum allowed size in bytes of the request body, for POST and PUT requests. This value is provided by the API service provider.
* signed-header: for specifying the ordered list of request headers to be included in the request signature. This is also provided by the API service provider. This parameter is optional if no header is needed in the signature.


==COMMAND LINE

egcurl supports most of the curl command line options that are relevant to API requests, with several additional optional arguments.

The additional optional arguments are: 

--eg-config FILE: Use FILE instead of ~/.egcurl to read the configuration.  
--eg-section SECTION: Use section SECTION instead of section "default" in the configuration.  
--eg-verbose: Print which line from the configuration matched the request, the actual arguments to be sent to curl, and perhaps other debugging information.

Restrictions on data options

There are several restrictions on specifying the request data for POST and PUT requests (currently only POST requests).

1. Only supports "-d", "--data" and "--data-ascii" for assii data and "--data-binary" for binary data. The form-related options, such as "-F", "--form", "--form-string", "--data-urlencode", "-G" and "--get", are not allowed.
2. Only one data options can be used on the same command line.
3. If the data starts with the letter @, the rest is treated as the name to read the data from. Only one file can be specified on the same command line.


==EXAMPLE

Here is an example configuration:

[default]  
host:akaa-u5x3btzf44hplb4q-6jrzwnvo7llch3po.luna.akamaiapis.net client\_token:akaa-nev5k66unzize2gx-5uz4svbszp4ko5wq access\_token:akaa-ublu6mqdcqkjw5lz-542a56pcogddddow secret:SOMESECRET max-body:2048

Here is an example invocation:

egcurl -sSik 'https://akaa-u5x3btzf44hplb4q-6jrzwnvo7llch3po.luna.akamaiapis.net/billing-usage/v1/reportSources'
