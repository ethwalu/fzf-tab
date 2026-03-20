# 翻译缓存：磁盘持久化 + 内存关联数组

# 从磁盘加载缓存（每次调用都重新加载，以便后台翻译的结果能及时生效）
_ftb_tr_cache_load() {
  local cmd="$1"
  local cache_file="$FTB_TRANSLATE_CACHE_DIR/${cmd}.zsh"
  if [[ ! -f "$cache_file" ]]; then
    _ftb_tr_log debug "缓存未命中: $cmd"
    return 1
  fi
  _ftb_tr_log debug "加载缓存: $cmd ($cache_file)"
  source "$cache_file" 2>/dev/null
}

# 保存内存缓存到磁盘
_ftb_tr_cache_save() {
  local cmd="$1"
  local cache_file="$FTB_TRANSLATE_CACHE_DIR/${cmd}.zsh"
  local cache_var="_ftb_tr_cache_${cmd}"
  if (( ${(P)#cache_var} == 0 )); then
    _ftb_tr_log warn "缓存为空，跳过保存: $cmd"
    return 1
  fi
  {
    print "# fzf-tab 翻译缓存（自动生成，请勿手动编辑）"
    # typeset -p 输出 typeset -A，改为 typeset -gA 确保全局可访问
    typeset -p "$cache_var" | sed 's/^typeset -A/typeset -gA/'
  } > "$cache_file"
  _ftb_tr_log info "缓存已保存: $cmd (${(P)#cache_var} 条) -> $cache_file"
}
