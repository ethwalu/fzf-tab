# 工具函数：Python 路径查找、URL 编码、日志、fzf 能力检测

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
  print "$(date '+%H:%M:%S') [${(U)level}] $*" >> "$_FTB_TR_LOG_FILE"
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

# 检测 fzf 是否支持 --listen（需要 0.43.0+），结果缓存到会话变量
_ftb_tr_check_fzf_listen() {
  [[ -n "${_ftb_tr_fzf_listen_support+_}" ]] && return $_ftb_tr_fzf_listen_support
  autoload -Uz is-at-least
  local ver
  ver=$(fzf --version 2>/dev/null | cut -d' ' -f1)
  typeset -g _ftb_tr_fzf_listen_support=1  # 默认：不支持
  if [[ -n "$ver" ]] && is-at-least 0.43.0 "$ver"; then
    _ftb_tr_fzf_listen_support=0
    _ftb_tr_log debug "fzf --listen 支持已确认 (version=$ver)"
  else
    _ftb_tr_log debug "fzf 不支持 --listen (version=${ver:-unknown})，跳过实时刷新"
  fi
  return $_ftb_tr_fzf_listen_support
}

# 选取一个空闲的本地 TCP 端口，通过 stdout 输出端口号
_ftb_tr_pick_port() {
  [[ -z "$_FTB_TR_PYTHON" ]] && return 1
  local port
  port=$("$_FTB_TR_PYTHON" -c "
import socket, sys
try:
    s = socket.socket()
    s.bind(('127.0.0.1', 0))
    print(s.getsockname()[1])
    s.close()
except Exception:
    sys.exit(1)
" 2>/dev/null) || return 1
  [[ -n "$port" ]] && print -r -- "$port"
}
