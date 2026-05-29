# homebrew-seamosworld (moved)

이 tap 은 **`AGMO-Inc`** 로 이전되었습니다.

## 새 설치 경로

```bash
brew install agmo-inc/seamosworld/seamosworld
```

새 tap: <https://github.com/AGMO-Inc/homebrew-seamosworld>

새 버전은 **Cask** 라서 `brew uninstall seamosworld` 한 번에 VM 이미지·앱·데이터까지 자동 삭제됩니다.

## 기존 설치자 마이그레이션

이미 이 tap(`hobeen-agmo`)으로 설치했다면:

```bash
brew uninstall seamosworld
brew untap hobeen-agmo/seamosworld
brew install agmo-inc/seamosworld/seamosworld
```
