package dockerfile

deny[msg] {
  input.commands[_].Cmd == "from"
  not startswith(lower(input.commands[_].Value), "node:20-alpine")
}
msg := "Base image must be node:20-alpine (pinned)"

deny[msg] {
  some i
  input.commands[i].Cmd == "user"
  input.commands[i].Value == "root"
}
msg := "Container must not run as root"

deny[msg] {
  not some i
  input.commands[i].Cmd == "expose"
}
msg := "Expose port 3000 or 3001"
