# 工具函数：Python 路径查找、URL 编码

typeset -g _FTB_TR_PYTHON=""

() {
  local p
  for p in /usr/bin/python3 /usr/local/bin/python3 /opt/homebrew/bin/python3 python3 python; do
    if command -v "$p" &>/dev/null; then
      _FTB_TR_PYTHON="$p"
      return
    fi
  done
}

# URL 编码
_ftb_tr_urlencode() {
  if [[ -n "$_FTB_TR_PYTHON" ]]; then
    "$_FTB_TR_PYTHON" -c \
      "import urllib.parse, sys; print(urllib.parse.quote(sys.stdin.read().strip()))" \
      <<< "$1"
  else
    print -r -- "${1// /%20}"
  fi
}
