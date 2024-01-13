# dotfiles

M2 MacBook購入後の初期セットアップ
OS: Sonoma 14.2.1

## 事前準備

- gitコマンドの実行
  terminalでgitコマンドを打つとXCode利用のためのソフトウェアインストールポップアップが表示されるのでインストールしておく
- [Homebrew](https://brew.sh/index_ja)のインストール
  ```sh
  # install
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # pathを通す
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
  ```
- このリポジトリを$HOME配下にcloneする
  ```sh
  cd ~ && git clone https://github.com/tabio/dotfiles
  ```
- AppStoreにログイン
  - BrewfileのmasはAppStoreからのインストールのため

## [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)でアプリケーションのインストール

```sh
brew bundle
```

## [Google IME](https://www.google.co.jp/ime/)は手動インストール

- Google IMEをインストールしたら「ひらがな (Google)」と「ABC」を残して全て削除

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

## setup系

```sh
# git
./setup-git.sh

# zsh
./setup-zsh.sh

# neovim
./setup-neovim.sh

# iterm2
./setup-iterm2.sh

# starship
# ref. https://github.com/starship/starship/blob/master/docs/ja-JP/guide/README.md
# setup後にはiterm2のtextフォントをFiraCode Nerd Fontに変更(絵文字反映のため)
./setup-starship.sh

# karabiner
# capslock -> control, cmd単体で入力切替のみ
cp karabiner.json ~/.config/karabiner/karabiner.json
```

## Finder

- 環境設定のサイドバー表示項目にホームディレクトリを追加
- 表示の項目パスバーを表示を有効化


## システム環境設定

- キーボード
  - キーボード > 修飾キーの変更(日本語切り替えの文脈)
    - キーボードを変更したためデフォルトの設定に戻した
  - ショートカット > デスクトップ1~4への切り替えを有効化
- デスクトップとDock > Mision Control > ホットコーナーで左下でロック画面表示
- Dockとメニューバー
  - Dockの最近使ったアプリケーションをDocに表示のチェックボックスを外す

## Better Touch Tool

Better Touch Toolのプリセットを選択して、better-touch-tool.bttpresetをインポート

## raycast

cmd + spaceはspotlightのショートカットが割り当てられているのでOFFにする

システム > キーボード > キーボードショートカット > Spotlight にてSpotlight検索を表示をOFF

raycastを起動させてraycastのconfigファイルをimportする

## 1password

1password8のMac版を[HPからDL](https://1password.com/jp/product/mac/)する
brew経由ではインストールしない
AppStoreにあるのはver.7なので注意
