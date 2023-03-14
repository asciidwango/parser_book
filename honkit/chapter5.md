# 5. 構文解析器生成系の世界

　4章では現在知られている構文解析手法について、アイデアと提案手法の概要について説明しました。実は、構文解析の世界ではよく知られていることなのですが、4章で説明した各種構文解析手法は毎回プログラマが手で実装する必要はありません。

　というのは、CFGやPEG（その類似表記も含む）によって記述された文法定義から特定の構文解析アルゴリズムを用いた構文解析器を生成する構文解析器生成系というソフトウェアがあるからです。もちろん、それぞれの構文解析アルゴリズムや生成する構文解析器の言語ごとに別のソフトウェアを書く必要がありますが、ひとたびある構文解析アルゴリズムのための構文解析器生成系を誰かが書けば、その構文解析アルゴリズムを知らないプログラマでもその恩恵にあずかることができるのです。

　構文解析器生成系でもっとも代表的なものはyaccあるいはその互換実装であるGNU bisonでしょう。yaccはLALR(1)法を利用したCの構文解析器を生成してくれるソフトウェアであり、yaccを使えばプログラマはLALR(1)法の恩恵にあずかることができます。

　この章では構文解析器生成系という種類のソフトウェアの背後にあるアイデアからはじまり、LL(1)、LALR(1）、PEGのための構文解析器を作る方法や多種多様な構文解析器生成系についての紹介などを行います。

　構文解析器生成系の実装方法についてもある程度踏み込んで説明します。本章を読むことで、読者の方も自前で構文解析器生成系を実装できるようになるでしょう。

（高すぎる目標かもしれない）

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

## 5.1 JSONの構文解析器を生成する

LL(1)構文解析器生成系で、JSONのパーザが作れることを示す。これを通じて、構文解析器生成系が実用的に使えることを理解してもらう。

## 5.2 構文解析器生成系の分類

構文解析器生成系は1970年代頃から研究の蓄積があり、数多くの構文解析生成系がこれまで開発されています。基本的には構文解析器生成系と採用しているアルゴリズムは対応するので、たとえば、JavaCCはLL(1)構文解析器を出力するため、LL(1)構文解析器生成系であると言ったりします。

同様に、yacc(bison)はLALR(1)構文解析器生成系を出力するので、LALR(1)構文解析器生成系であると言ったりもします。ただし、例外もあります。bisonはyaccと違って、LALR(1)より広いGLR構文解析器を生成できるので、GLR構文解析器生成系であるとも言えるのです。実際には、yaccを使う場合、ほとんどはLALR(1)構文解析器を出力するので、GLRについては言及されることは少ないですが、そのようなことは知っておいても損はないでしょう。

より大きなくくりでみると、下向き構文解析（LL法やPEG）と上向き構文解析（LR法など）という観点から分類することもできますし、ともに文脈自由文法ベースであるLL法やLR法と、解析表現文法など他の形式言語を用いた構文解析法を対比してみせることもできます。

## 5.3 JavaCC

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

## 5.4 ANTLR

1989年にPurdue Compiler Construction set(PCCTS)というものがありました、ANTLRはその後継というべきもので、これまでに、LL(k) -> LL(*) -> ALL(*)と取り扱える文法の幅を広げつつアクティブに開発が続けられています。作者はTerence Parrという方ですが、構文解析器一筋（？）と言っていいくらい、ANTLRにこれまでの時間を費やしてきている人です。

それだけに、ANTLRの完成度は非常に高いものになっています。また、一時期はLR法に比べてLL法の評価は低いものでしたが、Terence ParrがLL(k)を改良していく過程で、LL(*)やALL(*)のようなLR法に比べてもなんら劣らない、しかも実用的にも使いやすい構文解析法の発明に貢献したということができます。

ANTLRはJava、C++などいくつもの言語を扱うことができますが、特に安心して使えるのはJavaです。以下は先程と同様の、四則演算を解析できる数式パーザをANTLRで書いた場合の例です。

## 5.5 Yacc (GNU Bison)

YaccはYet another compiler compilerの略で、日本語にすると「もう一つのコンパイラコンパイラ」といったところでしょうか。yaccができた当時は、コンパイラを作るためのコンパイラについての研究が盛んだった時期で、構文解析器生成系もそのための研究の副産物とも言えます。1970年代にAT&Tのベル研究所にいたStephen C. Johnsonによって作られたソフトウェアで、非常に歴史がある構文解析器生成系です。YaccはLALR(1)法をサポートし、lexという字句解析器生成系と連携することで構文解析器を生成することができます（もちろん、lexを使わない実装も可能）。Yacc自体は色々な構文解析器生成系に多大な影響を与えており、現在使われているGNU BisonはYaccのGNUによる再実装でもあります。

## 5.6 Coco/R

Coco/Rは少々マイナーですが、一つの構文解析器生成系で多くのプログラミング言語に対応しているという点で珍しい構文解析器生成系です。