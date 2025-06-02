# Japanese Font Support for PDF Generation

This document explains how Japanese font support is configured for PDF generation in this project.

## Current Setup

### 1. PDF Engine
We use **LuaLaTeX** as the PDF engine, which has excellent support for Unicode and Japanese text processing.

### 2. Document Class
The `ltjsbook` document class is used, which is a Japanese-aware variant of the standard LaTeX book class provided by the LuaTeX-ja package.

### 3. Font Configuration
The following fonts are configured in `src/metadata.yaml`:

- **Main font (serif)**: Noto Serif CJK JP
- **Sans-serif font**: Noto Sans CJK JP  
- **Monospace font**: Noto Sans Mono CJK JP

These fonts are system fonts that come pre-installed on most Linux distributions.

### 4. Key Metadata Settings

```yaml
documentclass: ltjsbook          # Japanese-aware document class
lang: ja                         # Document language
mainfont: "Noto Serif CJK JP"    # For Latin text
sansfont: "Noto Sans CJK JP"     
monofont: "Noto Sans Mono CJK JP"
CJKmainfont: "Noto Serif CJK JP" # For CJK text
CJKsansfont: "Noto Sans CJK JP"
CJKmonofont: "Noto Sans Mono CJK JP"
pdf-engine: lualatex             # Unicode-aware engine
```

### 5. Additional Package
The `luatexja-fontspec` package is loaded in the header-includes section to ensure proper font handling.

## Troubleshooting

### Missing Character Warnings
If you see warnings like "Missing character: There is no ス (U+30B9) in font", it means:
- The PDF engine is not properly configured for Japanese
- The CJK fonts are not being applied correctly
- The document class doesn't support Japanese

### Font Not Found Errors
If fonts are not found:
1. Check installed fonts: `fc-list | grep -i "noto.*cjk"`
2. Install missing fonts: `sudo apt-get install fonts-noto-cjk`

### Alternative Fonts
If Noto fonts are not available, you can use:
- IPAex fonts: `ipaexm` (mincho/serif) and `ipaexg` (gothic/sans)
- Harano Aji fonts (included with TeX Live)

## Testing

To test Japanese font support:
```bash
./build_pdf.sh test
```

This will generate a test PDF with Japanese text in `build/test_sample.pdf`.

## Custom Template (Optional)

A custom LaTeX template is available at `templates/japanese.latex` for more advanced customization needs. To use it, add the `--template` option to pandoc commands.

## Dependencies

Required packages:
- texlive-luatex
- texlive-lang-japanese
- fonts-noto-cjk (or alternative CJK fonts)
- pandoc (2.0+)