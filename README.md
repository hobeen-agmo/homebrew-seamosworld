# homebrew-seamosworld

SeamOS SimulationWorld — NEVONEX FCAL 농기계 시뮬레이션 플랫폼(QEMU VM + Electron dashboard)의 Homebrew tap.

## 설치

```bash
brew install hobeen-agmo/seamosworld/seamosworld
```

`qemu` / `zstd` / `xorriso` 가 의존성으로 함께 설치됩니다 — **따로 설치할 것 없습니다.**

## 사용법

```bash
seamosworld start --vm-only   # VM(QEMU)만 기동 (첫 실행 시 VM 이미지 자동 다운로드)
seamosworld stop              # VM 종료
seamosworld start             # VM + Electron 앱 창 (첫 실행 시 앱 자동 다운로드)
seamosworld install <앱.fif>  # NEVONEX 앱 설치
seamosworld status            # 서비스 상태
seamosworld shell             # VM 에 SSH 접속
seamosworld apps              # 설치된 앱 목록
seamosworld logs <service>    # 서비스 로그
```

Dashboard: <http://localhost:3000>

## 요구사항

- macOS **Apple Silicon (arm64)** — QEMU `-accel hvf` 사용
- 디스크 여유 **~12GB** (VM 이미지 압축 4.9GB + 해제 후 11GB)
- 인터넷 (첫 실행 시 S3 에서 자동 다운로드)

첫 `seamosworld start` 시 자동으로 받는 것:
- VM 이미지 `qcow2` (압축 4.9GB) — `~/Library/Application Support/SimulationWorld/`
- Electron 앱 `SimWorld.app` (91MB)

이후 실행부터는 캐시되어 바로 뜹니다.

## 포트

VM 이 아래 호스트 포트를 hostfwd 로 점유합니다. **하나라도 다른 프로세스가 쓰고 있으면 기동이 중단**되고, 어느 포트를 누가 점유 중인지 표시됩니다.

| 포트 | 용도 |
|---|---|
| 3000 | Dashboard (VM nginx) |
| 2222 | VM SSH |
| 8116 | FIF API (앱 설치) |
| 8121 / 8122 | MQTT (WS / mTLS) |
| 5050 / 5100 | iot-server / api-server |
| 1456 | 앱 WebSocket |
| 29536 / 29539 | CAN / GPS serial |
| 8118–8126, 8201/8202 | 보조 서비스 |

포트 충돌 시:
```bash
seamosworld start --force   # 충돌 프로세스를 SIGTERM→SIGKILL 후 기동 (주의: 해당 프로세스 종료됨)
```

## 트러블슈팅

- **`포트 XXXX 사용 중`** → 충돌 프로세스를 끄거나 `--force`. (QEMU 는 hostfwd 포트 중 하나라도 겹치면 전체 기동이 실패합니다)
- **이미지 다운로드 실패** → 인터넷/디스크 확인 후 `seamosworld start` 재시도(이어받기 아님, 재다운로드)
- **Electron 앱이 안 뜸** → Dashboard 는 브라우저에서 <http://localhost:3000> 으로 접속 가능
- **앱 설치(`install`) 실패** → `seamosworld status` 로 VM/FIF 기동 확인

## 구조

- VM 은 electron 이 아니라 launcher CLI(`seamosworld start`)가 QEMU 로 직접 기동
- VM 안 systemd 가 dashboard(nginx)·api-server·iot·MQTT 등을 올림
- Electron 앱은 dashboard(`:3000`)를 띄우는 창일 뿐, QEMU 는 안 건드림
- 소스/이미지/앱은 public S3 에서 배포(repo 가 private 라 git/tap 인증을 피함)
