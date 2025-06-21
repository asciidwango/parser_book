# 構文解析の本

アスキードワンゴで出版予定の構文解析の技術書です。

Pandoc形式で執筆・管理しています。

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

### 必要な環境

- Pandoc 2.9以上
- LaTeX環境（LuaLaTeX）
- 日本語フォント（Noto CJK フォント）
- rsvg-convert（SVG画像変換用）

## 趣旨

[こちら](./PURPOSE.md)参照
