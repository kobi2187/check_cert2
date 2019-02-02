
# domain.nim
import uri, net, options, times, util

type Website* = object
  site*: string
  port*: int32


type CheckedSite* = object
  site*: string
  port*: int32
  connected*: Option[bool]
  certificateStart*: Option[DateTime]
  certificateEnd*: Option[DateTime]
  certFailed*: bool

proc newCheckedSite*(site: string; port: int32): CheckedSite =
  result.site = site
  result.port = port

type SiteGroup* = object
  send_to*: seq[string]
  sites_to_check*: seq[Website]

type UserInfo* = object
  sender_server*: string
  sender_port*: int32
  sender_user*: string
  groups*: seq[SiteGroup]

proc port_ok(p: int32): bool =
  result = 0 < p and p < 65536

import re
proc uri_ok(hostname: string): bool =
  # checks if hostname is ok. what does that mean? I think
  let host_re = re"\w+(\.\w+)+"
  hostname.match(host_re)


import strutils
type ValidMsg = object
  info*: string
  isValid*: bool

proc newValidMsg(info: string = ""; isValid: bool): ValidMsg =
  result.info = info
  result.isValid = isValid

proc isValid*(it: UserInfo): ValidMsg =
  result = newValidMsg(isValid = true)
  if not (it.sender_port == 0 or port_ok(it.sender_port)):
    return newValidMsg($it.sender_port, false)
  if not (it.sender_server.len == 0 or
    it.sender_server.uri_ok):
    return newValidMsg(it.sender_server, false)

  for g in it.groups:
    for w in g.sites_to_check:
      if not w.site.uri_ok: return newValidMsg(w.site, false)
      if not w.port.port_ok: return newValidMsg($w.port, false)



