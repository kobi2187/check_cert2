import docopt

import domain
import manage_reports, manage_certificate, manage_mailing, manage_network,
  manage_reporting

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

var sites: seq[CheckedSite] = @[]
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
    for website in sites.mitems:
      let s = check_site(website.site, website.port, 450)
      website.connected = some(s)
      echo if s: "yes" else: "no"

    # report the ones
    let failed = sites.filter(proc (x: CheckedSite): bool = not x.connected.get)
    if failed.len > 0:
      echo "failed to connect to websites:"
      for f in failed:
        echo f
      fail("Failed to connect to websites listed in config file. please fix.",
        false)
    else:
      echo "no problem connecting to the sites listed"

  proc doMail(args: Table[string, docopt.Value], cfg: UserInfo,
      report: string) =
    discard                   # TODO: mail part.


  echo "starts real program"
  # start operation.
  # validate user info.
  echo "\"calculating\" implications of arguments"
  let what = implications(args)
  if what.local: doLocal()
  if what.sites: doSites()

  for w in cfg.sites_to_check:
    sites.add(newCheckedSite(w.site, w.port))

  var report: string
  if what.report:
    report = doReport(sites)
    if not args["--dontshow"]:
      echo report

  if what.mail:
    doMail(args, cfg, report)

