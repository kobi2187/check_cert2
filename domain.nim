# domain.nim
import uri, sockets

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

proc uri_ok(url: string): bool =
  true                        #todo

import strutils
proc validate*(it: UserInfo): bool =
  result = true
  if not (it.sender_port == 0 or port_ok(it.sender_port)):
    return false
  # todo:
  if not (it.sender_server == "") and not uri_ok(
    it.sender_server): return false
  for w in it.sites_to_check:
    if not w.site.uri_ok: return false
    if not w.port.port_ok: return false



