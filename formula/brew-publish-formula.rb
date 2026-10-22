class BrewPublishFormula < Formula
  desc "Publish project releases to a Homebrew tap"
  homepage "https://github.com/hanqunfeng/brew-publish-formula"
  version "0.1.0"
  url "https://github.com/hanqunfeng/brew-publish-formula/archive/refs/tags/v#{version}.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"

  def install
    bin.install "brew-publish-formula"
  end

  def caveats
    <<~EOS
      Run brew-publish-formula in the root of the project you want to publish.
      That project needs formula/brew-publish.conf, or .brew-publish.conf.
      Publishing also needs git, curl, ruby, and a local Homebrew tap.
    EOS
  end

  test do
    assert_match "Homebrew Tap", shell_output("#{bin}/brew-publish-formula --help")
  end
end
