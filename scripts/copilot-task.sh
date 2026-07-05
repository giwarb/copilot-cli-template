#!/usr/bin/env sh
# Copilot CLI にタスク仕様ファイルを渡して非対話実行するラッパー (macOS/Linux)
# 使い方: ./scripts/copilot-task.sh tasks/T001-add-login.md [agent] [model]
#   agent: implementer (既定) | tester | reviewer
# 注: --allow-all が無い古いバージョンの Copilot CLI では --allow-all-tools に読み替えてください。
set -eu

TASK_FILE="${1:?使い方: $0 tasks/T###-*.md [agent] [model]}"
AGENT="${2:-implementer}"
MODEL="${3:-}"

if [ ! -f "$TASK_FILE" ]; then
    echo "タスクファイルが見つかりません: $TASK_FILE" >&2
    exit 1
fi

TASK_NAME=$(basename "$TASK_FILE" .md)
mkdir -p logs
LOG_FILE="logs/copilot-${TASK_NAME}.log"

PROMPT="タスク仕様ファイル ${TASK_FILE} を読み、その内容に従って作業してください。
「やらないこと(スコープ外)」を厳守し、完了前に「受け入れ基準」のコマンドを実行して確認すること。
完了後、タスクファイル (${TASK_FILE}) 末尾の「作業ログ」に実施内容を追記すること。"

echo "Copilot CLI (${AGENT}) にタスクを委譲します: ${TASK_FILE} (log: ${LOG_FILE})"
if [ -n "$MODEL" ]; then
    copilot --agent "$AGENT" -p "$PROMPT" --allow-all --model "$MODEL" 2>&1 | tee "$LOG_FILE"
else
    copilot --agent "$AGENT" -p "$PROMPT" --allow-all 2>&1 | tee "$LOG_FILE"
fi
