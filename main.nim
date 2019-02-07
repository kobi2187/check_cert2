# main.nim

import docopt, smtp, vmvc, os #, yaml
# import docopt/value
import domain, ctrl, util

let doc = """
Check Certificates.

Usage:
  check_cert -v | --version
  check_cert -h | --help
  check_cert file <configFile> [--timeout=<timeout>]
  check_cert file <configFile> [--local] [--validate-file] [--validate-sites] [--timeout=<timeout>]
  check_cert file <configFile> report [--timeout=<timeout>]  [--ignoreAfterDays=<ignoreAfterDays>]
  check_cert file <configFile> report <some_txt_file> [--timeout=<timeout>]  [--ignoreAfterDays=<ignoreAfterDays>]
  check_cert file <configFile> report <some_txt_file> [--dontshow]  [--timeout=<timeout>]  [--ignoreAfterDays=<ignoreAfterDays>]
  check_cert file <configFile> mail [--timeout=<timeout>]  [--ignoreAfterDays=<ignoreAfterDays>]
  check_cert file <configFile> mail <mail_password> [--timeout=<timeout>]  [--ignoreAfterDays=<ignoreAfterDays>]
  check_cert file <configFile> report <some_txt_file> mail [--timeout=<timeout>]  [--ignoreAfterDays=<ignoreAfterDays>]
  check_cert file <configFile> report <some_txt_file> mail [<mail_password>] [--timeout=<timeout>]  [--ignoreAfterDays=<ignoreAfterDays>]

Options:
  -h --help	    Show this screen.
  -v --version  Show version.
  -y --yes      Assumes yes, doesn't show confirmations.
  --dontshow    No need to show me the generated report.
"""



import streams, json, strutils

proc loadFromFile(path: string): UserInfo =
  if false: assert false
  #[
     if path.endsWith(".yaml"):

    let yaml = path
    if not yaml.fileExists:
      fail("file does not exist")
    else:
      let fs = newFileStream(yaml)
      var config: UserInfo
      try:
        load(fs, config)
        return config
      except:
        fail("couldn't load configuration file '" & yaml & "'")
      finally:
        fs.close
    ]#
  elif path.endsWith(".json"):
    let jsonFile = path
    var fs = newFileStream(jsonFile)
    let jsonNode = fs.parseJson
    let obj = jsonNode.to(UserInfo)
    return obj
  else:
    fail("please pass a yaml or json file", false)

import program_info
proc main() =
  # commandLineParams()
  let args = docopt(doc, version = version)
  echo args
  if not args["file"]:
    fail("must have file")
  else:
    let configFile = $(args["<configFile>"])
    let config = loadFromFile(configFile)
    ctrl.start(args, config) # by now we have args and config, enough to understand what user requests.

main()
