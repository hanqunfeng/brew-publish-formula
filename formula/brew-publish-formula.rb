# 由 brew-publish-formula --init 生成。
# 请按项目修改 desc、license 和 install。
class BrewPublishFormula < Formula
  desc "Install brew-publish-formula"
  homepage "https://github.com/hanqunfeng/brew-publish-formula"
  version "0.1.2"
  url "https://github.com/hanqunfeng/brew-publish-formula/archive/refs/tags/v#{version}.tar.gz"
  sha256 "ef162caf2adec82f2f61086d4a763b3990db075581225a7615c1a77db76955c1"
  license "MIT"

  def install
    bin.install "brew-publish-formula"
  end

  test do
    assert_match "brew-publish-formula", shell_output("#{bin}/brew-publish-formula --help")
  end
end
