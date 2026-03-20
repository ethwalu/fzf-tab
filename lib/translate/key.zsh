# 密钥管理：优先读环境变量，其次读配置文件

# 获取 API 密钥
_ftb_tr_get_key() {
  local api="$1"
  local env_var key_file key

  case "$api" in
    deepl) env_var="FTB_DEEPL_KEY" ;;
    *)     return 1 ;;
  esac

  # 优先从环境变量读取
  key="${(P)env_var}"
  if [[ -n "$key" ]]; then
    print -r -- "$key"
    return 0
  fi

  # 从配置文件读取
  key_file="$FTB_TRANSLATE_KEY_DIR/${api}.key"
  if [[ -f "$key_file" ]]; then
    key="$(<"$key_file")"
    key="${key%%$'\n'*}"
    if [[ -n "$key" ]]; then
      print -r -- "$key"
      return 0
    fi
  fi

  return 1
}

# 保存密钥到配置文件（权限 600）
_ftb_tr_set_key() {
  local api="$1" key="$2"
  [[ -z "$api" || -z "$key" ]] && return 1
  print -r -- "$key" > "$FTB_TRANSLATE_KEY_DIR/${api}.key"
  chmod 600 "$FTB_TRANSLATE_KEY_DIR/${api}.key"
}
