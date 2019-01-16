# check_cert
import system, osproc, strutils, times, strformat, options

proc validity_times*(host: string, port: int): Option[(DateTime,
  DateTime)] =
  let cmd = fmt"echo | openssl s_client -connect " & host & ":" & $port &
    " 2>/dev/null | openssl x509 -noout -dates"
  let res = execProcess(cmd)
  var dates: seq[DateTime]
  # echo res
  if not res.startsWith("notBefore="):
    return none((DateTime, DateTime))
  else:
    for x in res.strip.split("\n"):
      let part2 = x.split('=')[1]
      doAssert part2.endsWith(" GMT")
      let pt2 = part2.substr(0, part2.len-5) # remove the " GMT" part.
      let dt = pt2.parse("MMM d hh:mm:ss UUUU")
      # echo dt
      dates.add(dt)
    return some((dates[0], dates[1]))

# example: certificate_validity_times("en.minghui.org", 443)
# example: certificate_validity_times("github.org", 443)
