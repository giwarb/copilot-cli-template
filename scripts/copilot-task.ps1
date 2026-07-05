# Copilot CLI にタスク仕様ファイルを渡して非対話実行するラッパー (Windows)
# 使い方: ./scripts/copilot-task.ps1 tasks/T001-add-login.md [-Agent implementer] [-Model gpt-5-mini]
# 注: --allow-all が無い古いバージョンの Copilot CLI では --allow-all-tools に読み替えてください。
param(
    [Parameter(Mandatory = $true)][string]$TaskFile,
    [string]$Agent = "implementer",
    [string]$Model
)

if (-not (Test-Path $TaskFile)) {
    Write-Error "タスクファイルが見つかりません: $TaskFile"
    exit 1
}

$taskName = [IO.Path]::GetFileNameWithoutExtension($TaskFile)
New-Item -ItemType Directory -Force -Path "logs" | Out-Null
$logFile = "logs/copilot-$taskName.log"

$prompt = @"
タスク仕様ファイル $TaskFile を読み、その内容に従って作業してください。
「やらないこと(スコープ外)」を厳守し、完了前に「受け入れ基準」のコマンドを実行して確認すること。
完了後、タスクファイル ($TaskFile) 末尾の「作業ログ」に実施内容を追記すること。
"@

$copilotArgs = @("--agent", $Agent, "-p", $prompt, "--allow-all")
if ($Model) { $copilotArgs += @("--model", $Model) }

Write-Host "Copilot CLI ($Agent) にタスクを委譲します: $TaskFile (log: $logFile)"
& copilot @copilotArgs 2>&1 | Tee-Object -FilePath $logFile
exit $LASTEXITCODE
