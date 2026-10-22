# 由 brew-publish-formula --init 生成。
# 请按项目修改 desc、license 和 install。
class BrewPublishFormula < Formula
  desc "Install brew-publish-formula"
  homepage "https://github.com/hanqunfeng/brew-publish-formula"
  url "https://github.com/hanqunfeng/brew-publish-formula/archive/refs/tags/v0.1.5.tar.gz"
  sha256 "85d8e37c65b64708d6a98721e43f2626372ad5bafa0d05ac5da4d3c2dc2bc391"
  license "MIT"

  def install
    bin.install "brew-publish-formula"
  end

  test do
    assert_match "brew-publish-formula", shell_output("#{bin}/brew-publish-formula --help")
  end
end
