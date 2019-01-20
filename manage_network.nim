# manage_network
# purpose:
# check that we're able to connect to site:port
import uri, net, system
proc check_site*(host: Uri, port: Port): bool {.raises: [OSError,
  SslError].} =
  var socket = newSocket()
  try:
    socket.connect(host.hostname, port)
    return true
  # except OSError:
  except:
    # echo getCurrentExceptionMsg()
    # echo getCurrentException().getStackTrace

    return false
  finally:
    socket.close


# TODO: add unit tests, instead of repeated test runs
