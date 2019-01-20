template fail*(errMsg: string, lastException: bool = true) =
  var excMsg = ""
  if lastException:
    excMsg = getCurrentExceptionMsg()
  quit(excMsg & "\n" & errMsg, QuitFailure)

# domain.nim
import uri, net

type Website* = object
  site*: string
  port*: int32

type UserInfo* = object
  sender_server*: string
  sender_port*: int32
  sender_user*: string
  receipient_email*: string
  sites_to_check*: seq[Website]

proc port_ok(p: int32): bool =
  result = 0 < p and p < 65536

import re
proc uri_ok(hostname: string): bool =
  # checks if hostname is ok. what does that mean? I think
  let host_re = re"\w+(\.\w+)+"
  hostname.match(host_re)


import strutils
proc isValid*(it: UserInfo): (string, bool) =
  result = ("", true)
  if not (it.sender_port == 0 or port_ok(it.sender_port)):
    return ($it.sender_port, false)
  if not (it.sender_server.len == 0 or
    it.sender_server.uri_ok):
    return (it.sender_server, false)

  for w in it.sites_to_check:
    if not w.site.uri_ok: return (w.site, false)
    if not w.port.port_ok: return ($w.port, false)



