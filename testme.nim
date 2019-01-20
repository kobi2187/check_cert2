import net
var socket = newSocket()
socket.connect("localhost", Port(80))

import manage_network, uri
echo check_site(parseUri("google.com"), Port 8989)
