import docopt

import domain
import manage_reports, manage_certificate, manage_mailing, manage_network

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
proc start*(args: Table[string, docopt.Value], cfg: UserInfo) =
  proc doLocal() =
    echo "validating file information"
    let (more_info, res) = cfg.isValid
    echo "file is valid: " & $res
    if not res: fail("this value failed: " & more_info,
      lastException = false)

  proc doSites() =
    echo "checking if website online:"
    var res: seq[(Website, bool)] = @[]
    for website in cfg.sites_to_check:
      let s = check_site(parseUri(website.site), Port website.port)
      res.add((website, s))
    # report the ones
    let failed = res.filter(proc (x: (Website, bool)): bool = not x[1])
    if failed.len > 0:
      echo "failed to connect to websites:"
      for f in failed:
        echo f
      fail("Failed to connect to websites listed in config file. please fix.",
        false)
    else:
      echo "no problem connecting to the sites listed"
  proc doReport() =
    echo "checking for certificates..."
    for website in cfg.sites_to_check:
      let opt = validity_times(website.site, website.port)
      if opt.isNone:
        #todo: add to report here.
        echo "website: " & website.site & ":" &
            $website.port & "-- couldn't get certificate" #report
      else:
        let (timeFrom, timeTo) = opt.get()
        if timeFrom > now():
          echo "certificate time starts in the future" #report
        if timeTo < now() + 60.days: # todo: make 60 configurable. 60 as default
          let timeLeft = timeTo - now()
          if timeLeft.days < 0:
            echo "certificate already expired!" # report
          else:
            echo "certificate expires in " & $timeLeft.days & " days." #report
            # todo: sort by time left, in the report.
  proc doMail() =
    discard


  echo "starts real program"
  # start operation.
  # validate user info.
  echo "\"calculating\" implications of arguments"
  let what = implications(args)
  if what.local: doLocal()
  if what.sites: doSites()
  if what.report:
    doReport()

  if what.mail:
    doMail()

# todo refactor to smaller procs
