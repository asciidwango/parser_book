#!/bin/bash

# Pandoc PDF Build Script for Parser Book
# 構文解析本のPDF生成スクリプト

set -e  # エラー時に停止

echo "📚 構文解析本のPDF生成を開始します..."

# ディレクトリ設定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"
BUILD_DIR="$SCRIPT_DIR/build"
IMG_DIR="$SCRIPT_DIR/img"

# 出力ディレクトリの準備
mkdir -p "$BUILD_DIR"

# 依存関係チェック
check_dependencies() {
    echo "🔍 依存関係をチェックしています..."
    
    if ! command -v pandoc &> /dev/null; then
        echo "❌ pandocがインストールされていません"
        echo "インストール方法: https://pandoc.org/installing.html"
        exit 1
    fi
    
    if ! command -v lualatex &> /dev/null; then
        echo "❌ lualatexがインストールされていません"
        echo "インストール方法: sudo apt-get install texlive-luatex (Ubuntu/Debian)"
        exit 1
    fi
    
    echo "✅ 依存関係OK"
}

# 章ファイルを統合
merge_chapters() {
    echo "📚 章ファイルを統合しています..."
    
    CHAPTERS_DIR="$SRC_DIR/chapters"
    BOOK_FILE="$SRC_DIR/book.md"
    
    # 書籍ファイルを初期化
    cat > "$BOOK_FILE" << 'EOF'
<!-- 
このファイルは自動生成されています。
直接編集せず、src/chapters/内の個別章ファイルを編集してください。
生成コマンド: ./build_pdf.sh
-->
EOF
    
    # 各章を順番に追加
    chapters=(
        "chapter1.md"
        "chapter2.md" 
        "chapter3.md"
        "chapter4.md"
        "chapter5.md"
        "chapter6.md"
        "chapter7.md"
        "chapter8.md"
        "references.md"
    )
    
    for chapter in "${chapters[@]}"; do
        if [ -f "$CHAPTERS_DIR/$chapter" ]; then
            echo "📄 追加中: $chapter"
            echo "" >> "$BOOK_FILE"
            echo "\\newpage" >> "$BOOK_FILE"
            echo "" >> "$BOOK_FILE"
            cat "$CHAPTERS_DIR/$chapter" >> "$BOOK_FILE"
        else
            echo "⚠️  警告: $chapter が見つかりません"
        fi
    done
    
    # 行数をカウント
    line_count=$(wc -l < "$BOOK_FILE")
    echo "✅ 統合完了: $BOOK_FILE ($line_count 行)"
}

# メイン処理
build_pdf() {
    echo "🔧 PDFを生成しています..."
    
    cd "$SCRIPT_DIR"
    
    # 章ファイルを統合
    merge_chapters
    
    # 統合されたMarkdownファイルからPDFを生成
    echo "📖 統合ファイル (book.md) からPDFを生成..."
    pandoc \
        "$SRC_DIR/metadata.yaml" \
        "$SRC_DIR/book.md" \
        --from markdown \
        --to pdf \
        --pdf-engine=lualatex \
        --output="$BUILD_DIR/parser_book.pdf" \
        --top-level-division=chapter \
        --verbose
    
    echo "✅ PDF生成完了: $BUILD_DIR/parser_book.pdf"
}

# テスト用の簡単なサンプル生成
create_test_sample() {
    echo "🧪 テスト用サンプルを作成します..."
    
    cat > "$SRC_DIR/test_sample.md" << 'EOF'
# テスト章

これはPandoc環境のテスト用サンプルです。

## コードブロックのテスト

```java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, Parser World!");
    }
}
```

## 数式のテスト

インライン数式: $E = mc^2$

ブロック数式:
$$\sum_{i=1}^{n} i = \frac{n(n+1)}{2}$$

## 画像のテスト

![AST図](img/chapter1/ast1.svg){ width=50% }
EOF

    echo "📋 テストサンプルPDFを生成..."
    pandoc \
        "$SRC_DIR/metadata.yaml" \
        "$SRC_DIR/test_sample.md" \
        --from markdown \
        --to pdf \
        --pdf-engine=lualatex \
        --output="$BUILD_DIR/test_sample.pdf" \
        --top-level-division=chapter \
        --verbose
    
    echo "✅ テストサンプル生成完了: $BUILD_DIR/test_sample.pdf"
}

# クリーンアップ
clean() {
    echo "🧹 ビルドディレクトリをクリーンアップ..."
    rm -rf "$BUILD_DIR"/*
    echo "✅ クリーンアップ完了"
}

# HTMLプレビューを生成
generate_preview() {
    echo "🌐 HTMLプレビューを生成中..."
    
    # 章ファイルを統合
    merge_chapters
    
    pandoc \
        "$SRC_DIR/metadata.yaml" \
        "$SRC_DIR/book.md" \
        --from markdown \
        --to html5 \
        --standalone \
        --toc \
        --output="$BUILD_DIR/preview.html" \
        --css="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.2.0/github-markdown-light.min.css"
    
    echo "✅ プレビュー生成完了: $BUILD_DIR/preview.html"
}

# ヘルプ表示
show_help() {
    cat << EOF
使用方法: $0 [オプション]

オプション:
  build       章ファイルを統合してPDFを生成 (デフォルト)
  test        テスト用サンプルPDFを生成
  preview     章ファイルを統合してHTMLプレビューを生成
  merge       章ファイルを統合のみ (PDFを生成しない)
  clean       ビルドディレクトリをクリーンアップ
  check       依存関係をチェック
  help        このヘルプを表示

例:
  $0              # 章ファイルを統合してPDFを生成
  $0 test         # テスト用サンプルを生成
  $0 preview      # 章ファイルを統合してHTMLプレビューを生成
  $0 merge        # 章ファイルの統合のみ
  $0 clean        # クリーンアップ
EOF
}

# メイン処理
main() {
    case "${1:-build}" in
        "build")
            check_dependencies
            build_pdf
            ;;
        "test")
            check_dependencies
            create_test_sample
            ;;
        "preview")
            generate_preview
            ;;
        "merge")
            merge_chapters
            ;;
        "clean")
            clean
            ;;
        "check")
            check_dependencies
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo "❌ 不明なオプション: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"