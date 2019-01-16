# Package

version       = "0.1.0"
author        = "Kobi Lurie"
description   = "ssl certificate checker"
license       = "MIT"
srcDir        = "src"
bin           = @["check_cert"]


# Dependencies

requires "nim >= 0.19.9"
requires "docopt"
# requires "vmvc"