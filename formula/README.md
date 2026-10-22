# Homebrew Formula

本目录保存 `brew-publish-formula` 的 Homebrew formula，以及发布本仓库时读取的配置：

- [`brew-publish-formula.rb`](brew-publish-formula.rb)
- [`brew-publish.conf`](brew-publish.conf)

用户可以用 Homebrew 安装 `brew-publish-formula` 命令。命令本身在任意项目根目录执行，用来把那个项目发布到它自己的 Tap。

## 1. 安装、升级、卸载

GitHub 安装见仓库根目录的 [README.md](../README.md)。formula 发布到 Tap 之后，可以用 Homebrew：

```bash
brew tap hanqunfeng/tap
brew install brew-publish-formula

# 或一行安装
brew install hanqunfeng/tap/brew-publish-formula
```

确认：

```bash
brew-publish-formula --help
```

升级、卸载：

```bash
brew update && brew upgrade brew-publish-formula
brew uninstall brew-publish-formula
brew untap hanqunfeng/tap    # 可选：卸掉整个 Tap
```

第一次发布完成前，formula 中的 `sha256` 是占位值，还不能用这份文件安装。

## 2. 发布本仓库的新版本

在本仓库根目录执行。当前目录就是要发布的项目：

```bash
brew-publish-formula --version 0.1.0 --dry-run
brew-publish-formula --version 0.1.0
```

已有 tag 之后：

```bash
brew-publish-formula patch     # 0.1.0 → 0.1.1
brew-publish-formula minor
brew-publish-formula major
```

[`brew-publish.conf`](brew-publish.conf) 指定了 Tap 和 formula。发布版本写在 formula 的 `version` 属性中。

发布前检查：

```bash
shellcheck brew-publish-formula
```

本地 Tap 需要已经存在，并且 `origin` 指向 `hanqunfeng/brew-publish-formula`。

命令会：

1. 对主文件运行 shellcheck
2. 更新 formula 的 `version`，提交并推送，创建 `vX.Y.Z`
3. 下载该 tag 的源码包并计算 sha256
4. 更新本目录 formula 的 `url` / `sha256`，再提交推送
5. 复制到本地 Tap，执行 `brew style` / `brew audit`
6. 提交并推送 Tap

tag 已存在但 formula 或 Tap 没完成时：

```bash
brew-publish-formula --resume 0.1.0 --yes
```

## 3. 首次准备 Tap

本机还没有 Tap 时做一次：

```bash
brew tap-new hanqunfeng/homebrew-tap
cd "$(brew --repo hanqunfeng/homebrew-tap)"
git remote add origin https://github.com/hanqunfeng/homebrew-tap.git
git push -u origin main
```

`brew tap-new` 生成的目录里有 `Formula/`。发布命令会把 `brew-publish-formula.rb` 复制到：

```text
$(brew --repo hanqunfeng/homebrew-tap)/Formula/brew-publish-formula.rb
```

如果 Tap 使用按首字母分目录的布局，已有文件会保持原路径；新文件会放到 `Formula/b/`。

提交前可以检查整个 Tap：

```bash
brew style --fix --except-cops=FormulaAuditStrict,FormulaAudit/ComponentsOrder hanqunfeng/tap
brew audit --except-cops=FormulaAuditStrict,FormulaAudit/ComponentsOrder --tap=hanqunfeng/tap
```

发布命令默认只检查当前这份 formula。

## 4. Formula 结构

这是一个无需编译的 shell 命令。formula 负责下载指定 tag 的源码包、校验 sha256，并把 `brew-publish-formula` 安装到 `bin/`。

```ruby
class BrewPublishFormula < Formula
  desc "Publish project releases to a Homebrew tap"
  homepage "https://github.com/hanqunfeng/brew-publish-formula"
  # version 必须写在 url 前面，#{version} 才会被替换。
  version "0.1.0"
  url "https://github.com/hanqunfeng/brew-publish-formula/archive/refs/tags/v#{version}.tar.gz"
  sha256 "..."
  license "MIT"

  def install
    bin.install "brew-publish-formula"
  end
end
```

| 字段 | 说明 |
| --- | --- |
| `class BrewPublishFormula` | 对应 formula 名 `brew-publish-formula` |
| `url` | GitHub tag 源码包。每次改版本都要换成新 tag |
| `sha256` | 与当前 `url` 对应。改 `url` 后必须重算 |
| `license` | MIT，见仓库根目录 `LICENSE` |

语法检查：

```bash
ruby -c formula/brew-publish-formula.rb
```

## 5. 手工发布

优先使用第 2 节的命令。需要手工核对时：

```bash
shellcheck brew-publish-formula
git tag v0.1.0
git push origin HEAD
git push origin v0.1.0

curl -L -o v0.1.0.tar.gz \
  https://github.com/hanqunfeng/brew-publish-formula/archive/refs/tags/v0.1.0.tar.gz
shasum -a 256 v0.1.0.tar.gz
```

把得到的地址和哈希写入 `formula/brew-publish-formula.rb`，并把同一文件里的 `version` 改成对应版本。然后：

```bash
ruby -c formula/brew-publish-formula.rb
cp formula/brew-publish-formula.rb \
  "$(brew --repo hanqunfeng/homebrew-tap)/Formula/"

cd "$(brew --repo hanqunfeng/homebrew-tap)"
brew style --fix --except-cops=FormulaAuditStrict,FormulaAudit/ComponentsOrder hanqunfeng/tap/brew-publish-formula
brew audit --except-cops=FormulaAuditStrict,FormulaAudit/ComponentsOrder hanqunfeng/tap/brew-publish-formula
git add Formula/brew-publish-formula.rb
git commit -m "brew-publish-formula v0.1.0"
git push
```

若 `brew style --fix` 改写了 Tap 中的文件，把该文件拷回本仓库再提交，使两边保持一致。

## 6. 排障

- 每次修改 `url` 后都要重新计算 `sha256`
- 已发布的 tag 不再改历史。修正问题请发新版本
- 全量发布前先提交功能改动，保持工作区干净
- tag 已推送但后续失败时使用 `--resume X.Y.Z`
- Tap 推送没有上游时，在 Tap 仓库执行 `git push -u origin HEAD`
- `origin` 需要指向 GitHub。命令从 `origin` 得到源码包地址，并把 tag 推送到 `origin`
