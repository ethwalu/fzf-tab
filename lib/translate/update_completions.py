#!/usr/bin/env python3
"""
fzf-tab translate: 将 fzf 补全列表文件中的英文描述替换为翻译结果

用法：update_completions.py <completions_file> <pairs_file>

pairs_file 格式：每行 word\torig_desc\ttranslation（TSV）
completions_file 格式：fzf 的补全列表，字段以 \x00 分隔

替换模式：\x00word -- orig_desc → \x00word -- translation
"""
import sys
import os


def main():
    if len(sys.argv) < 3:
        sys.exit(1)

    completions_file = sys.argv[1]
    pairs_file = sys.argv[2]

    # 读取 (word, orig_desc, translation) 三元组
    pairs = []
    try:
        with open(pairs_file, "r", encoding="utf-8", errors="replace") as f:
            for line in f:
                parts = line.rstrip("\n").split("\t", 2)
                if len(parts) == 3:
                    pairs.append(parts)
    except Exception as e:
        print(f"[update_completions] 读取 pairs_file 失败: {e}", file=sys.stderr)
        sys.exit(1)

    if not pairs:
        sys.exit(0)

    # 读取补全文件（二进制模式保留 null bytes）
    try:
        with open(completions_file, "rb") as f:
            content = f.read()
    except Exception as e:
        print(f"[update_completions] 读取 completions_file 失败: {e}", file=sys.stderr)
        sys.exit(1)

    # 就地替换：\x00word -- orig → \x00word -- translation
    for word, orig, trans in pairs:
        old = ("\x00" + word + " -- " + orig).encode("utf-8")
        new = ("\x00" + word + " -- " + trans).encode("utf-8")
        content = content.replace(old, new)

    try:
        with open(completions_file, "wb") as f:
            f.write(content)
    except Exception as e:
        print(f"[update_completions] 写入 completions_file 失败: {e}", file=sys.stderr)
        sys.exit(1)


main()
