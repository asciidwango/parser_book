# 構文解析の本

アスキードワンゴで出版予定。2023年中になんとか完成にこぎつけたい。

Honkit形式で執筆中。

# リポジトリの構成

```
./
  book.json // Honkitの設定ファイル
  package.json // npmの各種設定
  package-lock.json // package.jsonのロックファイル
  README.md // このファイル
  honkit / // 原稿が入ったディレクトリ
    SUMMARY.md // 章構成
    README.md // 原稿のREADME
    preface.md // はじめに
    chapter1.md // 第一章
    chapter2.md // 第二章
    chapter3.md // 第三章
    chapter4.md // 第四章
    chapter5.md // 第五章
    chapter6.md // 第六章
    chapter7.md // 第七章
    appendix.md // 付録
  .gitignore // gitの管理対象から除外するパターンの列挙
```

## 書籍のビルド方法

1. `npm i`

依存ライブラリをインストールする

```
$ npm i
```

2. `npm run start`

Honkitによって、書籍をビルドし、プレビューができる状態にする

```bash
npm start // Honkitによるプレビュー
...
Starting server ...
Serving book on http://localhost:4000
```

3. [http://localhost:4000](http://localhost:4000)にアクセス

## 趣旨

[こちら](./PURPOSE.md)参照
