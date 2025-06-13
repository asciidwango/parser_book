
# 第6章 構文解析器生成系の世界

第5章では現在知られている構文解析手法について、アイデアと提案手法の概要について説明しました。実は、構文解析の世界ではよく知られていることなのですが、第5章で説明した各種構文解析手法は毎回プログラマが手で実装する必要はありません。

というのは、CFG（文脈自由文法）やPEG（その類似表記も含む）によって記述された文法定義から特定の構文解析アルゴリズムを用いた構文解析器を生成する**構文解析器生成系**（パーサジェネレータ）というソフトウェアがあるからです。

簡単に言えば、「文法の定義を書いたら、それに対応したパーサーのJavaコードを自動生成してくれるツール」です。これにより、複雑な構文解析アルゴリズムを知らなくても、文法定義さえ書ければ高性能なパーサーを作れるのです。

構文解析器生成系でもっとも代表的なものはyacc（ヤック）あるいはその互換実装であるGNU bison（バイソン）でしょう。yaccはLALR(1)法を利用したC言語の構文解析器を生成してくれるソフトウェアです。

ちなみに「yacc」は「Yet Another Compiler Compiler」（また別のコンパイラコンパイラ）の略で、「コンパイラを作るためのコンパイラ」という意味です。

この章では構文解析器生成系という種類のソフトウェアの背後にあるアイデアからはじまり、LL(1)、LALR(1)、PEGのための構文解析器を作る方法や多種多様な構文解析器生成系についての紹介などを行います。

また、この章の最後ではある意味構文解析生成系の一種とも言える**パーザコンビネータ**の実装方法について踏み込んで説明します。

パーザコンビネータとは、簡単に言えば「プログラミング言語自体でパーサーを組み立てる方法」です。通常の構文解析器生成系が「文法定義ファイル」から「Javaコード」を生成するのに対し、パーザコンビネータではJavaのメソッドを組み合わせて直接パーサーを作ります。

一方、パーザコンビネータであれば、いわゆる「ラムダ式」（Java 8から導入された匿名関数のようなもの）を持つほとんどのプログラミング言語で比較的簡単に実装できます。本書で利用しているJava言語でも同様です。というわけで、本章を読めば皆さんもパーザコンビネータを明日から自前で実装できるようになります。

## Dyck言語の文法とPEGによる構文解析器生成

これまで何度も登場したDyck言語（括弧の対応が取れた文字列を表す言語）は明らかにLL(1)法でもLR(1)法でもPEGによっても解析可能な言語です。（第4章でDyck言語のBNFやCFG（文脈自由文法）を紹介しましたが、具体的な手書きPEGパーザのコードは第5章の再帰下降パーザが近い考え方です）。しかし、手書きでパーザを実装しようとすると、退屈な繰り返しコードが多くなりがちです。

実際のところ、Dyck言語を表現する文法があって、構文解析アルゴリズムがPEGということまで分かれば対応するJavaコードを**機械的に生成する**ことも可能そうに見えます。特に、構文解析はコード量が多いわりには退屈な繰り返しコードが多いものですから、文法からJavaコードを生成できれば劇的に工数を削減できそうです。

このように「文法と構文解析手法が決まれば、後のコードは自動的に決定可能なはずだから、機械に任せてしまおう」という考え方が構文解析器生成系というソフトウェアの背後にあるアイデアです。

早速ですが、以下のようにDyck言語を表す文法（第4章で示した `P -> ( P ) P | ε` に近いもの）がPEGで与えられたとして、構文解析器を生成する方法を考えてみましょう。

PEGの記法では、`/`は「順序付き選択」を表し、BNFの`|`とは異なり「最初の選択肢がマッチしたらそれを採用し、2番目以降は試さない」という意味になります。

```text
D <- P;
P <- "(" P ")" P / ""; // "" は空文字列ε（イプシロン）を表す
```
このPEG定義は、`P` が `(P)P` の形であるか、または空文字列であることを示します。
PEGでは非終端記号の呼び出しは関数呼び出しとみなすことができますから、この定義から機械的に対応するパーザ関数（メソッド）のスケルトンを考えると、まず次のようなコードのイメージになります。

```java
// 概念的なスケルトン
public boolean parseD() {
    return parseP(); // DはPに委譲
}

public boolean parseP() {
    // P <- "(" P ")" P / "";
    // まず "(" P ")" P を試す
    //   "(" にマッチするか？
    //   マッチしたら、P を再帰的に呼び出す (1回目)
    //   成功したら、")" にマッチするか？
    //   マッチしたら、P を再帰的に呼び出す (2回目)
    //   成功したら、全体として成功
    // もし途中で失敗したら、バックトラックして "" を試す
    //   "" は常に成功（空文字列を消費）
    // どちらかが成功すれば parseP は成功
}
```

## Dyck言語の構文解析器を生成する

先ほどのDyck言語のPEG定義：

```text
D <- P;
P <- "(" P ")" P / "";
```

をJavaコードに変換していきます。

このとき、PEGからJavaコードへの機械的な変換は、以下の規則に従います：

1. **非終端記号**：非終端記号`X`に対して `parseX()` という名前のメソッドを生成
2. **文字列リテラル**：`match("文字列")` の呼び出しに変換
3. **連接**：各要素を順番に呼び出し、すべて成功したときのみ成功
4. **順序付き選択**：最初の選択肢を試し、失敗したらバックトラックして次を試す
5. **繰り返し**：ループ構造に変換

```java
public class DyckParser {
    private String input;
    private int position;
    
    public DyckParser(String input) {
        this.input = input;
        this.position = 0;
    }
    
    // D <- P
    public boolean parseD() {
        return parseP();
    }
    
    // P <- "(" P ")" P / ""
    public boolean parseP() {
        // 現在位置を保存（バックトラック用）
        int savedPos = position;
        
        // まず "(" P ")" P を試す
        if (match("(")) {
            if (parseP()) {  // 最初のP
                if (match(")")) {
                    if (parseP()) {  // 2番目のP
                        return true;  // すべて成功
                    }
                }
            }
        }
        
        // 失敗したらバックトラック
        position = savedPos;
        
        // 次に空文字列 "" を試す（常に成功）
        return true;
    }
    
    // 文字列のマッチングを行うヘルパーメソッド
    private boolean match(String str) {
        if (position + str.length() <= input.length() &&
            input.startsWith(str, position)) {
            position += str.length();
            return true;
        }
        return false;
    }
    
    // パース実行メソッド
    public boolean parse() {
        boolean result = parseD();
        return result && position == input.length();  // 全体を消費したか確認
    }
}
```

このようにして、比較的シンプルにPEGからDyck言語の構文解析器を生成することができました。

### 構文解析器生成系の実装

実際の構文解析器生成系では、以下のようなステップで自動生成を行います：

1. **PEG文法の解析**：PEG記法で書かれた文法定義自体を解析
2. **中間表現の生成**：文法規則を内部的なデータ構造に変換
3. **コード生成**：テンプレートを使ってJavaコードを出力

以下は中間表現が生成された後のコード生成の例です。ここでは、PEGの規則を表すクラス`Rule`と、各種PEG式を表す`Expression`クラスを定義し、Javaコードを生成しています。

