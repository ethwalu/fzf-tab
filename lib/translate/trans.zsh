# translate-shell (trans) 翻译实现
# 依赖：https://github.com/soimort/translate-shell

# 检测 trans 命令是否可用
_ftb_tr_trans_available() {
  command -v trans &>/dev/null
}

# 批量翻译（逐条调用 trans，保证输出行数与输入一致）
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
  local ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
  _ftb_tr_log info "translate-shell 请求: ${#texts[@]} 条 -> $target（引擎=$engine）"

  # 每条单独调用，保证 1 输入 = 1 输出
  # trans 多参数时可能合并为一个请求，导致输出行数与输入不匹配
  local t
  for t in "${texts[@]}"; do
    trans -b -e "$engine" -u "$ua" ":${target}" -- "$t" 2>/dev/null
  done
}
