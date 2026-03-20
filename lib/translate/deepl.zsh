# DeepL API 翻译实现

# 批量翻译（DeepL 支持在一次请求中传多个 text 参数）
# 输出：每行一条翻译结果，顺序与输入一致
_ftb_tr_deepl_batch() {
  local -a texts=("$@")
  (( ${#texts[@]} == 0 )) && return 1

  local key
  key=$(_ftb_tr_get_key deepl) || {
    _ftb_tr_log error "DeepL 密钥未设置（FTB_DEEPL_KEY 或 $FTB_TRANSLATE_KEY_DIR/deepl.key）"
    return 1
  }

  # 免费版 key 以 :fx 结尾，使用不同端点
  local endpoint="https://api-free.deepl.com/v2/translate"
  [[ "$key" != *":fx" ]] && endpoint="https://api.deepl.com/v2/translate"

  _ftb_tr_log info "DeepL 请求: ${#texts[@]} 条 -> $endpoint"

  # 为每条文本构建 -d text=... 参数
  local -a params=()
  local t
  for t in "${texts[@]}"; do
    params+=(-d "text=$(_ftb_tr_urlencode "$t")")
  done

  local response
  response=$(curl -s --max-time "$FTB_TRANSLATE_TIMEOUT" \
    -H "Authorization: DeepL-Auth-Key $key" \
    "${params[@]}" \
    -d "source_lang=EN" \
    -d "target_lang=${FTB_TRANSLATE_LANG}" \
    "$endpoint" 2>/dev/null)

  if [[ -z "$response" ]]; then
    _ftb_tr_log error "DeepL 响应为空（网络错误或超时）"
    return 1
  fi

  _ftb_tr_log debug "DeepL 响应: ${#response} 字节"

  # 提取所有翻译结果，每行一条
  "$_FTB_TR_PYTHON" -c "
import json, sys
try:
    d = json.loads(sys.stdin.read())
    for t in d['translations']:
        print(t['text'])
except Exception as e:
    sys.stderr.write(str(e) + '\n')
    sys.exit(1)
" <<< "$response"
}
