# main.nim

import docopt, yaml, smtp, vmvc, os
# import docopt/value
import domain, ctrl

let doc = """
Check Certificates.

Usage:
  check_cert -v | --version
  check_cert -h | --help
  check_cert file <yaml>  
  check_cert file <yaml> --local
  check_cert file <yaml> --validate-file --validate-sites
  check_cert file <yaml> report
  check_cert file <yaml> report <some_txt_file>
  check_cert file <yaml> report <some_txt_file> --dontshow
  check_cert file <yaml> mail
  check_cert file <yaml> mail -y
  check_cert file <yaml> mail <mail_password>
  check_cert file <yaml> report <some_txt_file> mail
  check_cert file <yaml> report <some_txt_file> mail [<mail_password>]

Options:
  -h --help	    Show this screen.
  -v --version  Show version.
  -y --yes      Assumes yes, doesn't show confirmations.
  --dontshow    No need to show me the generated report.
"""



import streams

proc main() =
  # commandLineParams()
  let args = docopt(doc, version = "0.1")
  echo args
  if not args["file"]:
    fail("must have file")
  else:
    let yaml = $(args["<yaml>"])
    if not yaml.fileExists:
      fail("file does not exist")
    else:
      let fs = newFileStream(yaml)
      var config: UserInfo
      try:
        load(fs, config)
      except:
        fail("couldn't load configuration file '" &
            yaml & "'")
      finally:
        fs.close

      ctrl.start(args, config) # by now we have args and config, enough to understand what user requests.

main()
