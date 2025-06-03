# Pandoc版 構文解析本

このディレクトリには、HonkitからPandocへ移行した構文解析本のファイルが含まれています。

## ディレクトリ構造

```
pandoc/
├── src/                     # ソースファイル
│   ├── metadata.yaml       # 書籍メタデータ（著者、タイトルなど）
│   ├── book.md            # 統合された書籍ファイル（自動生成）
│   └── chapters/          # 個別章ファイル（編集用）
├── img/                   # 画像ファイル
├── templates/             # LaTeX/PDFテンプレート（カスタマイズ用）
├── filters/              # Pandocフィルター（カスタマイズ用）
├── build/                # 出力ディレクトリ
├── build_pdf.sh         # PDF生成スクリプト
└── README.md            # このファイル
```

## 必要な環境

### 必須
- [Pandoc](https://pandoc.org/installing.html) 2.19以上
- [LuaLaTeX](https://www.luatex.org/) (TeX Live 2022以上推奨)
- 日本語フォント (Noto CJK フォント推奨)

### Ubuntu/Debianでのインストール

[こちら](https://qiita.com/YuH25/items/76f056bf691855e420e0)を参考に、以下のコマンドで必要なパッケージをインストールできます。

```bash
# Pandoc
sudo apt update
sudo apt install -y pandoc

# TeX Live (LuaLaTeX含む)
sudo apt install -y texlive-lang-japanese
sudo apt install -y texlive-luatex
sudo apt install -y texlive-pictures texlive-latex-extra

# 日本語フォント
sudo apt install -y fonts-noto-cjk

# rsvg-convert  # SVG画像の変換に必要
sudo apt install -y librsvg2-dev
```

### macOSでのインストール
```bash
# Homebrew使用
brew install pandoc
brew install --cask mactex

# 日本語フォント
brew install --cask font-noto-sans-cjk-jp
```

## 使用方法

### 1. 執筆ワークフロー

```bash
# 章を編集（src/chapters/*.md）
vim src/chapters/chapter1.md

# PDFを生成
./build_pdf.sh build
```

### 2. PDF生成

```bash
# 環境チェック
./build_pdf.sh check

# テスト用サンプルPDF生成
./build_pdf.sh test

# 本番PDF生成
./build_pdf.sh build
```

### 3. プレビュー確認

```bash
# HTMLプレビュー生成
./build_pdf.sh preview

# ブラウザで開く
open build/preview.html  # macOS
xdg-open build/preview.html  # Linux
```

## 編集方法

### メタデータの変更
`src/metadata.yaml` で書籍の基本情報を編集：
- タイトル、著者、出版日
- フォント設定
- レイアウト設定

### コンテンツの編集

**推奨ワークフロー**
1. `src/chapters/` 内の個別章ファイルを編集
2. `./build_pdf.sh build` でPDFを生成

**注意**: `src/book.md` は自動生成されるファイルです。直接編集せず、必ず個別章ファイルを編集してください。

### フォーマット対応
- PDF (高品質、印刷対応)
- HTML (プレビュー用)
- EPUB (将来的に電子書籍対応予定)
- LaTeX (上級者向けカスタマイズ)

## カスタマイズ

### レイアウト調整
`src/metadata.yaml` の以下の項目を調整：
- `geometry`: ページマージン
- `fontsize`: フォントサイズ
- `linestretch`: 行間

### テンプレート使用
`templates/` ディレクトリにカスタムLaTeXテンプレートを配置可能

### フィルター使用
`filters/` ディレクトリにPandocフィルターを配置して、変換処理をカスタマイズ可能