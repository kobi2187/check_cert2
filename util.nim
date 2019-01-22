template fail*(errMsg: string, lastException: bool = true) =
  var excMsg = ""
  if lastException:
    excMsg = getCurrentExceptionMsg()
  quit(excMsg & "\n" & errMsg, QuitFailure)
