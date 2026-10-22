# 由 brew-publish-formula --init 生成。
# 请按项目修改 desc、license 和 install。
class BrewPublishFormula < Formula
  desc "Install brew-publish-formula"
  homepage "https://github.com/hanqunfeng/brew-publish-formula"
  url "https://github.com/hanqunfeng/brew-publish-formula/archive/refs/tags/v0.1.4.tar.gz"
  version "0.1.4"
  sha256 "6f43025089cb9ddb1e2d9eb02c8b10810559202148823a9ca1c328b30c176ba9"
  license "MIT"

  def install
    bin.install "brew-publish-formula"
  end

  test do
    assert_match "brew-publish-formula", shell_output("#{bin}/brew-publish-formula --help")
  end
end
