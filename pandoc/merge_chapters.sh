#!/bin/bash

# 個別章ファイルから統合書籍ファイル (book.md) を生成するスクリプト

set -e

echo "📚 章ファイルを統合しています..."

# ディレクトリ設定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"
CHAPTERS_DIR="$SRC_DIR/chapters"
BOOK_FILE="$SRC_DIR/book.md"

# 書籍ファイルを初期化
cat > "$BOOK_FILE" << 'EOF'
<!-- 
このファイルは自動生成されています。
直接編集せず、src/chapters/内の個別章ファイルを編集してください。
生成コマンド: ./merge_chapters.sh
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
echo ""
echo "次のステップ:"
echo "  ./build_pdf.sh build    # PDFを生成"