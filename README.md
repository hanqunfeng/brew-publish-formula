# brew-publish-formula

[中文](README.zh-CN.md)

A Homebrew release command that runs in a project root. It computes the next version from the current repository, pushes a tag, updates the formula `url` and `sha256`, then copies the formula into the local Tap.

The working directory is the project being published. The command reads its config, formula, and git information from that directory.

## Install

Requirements:

- git, curl, ruby, and Homebrew
- `shasum` or `sha256sum`
- shellcheck, used when publishing this repository

### From GitHub

Clone the repository, make the script executable, and add the clone to `PATH`:

```bash
git clone https://github.com/hanqunfeng/brew-publish-formula.git ~/brew-publish-formula
chmod +x ~/brew-publish-formula/brew-publish-formula
```

Add this to `~/.zshrc`:

```bash
export PATH="$HOME/brew-publish-formula:$PATH"
```

Open a new terminal and confirm:

```bash
brew-publish-formula --help
```

### From Homebrew

After this repository's formula has been published to the Tap:

```bash
brew tap hanqunfeng/tap
brew install brew-publish-formula
```

Or in one line:

```bash
brew install hanqunfeng/tap/brew-publish-formula
```

Upgrade:

```bash
brew update && brew upgrade brew-publish-formula
```

The `sha256` in `.formula/*.rb` may be a placeholder until the first successful publish. After the tag is pushed, the command writes the real hash, copies the file into the Tap, and commits it there. `.formula` is not added to the project repository.

## Project config

Place `.formula/brew-publish.conf` in the root of the repository you want to publish. `.brew-publish.conf` in the root also works. A file given with `--config` takes priority. After confirming that the current directory is the git root, the command looks for a config in those locations and stops if none exists, telling you to run:

```bash
brew-publish-formula --init
```

`--init` creates `.formula/brew-publish.conf` and adds `.formula` to `.gitignore`. It creates `.gitignore` when that file is missing. `formula=` is a filename only; the formula file always lives under `.formula/`. Existing config and `.rb` files are left unchanged. Pass `--tap user/homebrew-tap` to choose the Tap written into a new config.

When the target `.rb` does not exist yet:

1. Look for the configured Tap locally. If it is missing, ask whether to run `brew tap-new`.
2. If the Tap already has a formula with the same name, copy it into `.formula/`.
3. If the Tap does not have one either, ask whether to write a formula template.

```text
tap=hanqunfeng/homebrew-tap
formula=brew-publish-formula.rb
tag_prefix=v
```

| Key | Meaning |
| --- | --- |
| `tap` | `user/homebrew-tap` or `user/tap`. Before publishing, the command checks that this Tap exists locally. If it does not, create it with `brew tap-new user/homebrew-tap` |
| `formula` | A filename such as `brew-publish-formula.rb`. The path is `.formula/` plus that name. When omitted, `.formula/` must contain exactly one `*.rb` |
| `tag_prefix` | Optional. Defaults to `v`, producing `v1.2.3` |

`origin` must point at GitHub. The archive URL and the tag push both use that remote:

```text
https://github.com/<owner>/<repo>/archive/refs/tags/vX.Y.Z.tar.gz
```

Write the tag directly in `url`, for example `v1.2.3`. Homebrew reads the version from that URL, so the formula does not also declare `version`. A matching `version` line makes `brew audit` report it as redundant. A publish rewrites the tag in `url` and updates `sha256`.

The version comes from the latest semver tag. With no tag, it is read from the formula `url`. With neither, the next version starts from `0.0.0`. The first tag can be set with `--version`; earlier tags are not required.

## Publish

Run this in the project root:

```bash
brew-publish-formula patch --dry-run
brew-publish-formula patch              # 1.0.5 → 1.0.6
brew-publish-formula minor              # 1.0.5 → 1.1.0
brew-publish-formula major              # 1.0.5 → 2.0.0
brew-publish-formula --version 1.2.0
brew-publish-formula --resume 1.0.6 --yes
```

The command prints the release plan and waits for confirmation. `--yes` skips the prompt.

| Option | Meaning |
| --- | --- |
| `--dry-run` | Print the operations that would run |
| `--yes` / `-y` | Skip the confirmation prompt |
| `--skip-check` | Skip shellcheck when publishing this repository |
| `--skip-tap-audit` | Skip `brew style` / `brew audit` |
| `--no-push` | Do not push. The command stops after creating the local tag, because `sha256` cannot be computed yet |
| `--resume X.Y.Z` | Continue from the archive download when the tag is already pushed |
| `--tap` `--formula` `--tag-prefix` `--config` | Override the matching config keys |

A full publish requires a clean worktree. Changes under an ignored `.formula` do not appear in `git status`. On `--resume`, if the formula file is still tracked, only that file and `brew-publish-formula` may be modified.

The real `sha256` is available only after the tag reaches GitHub. The script writes it into the local `.formula` file, then copies that file into the Tap. The commit is made in the Tap repository, not in the project repository. Homebrew reads the formula from the Tap.

If the tag was pushed and a later step failed, continue with `--resume`. Do not bump the version again.

## Verify after publishing

```bash
brew update
brew upgrade <formula-name>
```

You can also install once from the formula file in the project:

```bash
brew install --build-from-source ./.formula/<formula-name>.rb
```

## Add it to an existing project

For `java-project-generator`, add `.formula/brew-publish.conf` to that repository:

```text
tap=hanqunfeng/homebrew-tap
formula=java-project-generator.rb
tag_prefix=v
```

Then run `brew-publish-formula patch` in that repository's root.

## Develop this repository

```bash
shellcheck brew-publish-formula
```

Publishing this repository runs the same check. `--skip-check` skips it.
