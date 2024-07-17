# RELEASE NOTES

## 2022-04-14

* Reorder list of arguments before parsing it, moving URL to the beginning.

## 2022-04-13

* Pass unknown argument before known ones, to let -q be passed in 1st position and honored.

## 2021-04-22

* Added PATCH as a valid method argument.

## 2017-07-27

* Add --eg-json argument to pretty-format JSON responses.

## 2016-11-07

* Add support for EdgeRc configuration files.

## 2016-08-25

* Use EdgeGridAuth to sign requests.
* Automatically use hostname specified by configuration section.

## 2016-06-01

* Use logging module for logging.
* Replace getopt argument parsing code with argparse (requires python 2.7+)

## 2014-05-13

* (GRID-231) A POST request body larger than the content hash max-body is allowed but only the first (max-body) bytes are used in the [Content hash aspect of the request signature](https://developer.akamai.com/stuff/Getting_Started_with_OPEN_APIs/Client_Auth.html).