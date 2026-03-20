# translate-shell (trans) 翻译实现
# 依赖：https://github.com/soimort/translate-shell

# 检测 trans 命令是否可用
_ftb_tr_trans_available() {
  command -v trans &>/dev/null
}

# 批量翻译（分块调用 trans，每块不超过 FTB_TRANSLATE_CHUNK_SIZE 条）
# Google Translate 单次请求有字符数限制，分块可避免超限导致结果不完整
# 输出：每行一条翻译结果，顺序与输入一致
_ftb_tr_trans_batch() {
  local -a texts=("$@")
  (( ${#texts[@]} == 0 )) && return 1

  if ! _ftb_tr_trans_available; then
    _ftb_tr_log error "trans 命令未找到，请安装 translate-shell（https://github.com/soimort/translate-shell）"
    return 1
  fi

  local target="$FTB_TRANSLATE_LANG"
  local engine="${FTB_TRANSLATE_ENGINE:-google}"
  local chunk_size="${FTB_TRANSLATE_CHUNK_SIZE:-10}"
  local ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
  _ftb_tr_log info "translate-shell 请求: ${#texts[@]} 条 -> $target（引擎=$engine，每块 $chunk_size 条）"

  local i
  for (( i=1; i<=${#texts[@]}; i+=chunk_size )); do
    local -a chunk=("${texts[@]:$((i-1)):$chunk_size}")
    trans -b -e "$engine" -u "$ua" ":${target}" -- "${chunk[@]}" 2>/dev/null
  done
}
