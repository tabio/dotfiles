# mac-setup

mac購入後の初期セットアップ

## 事前準備

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

## zsh

```sh
./setup-zsh.sh
```

## neovim

[dotfiles_neovim](https://github.com/tabio/dotfiles_neovim)を$HOME配下にインストールしてREADMEに従う

## hammerspoon

hammerspoonを使う場合はconfigファイルをコピー
```sh
cp hammerspoon-init.lua ~/.hammerspoon/init.lua
```

## システム環境設定

- キーボード > キーボードで修飾キーの変更
- Mision Control > ホットコーナーでディスプレイのスリープ設定を追加
