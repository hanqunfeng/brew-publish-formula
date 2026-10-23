# 由 brew-publish-formula --init 生成。
# 请按项目修改 desc、license 和 install。
class BrewPublishFormula < Formula
  desc "Install brew-publish-formula"
  homepage "https://github.com/hanqunfeng/brew-publish-formula"
  url "https://github.com/hanqunfeng/brew-publish-formula/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "adeb4b59d810a66f38f6ad4da58ec593e02a2998b73fec5e987d9e607a96f3c3"
  license "MIT"

  def install
    bin.install "brew-publish-formula"
  end

  test do
    assert_match "brew-publish-formula", shell_output("#{bin}/brew-publish-formula --help")
  end
end
