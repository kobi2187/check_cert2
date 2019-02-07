# manage_reporting
import domain, manage_certificate, options, times
import strutils

include program_info

proc doCertChecking(sites: var seq[CheckedSite], ignoreAfterDays: int) =
  echo "checking for certificates..."
  for website in sites.mitems:
    echo website.site

    let opt = validity_times(website.site, website.port)
    if opt.isNone:
      website.cert_failed = true
      echo "website: " & website.site & ":" &
          $website.port & "-- couldn't get certificate"
    else:
      let (timeFrom, timeTo) = opt.get()
      website.certificateStart = some(timeFrom)
      website.certificateEnd = some(timeTo)
      # all set.

      if website.hasFutureStartTime:
        echo "certificate time starts in the future"

      elif website.expiresInLessThan(ignoreAfterDays.days):
        if website.hasExpired:
          echo "certificate already expired!"
        else:
          echo "certificate expires in " & $website.timeLeft.days &
              " days."
      else:
        echo "got certificate"
        echo $website.timeLeft.days & " days left"


proc generateReport(progName, version: string, urgentMessage: string;
    the_rest,
    future_start_note, sites_without_certificates, already_expired: seq[
        CheckedSite]): (string, string) =
  var report = "\n\nThis is a certificate checking report, made by the program '" & progName & "', (version " & version & ").\n"
  if urgentMessage.len > 0: report &= "\nMost urgent: " & urgentMessage &
      "\n"
  if already_expired.len > 0:
    report &= "\nsites that already expired:\n"
    for w in already_expired:
      report &= "!!  " & w.site & ":" & $w.port & "\n"

  if sites_without_certificates.len > 0:
    report &= "\nsites without certificates:\n"
    for w in sites_without_certificates:
      report &= " -  " & w.site & ":" & $w.port & "\n"

  if future_start_note.len > 0:
    report &= "\nsites whose certificate starts in the future:\n\n"
    for w in future_start_note:
      report &= " NOTE: " & w.site & ":" & $w.port &
          " starts in the future: " &
          $w.certificateStart & "\n"

  if the_rest.len > 0:
    report &= "\nlist of sites by expiry date:\n"
    for w in the_rest:
      report &= "+ [" & align($w.timeLeft.days,
          4) & " days]  " & w.site & ":" &
          $w.port &
          "\n"

  result = (urgentMessage, report)

import sequtils, algorithm
proc doReport*(sites: var seq[CheckedSite], ignoreAfterDays: int): (string,
    string) =
  echo "Starting report here..."
  doCertChecking(sites, ignoreAfterDays)
  echo "we have all information needed now."
  echo "generating report..."
  #  report: 1) sites that don't have certificates. (this may be a config error)
  let sites_without_certificates = sites.filterIt(not it.hasCertificate)
  # 2) sites that have start time in the future (warning, but may be valid if ordering in advance)
  let future_start_note = sites.filterIt(
      it.hasCertificate and it.hasFutureStartTime)
  # 3) sites that expired (most urgent #1). choose the first for email subject.
  let already_expired = sites.filterIt(it.hasCertificate and it.hasExpired)
  # 4) then, list sites by order of expiry with #days next to them.
  let the_rest = sites.filterIt(it.hasCertificate and
      not it.hasExpired).sorted(proc(ws1,
          ws2: CheckedSite): int = ws1.timeLeft.cmp(ws2.timeLeft))
  # 5) subject of email will be the most urgent finding.
  var urgentMessage: string
  if already_expired.len > 0:
    let expired = already_expired[0]
    urgentMessage = "Certificate for website " & expired.site &
        " has already expired!"
  else:
    let soon = the_rest[0]
    urgentMessage = "Certificate for website " & soon.site & " expires in " &
        $soon.timeleft.days & " days"

  result = generateReport(progName, version, urgentMessage, the_rest,
      future_start_note,
      sites_without_certificates, already_expired)