```java
// 簡単な構文解析器生成系の例
public class PEG2Java {
    // 文法規則を表すクラス
    static class Rule {
        String name;
        Expression body;
    }
    
    // PEG式を表す抽象クラス
    abstract static class Expression {
        abstract String generateCode(String indent);
    }
    
    // 文字列リテラル
    static class Literal extends Expression {
        String value;
        
        String generateCode(String indent) {
            return indent + "if (match(\"" + value + "\")) {\n";
        }
    }
    
    // 連接
    static class Sequence extends Expression {
        List<Expression> elements;
        
        String generateCode(String indent) {
            StringBuilder code = new StringBuilder();
            for (Expression e : elements) {
                code.append(e.generateCode(indent));
            }
            return code.toString();
        }
    }
    
    // コード生成のメインメソッド
    public String generateParser(List<Rule> rules) {
        StringBuilder code = new StringBuilder();
        code.append("public class GeneratedParser {\n");
        
        // 各規則に対してメソッドを生成
        for (Rule rule : rules) {
            code.append("    public boolean parse" + rule.name + "() {\n");
            code.append(rule.body.generateCode("        "));
            code.append("    }\n\n");
        }
        
        code.append("}\n");
        return code.toString();
    }
}
```

このように、PEGの文法定義から機械的にJavaコードを生成することで、手書きの退屈な作業を自動化できます。実際の構文解析器生成系では、エラー処理、最適化、デバッグ情報の付加など、より高度な機能も実装されています。

## 構文解析器生成系の分類

構文解析器生成系は1970年代頃から研究の蓄積があり、数多くの構文解析器生成系がこれまで開発されています。

基本的には、構文解析器生成系は採用している構文解析アルゴリズムによって分類されます。たとえば：

- JavaCCはLL(1)構文解析器を出力するため、**LL(1)構文解析器生成系**
- yacc/bisonはLALR(1)構文解析器を出力するため、**LALR(1)構文解析器生成系**

一般的な構文解析器生成系の処理フローは、おおむね以下のようになります。

```{=latex}
\begin{figure}[H]
\centering
\begin{tikzpicture}[
    scale=0.8, transform shape,
    node distance=2.2cm,
    box/.style={draw, rectangle, minimum width=3cm, minimum height=0.8cm, align=center, font=\small},
    diamond/.style={draw, ellipse, minimum width=2.8cm, minimum height=1cm, align=center, font=\small},
    arrow/.style={->, thick},
    label/.style={midway, above, font=\footnotesize}
]
    % ノードの定義
    \node[box] (A) {文法定義ファイル\\(.g, .y, .jjなど)};
    \node[diamond, right=1.8cm of A] (B) {構文解析器\\生成系};
    \node[box, above right=1cm and 1.5cm of B] (C) {字句解析器\\コード生成部};
    \node[box, right=1.8cm of C] (D) {生成された\\字句解析器コード\\(.java, .cなど)};
    \node[box, below right=1cm and 1.5cm of B] (E) {構文解析器\\コード生成部};
    \node[box, right=1.8cm of E] (F) {生成された\\構文解析器コード\\(.java, .cなど)};
    \node[diamond, right=3.5cm of B] (H) {コンパイラ};
    \node[box, right=1.8cm of H] (I) {実行可能な\\パーサー};
    
    % 矢印の定義
    \draw[arrow] (A) -- (B);
    \draw[arrow] (B) -- node[label,sloped] {字句解析ルール} (C);
    \draw[arrow] (C) -- (D);
    \draw[arrow] (B) -- node[label,sloped] {構文解析ルール} (E);
    \draw[arrow] (E) -- (F);
    \draw[arrow] (D) -- (H);
    \draw[arrow] (F) -- (H);
    \draw[arrow] (H) -- (I);
\end{tikzpicture}
\caption{一般的な構文解析器生成系の処理フロー}
\label{fig:parser-generator-flow}
\end{figure}
```

Yacc/Lexのように、字句解析器生成系（Lex）と構文解析器生成系（Yacc）が別々のツールとして提供され、連携して動作するケースもあります。

ただし、例外もあります。GNU Bisonはyaccと違って、LALR(1)より広いGLR（Generalized LR：一般化LR）構文解析器も生成できるので、GLR構文解析器生成系であるとも言えるのです。

GLRは、通常のLR構文解析ではコンフリクト（シフト/還元コンフリクトなど）が発生するような曖昧な文法も扱えるように拡張された手法です。実際には、yacc/bisonを使う場合、ほとんどはLALR(1)構文解析器を出力するので、GLRについて言及されることは少ないですが、そのようなことは知っておいても損はないでしょう。

より大きなくくりでみると、下向き構文解析（LL法やPEG）と上向き構文解析（LR法など）という観点から分類することもできますし、ともに文脈自由文法ベースであるLL法やLR法と、解析表現文法など他の形式言語を用いた構文解析法を対比してみせることもできます。

以下に、本書で紹介する代表的な構文解析器生成系の比較をまとめます。

| 特徴項目                     | JavaCC                                     | Yacc/Bison                                     | ANTLR                                                              |
| ---------------------------- | ------------------------------------------ | ---------------------------------------------- | ------------------------------------------------------------------ |
| **採用アルゴリズム**         | LL(k) (デフォルトはLL(1))                  | LALR(1) (BisonはGLRも可)                       | ALL(*) (適応型LL(*))                                               |
| **生成コードの言語**         | Java                                       | C, C++ (BisonはJavaなども限定的にサポート)       | Java, C++, Python, JavaScript, Go, C#, Swift, Dart, PHP (多言語対応) |
| **左再帰の扱い**             | 不可 (文法書き換えが必要)                    | 直接左再帰を扱える                             | 直接・間接左再帰を扱える (v4以降)                                  |
| **曖昧性解決**               | 先読みトークン数(k)の調整、意味アクション    | 演算子の優先順位・結合規則指定、%precなどで対応 | 意味アクション、構文述語、ALL(*)による自動解決                     |
| **エラー報告/リカバリ機能**  | 基本的                                     | `error`トークンによる限定的なリカバリ            | 高度なエラー報告、柔軟なエラーリカバリ戦略                         |
| **学習コスト**               | Javaユーザーには比較的容易                   | やや高め (C言語と連携の知識も必要)             | 機能が豊富で強力な分、やや高め                                     |
| **ライセンス**                 | 3条項BSDライセンス                         | GPL (Bison), Public Domain (Yaccのオリジナル)  | 3条項BSDライセンス                                                 |
| **その他特徴**               | Javaに特化、構文がJavaライク               | C言語との親和性が高い、歴史と実績がある        | 強力な解析能力、豊富なターゲット言語、優れたツールサポート(GUIなど)  |

## JavaCC：Javaの構文解析生成系の定番

