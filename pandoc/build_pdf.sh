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

# メイン処理
build_pdf() {
    echo "🔧 PDFを生成しています..."
    
    cd "$SCRIPT_DIR"
    
    # 統合されたMarkdownファイルが存在する場合
    if [ -f "$SRC_DIR/book.md" ]; then
        echo "📖 統合ファイル (book.md) からPDFを生成..."
        pandoc \
            "$SRC_DIR/metadata.yaml" \
            "$SRC_DIR/book.md" \
            --from markdown \
            --to pdf \
            --pdf-engine=lualatex \
            --output="$BUILD_DIR/parser_book.pdf" \
            --verbose
    else
        echo "📑 個別章ファイルからPDFを生成..."
        # 将来的に個別ファイルを統合する場合の処理
        echo "⚠️  まだbook.mdが作成されていません"
        echo "次のフェーズで変換作業を行ってください"
        exit 1
    fi
    
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
  build       PDFを生成 (デフォルト)
  test        テスト用サンプルPDFを生成
  preview     HTMLプレビューを生成
  clean       ビルドディレクトリをクリーンアップ
  check       依存関係をチェック
  help        このヘルプを表示

例:
  $0              # PDFを生成
  $0 test         # テスト用サンプルを生成
  $0 preview      # HTMLプレビューを生成
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