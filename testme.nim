import net
var socket = newSocket()
try:
  socket.connect("google.com", Port(80))
  echo "did it"
except OSError:
  echo "here"
finally: socket.close


import manage_network, uri
echo check_site(parseUri("google.com"), Port 8989)
