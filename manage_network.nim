# manage_network
# purpose:
# check that we're able to connect to site:port
import uri, net, system
proc check_site*(host: string; port: int; timeout: int): bool =
  var socket = newSocket()
  try:
    echo host, ":", $port
    socket.connect(host, Port port, timeout)
    return true
  except [OSError, TimeoutError]:
    return false
  finally:
    socket.close


# TODO: add unit tests, instead of repeated test runs
