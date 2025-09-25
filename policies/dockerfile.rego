package dockerfile

# Disallow "latest" tag in FROM
deny[msg] {
  instr := input.stages[_].instructions[_]
  instr.name == "FROM"
  contains(lower(instr.value), "latest")
  msg := "Avoid using 'latest' tag in FROM"
}

# Require a non-root USER
deny[msg] {
  not some_user_set
  msg := "Dockerfile should set a non-root USER"
}

some_user_set {
  instr := input.stages[_].instructions[_]
  instr.name == "USER"
  lower(instr.value) != "root"
}
