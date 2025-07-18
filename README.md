# 構文解析の本

アスキードワンゴで出版予定の構文解析の技術書です。Pandoc形式で執筆・管理しています。

# リポジトリの構成

```
./
  README.md         // このファイル
  PURPOSE.md        // 本書の趣旨
  book.md           // 統合された書籍全体（自動生成）
  metadata.yaml     // 書籍メタデータ
  build_pdf.sh      // PDF生成スクリプト
  contents/         // 個別章のMarkdownファイル
    chapter1.md     // 第1章：構文解析の世界へようこそ
    chapter2.md     // 第2章：構文解析の基礎
    chapter3.md     // 第3章：JSONの構文解析
    chapter4.md     // 第4章：文脈自由文法の世界
    chapter5.md     // 第5章：構文解析アルゴリズム・処理系統
    chapter6.md     // 第6章：構文解析器生成系の世界
    chapter7.md     // 第7章：現実の構文解析
    chapter8.md     // 第8章：おわりに
    references.md   // 参考文献
  templates/        // LaTeX/PDFテンプレート
  build/            // ビルド出力ディレクトリ
  code/             // サンプルコード
    chapter3/       // JSON パーサー実装
    chapter5/       // SLR(1) パーサー実装
    chapter6/       // パーサージェネレータの例
  pandoc/           // 旧Pandoc環境（移行後削除予定）
  .gitignore        // gitの管理対象から除外するパターン
```

## 必要な環境

- [Pandoc](https://pandoc.org/installing.html) 2.9以上
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

## 書籍のビルド方法

### PDFビルド

```bash
./build_pdf.sh
# build/parser_book.pdf が生成されます
```

### HTMLプレビュー

```bash
./build_pdf.sh preview
# build/preview.html が生成されます
# ブラウザでbuild/preview.htmlを開く
```

## 執筆ワークフロー

```bash
# 章を編集（contents/*.md）
vim contents/chapter1.md

# PDFを生成
./build_pdf.sh
```

## 趣旨

[こちら](./PURPOSE.md)参照
