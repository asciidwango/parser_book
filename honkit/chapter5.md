# 5. 構文解析器生成系の世界

　4章では現在知られている構文解析手法について、アイデアと提案手法の概要について説明しました。実は、構文解析の世界ではよく知られていることなのですが、4章で説明した各種構文解析手法は毎回プログラマが手で実装する必要はありません。

　というのは、CFGやPEG（その類似表記も含む）によって記述された文法定義から特定の構文解析アルゴリズムを用いた構文解析器を生成する構文解析器生成系というソフトウェアがあるからです。もちろん、それぞれの構文解析アルゴリズムや生成する構文解析器の言語ごとに別のソフトウェアを書く必要がありますが、ひとたびある構文解析アルゴリズムのための構文解析器生成系を誰かが書けば、その構文解析アルゴリズムを知らないプログラマでもその恩恵にあずかることができるのです。

　構文解析器生成系でもっとも代表的なものはyaccあるいはその互換実装であるGNU bisonでしょう。yaccはLALR(1)法を利用したCの構文解析器を生成してくれるソフトウェアであり、yaccを使えばプログラマはLALR(1)法の恩恵にあずかることができます。

　この章では構文解析器生成系という種類のソフトウェアの背後にあるアイデアからはじまり、LL(1)、LALR(1）、PEGのための構文解析器を作る方法や多種多様な構文解析器生成系についての紹介などを行います。

　また、この章の最後ではある意味構文解析生成系の一種とも言えるパーザコンビネータの実装方法について踏み込んで説明します。構文解析生成系はいったん対象となるプログラミング言語のソースコードを生成します。この時、対象言語のコードを部分的に埋め込む必要性が出てくるのですが、この「対象言語のコードを埋め込める必要がある」というのは結構曲者でして、実用上ほぼ必須だけど面倒くささと伴うので、構文解析系をお手軽に作るとは行かない部分があります。

　一方、パーザコンビネータであれば、いわゆる「ラムダ式」を持つほとんどのプログラミング言語で比較的簡単に実装できます。本書で利用しているJava言語でも同様です。というわけで、本章を読めば皆さんもパーザコンビネータを明日から自前で実装できるようになります。

## 5.1 Dyck言語の文法とPEGによる構文解析器生成

これまで何度も登場したDyck言語は明らかにLL(1)法でもLR(1)法でもPEGによっても解析可能な言語です。実際、4章ではDyck言語を解析する手書きのPEGパーザを書いたのでした。しかし、立ち戻ってよくよく考えてみると退屈な繰り返しコードが散見されたのに気づいた方も多いのではないでしょうか（4章に盛り込む予定）。

実際のところ、Dyck言語を表現する文法があって、構文解析アルゴリズムがPEGということまで分かれば対応するJavaコードを**機械的に生成する**ことも可能そうに見えます。特に、構文解析はコード量が多いわりには退屈な繰り返しコードが多いものですから、文法からJavaコードを生成できれば劇的に工数を削減できそうです。

このように「文法と構文解析手法が決まれば、後のコードは自動的に決定可能なはずだから、機械に任せてしまおう」という考え方が構文解析器生成系というソフトウェアの背後にあるアイデアです。

早速ですが、以下のようにDyck言語を表す文法が与えられたとして、PEGを使った構文解析器を生成する方法を考えてみましょう。

```bnf
D <- P;
P <- "(" P ")" | "()";
```

PEGでは非終端記号の呼び出しは関数呼び出しとみなすことができますから、まず次のようなコードになります。

```java
public boolean parseD() {
    return parseP();
}
public boolean parseP() {
    "(" P ")" | "()"
}
```

## 5.1 JSONの構文解析器を生成する

LL(1)構文解析器生成系で、JSONのパーザが作れることを示す。これを通じて、構文解析器生成系が実用的に使えることを理解してもらう。

## 5.2 構文解析器生成系の分類

構文解析器生成系は1970年代頃から研究の蓄積があり、数多くの構文解析生成系がこれまで開発されています。基本的には構文解析器生成系と採用しているアルゴリズムは対応するので、たとえば、JavaCCはLL(1)構文解析器を出力するため、LL(1)構文解析器生成系であると言ったりします。

同様に、yacc(bison)はLALR(1)構文解析器生成系を出力するので、LALR(1)構文解析器生成系であると言ったりもします。ただし、例外もあります。bisonはyaccと違って、LALR(1)より広いGLR構文解析器を生成できるので、GLR構文解析器生成系であるとも言えるのです。実際には、yaccを使う場合、ほとんどはLALR(1)構文解析器を出力するので、GLRについては言及されることは少ないですが、そのようなことは知っておいても損はないでしょう。

より大きなくくりでみると、下向き構文解析（LL法やPEG）と上向き構文解析（LR法など）という観点から分類することもできますし、ともに文脈自由文法ベースであるLL法やLR法と、解析表現文法など他の形式言語を用いた構文解析法を対比してみせることもできます。

## 5.3 JavaCC：Javaの構文解析生成系の定番

1996年、Sun Microsystems（当時）は、Jackという構文解析器生成系をリリースしました。その後、Jackの作者が自らの会社を立ち上げ、JackはJavaCCに改名されて広く知られることとなりましたが、現在では紆余曲折の末、[javacc.github.io](https://javacc.github.io/javacc)の元で開発およびメンテナンスが行われています。現在のライセンスは3条項BSDライセンスです。

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
o
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
    r=primary() ( <MULTIPLY> v=primary() { r *= v; }| <DIVIDE> r=primary() { r /= v; })* {
        return r;
    }
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

の部分はトークン定義になります。ここでは、7つのトークンを定義しています。トークン定義の後が構文規則の定義になります。ここでは、

- `expression()`
- `add()`
- `mult()`
- `primary()`

の4つの構文規則が定義されています。各構文規則はJavaのメソッドに酷似した形で記述されますが、実際、ここから生成される.javaファイルには同じ名前のメソッドが定義されます。`expression()`が`add()`を呼び出して、`add()`が`mult()`を呼び出して、`mult()`が`primary()`を呼び出すという構図は第2章で既にみた形ですが、第2章と違って単純に宣言的に各構文規則の関係を書けばそれでOKなのが構文解析器生成系の強みです。

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
        Calculator calculator = new Calculator(new StringReader("1 + 2 * 3"));
        assertEquals(7, calculator.expression());
    }

    @Test
    @Description("(1 + 2) * 4 = 12")
    public void test2() throws Exception {
        Calculator calculator = new Calculator(new StringReader("(1 + 2) * 4"));
        assertEquals(12, calculator.expression());
    }

    @Test
    @Description("(5 * 6) - (3 + 4) = 23")
    public void test3() throws Exception {
        Calculator calculator = new Calculator(new StringReader("(5 * 6) - (3 + 4)"));
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

ここでは、`LOOKAHEAD = 2`というオプションによって、先読みトークン数を2に増やしています。LOOKAHEADは固定されていれば任意の正の整数にできるので、JavaCCはデフォルトではLL(1)だが、オプションを設定することによってLL(k)になるともいえます。

また、JavaCCは構文定義ファイルの文法がかなりJavaに似ているため、生成されるコードの形を想像しやすいというメリットがあります。JavaCCはJavaの構文解析生成系の中では最古の部類の割に今でも現役で使われているのは、Javaユーザにとっての使いやすさが背景にあるように思います。


## 5.4 Yacc (GNU Bison)：構文解析器生成系の老舗

YaccはYet another compiler compilerの略で、日本語にすると「もう一つのコンパイラコンパイラ」といったところでしょうか。yaccができた当時は、コンパイラを作るためのコンパイラについての研究が盛んだった時期で、構文解析器生成系もそのための研究の副産物とも言えます。1970年代にAT&Tのベル研究所にいたStephen C. Johnsonによって作られたソフトウェアで、非常に歴史がある構文解析器生成系です。YaccはLALR(1)法をサポートし、lexという字句解析器生成系と連携することで構文解析器を生成することができます（もちろん、lexを使わない実装も可能）。Yacc自体は色々な構文解析器生成系に多大な影響を与えており、現在使われているGNU BisonはYaccのGNUによる再実装でもあります。

Yaccを使って、四則演算を行う電卓プログラムを作るにはまず字句解析器生成系であるflex用の定義ファイルを書く必要ががあります。その定義ファイル`token.l`は次のようになります：

```lex
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

```yacc
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

```yacc
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

## 5.5 ANTLR：多言語対応の強力なトップダウン構文解析生成系

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

ANTLRはトップダウン型の構文解析が苦手とする左再帰もある程度扱うことができます。先程の定義ファイルでは繰り返しを使っていましたが、これを左再帰に直した以下の定義ファイルも全く同じ挙動をします。

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

```
element returns [Element e]
    : ('<' begin=NAME '>' es=elements '</' end=NAME '>' {$begin.text.equals($end.text)}?
      {$e = new Element($begin.text, $es.es);})
    | ('<' name=NAME '/>' {$e = new Element($name.text);})
    ;
```

ここで空要素（`<e/>`など）に分岐するか、子要素を持つ要素（`<a><b/></a>`など）に分岐するかを決定するには、`<`に加えて、任意の長さになり得るタグ名まだ先読みしなければいけません。通常のLLパーザでは何文字（何トークン）先読みしているのは予め決定されているのでこのような文法定義を取り扱うことはできません。しかし、ANTLRの`ALL(*)`アルゴリズムとその前身となる`LL(*)`アルゴリズムでは任意個の文字数を先読みして分岐を決定することができます。

ANTLRでは通常のLLパーザで文法を記述する上での大きな制約がないわけで、これは非常に強力です。理論的な意味での記述能力でも`ALL(*)`アルゴリズムは任意の決定的な文脈自由言語を取り扱うことができます。

また、`ALL(*)`アルゴリズム自体とは関係ありませんが、XMLのパーザを書くときには開きタグと閉じタグの名前が一致している必要があります。この条件を記述するために`PetitXML`では次のように記述されています。

```java 
'<' begin=NAME '>' es=elements '</' end=NAME '>' {$begin.text.equals($end.text)}?
```

この中の`{$begin.text.equals($end.text)}?`という部分はsemantic predicateと呼ばれ、プログラムとして書かれた条件式が真になるときにだけマッチします。semantic predicateのような機能はプログラミング言語をそのまま埋め込むという意味で、正直「あまり綺麗ではない」と思わなくもないですが、実用上はsemantic predicateを使いたくなる場面にしばしば遭遇します。

ANTLRはこういった実用上重要な痒いところにも手が届くように作られており、非常によくできた構文解析機生成系といえるでしょう。

## 5.6 SComb

手前味噌ですが、拙作のパーザコンビネータである[SComb](https://github.com/kmizu/scomb)も紹介しておきます。これまで紹介してきたものは構文解析器生成系であって、独自の言語を用いて文法を記述し、そこから何かしらの言語（CであったりJavaであったり）で書かれた構文解析器を生成するものだったわけですが、パーザコンビネータは少々趣が違います。

パーザコンビネータではその言語の関数やオブジェクトとして構文解析器を定義し、演算子やメソッドによって構文解析器を組み合わせることで構文解析器を組み立てていきます。パーザコンビネータではメソッドや関数として文法規則自体を記述するため、特別にプラグインなどを作らなくてもIDEによる支援が受けられることや、対象言語が静的型システムを持っていた場合、型チェックによる支援を受けられることなどがメリットとして挙げられます。

SCombで四則演算を解析できるプログラムを書くと以下のようになります。

```scala
object Calculator extends SCombinator {
  def root: Parser[Int] = expression

  def expression: Parser[Int] = rule(A)

  def A: Parser[Int] = rule(chainl(M) {
    $("+").map { op => (lhs: Int, rhs: Int) => lhs + rhs } |
    $("-").map { op => (lhs: Int, rhs: Int) => lhs - rhs }
  })

  def M: Parser[Int] = rule(chainl(P) {
    $("*").map { op => (lhs: Int, rhs: Int) => lhs * rhs } |
    $("/").map { op => (lhs: Int, rhs: Int) => lhs / rhs }
  })

  def P: P[Int] = rule{
    (for {
      _ <- string("("); e <- expression; _ <- string(")")} yield e) | number
  }
  
  def number: P[Int] = rule(set('0'to'9').+.map{ digits => digits.mkString.toInt})

  def parse(input: String): Result[Int] = parse(root, input)
}
```

Scalaは元々DSLの記述に向いている言語なのですが、そのパワーを使ってかなり簡潔に記述できています。`chainl`というメソッドについては見慣れない読者の方も多いかともいますが、パーザコンビネータの世界では比較的よく使われる演算子で、特に二項演算を簡潔に記述するのに使われます。

また、for式を用いて、必要な部分だけ値を取り出して計算を行っています。

筆者は自作言語Klassicの処理系作成のためなどにSCombを使っていますが、かなり複雑な文法を記述できるにも関わらず、SCombのコア部分はわずか600行ほどです。それでいて高い拡張性や簡潔な記述が可能なのは、Scalaという言語の能力とPEGという手法のシンプルさがあってのものだと言えるでしょう。

## 5.7 パーザコンビネータJCombを自作しよう！

コンパイラについて解説した本は数えきれないほどありますし、その一環として構文解析アルゴリズムについて説明した本も少なからずあります。しかし、構文解析アルゴリズムについてのみフォーカスした本はParsing Techniquesほぼ一冊といえる現状です。その上でパーザコンビネータの自作まで踏み込んだ書籍はほぼ皆無と言っていいでしょう。読者の方には「さすがにちょっとそれは無理では」と思われた方もいるのではないでしょうか。

しかし、現代的な言語であればパーザコンビネータを自作するのは本当に驚くほど簡単です。おそらく多くの読者の方々が拍子抜けしてしまうくらいに。というわけでこの章ではJavaで書かれたパーザコンビネータJCombを自作する過程を通じて皆さんにパーザコンビネータとはどのようなものかを学んでいただきます。パーザコンビネータと構文解析器生成系は物凄く雑に言ってしまえば近縁種のようなものですし、パーザコンビネータの理解は構文解析器生成系の仕組みの理解にも役立つはずです。きっと。

復習になりますが、構文解析器というのは文字列を入力として受け取って、解析結果を返す関数（あるいはメソッド）とみなせるのでした。これは特にPEGパーザを実装するときに有用な見方です。これをそのまま以下のようなインタフェースとしてまずは定義していまいます。

```java
interface JParser<R> {
  Result<R> void parse(String input);
}
record Result<V>(V value, String rest){}
```

ここで構文解析器を表現するインタフェース`JParser<R>`は型パラメータ`R`を受け取ることに注意してください。一般に構文解析の結果は抽象構文木になりますが、インタフェースを定義する時点では抽象構文木がどのような形になるかはわかりようがないので、型パラメータにしておくのです。

レコードクラス`Result<V>`は解析結果を保持するクラスです。`value`は先程の型パラメータ`R`として表現されていた型の値に相当し、`rest`は解析した結果「残った」文字列を表します。

インタフェースの実装がどうなるかはおいておき、次のように使えるといいですね。

```java
JParser<Integer> calculator = ...;
Result<Integer> result = calculator.parse("1+2*3");
assert 7 == result.value();
```

パーザコンビネータというのはまさにこのようなどこか都合の良い`JParser<R>`を、文法規則を連ねていくのに近い使い勝手で構築するための技法です。前の節で紹介したSCombもパーザコンビネータでしたが基本的には同じようなものです。

### 5.7.1 プリミティブなパーザを作ろう！

最終的には先程のような算術式を解析できるようなパーザコンビネータが作れるようになるのが目標ですが、その前にパーザコンビネータの基本となる「部品」を作る必要があります。特に、

- 引数として文字列を受け取って、その文字列を解析できるパーザを返す`string()`メソッド
  -  `JParser<String> string(String literal);`
- パーザを受け取って、`Result<T>`を別の型`Result<U>`に変換する`map()`メソッド
  - `<T, U> JParser<U> map(Parser<T> parser, Function<T, U> function);`
- 二つのパーザを受け取って「選択」パーザを返す`alt()`メソッド
  - `<T> JParser<T> alt(Parser<T> p1, Parser<T> p1);`
- 二つのパーザを受け取って「連接」パーザを返す`seq()`メソッド
  - `<T> JParser<T> seq(Parser<T> p1, Parser<T> p2);`
- パーザを受け取って「繰り返し」パーザを返す`rep()`メソッド
  - `<T> JParser<T> rep(Parser<T> p);`

は是非ほしいところです。

#### 5.7.1.1 `string()`メソッド

まず最初に`string()`メソッドで返す`JParser<String>`の中身を作ってみましょう。中身は以下のクラスのようになります。

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

リテラルを表すフィールド`literal`が`input`の先頭とマッチした場合、`Result<String>`を返します。そうでない場合は返すべき`Result`がないので`null`を返します。簡単ですね。あとはこのクラスのインスタンスを返す`string()`メソッドを作成するだけです。

```java
JParser<String> string(String literal) {
  return new JLiteralParser(literal);
}
```

使う時は次のようになります。

```java
JParser<String> foo = string("foo_bar");
foo.parse("foo"); // Result<String>("foo", "_bar")
foo.parse("baz"); // null
```

#### 5.7.1.2 `alt()`メソッド

次に二つのパーザを取って「選択」パーザを返すメソッド`alt()`を実装します。先程のようにクラスを実装してもいいですが、メソッドは一つだけなのでラムダ式にしてみます。

```java
// p1 / p2
    public static <A> JParser<A> alt(JParser<A> p1, JParser<A> p2) {
        return (input) -> {
            var result = p1.parse(input);
            if(result != null) return result;
            return p2.parse(input);
        };
    }
```

これは実質的には以下のような匿名クラスを書いたのと同じになります。

```java
    public static <A> JParser<A> alt(JParser<A> p1, JParser<A> p2) {
        return new JAltParser<A>(p1, p2);
    }

class JAltParser<A> implements JParser<A> {
  private JParser<A> p1, p2;;
  public JAltParser(Parser<A> p1, Parser<A> p2) {
    this.p1 = p1;
    this.p2 = p2;
  }
  public Result<String> parse(String input) {
    var result = p1.parse(input);
    if(result != null) return result;
    return p2.parse(input);
  }
}
```

PEGの`/`の定義を思い出して欲しいのですが、最初に試したパーザが失敗したときのみ次のパーザを試すのでした。ですから、このシンプルな定義でうまく行くのです。

#### 5.7.1.3 `seq()`メソッド

次に二つのパーザを取って「連接」パーザを返すメソッド`seq()`を実装します。先程と同じくラムダ式にしてみます。

```java
record Pair<A, B>(A a, B b){}
// p1 p2
    public static <A, B> JParser<Pair<A, B>> seq(JParser<A> p1, JParser<B> p2) {
        return (input) -> {
            var result1 = p1.parse(input);
            if(result1 == null) return null;
            var rest = result1.rest();
            var result2 = p2.parse(rest);
            if(result2 == null) return null;
            return new Result<>(new Pair<A, B>(result1.value(), result2.value()), result2.rest());
        };
    }
```

先程の`alt()`メソッドと似通った実装ですが、p1が失敗したら全体が失敗する（nullを返す）のがポイントですね。p1とp2の両方が成功した場合は、二つの値のペアを返しています。二つの値のペアはレコード型を使ってシンプルに`record Pair<A, B>(...){}`として実装しました。

#### 5.7.1.4 `rep0()`, `rep1()`メソッド

PEGでパーザを組み立てるのに必要な基本要素はここまでで既に実装しましたが、シンタックスシュガーとしての繰り返し（`p*`, `p+`）も使い勝手の上で重要なので実装します。`p*`は`rep0()`メソッド、`p+`は`rep1()`メソッドとして実装します。

まず、`rep0()`メソッドは次のようになります。

```java
    public static <A> JParser<List<A>> rep0(JParser<A> p) {
        return (input) -> {
            var result = p.parse(input);
            if(result == null) return new Result<>(List.of(), input);
            var value = result.value();
            var rest = result.rest();
            var result2 = rep0(p).parse(rest);
            if(result2 == null) return new Result<>(List.of(value), rest);
            List<A> values = new ArrayList<>();
            values.add(value);
            values.addAll(result2.value());
            return new Result<>(values, result2.rest());
        };
    }
```

パーザpを適用して、失敗した場合空リストからなる結果を返し、そうでなければ自身を再帰的に呼び出す。シンプルな実装ですね。同様にして`rep1()`も実装することができます。


```java 
    public static <A> JParser<List<A>> rep1(JParser<A> p) {
        return (input) -> {
            var result = p.parse(input);
            if(result == null) return null;
            var value = result.value();
            var rest = result.rest();
            var result2 = rep0(p).parse(rest);
            if(result2 == null) return new Result<>(List.of(value), rest);
            List<A> values = new ArrayList<>();
            values.add(value);
            values.addAll(result2.value());
            return new Result<>(values, result2.rest());
        };
    }
```

あとは、既に作られたパーザを加工して別の値を生成するためのメソッド`map()`を`JParser`に実装してみましょう。インタフェースの`default`メソッドが使えます。


```java
interface JParser<R> {
    Result<R> parse(String input);

    default <T> JParser<T> map(Function<R, T> f) {
        return (input) -> {
            var result = this.parse(input);
            if (result == null) return null;
            return new Result<>(f.apply(result.value()), result.rest());
        };
    }
}
```

パーザを遅延評価するためのメソッド`lazy()`も導入します。後述するサンプルで必要になります。

```java
 public static <A> JParser<A> lazy(Supplier<JParser<A>> supplier) {
        return (input) -> supplier.get().parse(input);
    }
```

ここまでで最低限の部品は出揃ったのですが、せっかくなので正規表現を扱えるようなメソッド`regex()`も導入してみましょう。

```java
    public static JParser<String> regex(String regex) {
        return (input) -> {
            var matcher = Pattern.compile(regex).matcher(input);
            if(matcher.lookingAt()) {
                return new Result<>(matcher.group(), input.substring(matcher.end()));
            } else {
                return null;
            }
        };
    }
```

引数として与えられた文字列を`Pattern.compile()`で正規表現に変換して、マッチングを行うだけです。これで後でパーザコンビネータで
`regex("[0-9]+)`のような表現を使えるようになります。

さて、ここまでで作ったパーザコンビネータ`JComb`を使っていよいよ簡単な算術式のインタプリタを書いてみましょう。仕様は次の通りです。

- 扱える数値は整数のみ
- 演算子は加減乗除（`+|-|*|/`）のみ
- `()`によるグルーピングができる

まず実装だけを提示すると次のようになります。

```java
   public JParser<Integer> expression() {
        /*
         * expression <- additive ( ("+" / "-") additive )*
         */
        return seq(
                lazy(() -> additive()),
                rep0(
                        seq(
                                alt(string("+"), string("-")),
                                lazy(() -> additive())
                        )
                )
        ).map(p -> {
            var left = p.a();
            var rights = p.b();
            for (var right : rights) {
                var op = right.a();
                var rightValue = right.b();
                if (op.equals("+")) {
                    left += rightValue;
                } else {
                    left -= rightValue;
                }
            }
            return left;
        });
    }

    public JParser<Integer> additive() {
        /*
         * additive <- primary ( ("*" / "/") primary )*
         */
        return seq(
                lazy(() -> primary()),
                rep0(
                        seq(
                                alt(string("*"), string("/")),
                                lazy(() -> primary())
                        )
                )
        ).map(p -> {
            var left = p.a();
            var rights = p.b();
            for (var right : rights) {
                var op = right.a();
                var rightValue = right.b();
                if (op.equals("*")) {
                    left *= rightValue;
                } else {
                    left /= rightValue;
                }
            }
            return left;
        });
    }

    public JParser<Integer> primary() {
        /*
         * primary <- number / "(" expression ")"
         */
        return alt(
                number,
                seq(
                        string("("),
                        seq(
                            lazy(() -> expression()),
                            string(")")
                        )
                ).map(p -> p.b().a())
        );
    }
    
    // number <- [0-9]+
    JParser<Integer> number = regex("[0-9]+").map(Integer::parseInt);
```

コメントに対応するPEGを付加してありますが、表記は冗長なもののほぼPEGに一対一に対応しているのがわかるのではないでしょうか？

TODO：解説を色々と

このように、パーザコンビネータを使うと、パーザジェネレータを作るには割に合わないケースでも気軽にパーザを組み立てるだめのDSL（Domain Specific Language）を定義できるのです。