# dotfiles

M1 MacBook購入後の初期セットアップ
OS: Monterey 12.0.1

## 事前準備

- このリポジトリを$HOME配下にcloneする
  ```sh
  cd ~ && git clone https://github.com/tabio/dotfiles
  ```
- [Homebrew](https://brew.sh/index_ja)のインストール
  ```sh
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```
- AppStoreにログイン
  - BrewfileのmasはAppStoreからのインストールのため

## [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)でアプリケーションのインストール

```sh
brew bundle
```

## [Google IME](https://www.google.co.jp/ime/)はRosettaがないとインストールできないので手動でインストールする

- Rosettaをインストールするか聞かれるので「Yes」
- Google IMEをインストールしたら「ひらがな (Google)」と「ABC」を残して全て削除
- システム環境設定 > ショートカット > 入力ソースで「前の入力ソース」を「cmd＋スペース」へ変更

## anyenvの設定

- xxenvをインストールできるようにプラグインを追加
  ```sh
  anyenv install --init
  ```
- ○○envをインストール
  ```
  anyenv install rbenv
  anyenv install pyenv
  anyenv install nodenv
  ```
- shellの再起動
  ```
  echo 'eval "$(anyenv init -)"' >> ~/.zshrc
  exec $SHELL -l
  ```
- nodeをインストールしておく(neovimのcoc pluginで利用するため)
  ```sh
   nodenv install xx.xx.xx
   nodenv global xx.xx.xx
  ```

## git

```sh
./setup-git.sh
```

## zsh

```sh
./setup-zsh.sh
```

## neovim

```sh
./setup-neovim.sh
```

## hammerspoon

hammerspoonを使う場合はconfigファイルをコピー
```sh
cp hammerspoon-init.lua ~/.hammerspoon/init.lua
```

## Finder

- 環境設定のサイドバー表示項目にホームディレクトリを追加
- 表示の項目パスバーを表示を有効化


## システム環境設定

- キーボード > キーボードで修飾キーの変更
- Mision Control > ホットコーナーでディスプレイのスリープ設定を追加
- Dockとメニューバー
  - Dockの最近使ったアプリケーションをDocに表示のチェックボックスを外す
