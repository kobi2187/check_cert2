import yaml

type X = object
  a: string
  b: int


let yamlStr = """
  a: "hi"
  b: 3
"""

var output: X
load(yamlstr, output)
