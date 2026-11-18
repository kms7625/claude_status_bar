# Claude Code Status Bar

Claude Code용 커스텀 상태바 스크립트. 다음 정보를 표시합니다:

- 현재 사용 중인 모델명
- 현재 작업 디렉토리명
- Git 브랜치 (git 저장소인 경우)
- 컨텍스트 사용률 (%) — 60% 이상 노랑, 80% 이상 빨강
- 5시간 사용률 (%) + 재설정 예정 시각
- 7일 사용률 (%) + 재설정 예정 날짜·시각

## 설치

```bash
git clone https://github.com/kms7625/claude_status_bar.git
cp claude_status_bar/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

`~/.claude/settings.json`에 아래 설정을 추가(또는 확인):

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline.sh"
  }
}
```

## 요구사항

- `jq`, `awk` 필요 (macOS 기본 제공 `awk`, `jq`는 `brew install jq`)
- macOS(BSD `date`)와 Windows Git Bash·Linux(GNU `date`)를 자동 판별하므로 수정 없이 동작
