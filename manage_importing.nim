# manage_importing
# abstract the importing process, choose based on filename's extension
# import json, yaml, etc according to need.


import json, yaml
import streams
import domain

let path = "/home/kobi7/prog/nim/check_cert/example.json"
let jsonNode = parseJson(newFileStream(path))
let obj = jsonNode.to(UserInfo)

