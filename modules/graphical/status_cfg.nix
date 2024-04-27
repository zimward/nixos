{pkgs, ...}:
pkgs.writeText "configuration.toml" ''
  [[block]]
  block = "battery"
  format = " $icon $percentage "
  missing_format = ""

  [[block]]
  block = "cpu"

  [[block]]
  block = "memory"

  [[block]]
  block = "time"
  format = "$timestamp.datetime(f:'%Y.%m.%d %a曜日 %H:%M:%S',l:ja_JP)"
  interval = 1
''
