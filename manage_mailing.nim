# manage_mailing

import smtp, net
import domain

proc sendReportMailOne(sender_server, sender_user: string; sender_port: Port;
  subject, body: string; to: seq[string]; pass: string) =
  var msg = createMessage(subject, body, to)
  let smtpConn = newSmtp(useSsl = true, debug = true)
  smtpConn.connect(sender_server, sender_port)
  smtpConn.auth(sender_user, pass)
  smtpConn.sendmail(sender_user, to, $msg)

proc sendReportMailOne*(info: UserInfo; group: SiteGroup; subject,
    body: string; pass: string) =
  sendReportMailOne(info.sender_server, info.sender_user,
  Port info.sender_port, subject, body, group.send_to, pass)

