# brew-publish-formula

在项目根目录执行的 Homebrew 发布命令。它根据当前仓库计算新版本、推送 tag、更新 formula 的 `url` / `sha256`，再把 formula 同步到本地 Tap。

当前工作目录就是要发布的项目根目录。命令从这个目录读取配置、formula 和 git 信息。

## 安装

依赖：

- git、curl、ruby、Homebrew
- `shasum` 或 `sha256sum`
- 发布本仓库时，命令会用 shellcheck 检查主文件

### 从 GitHub 安装

克隆仓库，确认脚本可执行，并把克隆目录加入 `PATH`：

```bash
git clone https://github.com/hanqunfeng/brew-publish-formula.git ~/brew-publish-formula
chmod +x ~/brew-publish-formula/brew-publish-formula
```

在 `~/.zshrc` 中加入：

```bash
export PATH="$HOME/brew-publish-formula:$PATH"
```

新开一个终端后确认：

```bash
brew-publish-formula --help
```

### 从 Homebrew 安装

本仓库的 formula 发布到 Tap 之后：

```bash
brew tap hanqunfeng/tap
brew install brew-publish-formula
```

或一行安装：

```bash
brew install hanqunfeng/tap/brew-publish-formula
```

升级：

```bash
brew update && brew upgrade brew-publish-formula
```

`.formula/brew-publish-formula.rb` 里的 `sha256` 在第一次成功发布前是占位值。发布命令会在 tag 推送后写成真实哈希。安装方式、Tap 初始化和手工步骤见 [`.formula/README.md`](.formula/README.md)。

## 项目配置

在要发布的仓库根目录放置 `.formula/brew-publish.conf`。根目录的 `.brew-publish.conf` 也可以，`--config` 指定的文件优先。确认当前目录是 git 仓库根目录后，命令会立刻检查这些位置是否有配置文件，没有则停止，并提示运行：

```bash
brew-publish-formula --init
```

`--init` 会生成 `.formula/brew-publish.conf`。`formula=` 只写文件名，公式文件固定放在 `.formula/` 下。已有配置和已有 `.rb` 不会被覆盖。可以用 `--tap user/homebrew-tap` 指定写入配置的 Tap。

目标 `.rb` 还不存在时：

1. 先看本地有没有配置里的 Tap。没有则询问是否执行 `brew tap-new`。
2. Tap 里已有同名 `.rb` 时，复制到 `.formula/`。
3. Tap 里也没有时，询问是否生成公式模板。

```text
tap=hanqunfeng/homebrew-tap
formula=brew-publish-formula.rb
tag_prefix=v
```

| 键 | 含义 |
| --- | --- |
| `tap` | `user/homebrew-tap` 或 `user/tap`。发布前会检查本地是否已有该 Tap；没有则先执行 `brew tap-new user/homebrew-tap` |
| `formula` | 文件名，例如 `brew-publish-formula.rb`。实际路径是 `.formula/` 加上这个文件名。省略时，`.formula/` 下只能有一个 `*.rb` |
| `tag_prefix` | 可选，默认 `v`，生成 `v1.2.3` |

`origin` 必须指向 GitHub。源码包地址和 tag 推送都使用这个远程：

```text
https://github.com/<owner>/<repo>/archive/refs/tags/vX.Y.Z.tar.gz
```

`url` 里直接写 tag，例如 `v1.2.3`。Homebrew 会从这段地址识别版本，所以公式里不再单独写 `version`。再写一行相同的 `version` 时，`brew audit` 会报 redundant。发布时会把 `url` 里的 tag 改成新版本，并更新 `sha256`。

版本号优先取最新的语义化 tag。没有 tag 时从 formula 的 `url` 读取。都没有时按 `0.0.0` 递增。第一次打 tag 可以用 `--version` 指定版本，不必先有历史 tag。

## 发布

在项目根目录执行：

```bash
brew-publish-formula patch --dry-run
brew-publish-formula patch              # 1.0.5 → 1.0.6
brew-publish-formula minor              # 1.0.5 → 1.1.0
brew-publish-formula major              # 1.0.5 → 2.0.0
brew-publish-formula --version 1.2.0
brew-publish-formula --resume 1.0.6 --yes
```

命令会先打印发布计划，确认后执行。`--yes` 跳过确认。

| 选项 | 含义 |
| --- | --- |
| `--dry-run` | 只打印将执行的操作 |
| `--yes` / `-y` | 跳过交互确认 |
| `--skip-check` | 发布本仓库时跳过 shellcheck |
| `--skip-tap-audit` | 跳过 `brew style` / `brew audit` |
| `--no-push` | 不推远程。本地 tag 创建后会停止，因为还不能计算 sha256 |
| `--resume X.Y.Z` | tag 已经推送时，从下载源码包继续 |
| `--tap` `--formula` `--tag-prefix` `--config` | 覆盖配置文件中的对应项 |

全量发布要求工作区干净。`--resume` 时只允许 `.formula` 里的公式已修改；发布本仓库时还允许 `brew-publish-formula` 已修改。

正确的 `sha256` 只能在 tag 到达 GitHub 之后得到，所以 formula 的最终提交在 tag 之后。Homebrew 读取 Tap 里的 formula。

tag 已推送但后续失败时，用 `--resume` 继续，不要再次 bump。

## 发布后验证

```bash
brew update
brew upgrade <formula-name>
```

也可以用项目里的 formula 文件做一次本地安装：

```bash
brew install --build-from-source ./.formula/<formula-name>.rb
```

## 接入已有项目

以 `java-project-generator` 为例，在该仓库新增 `.formula/brew-publish.conf`：

```text
tap=hanqunfeng/homebrew-tap
formula=java-project-generator.rb
tag_prefix=v
```

之后在该仓库根目录执行 `brew-publish-formula patch`。

## 开发本仓库

```bash
shellcheck brew-publish-formula
```

发布本仓库时也会执行同样的检查。`--skip-check` 可以跳过。
