import docopt

import domain
import manage_certificate, manage_mailing, manage_network,
  manage_reporting

import sugar, strutils

type WhatToDo = object
  local*: bool
  sites*: bool
  report*: bool
  mail*: bool

proc implications(args: Table[string, docopt.Value]): WhatToDo =
  var operations = WhatToDo()
  if args["--local"] or args["--validate-file"]:
    operations.local = true
  if args["--validate-sites"]:
    operations.local = true
    operations.sites = true
  # report implies local checking, and sites existence.
  if args["report"]:
    operations.local = true
    operations.sites = true
    operations.report = true
  # mail implies report
  if args["mail"]:
    operations.local = true
    operations.sites = true
    operations.report = true
    operations.mail = true

  result = operations




import uri, net, sequtils, sugar, options, times

var allSites: seq[CheckedSite] = @[]
import util

proc start*(args: Table[string, docopt.Value], cfg: UserInfo) =

  proc doLocal() =
    echo "validating file information"
    let msg = cfg.isValid
    echo "file is valid: " & $msg.isValid
    if not msg.isValid: fail("this value failed: " & msg.info,
      lastException = false)

  proc doSites() =
    echo "checking if website online:"
    for website in allSites.mitems:
      let s = check_site(website.site, website.port, 450)
      website.connected = some(s)
      echo if s: "yes" else: "no"

    # report the ones
    let failed = allSites.filter(proc (x: CheckedSite): bool = not x.connected.get)
    if failed.len > 0:
      echo "failed to connect to websites:"
      for f in failed:
        echo f
      fail("Failed to connect to websites listed in config file. please fix.",
        false)
    else:
      echo "no problem connecting to the sites listed"

  proc doMail(args: Table[string, docopt.Value], cfg: UserInfo,
      group: SiteGroup; subject, report: string, pass: string) =

    assert pass.len > 0
    sendReportMailOne(cfg, group, subject, report, pass)


  echo "starts real program"
  # start operation.
  # validate user info.
  echo "\"calculating\" implications of arguments"
  let what = implications(args)
  if what.local: doLocal()

  for w in cfg.groups:
    for site in w.sites_to_check:
      allSites.add(newCheckedSite(site.site, site.port))

  if what.sites: doSites()
  var pass: string
  if what.mail:
    if args["<mail_password>"]:
      pass = $args["<mail_password>"]
    else:
      echo "please enter your mail password (CLEAR TEXT; please note your terminal will visibly show it)"
      pass = stdin.readline.strip
  # var report: string
  if what.report: #TODO: find a way to cleanup the finally part better.
    var file: File
    var openedFile = false
    defer:
      if openedFile: file.close()

    if args["<some_txt_file>"]:
      try:
        let path = $args["<some_txt_file>"]
        file = path.open(fmWrite) # older content gets overwritten, but new one is appended
        openedFile = true
      except:
        fail("could not open specified file for writing the report")

    for i, group in cfg.groups:
      var checkThose = group.sites_to_check.mapIt(newCheckedSite(
          it.site, it.port))
      let (subject, report) = doReport(checkThose)
      if not args["--dontshow"]:
        echo report
      if openedFile: # we append all the reports to this one file.
        file.write(report)
        file.write("\n\n" & $(i+1) & ")\n")

      # there is no mail, without report. after each report send the mail.
      if what.mail:
        doMail(args, cfg, group, subject, report, pass)

