# SeamOS SimulationWorld — Homebrew formula
#
# 설치 (인증 불필요, 추가 설치 없음 — qemu 는 의존성으로 자동):
#   brew install https://seamosworld-dist-795591862191.s3.ap-northeast-2.amazonaws.com/seamosworld.rb
#
# 소스/이미지/Electron 앱 모두 public S3 에서 받는다(repo 가 private 라 git/tap 인증을
# 피하기 위함). VM 이미지(qcow2)와 Electron 앱은 첫 `seamosworld start` 시 자동
# 다운로드한다(cmd-update.sh / cmd-start.sh).
class Seamosworld < Formula
  desc "SeamOS SimulationWorld — QEMU VM + Electron dashboard for NEVONEX FCAL"
  homepage "https://github.com/AGMO-Inc/seamos-simulator"
  url "https://seamosworld-dist-795591862191.s3.ap-northeast-2.amazonaws.com/src/seamosworld-launcher-1.0.0.tar.gz"
  sha256 "f665da00506b34025fd65cf87f2850b92e19dee080a3cab62a9cb224fd313378"
  version "1.0.0"
  license "Proprietary"

  depends_on "qemu"
  depends_on "zstd"
  depends_on "xorriso" # cloud-init NoCloud seed.iso 생성(user-seed.sh) — SSH 키 주입용

  def install
    # tarball 최상위(brew 가 단일 top dir strip 후 cwd): simworld, lib/
    libexec.install "simworld"
    libexec.install "lib"

    (bin/"seamosworld").write <<~SH
      #!/bin/bash
      exec "#{libexec}/simworld" "$@"
    SH
    bin.install_symlink bin/"seamosworld" => "simworld"
  end

  # brew install / upgrade 시 VM 이미지 + Electron 앱을 받는다(--if-needed: 버전이
  # 같으면 생략 → upgrade 때 바뀐 것만 받음). 다운로드 실패해도 설치는 성공시키고
  # 안내만 남긴다(start 때 안전망으로 다시 시도).
  def post_install
    system bin/"seamosworld", "fetch", "--if-needed"
  rescue
    opoo "Asset download incomplete — run 'seamosworld fetch' or it will retry on 'seamosworld start'."
  end

  def caveats
    <<~EOS
      qemu/zstd were installed as dependencies — nothing else to install.

        seamosworld start --vm-only   # Start VM(QEMU) only (image auto-downloads on first run)
        seamosworld stop              # Stop VM
        seamosworld start             # VM + Electron app window (app auto-downloads on first run)
        seamosworld install <app.fif> # Install NEVONEX app
        seamosworld status / shell / apps / logs <svc>

      Dashboard: http://localhost:3000
    EOS
  end

  test do
    assert_match "SimulationWorld", shell_output("#{bin}/seamosworld --help 2>&1")
  end
end
