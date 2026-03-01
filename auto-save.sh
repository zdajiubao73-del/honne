#!/bin/bash

# honne - 自動保存スクリプト
# 変更があれば自動でコミット＆GitHubにpushする

cd /Users/okubotomoya/Desktop/Projects/consultation

# 変更がなければ何もしない
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  exit 0
fi

# 変更をステージング
git add -A

# タイムスタンプ付きでコミット
git commit -m "Auto-save: $(date '+%Y-%m-%d %H:%M')"

# GitHubにpush
git push
