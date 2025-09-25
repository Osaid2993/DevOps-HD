package docker.security

deny[msg] {
  input.Instructions[i].Name == "USER"
  not input.Instructions[i].Value
  msg := "Container must set a non-root USER"
}

deny[msg] {
  input.StageInstructions[_][i].Name == "RUN"
  contains(lower(input.StageInstructions[_][i].Value), "apk add")
  not contains(lower(input.StageInstructions[_][i].Value), "--no-cache")
  msg := "Use --no-cache with apk add"
}
