# fzf-tab 翻译功能初始化
# 支持的 API：deepl（需密钥）、trans（需安装 translate-shell）

typeset -g FTB_TRANSLATE_API="${FTB_TRANSLATE_API:-deepl}"
typeset -g FTB_TRANSLATE_LANG="${FTB_TRANSLATE_LANG:-ZH}"
typeset -g FTB_TRANSLATE_TIMEOUT="${FTB_TRANSLATE_TIMEOUT:-10}"
typeset -g FTB_TRANSLATE_CACHE_DIR="${FTB_TRANSLATE_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/fzf-tab/translate}"
typeset -g FTB_TRANSLATE_KEY_DIR="${FTB_TRANSLATE_KEY_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/fzf-tab}"

# 调试模式：设置 FTB_TRANSLATE_DEBUG=1 开启，日志写入文件
# （TAB 补全期间 stderr 不可见，故必须写文件）
typeset -g FTB_TRANSLATE_DEBUG="${FTB_TRANSLATE_DEBUG:-0}"
typeset -g _FTB_TR_LOG_FILE="${FTB_TRANSLATE_CACHE_DIR}/debug.log"

[[ -d "$FTB_TRANSLATE_CACHE_DIR" ]] || mkdir -p "$FTB_TRANSLATE_CACHE_DIR"
[[ -d "$FTB_TRANSLATE_KEY_DIR" ]] || mkdir -p "$FTB_TRANSLATE_KEY_DIR"

# 调试模式下在日志中写入会话分隔符
if (( FTB_TRANSLATE_DEBUG )); then
  print "\n===== $(date '+%Y-%m-%d %H:%M:%S') =====" >> "$_FTB_TR_LOG_FILE"
fi
