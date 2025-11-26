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

## パッケージ管理ツール mise で必要そうなものをインストール

- Brewfileに入っているのでインストールされていることが前提
- mise use -g node@22
- mise use -g pnpm@latest
    - mise use uv@latest (uvも入れておく)

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
  - Fnキーを標準のファンクションキーとして使用
    - キーボード > キーボードのショートカット > 左メニューのファンクションキー
- デスクトップとDock > Mision Control > ホットコーナーで左下でロック画面表示
- Dockとメニューバー
  - Dockの最近使ったアプリケーションをDocに表示のチェックボックスを外す
- トラックパッド
    - タップでクリックをON
- Bluetoothをメニューに表示
    - システム > コントロールセンター 「Bluetooth」の項目でメニューに表示

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

## aws / github

sshを利用してgithubにアクセスするため、旧PCの.ssh/configを確認して必要に応じて秘密鍵・公開鍵を持ってくる
awsやgithubの鍵はiCloudの共有を利用するなどする

## VSCode

基本的には設定はgithubアカウントで同期させている
vscodevimプラグインを入れているが、初期状態だとjhklによる長押しでの移動が動かないのでVSCodeのターミナルに以下コマンドを入力し再起動する
```
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false
```

## キーボード

keychron q11を使っている
キーマップのベースはkeychron自体に変更を加えている
変更は[公式HP](https://www.keychron.com/blogs/archived/how-to-use-via-to-program-your-keyboard)の方法を使い、Chrome上でVIAというソフトウェアを介して操作を行っている

## cursor

- vimのjkなどが長押しで動かない。以下のコマンドをitermで打ち込んでcursorを再起動
    - defaults write $(osascript -e 'id of app "Cursor"') ApplePressAndHoldEnabled -bool false
- ユーザー設定
    - Workbench › Activity Bar: Orientation -> horizon
- タブの下部をハイライト
    ```
    "workbench.colorCustomizations": {
      "tab.activeBorder": "#0cf388",
    }
    ```
- cursorで必要な拡張機能をいれる
    - Claude Code for VS Code
    - ms-pythonを入れてコマンドパレット上で「Python: select interpreter」を入力し、venvのpathを通す（ex. ./venv/bin/pythonなど）