1996年、Sun Microsystems（当時）は、Jackという構文解析器生成系をリリースしました。その後、Jackの作者が自らの会社を立ち上げ、JackはJavaCCに改名されて広く知られることとなりましたが、現在では紆余曲折の末、[javacc.github.io](https://javacc.github.io/javacc)の元で開発およびメンテナンスが行われています。現在のライセンスは3条項BSDライセンスです。

JavaCCという名前は「Java Compiler Compiler」の略で、yacc同様「コンパイラを作るためのコンパイラ」という意味です。

JavaCCはLL(1)法を元に作られており、構文定義ファイルからLL(1)パーザを生成します。以下は四則演算を含む数式を計算できる電卓をJavaCCで書いた場合の例です。

```java
options {
  STATIC = false;
  JDK_VERSION = "17";
}

PARSER_BEGIN(Calculator)
package com.github.kmizu.calculator;
public class Calculator {
  public static void main(String[] args) throws ParseException {
    Calculator parser = new Calculator(System.in);
    parser.start();
  }
}
PARSER_END(Calculator)

SKIP : { " " | "\t"  | "\r" | "\n" }
TOKEN : {
  <ADD: "+">
| <SUBTRACT: "-">
| <MULTIPLY: "*">
| <DIVIDE: "/">
| <LPAREN: "(">
| <RPAREN: ")">
| <INTEGER: (["0"-"9"])+>
}

public int expression() :
{int r = 0;}
{
  r=add() <EOF> { return r; }
}

public int add() :
{int r = 0; int v = 0;}
{
    r=mult() ( <ADD> v=mult() { r += v; }| <SUBTRACT> v=mult() { r -= v; })* {
        return r;
    }
}


public int mult() :
{int r = 0; int v = 0;}
{
   r=primary() ( 
     <MULTIPLY> v=primary() { r *= v; }
   | <DIVIDE> v=primary() { r /= v; })* { return r; }
}

public int primary() :
{int r = 0; Token t = null;}
{
(
  <LPAREN> r=expression() <RPAREN>
| t=<INTEGER> { r = Integer.parseInt(t.image); }
) { return r; }
}

```

この`SKIP`から`TOKEN`までの部分はトークン定義になります。トークンとは、構文解析の基本単位となる要素で、「+」「123」「(」などのことです。第3章のJSONパーサーでも「文字列」「数値」「中括弧」などをトークンとして扱いましたね。ここでは、7つのトークンを定義しています。トークン定義の後が構文規則の定義になります。ここでは、

- `expression()`
- `add()`
- `mult()`
- `primary()`

の4つの構文規則が定義されています。各構文規則はJavaのメソッドに酷似した形で記述されますが、実際、ここから生成される.javaファイルには同じ名前のメソッドが定義されます。

`expression()`が`add()`を呼び出して、`add()`が`mult()`を呼び出して、`mult()`が`primary()`を呼び出すという構図は第2章で既にみた形ですが、第2章と違って単純に宣言的に各構文規則の関係を書けばそれでOKなのが構文解析器生成系の強みです。

ちなみに、`{int r = 0;}`のような部分はJavaコードの埋め込みで、構文解析中に実行される処理を記述しています。これを「セマンティックアクション」（意味的動作）と呼びます。セマンティックアクションを使うことで、単に文法が正しいかチェックするだけでなく、解析しながら計算や抽象構文木の構築などの処理を行うことができます。

このようにして定義した電卓プログラムは次のようにして利用することができます。

```java
package com.github.kmizu.calculator;

import jdk.jfr.Description;
import org.junit.jupiter.api.Test;
import com.github.kmizu.calculator.Calculator;
import java.io.*;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class CalculatorTest {
    @Test
    @Description("1 + 2 * 3 = 7")
    public void test1() throws Exception {
        Calculator calculator = new Calculator(
            new StringReader("1 + 2 * 3"))
        ;
        assertEquals(7, calculator.expression());
    }

    @Test
    @Description("(1 + 2) * 4 = 12")
    public void test2() throws Exception {
        Calculator calculator = new Calculator(
            new StringReader("(1 + 2) * 4")
        );
        assertEquals(12, calculator.expression());
    }

    @Test
    @Description("(5 * 6) - (3 + 4) = 23")
    public void test3() throws Exception {
        Calculator calculator = new Calculator(
            new StringReader("(5 * 6) - (3 + 4)")
        );
        assertEquals(23, calculator.expression());
    }
}
```

この`CalculatorTest`クラスではJUnit5を使って、JavaCCで定義した`Calculator`クラスの挙動をテストしています。空白や括弧を含む数式を問題なく計算できているのがわかるでしょう。

このようなケースでは先読みトークン数が1のため、JavaCCのデフォルトで構いませんが、定義したい構文によっては先読み数を2以上に増やさなければいけないこともあります。そのときは、以下のようにして先読み数を増やすことができます：

```java
options {
  STATIC = false;
  JDK_VERSION = "17";
  LOOKAHEAD = 2
}
```

ここでは、`LOOKAHEAD = 2`というオプションによって、先読みトークン数を2に増やしています。

先読みトークン数が2ということは、「次の2つのトークンを見て、どの規則を適用するか決定できる」という意味です。LOOKAHEADは固定されていれば任意の正の整数にできるので、JavaCCはデフォルトではLL(1)だが、オプションを設定することによってLL(k)になるともいえます。

また、JavaCCは構文定義ファイルの文法がかなりJavaに似ているため、生成されるコードの形を想像しやすいというメリットがあります。JavaCCはJavaの構文解析生成系の中では最古の部類の割に今でも現役で使われているのは、Javaユーザにとっての使いやすさが背景にあるように思います。


## Yacc (GNU Bison)：構文解析器生成系の老舗

既に紹介しましたが、YaccはYet another compiler compilerの略で、日本語にすると「もう一つのコンパイラコンパイラ」といったところでしょうか。yaccができた当時は、コンパイラを作るためのコンパイラについての研究が盛んだった時期で、構文解析器生成系もそのための研究の副産物とも言えます。

1970年代にAT&Tのベル研究所にいたStephen C. Johnson（スティーブン・C・ジョンソン）によって作られたソフトウェアで、非常に歴史がある構文解析器生成系です。第5章で学んだLALR(1)法を実用化した最初のツールでもあります。

YaccはLALR(1)法をサポートし、lex（レックス）という字句解析器生成系と連携することで構文解析器を生成することができます（もちろん、lexを使わない実装も可能）。

「lex」は「lexical analyzer」（字句解析器）の略で、テキストをトークンに分割するツールです。Yacc自体は色々な構文解析器生成系に多大な影響を与えており、現在使われているGNU BisonはYaccのGNUによる再実装でもあります。

Yaccを使って、四則演算を行う電卓プログラムを作るにはまず字句解析器生成系であるflex用の定義ファイルを書く必要ががあります。その定義ファイル`token.l`は次のようになります：

```text
%{
#include "y.tab.h"
%}

%%
[0-9]+      { yylval = atoi(yytext); return NUM; }
[-+*/()]    { return yytext[0]; }
[ \t]       { /* ignore whitespce */ }
"\r\n"      { return EOL; }
"\r"        { return EOL; }
"\n"        { return EOL; }
.           { printf("Invalid character: %s\n", yytext); }
%%
```

`%%`から`%%`までがトークンの定義です。これはそれぞれ次のように読むことができます。

- `[0-9]+      { yylval = atoi(yytext); return NUM; }`

  0-9までの数字が1個以上あった場合はに数値として解釈し（`atoi(yytext)`)、トークン`NUM`として返します。

- `[-+*/()]    { return yytext[0]; }`

  `-`,`+`,`*`,`/`,`(`,`)`についてはそれぞれの文字をそのままトークンとして返します。

- `[ \t]       { /* ignore whitespce */ }`

  タブおよびスペースは単純に無視します

- `"\r\n"      { return EOL; }`

  改行はEOLというトークンとして返します

- `"\r"        { return EOL; }`

  前に同じ

- `"\n"        { return EOL; }`

  前に同じ

- `.           { printf("Invalid character: %s\n", yytext); }`

  それ以外の文字が来たらエラーを吐きます

このトークン定義ファイルを入力として与えると、flexは`lex.yy.c`という形で字句解析器を出力します。

次に、yaccの構文定義ファイルを書きます：

```text
%{
#include <stdio.h>
int yylex(void);
void yyerror(char const *s);
int yywrap(void) {return 1;}
extern int yylval;
%}

%token NUM
%token EOL
%left '+' '-'
%left '*' '/'

%%

input : expr EOL
      { printf("Result: %d\n", $1); }
      ;

expr : NUM
      { $$ = $1; }
      | expr '+' expr
      { $$ = $1 + $3; }
      | expr '-' expr
      { $$ = $1 - $3; }
      | expr '*' expr
      { $$ = $1 * $3; }
      | expr '/' expr
      {
        if ($3 == 0) { yyerror("Cannot divide by zero."); }
        else { $$ = $1 / $3; }
      }
      | '(' expr ')'
      { $$ = $2; }
      ;


void yyerror(char const *s)
{
  fprintf(stderr, "Parse error: %s\n", s);
}

int main()
{
  yyparse();
}
```

flexの場合と同じく、`%%`から`%%`までが構文規則の定義の本体です。実行されるコードが入っているので読みづらくなっていますが、それを除くと以下のようになります：

```text
% {
%token NUM
%token EOL
%left '+' '-'
%left '*' '/'
}

%%
input : expr EOL
      { printf("Result: %d\n", $1); }
      ;

expr : NUM
      | expr '+' expr
      | expr '-' expr
      | expr '*' expr
      | expr '/' expr
      | '(' expr ')'
      ;
%%
```

だいぶ見やすくなりましたね。入力を表す`input`規則は`expr EOL`からなります。`expr`は式を表す規則ですから、その後に改行が来れば`input`は終了となります。

次に、`expr`規則ですが、ここではyaccの優先順位を表現するための機能である`%left`を使ったため、優先順位のためだけに規則を作る必要がなくなっており、定義が簡潔になっています。ともあれ、こうして定義された文法定義ファイルをyaccに与えると`y.tab.c`というファイルを出力します。

flexとyaccが出力したファイルを結合して実行ファイルを作ると、次のような入力に対して：

```
1 + 2 * 3
2 + 3
6 / 2
3 / 0
```

それぞれ、次のような出力を返します。

```
Result: 7
Result: 5
Result: 3
Parse error: Cannot divide by zero.
```

yaccはとても古いソフトウェアの一つですが、Rubyの文法定義ファイルparse.yはyacc用ですし、未だに各種言語処理系では現役で使われてもいます。

## ANTLR：多言語対応の強力な下向き構文解析生成系

1989年にPurdue Compiler Construction set(PCCTS)というものがありました、ANTLRはその後継というべきもので、これまでに、LL(k) -> LL(*) -> ALL(*)と取り扱える文法の幅を広げつつアクティブに開発が続けられています。作者はTerence Parrという方ですが、構文解析器一筋（？）と言っていいくらい、ANTLRにこれまでの時間を費やしてきている人です。

それだけに、ANTLRの完成度は非常に高いものになっています。また、一時期はLR法に比べてLL法の評価は低いものでしたが、Terence ParrがLL(k)を改良していく過程で、LL(*)やALL(*)のようなLR法に比べてもなんら劣らない、しかも実用的にも使いやすい構文解析法の発明に貢献したということができます。

ANTLRはJava、C++などいくつもの言語を扱うことができますが、特に安心して使えるのはJavaです。以下は先程と同様の、四則演算を解析できる数式パーザをANTLRで書いた場合の例です。

ANTLRでは構文規則は、`規則名 : 本体 ;` という形で記述しますが、LLパーザ向けの構文定義を素直に書き下すだけでOKです。

```java
grammar Expression;

expression returns [int e]
    : v=additive {$e = $v.e;}
    ;

additive returns [int e = 0;]
    : l=multitive {$e = $l.e;} (
      '+' r=multitive {$e = $e + $r.e;}
    | '-' r=multitive {$e = $e - $r.e;}
    )*
    ;

multitive returns [int e = 0;]
    : l=primary {$e = $l.e;} (
      '*' r=primary {$e = $e * $r.e;}
    | '/' r=primary {$e = $e / $r.e;}
    )*
    ;

primary returns [int e]
    : n=NUMBER {$e = Integer.parseInt($n.getText());}
    | '(' x=expression ')' {$e = $x.e;}
    ;

LP : '(' ;
RP : ')' ;
NUMBER : INT ;
fragment INT :   '0' | [1-9] [0-9]* ; // no leading zeros
WS  :   [ \t\n\r]+ -> skip ;

```

規則`expression`が数式を表す規則です。そのあとに続く`returns [int e]`はこの規則を使って解析を行った場合に`int`型の値を返すことを意味しています。これまで見てきたように構文解析器をした後には抽象構文木をはじめとして何らかのデータ構造を返す必要があります。`returns ...`はそのために用意されている構文です。名前が全て大文字の規則はトークンを表しています。

数式を表す各規則についてはこれまで書いてきた構文解析器と同じ構造なので読むのに苦労はしないでしょう。

規則`WS`は空白文字を表すトークンですが、これは数式を解析する上では読み飛ばす必要があります。 `[ \t\n\r]+ -> skip`は

- スペース
- タブ文字
- 改行文字

のいずれかが出現した場合は読み飛ばすということを表現しています。

ANTLRは下向き型の構文解析が苦手とする左再帰もある程度扱うことができます。先程の定義ファイルでは繰り返しを使っていましたが、これを左再帰に直した以下の定義ファイルも全く同じ挙動をします。

```java
grammar LRExpression;

expression returns [int e]
    : v=additive {$e = $v.e;}
    ;

additive returns [int e]
    : l=additive op='+' r=multitive {$e = $l.e + $r.e;}
    | l=additive op='-' r=multitive {$e = $l.e - $r.e;}
    | v=multitive {$e = $v.e;}
    ;

multitive returns [int e]
    : l=multitive op='*' r=primary {$e = $l.e * $r.e;}
    | l=multitive op='/' r=primary {$e = $l.e / $r.e;}
    | v=primary {$e = $v.e;}
    ;

primary returns [int e]
    : n=NUMBER {$e = Integer.parseInt($n.getText());}
    | '(' x=expression ')' {$e = $x.e;}
    ;

LP : '(' ;
RP : ')' ;
NUMBER : INT ;
fragment INT :   '0' | [1-9] [0-9]* ; // no leading zeros
WS  :   [ \t\n\r]+ -> skip ;
```

左再帰を使うことでより簡単に文法を定義できることもあるので、あると嬉しい機能だと言えます。

さらに、ANTLRは`ALL(*)`というアルゴリズムを採用しているため、通常のLLパーザでは扱えないような文法定義も取り扱うことができます。以下の「最小XML」文法定義を見てみましょう。

```java
grammar PetitXML;
@parser::header {
    import static com.github.asciidwango.parser_book.ch5.PetitXML.*;
    import java.util.*;
}

root returns [Element e]
    : v=element {$e = $v.e;}
    ;

element returns [Element e]
    : ('<' begin=NAME '>' es=elements '</' end=NAME '>' {$begin.text.equals($end.text)}?
      {$e = new Element($begin.text, $es.es);})
    | ('<' name=NAME '/>' {$e = new Element($name.text);})
    ;

elements returns [List<Element> es]
    : { $es = new ArrayList<>();} (element {$es.add($element.e);})*
    ;

LT: '<';
GT: '>';
SLASH: '/';
NAME:  [a-zA-Z_][a-zA-Z0-9]* ;

WS  :   [ \t\n\r]+ -> skip ;
```

`PeitXML`の名の通り、属性やテキストなどは全く扱うことができず、`<a>`や`<a/>`、`<a><b></b></a>`といった要素のみを扱うことができます。規則`element`が重要です。

```java
element returns [Element e]
    : ('<' begin=NAME '>' es=elements '</' end=NAME '>' {
            $begin.text.equals($end.text)
       }?
      {$e = new Element($begin.text, $es.es);})
    | ('<' name=NAME '/>' {$e = new Element($name.text);})
    ;
```

ここで空要素（`<e/>`など）に分岐するか、子要素を持つ要素（`<a><b/></a>`など）に分岐するかを決定するには、`<`に加えて、任意の長さになり得るタグ名まだ先読みしなければいけません。通常のLLパーザでは何文字（何トークン）先読みしているのは予め決定されているのでこのような文法定義を取り扱うことはできません。しかし、ANTLRの`ALL(*)`アルゴリズムとその前身となる`LL(*)`アルゴリズムでは任意個の文字数を先読みして分岐を決定することができます。

ANTLRでは通常のLLパーザで文法を記述する上での大きな制約がないわけで、これは非常に強力です。理論的な意味での記述能力でも`ALL(*)`アルゴリズムは任意の決定的な文脈自由言語を取り扱うことができます。

また、`ALL(*)`アルゴリズム自体とは関係ありませんが、XMLのパーザを書くときには開きタグと閉じタグの名前が一致している必要があります。この条件を記述するために`PetitXML`では次のように記述されています。

```java 
'<' begin=NAME '>' es=elements '</' end=NAME '>' {
  $begin.text.equals($end.text)
}?
```

この中の`{$begin.text.equals($end.text)}?`という部分はsemantic predicate（意味的述語）と呼ばれ、プログラムとして書かれた条件式が真になるときにだけマッチします。この例では、開きタグの名前（`begin`）と閉じタグの名前（`end`）が一致しているかをJavaのコードで確認しています。semantic predicateのような機能はプログラミング言語をそのまま埋め込むという意味で、正直「あまり綺麗ではない」と思わなくもないですが、実用上はsemantic predicateを使いたくなる場面にしばしば遭遇します。

ANTLRはこういった実用上重要な痒いところにも手が届くように作られており、非常によくできた構文解析機生成系といえるでしょう。

## SComb

手前味噌ですが、拙作のパーザコンビネータである[SComb](https://github.com/kmizu/scomb)も紹介しておきます。これまで紹介してきたものはすべて構文解析器生成系です。つまり、独自の言語を用いて作りたい言語の文法を記述し、そこから**対象言語**（CであったりJavaであったり様々ですが）で書かれた構文解析器を生成するものだったわけですが、パーザコンビネータは少々違います。

パーザコンビネータでは対象言語のメソッドや関数、オブジェクトとして構文解析器を定義し、演算子やメソッドによって構文解析器を組み合わせることで構文解析器を組み立てていきます。「コンビネータ」という名前は「組み合わせる（combine）」から来ており、小さなパーサーを組み合わせて大きなパーサーを作るという意味です。パーザコンビネータではメソッドや関数、オブジェクトとして規則自体を記述するため、特別にプラグインを作らなくてもIDEによる支援が受けられることや、対象言語が静的型システムを持っていた場合、型チェックによる支援を受けられることがメリットとして挙げられます。

SCombで四則演算を解析できるプログラムを書くと以下のようになります。先程述べたようにSCombはパーザコンビネータであり、これ自体がScalaのプログラム（`object`宣言）でもあります。

```scala
object Calculator extends SCombinator {
  // root ::= E 
  def root: Parser[Int] = E

  // E ::= A
  def E: Parser[Int] = rule(A)

  // A ::= M ("+" M | "-" M)* 
  def A: Parser[Int] = rule(chainl(M) {
    $("+").map { op => (lhs: Int, rhs: Int) => lhs + rhs } |
    $("-").map { op => (lhs: Int, rhs: Int) => lhs - rhs }
  })

  // M ::= P ("*" P | "/" P)* 
  def M: Parser[Int] = rule(chainl(P) {
    $("*").map { op => (lhs: Int, rhs: Int) => lhs * rhs } |
    $("/").map { op => (lhs: Int, rhs: Int) => lhs / rhs }
  })

  // P ::= "(" E ")" | N
  def P: P[Int] = rule{
    (for {
      _ <- string("("); e <- E; _ <- string(")")} yield e) | N
  }
  
  // N ::= [0-9]+ 
  def N: P[Int] = rule(set('0'to'9').+.map{ digits => digits.mkString.toInt})

  def parse(input: String): Result[Int] = parse(root, input)
}
```

ScalaはJavaとは異なるプログラミング言語ですが、JVM上で動く言語なので、Javaユーザーの方でも比較的理解しやすいと思います。

各メソッドに対応するBNFによる規則をコメントとして付加してみましたが、BNFと比較しても簡潔に記述できているのがわかります。Scalaは記号をそのままメソッドとして記述できるなど、元々DSL（ドメイン特化言語）に向いている特徴を持った言語なのですが、その特徴を活用しています。`chainl`というメソッドについてだけは見慣れない読者の方は多そうですが、これは

```
// M ::= P ("+" P | "-" P)* 
```

のような二項演算を簡潔に記述するためのコンビネータ（メソッド）です。パーザコンビネータの別のメリットとして、BNF（あるいはPEG）に無いような演算子をこのように後付で導入できることも挙げられます。構文規則からの値（意味値）の取り出しもScalaのfor式（Javaのfor文とは異なり、値を生成する式です）を用いて簡潔に記述できています。

筆者は自作言語Klassicの処理系作成のためにSCombを使っていますが、かなり複雑な文法を記述できるにも関わらず、SCombのコア部分はわずか600行ほどです。それでいて高い拡張性や簡潔な記述が可能なのは、Scalaという言語の能力と、SCombがベースとして利用しているPEGという手法のシンプルさがあってのものだと言えるでしょう。

## パーザコンビネータJCombを自作しよう！

コンパイラについて解説した本は数えきれないほどありますし、その中で構文解析アルゴリズムについて説明した本も少なからずあります。しかし、構文解析アルゴリズムについてのみフォーカスした本はParsing Techniquesほぼ一冊といえる現状です。その上でパーザコンビネータの自作まで踏み込んだ書籍はほぼ皆無と言っていいでしょう。読者の方には「さすがにちょっとパーザコンビネータの自作は無理があるのでは」と思われた方もいるのではないでしょうか。

しかし、驚くべきことに、現代的な言語であればパーザコンビネータを自作するのは本当に簡単です。きっと、多くの読者の方々が拍子抜けしてしまうくらいに。この節ではJavaで書かれたパーザコンビネータJCombを自作する過程を通じて皆さんにパーザコンビネータとはどのようなものかを学んでいただきます。

パーザコンビネータと構文解析器生成系の関係は、次のように考えることができます：
- 構文解析器生成系：文法定義ファイル → ツール → Javaコード
- パーザコンビネータ：Javaコードで直接文法を表現

つまり、パーザコンビネータは「生成」のステップを省き、プログラミング言語の機能を活用して直接パーサーを組み立てる手法なのです。

まず復習になりますが、構文解析器というのは文字列を入力として受け取って、解析結果を返す関数（あるいはオブジェクト）とみなせるのでした。これはパーザコンビネータ、特にPEGを使ったパーザコンビネータを実装するときに有用な見方です。この「構文解析器はオブジェクトである」を文字通りとって、以下のようなジェネリックなインタフェース`JParser<R>`を定義します。

```java
interface JParser<R> {
  Result<R> parse(String input);
}
```

ここで構文解析器を表現するインタフェース`JParser<R>`は型パラメータ`R`を受け取ることに注意してください。Javaの型パラメータ（ジェネリクス）は、「このインタフェースは何かの型`R`に対して動作しますが、具体的な型は使用時に決まります」という意味です。一般に構文解析の結果は抽象構文木になりますが、インタフェースを定義する時点では抽象構文木がどのような形になるかはわかりようがないので、型パラメータにしておくのです。`JParser<R>`はたった一つのメソッド`parse()`を持ちます。`parse()`は入力文字列`input`を受け取り、解析結果を`Result<R>`として返します。

`JParser<R>`の実装は一体全体どのようなものになるの？という疑問を脇に置いておけば理解は難しくないでしょう。次に解析結果`Result<V>`をレコードとして定義します。

```java
record Result<V>(V value, String rest){}
```

レコード`Result<V>`は解析結果を保持するクラスです。`value`は解析結果の値を表現し、`rest`は解析した結果「残った」文字列を表します。たとえば、`"123abc"`という文字列から数値部分`"123"`を解析した場合、`value`は`123`（整数値）、`rest`は`"abc"`（残りの文字列）となります。

このインタフェース`JParser<R>`は次のように使えると理想的です。

```java
JParser<Integer> calculator = ...;
Result<Integer> result = calculator.parse("1+2*3");
assert 7 == result.value();
```

パーザコンビネータは、このようなどこか都合の良い`JParser<R>`を、BNF（あるいはPEG）に近い文法規則を連ねていくのに近い使い勝手で構築するための技法です。前の節で紹介した`SComb`もパーザコンビネータでしたが基本的には同じようなものです。

この節では最終的に上のような式を解析できるパーザコンビネータを作るのが目標です。

### 部品を考えよう

これからパーザコンビネータを作っていくわけですが、パーザコンビネータの基本となる「部品」を作る必要があります。

まず最初に、文字列リテラルを受け取ってそれを解析できる次のような`string()`メソッドは是非とも欲しいところです。

```java
assert new Result<String>("123", "").equals(string("123").parse("123"));
```

これはBNFで言えば文字列リテラルの表記に相当します。

次に、解析に成功したとしてその値を別の値に変換するための方法もほしいところです。たとえば、`123`という文字列を解析したとして、これは最終的に文字列ではなくintに変換したいところです。Javaのラムダ式（無名関数）を使えば、このような変換を簡潔に書けます。このようなメソッドは、ラムダ式で変換を定義できるように、次のような`map()`メソッドとして提供したいところです。

```java
<T, U> JParser<U> map(Parser<T> parser, Function<T, U> function);
assert (new Result<Integer>(123, "")).equals(
    map(string("123"), v -> Integer.parseInt(v)).parse("123")
);
```

これは構文解析器生成系でセマンティックアクションを書くのに相当すると言えるでしょう。つまり、単に文法をチェックするだけでなく、解析結果を使って何か計算をしたり、データ構造を構築したりする部分です。

BNFで`a | b`、つまり選択を書くのに相当するメソッドも必要です。これは次のような`alt()`メソッドとして提供します。

```java
<T> JParser<T> alt(JParser<T> p1, JParser<T> p2); // 引数名と型名を修正
assert (new Result<String>("bar", "")).equals(
    alt(string("foo"), string("bar")).parse("bar")
); // .parse() を追加
```

同様に、BNFで`a b`、つまり連接」を書くのに相当するメソッドも必要ですが、これは次のような`seq()`メソッドとして提供します。

```java
record Pair<A, B>(A a, B b){}
<A, B> JParser<Pair<A, B>> seq(JParser<A> p1, JParser<B> p2);
assert (new Result<>(new Pair<>("foo", "bar"), "")).equals(
    seq(string("foo"), string("bar")).parse("foobar")
);
```

最後に、BNFで`a*`、つまり0回以上の繰り返しに相当する`rep0()`メソッド

```java
<T> JParser<List<T>> rep0(JParser<T> p);
```

や`a+`、つまり1回以上の繰り返しに相当する`rep1()`メソッドもほしいところです。

```java
<T> JParser<List<T>> rep1(JParser<T> p);
assert (new Result<List<String>>(List.of("a", "a", "a"), "")).equals(
  rep1(string("a")).parse("aaa")
);
```

この節ではこれらのプリミティブなメソッドの実装方法について説明していきます。

### `string()`メソッド

まず最初に`string(String literal)`メソッドで返す`JParser<String>`の中身を作ってみましょう。`JParser`クラスはただ一つのメソッド`parser()`をもつので次のような実装になります。

```java
class JLiteralParser implements JParser<String> {
  private String literal;
  public JLiteralParser(String literal) {
    this.literal = literal;

  }
  public Result<String> parse(String input) {
    if(input.startsWith(literal)) {
      return new Result<String>(literal, input.substring(literal.length()));
    } else {
      return null;
    }
  }
}
```

このクラスは次のようにして使います。

```java
assert new Result<String>("foo", "").equals(new JLiteralParser("foo"));
```

リテラルを表すフィールド`literal`が`input`の先頭とマッチした場合、`literal`と残りの文字列からなる`Result<String>`を返します。そうでない場合は返すべき`Result`がないので`null`を返します。簡単ですね。

`startsWith`メソッドは、文字列がある文字列で始まるかを判定するJavaの標準メソッドです。`substring`メソッドは、文字列の一部を切り出すメソッドです。

あとはこのクラスのインスタンスを返す`string()`メソッドを作成するだけです。なお、使うときの利便性のため、以降では各種メソッドはクラス`JComb`のstaticメソッドとして実装していきます。

```java
public class JComb {
  JParser<String> string(String literal) {
    return new JLiteralParser(literal);
  }
}
```

使う時は次のようになります。

```java
JParser<String> foo = string("foo");
assert new Result<String>("foo", "_bar").equals(foo.parse("foo_bar"));
assert null == foo.parse("baz");
```

### `alt()`メソッド

次に二つのパーザを取って「選択」パーザを返すメソッド`alt()`を実装します。先程のようにクラスを実装してもいいですが、メソッドは一つだけなのでラムダ式（Java 8から導入された無名関数）にします。

```java
public class JComb {
    // p1 / p2 (PEGの順序付き選択に対応)
    public static <A> JParser<A> alt(JParser<A> p1, JParser<A> p2) {
        return (input) -> {
            var result = p1.parse(input);//(1) p1を試す
            if(result != null) return result;//(2) p1が成功したらその結果を返す
            return p2.parse(input);//(3) p1が失敗したらp2を試す
        };
    }
}
```

ラムダ式について復習しておくと、これは実質的には以下のような匿名クラスを書いたのと同じになります。

```java
public class JComb {
    public static <A> JParser<A> alt(JParser<A> p1, JParser<A> p2) {
        return new JAltParser<A>(p1, p2);
    }
}

class JAltParser<A> implements JParser<A> {
  private JParser<A> p1, p2;
  public JAltParser(JParser<A> p1, JParser<A> p2) {
    this.p1 = p1;
    this.p2 = p2;
  }
  public Result<A> parse(String input) {
    var result = p1.parse(input);
    if(result != null) return result;
    return p2.parse(input);
  }
}
```

この定義では、

(1) まずパーザ`p1`を試しています
(2) `p1`が成功した場合は`p2`を試すことなく値をそのまま返します
(3) `p1`が失敗した場合、`p2`を試しその値を返します

のような挙動をします。これはBNFの選択 `|` とは異なり、PEGの「順序付き選択 `/`」に対応します。BNFの選択は曖昧性を許容しますが、PEGの順序付き選択は最初の選択肢がマッチすればそれが採用され、バックトラックは発生しません（選択肢の内部でのバックトラックはあり得ます）。
実は今ここで作っているパーザコンビネータである`JComb`は（`SComb`と同様に）PEGをベースとしたパーザコンビネータだったのです。もちろん、PEGベースでないパーザコンビネータを作ることも出来るのですが実装がかなり複雑になってしまいます。PEGの挙動をそのままプログラミング言語に当てはめるのは非常に簡単であるため、今回はPEGを採用しましたが、もし興味があればBNFベース（文脈自由文法ベース）のパーザコンビネータも作ってみてください。

### `seq()`メソッド

次に二つのパーザを取って「連接」パーザを返すメソッド`seq()`を実装します。これはPEGの連接 `e1 e2` に対応します。先程と同じくラムダ式にしてみます。

```java
record Pair<A, B>(A a, B b){}
// p1 p2 (PEGの連接に対応)
public class JComb {
    public static <A, B> JParser<Pair<A, B>> seq(JParser<A> p1, JParser<B> p2) {
        return (input) -> {
            var result1 = p1.parse(input); //(1-1) p1を試す
            if(result1 == null) return null; //(1-2) p1が失敗したら全体も失敗
            var result2 = p2.parse(result1.rest()); //(2-1) p1の残り入力でp2を試す
            if(result2 == null) return null; //(2-2) p2が失敗したら全体も失敗
            // 両方成功したら、結果をペアにして返す
            return new Result<>(new Pair<A, B>(result1.value(), result2.value()), result2.rest());//(2-3)
        };
    }
}
```

先程の`alt()`メソッドと似通った実装ですが、p1が失敗したら全体が失敗する（nullを返す：(1-2)）のがポイントです。p1とp2の両方が成功した場合は、二つの値のペアを返しています（2-3）。

#### `rep0()`, `rep1()`メソッド

残りは0回以上の繰り返し（PEGの `p*`）を表す`rep0()`と1回以上の繰り返し（PEGの `p+`）を表す`rep1()`メソッドです。

まず、`rep0()`メソッドは次のようになります。

```java
public class JComb {
    public static <A> JParser<List<A>> rep0(JParser<A> p) {
        return (input) -> {
            var result = p.parse(input); // (1)
            if(result == null) return new Result<>(List.of(), input); // (2)
            var value = result.value();
            var rest = result.rest();
            var result2 = rep0(p).parse(rest); //(3)
            if(result2 == null) return new Result<>(List.of(value), rest);
            List<A> values = new ArrayList<>();
            values.add(value);
            values.addAll(result2.value());
            return new Result<>(values, result2.rest());
        };
    }
}
```

(1)でまずパーザ`p`を適用しています。ここで失敗した場合、0回の繰り返しにマッチしたことになるので、空リストからなる結果を返します（(2)）。そうでなければ、1回以上の繰り返しにマッチしたことになるので、繰り返し同じ処理をする必要がありますが、これは再帰呼出しによって簡単に実装できます（(3)）。シンプルな実装ですね。


`rep1(p)`は意味的には`seq(p, rep0(p))`なので、次のようにして実装を簡略化することができます。


```java 
public class JComb {
    public static <A> JParser<List<A>> rep1(JParser<A> p) {
        JParser<Pair<A, List<A>>> rep1Sugar = seq(p, rep0(p));
        return (input) -> {
            var result = rep1Sugar.parse(input);//(1)
            if(result == null) return null;//(2)
            var pairValue = result.value(); // resultから値を取得
            var values = new ArrayList<A>();
            values.add(pairValue.a()); // Pairの最初の要素
            values.addAll(pairValue.b()); // Pairの2番目の要素 (List)
            return new Result<>(values, result.rest()); //(3)
        };
    }
}
```

実質的な本体は(1)だけで、あとは結果の値が`Pair`なのを`List`に加工しているだけですね。

### `map()`メソッド

パーザを加工して別の値を生成するためのメソッド`map()`をに実装してみましょう。`map()`は`JParser<R>`のメソッドとして実装するとメソッドチェインが使えて便利なので、インタフェースの`default`メソッドとして実装します。


```java
interface JParser<R> {
    Result<R> parse(String input);

    default <T> JParser<T> map(Function<R, T> f) {
        return (input) -> {
            var result = this.parse(input);
            if (result == null) return null;
            return new Result<>(f.apply(result.value()), result.rest()); (1)
        };
    }
}
```

(1)で`f.apply(result.value())`として値を加工しているのがポイントです。

### `lazy()`メソッド

パーザを遅延評価するためのメソッド`lazy()`も導入します。Javaはデフォルトでは遅延評価（必要になるまで計算を遅らせる）を採用しない言語なので、再帰的な規則を記述するときにこのようなメソッドがないと無限に再帰してスタックオーバーフローを起こしてしまいます。

```java
public class JComb {
    public static <A> JParser<A> lazy(Supplier<JParser<A>> supplier) {
        return (input) -> supplier.get().parse(input);
    }
}
```

`lazy`メソッドの必要性について補足します。Javaは先行評価（関数が呼ばれたらすぐに評価）を行う言語であるため、再帰的な文法規則を直接メソッド呼び出しで表現しようとすると、パーサオブジェクトの構築時に無限再帰が発生し `StackOverflowError` となることがあります。例えば、算術式の文法で `expression` が `additive` を呼び出し、`additive` が `primary` を呼び出し、`primary` が括弧表現の中で再び `expression` を呼び出すような相互再帰構造を考えてみましょう。
```java
// JComb を使った算術式のパーサ定義（簡略版・lazyなしのイメージ）
// public static JParser<Integer> expression = additive(); // 仮に直接代入しようとすると...
// public static JParser<Integer> additive = primary();   // ここでprimaryがexpressionを...
// public static JParser<Integer> primary = alt(number, seq(string("("), expression(), string(")"))); // expressionが未初期化
```
上記のように単純にメソッド呼び出しでパーサを組み合わせようとすると、`expression` の初期化時に `additive` が必要になり、その `additive` の初期化に `primary` が、さらにその `primary` の初期化に `expression` が必要となり、循環参照によって初期化が終わらなくなります。

`lazy` は `Supplier<JParser<A>>` を引数に取ることで、実際の `JParser<A>` オブジェクトの取得（`supplier.get()`）を、そのパーサが実際に `parse()` メソッドで使われるときまで遅延させます。`Supplier`はJavaの関数型インタフェースで、「引数なしで値を返す関数」を表します。これにより、相互再帰するパーサ定義でも、オブジェクト構築時の無限再帰を避けることができます。算術式の例では、`expression` の定義内で `additive` を呼び出す部分を `lazy(() -> additive())` のように記述することで、この問題を解決します。

### `regex()`メソッド

せっかくなので正規表現を扱うメソッド`regex()`も導入してみましょう。

```java
public class JComb {
    public static JParser<String> regex(String regex) {
        return (input) -> {
            var matcher = Pattern.compile(regex).matcher(input);
            if(matcher.lookingAt()) {
                return new Result<>(
                    matcher.group(), input.substring(matcher.end())
                );
            } else {
                return null;
            }
        };
    }
}
```

引数として与えられた文字列を`Pattern.compile()`で正規表現に変換して、マッチングを行うだけです。`matcher.lookingAt()`は文字列の先頭から正規表現にマッチする部分があるかを確認するメソッドです。これは次のようにして使うことができます。

```java
var number = regex("[0-9]+").map(v -> Integer.parseInt(v));
assert (new Result<Integer>(10, "")).equals(number.parse("10"));
```

### 算術式のインタプリタを書いてみる

ここまでで作ったクラス`JComb`と`JParser`などを使っていよいよ簡単な算術式のインタプリタを書いてみましょう。仕様は次の通りです。

- 扱える数値は整数のみ
- 演算子は加減乗除（`+|-|*|/`）のみ
- `()`によるグルーピングができる

実装だけを提示すると次のようになります。

```java
public class Calculator {
    // expression は加減算を担当 (左結合)
    // PEG: expression <- multitive ( ( "+" / "-" ) multitive )*
    public static JParser<Integer> expression() {
        return seq( // multitive と (( "+" / "-" ) multitive )* の連接
                lazy(() -> multitive()), // 左辺の multitive (乗除の項)
                rep0( // 0回以上の繰り返し
                        seq( // ( "+" / "-" ) と multitive の連接
                                alt(string("+"), string("-")), // "+" または "-"
                                lazy(() -> multitive()) // 右辺の multitive
                        )
                )
        ).map(p -> { // 解析結果を処理するラムダ式
            var left = p.a(); // 初期値 (最初の項)
            var rights = p.b(); // 残りの演算子と項のペアのリスト
            for (var rightPair : rights) { // 各 Pair<String, Integer> について
                var op = rightPair.a(); // 演算子 ( "+" または "-" )
                var rightValue = rightPair.b(); // 項の値
                if (op.equals("+")) {
                    left += rightValue;
                } else { // op.equals("-")
                    left -= rightValue;
                }
            }
            return left; // 計算結果
        });
    }

    // multitive は乗除算を担当 (左結合)
    // PEG: multitive <- primary ( ( "*" / "/" ) primary )*
    public static JParser<Integer> multitive() {
        return seq( // primary と ( ( "*" / "/" ) primary )* の連接
                lazy(() -> primary()), // 左辺の primary
                rep0( // 0回以上の繰り返し
                        seq( // ( "*" / "/" ) と primary の連接
                                alt(string("*"), string("/")), // "*" または "/"
                                lazy(() -> primary()) // 右辺の primary
                        )
                )
        ).map(p -> { // 解析結果を処理するラムダ式
            var left = p.a(); // 初期値 (最初の因子)
            var rights = p.b(); // 残りの演算子と因子のペアのリスト
            for (var rightPair : rights) {
                var op = rightPair.a(); // 演算子 ( "*" または "/" )
                var rightValue = rightPair.b(); // 因子の値
                if (op.equals("*")) {
                    left *= rightValue;
                } else { // op.equals("/")
                    if (rightValue == 0) 
                        throw new ArithmeticException("Division by zero"); 
                    left /= rightValue;
                }
            }
            return left; // 計算結果
        });
    }

    // primary <- number / "(" expression ")"
    public static JParser<Integer> primary() {
        return alt( // number または "(" expression ")" の選択
                number, // 数値パーサ
                seq(
                    string("("), // 開き括弧
                    // 括弧内の式 (expressionを再帰呼び出し)
                    lazy(() -> expression()) 
                ).flatMap(p1 -> 
                    // p1 は Pair<String, Integer>型 ("(" と expressionの結果)
                    seq(
                        p1.b(), // expressionの結果 (Integer) を次のseqの左側にする
                        string(")")  // 閉じ括弧
                    // p2は Pair<Integer, String>型、その最初の要素(Integer)を返す
                    ).map(p2 -> p2.a()) 
                )
        );
    }
    
    // number <- [0-9]+ (PEGの正規表現リテラルに対応)
    private static JParser<Integer> number = 
        regex("[0-9]+").map(Integer::parseInt);
}
```

表記は冗長なもののほぼPEGに一対一に対応しているのがわかるのではないでしょうか？`expression`メソッドを例に、`map`内のラムダ式がどのように動作するかを見てみましょう。演算子の優先順位により「1+2*3」は`multitive`で乗算が先に処理されるため、ここでは左結合のロジックを説明するために「1+2-3」のような入力を想定します。

入力: "1+2-3"
1.  `lazy(() -> multitive())` が "1" を解析し、結果 `1` (Integer) を返します。これが `p.a()` になります。
2.  `rep0(...)` が `+2-3` の部分を解析します。
    *   最初の `seq(alt(string("+"), string("-")), lazy(() -> multitive()))` が `+2` を解析し、`Pair("+", 2)` を生成します。
    *   次の `seq(...)` が `-3` を解析し、`Pair("-", 3)` を生成します。
    *   結果として `p.b()` は `List [Pair("+", 2), Pair("-", 3)]` となります。
3.  `map` のラムダ式が実行されます。
    *   `left` は `p.a()` なので `1` で初期化されます。
    *   ループ1回目: `rightPair` は `Pair("+", 2)`。`op` は `"+"`, `rightValue` は `2`。`left` は `1 + 2 = 3` になります。
    *   ループ2回目: `rightPair` は `Pair("-", 3)`。`op` は `"-"`, `rightValue` は `3`。`left` は `3 - 3 = 0` になります。
    *   最終的に `0` が返されます。

これに対してJUnitを使って以下のようなテストコードを記述してみます。無事、意図通りに解釈されていることがわかります。

```java
assertEquals(
    new Result<>(7, ""), Calculator.expression().parse("1+2*3")
); // テストをパス (実際には multitive で処理される)
assertEquals(
    new Result<>(0, ""), Calculator.expression().parse("1+2-3")
); // テストをパス
```

DSL（ドメイン特化言語）に向いたScalaに比べれば冗長になったものの、手書きで再帰下降パーザを組み立てるのに比べると大幅に簡潔な記述を実現することができました。しかも、JComb全体を通しても500行にすら満たないのは特筆すべきところです。Javaがユーザ定義の中置演算子（`+`や`*`のような演算子を自分で定義できる機能）をサポートしていればもっと簡潔にできたのですが、そこは向き不向きといったところでしょうか。

### まとめ

パーザコンビネータを使うと、手書きでパーザを書いたり、あるいは、対象言語に構文解析器生成系がないようなケースでも、比較的気軽にパーザを組み立てるためのDSL（Domain Specific Language）を定義できるのです。また、それだけでなく、特にJavaのような静的型付き言語を使った場合ですが、IDEによる支援も受けられますし、BNFやPEGにはない便利な演算子を自分で導入することもできます。

パーザコンビネータはお手軽なだけあって各種プログラミング言語に実装されています。たとえば、Java用なら[jparsec](https://github.com/jparsec/jparsec)があります。しかし、筆者としては、パーザコンビネータが動作する仕組みを理解するために、是非とも**自分だけの**パーザコンビネータを実装してみてほしいと思います。
