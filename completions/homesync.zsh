if [[ ! -o interactive ]]; then
    return
fi

compctl -K _homesync homesync

_homesync() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(homesync commands)"
  else
    completions="$(homesync completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}
