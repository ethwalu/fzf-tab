# 工具函数：Python 路径查找、URL 编码、日志

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

# 日志输出（仅在 FTB_TRANSLATE_DEBUG=1 时写入日志文件）
# 用法：_ftb_tr_log <level> <message>
# level: debug | info | warn | error
_ftb_tr_log() {
  (( FTB_TRANSLATE_DEBUG )) || return 0
  local level="$1"; shift
  print "${(%):-%D{%H:%M:%S}} [${(U)level}] $*" >> "$_FTB_TR_LOG_FILE"
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
