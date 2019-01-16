# main.nim

import docopt, parsecfg, smtp, vmvc, os
# import docopt/value
import domain

let doc = """
Check Certificates.

Usage:
  check_cert file <cfg_file>  
  check_cert file <cfg_file> --local
  check_cert file <cfg_file> --validate-file --validate-sites
  check_cert file <cfg_file> report <some_txt_file>
  check_cert file <cfg_file> report <some_txt_file> --dontshow
  check_cert file <cfg_file> mail
  check_cert file <cfg_file> mail -y
  check_cert file <cfg_file> mail <mail_password>
  check_cert file <cfg_file> report <some_txt_file> mail
  check_cert file <cfg_file> report <some_txt_file> mail [<mail_password>]
  check_cert -v | --version
  check_cert -h | --help

Options:
  -h --help	    Show this screen.
  -v --version  Show version.
  -y --yes      Assumes yes, doesn't show confirmations.
  --dontshow    No need to show me the generated report.
"""

template fail(errMsg: string) =
  quit(errMsg, QuitFailure)


proc main() =
  # commandLineParams()
  let args = docopt(doc, version = "0.1")
  echo args
  if args["file"]:
    let cfg = $(args["<cfg_file>"])
    echo cfg
    if not cfg.fileExists:
      fail("file does not exist")


main()
# proc start(userArgs: UserConfig) =
#   # starts real program

#   # validate file exists, validate file structure, validate info.
#   # create info as new object
#   let info: Info #... creates info from cfg file

#   # start operation.
