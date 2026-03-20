# translate-shell (trans) 翻译实现
# 依赖：https://github.com/soimort/translate-shell

# 检测 trans 命令是否可用
_ftb_tr_trans_available() {
  command -v trans &>/dev/null
}

# 批量翻译（每条文本单独调用 trans，输出顺序与输入一致）
# 输出：每行一条翻译结果
_ftb_tr_trans_batch() {
  local -a texts=("$@")
  (( ${#texts[@]} == 0 )) && return 1

  if ! _ftb_tr_trans_available; then
    _ftb_tr_log error "trans 命令未找到，请安装 translate-shell（https://github.com/soimort/translate-shell）"
    return 1
  fi

  local target="$FTB_TRANSLATE_LANG"
  _ftb_tr_log info "translate-shell 请求: ${#texts[@]} 条 -> $target"

  # trans 支持在单次调用中翻译多条文本（-b 简洁模式，每条结果一行）
  local -a results=()
  local t result
  for t in "${texts[@]}"; do
    result=$(trans -b ":${target}" -- "$t" 2>/dev/null)
    if [[ -z "$result" ]]; then
      _ftb_tr_log warn "translate-shell 翻译失败或返回空: $t"
      # 返回空行以保持顺序
      results+=("")
    else
      results+=("$result")
    fi
  done

  local r
  for r in "${results[@]}"; do
    print -r -- "$r"
  done
}
