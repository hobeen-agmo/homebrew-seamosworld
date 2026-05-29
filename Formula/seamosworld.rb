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
  sha256 "83cf45a09313e8d4364c382b81f1bc1a57440c2554802901e6d1945eabd01167"
  version "1.0.0"
  license "Proprietary"

  depends_on "qemu"
  depends_on "zstd"

  def install
    # tarball 내부 구조: packaging/launcher/{simworld,lib}
    libexec.install "packaging/launcher/simworld"
    libexec.install "packaging/launcher/lib"

    (bin/"seamosworld").write <<~SH
      #!/bin/bash
      exec "#{libexec}/simworld" "$@"
    SH
    bin.install_symlink bin/"seamosworld" => "simworld"
  end

  def caveats
    <<~EOS
      qemu/zstd 가 의존성으로 함께 설치되었습니다 — 따로 설치할 것 없습니다.

        seamosworld start --vm-only   # VM(QEMU) 만 기동 (이미지 첫 실행 시 자동 다운로드)
        seamosworld stop              # VM 종료
        seamosworld start             # VM + Electron 앱 창 (앱 첫 실행 시 자동 다운로드)
        seamosworld install <앱.fif>  # NEVONEX 앱 설치
        seamosworld status / shell / apps / logs <svc>

      Dashboard: http://localhost:3000
    EOS
  end

  test do
    assert_match "SimulationWorld", shell_output("#{bin}/seamosworld --help 2>&1")
  end
end
