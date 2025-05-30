# 第4章 文脈自由文法の世界

第3章では、JSONの構文解析器を記述することを通して、構文解析のやり方を学びました。構文解析器についても、PEG型の構文解析器および字句解析器を使った2通りを作ってみることで、構文解析器といっても色々な書き方があるのがわかってもらえたのではないかと思います。

この第4章では、現代の構文解析を語る上で必須である、文脈自由文法という概念について学ぶことにします。「文脈自由文法」というと、一見、堅くて難しそうな印象を持つ方も多いかもしれません。しかし、一言で言ってしまえば、BNFをよりシンプルに、数学的に厳密にしただけのものであって、厳しい言葉から漂う程難解な概念ではありません。一方で、「文脈自由文法」という概念を習得することによるメリットは計り知れないものがあります。たとえば、それによって、正規表現で記述出来ないが文脈自由言語（BNFと表現力では等価）で記述出来る「言語」を知ることが出来ますし、文脈自由言語では記述不可能な「言語」について知ることも出来ます。

さて、文脈自由文法の世界に飛び込んで見ましょう。

## 4.1 BNFと文脈自由文法

文脈自由文法の定義を大上段に示すと抽象的過ぎますので、皆様に馴染みがあるBNFを文脈自由文法を用いた記述に変換することで、文脈自由文法についての理解のとっかかりとしたいと思います。お題は、「カッコの釣り合いがとれた文字列が任意個続いたもの」です。

たとえば、

```
()
(())
(()())
()()()
```

は釣り合いの取れた文字列の例です。一方で、

```
)(
(()
())
```

は釣り合いの取れていない文字列の例です。このような言語をDyck言語（ディック言語）と呼び、文脈自由文法を特徴づける言語とされています。

Dyck言語の文法をBNFで記述してみると以下のようになります。

```text
D = P;
P = "(" P ")" P | ""; // これが正しいDyck言語のBNFの一例
```

`D`が構文解析の際に最初に参照される記号（開始記号）です。このBNFを文脈自由文法による記述に直していきましょう。

最初に、外側にある"|"を消去します。結果として以下のようになります。

```text
D = P;
P = "(" P ")" P;
P =  "";
```

同じ名前`P`を持つ記号が二つ出てきてしまいましたね。文脈自由文法の標準的な表記法では、同じ名前の規則が複数出てきても構いません。その場合の解釈は、BNFで同名の規則を"|"でくくった場合とほぼ同じです。

次に"="を"→"に置き換えます。

```text
D → P
P → "(" P ")" P
P → ""
```

空文字列は`ε`で表現されるのでこれも置き換えます。

```text
D → P
P → "(" P ")" P
P → ε
```

文字を表すときの`"`も使わないのでこれも消去します。

```
D → P
P → ( P ) P
P → ε
```

このようにして変換して出来た文脈自由文法ですが、この中で、

`D → P`

のような、`→`で区切られた右と左をあわせたものを**生成規則**と呼びます。DやPを**非終端記号**と呼び、(は**終端記号**と呼びます。このようにして見ていくと、文脈自由文法とは、

- 生成規則の1個以上の並び

からなっており、生成規則は、

- 左辺：1個の非終端記号
- 右辺：0個以上の終端記号または非終端記号の並び（空文字列εも含む）

からなっていることがわかります。改めて、Dyck言語のBNFによる表現と文脈自由文法による表現を見てみることにします。

まず、BNFによる表現です。（ここでのPの右辺は、先の例と同じく `P = "(" P ")" P | ""` とします）

```text
D = P;
P = "(" P ")" P | "";
```

次に、文脈自由文法で表現したものです。

```
D → P
P → ( P ) P
P → ε
```

多少冗長になりましたが、大きくは変わらないことがわかると思います。実質的に、BNFは文脈自由文法の表記法の1つとも言えますから、本質的に両者の能力に差はありません。

何故、BNFでなく文脈自由文法の標準的な表記法に変換するかといえば、5章以降で示す種々の構文解析アルゴリズムの多くが、文脈自由文法の標準的な表記法をベースに構築されているからです。

構文解析を語る上で欠かせない、構文木という概念を説明するためにも、文脈自由文法という概念は重要になります。以降の節では、Dyck言語を表現した文脈自由文法を元に、構文解析の基礎をなす様々な概念について説明していきます。

## 4.2 文脈自由文法と言語

前の節で定義したDyckの定義は以下のようなものでした。

```
D → P
P → ( P ) P
P → ε
```

これまでは「言語」という用語を明確な定義なしに使っていました。「言語」という言葉を一般的な文脈で使ったときに多くの人が思い浮かべるのは、日本語や英語、フランス語、などの**自然言語**でしょう。

しかし、この書籍で扱う**言語**は、プログラミング言語のような**曖昧さ**を持たないものです。たとえば、JavaやRuby、Pythonといったプログラミング言語の文法には曖昧さがなく、同じテキストは常に同じプログラムを意味します。

では、たとえば、Java言語といったときに、**言語**が指すものは何なのでしょうか？文脈自由文法のような形式文法の世界では、**言語**を**文字列の集合**として取り扱います。

これでは抽象的ですね。たとえば、以下のHello, World!プログラムは、正しいJavaScript言語のプログラムですが、文字列として見ることもできます。

```javascript
console.log("Hello, World!");
```

3を表示するだけのプログラムも考えてみます。一番単純な形は以下のようになるでしょう。

```javascript
console.log(3);
```

`3+5`を表示するだけのプログラムは以下のようになるでしょう。

```java
console.log(3 + 5);
```

このようにJavaScriptのプログラムとして認められる文字列を列挙していくと、次のような**文字列の集合**`JP`になります。

```text
JP = {
  console.log("Hello, World!");,
  console.log(3);,
  console.log(3 + 5);,
  ...
}
```

JavaScript言語のプログラムとして認められる文字列は無数にありますから、集合`JP`の要素は無限個あります。つまり、`JP`は**無限集合**になります。

同様にRubyを「言語」として見ると次のようになります。

```text
RB = {
  puts 'Hello, World!',
  puts 3,
  puts 3 + 5,
  ...
}
```

Rubyプログラムとして認められる文字列は無数にあるので、`RB`もやはり無限集合となります。

このように、形式言語の世界では文字列の集合を言語としてとらえるわけです。

例をDyck言語に戻します。Dyck言語が表す文字列の集合が一体何なのかを考えてみます。Dyck言語とは「括弧の釣り合いが取れた文字列」を表すものでした。ということは、括弧の釣り合いが取れた文字列を要素に持つ集合を考えればいいことになります。

```text
DK = {
  (),
  (()),
  ((())),
  (()()),
  ()(),
  ()()(),
  ...
}
```

言語を文字列の集合として見ることについて、掴めて来たのではないかと思います。

言語を文字列の集合として表現すると、**集合論**の立場で言語について論じられることが大きなメリットです。

たとえば、Dyck言語の条件を満たす文字列`()`について以下のように表記することが可能です。

```text
() ∈ DK
```

`DK`は文字列の集合であり、`()`は文字列ですから、集合論の記法をそのまま使うことができます。

一方で、Dyck言語でない文字列`) (`は以下のように表記することが可能になります。

```
)( ∉ DK
```

`DK`は単なる集合なので、皆さんが中学や高校で習ったように、和や積を考えることができます。

Ruby言語を表す無限集合を`RB`と考えたとき、集合の和`RB ∪ DK`を考えることができます。`RB ∪ DK`は以下のようになります。

```
RB ∪ DK = {
  `()`,
  `puts 3`,
  `(())`,
  `puts 3 + 5`,
  ...
}
```

集合の積`RB ∩ DK`を考えることもできます。Ruby言語のプログラムでかつDyck言語であるような文字列は存在しませんから`RB ∩ DK`は**空集合**になります。つまり、`RB ∩ DK = ∅`です。

集合論の道具を自由に使えるのが言語を文字列の集合としてとらえることのメリットです。

別の例として、Java言語のプログラムの後方互換性を考えてみましょう。Java 5で書かれたプログラムはJava 8でも（基本的に）OKです。ここで、Java 5のプログラムを表す集合を`J5`、Java 8のプログラムを表す集合を`J8`とすると、以下のように表記できます。

`J5 ⊂ J8`

Java 8はJava 5の後方互換であるという事実を、このように集合論の立場で言うことができるわけです。

## 4.3 文脈自由言語と言語の階層

ここまで見てきたように**ある**文脈自由文法は、言語、つまり、文字列の集合を定義するのでした。ところで、**すべての**文脈自由文法、言い換えれば文脈自由文法自体の集合はどのようなものになるのでしょうか？

**ある**文脈自由文法は文字列の集合を定義するわけですから、ここで考えているのは**文字列の集合の集合**がどのような構造を持つかということになります。このような言語の集合のことを言語クラスと呼びます。

この問題を考えるためには、皆さんが普段駆使しておられる正規表現を思い浮かべてもらうのがわかりやすいと思います。正規表現に馴染みのない方もいると思うので念のため解説します。正規表現は**文字列のパターン**を定義するための言語です。現代のプログラミング言語で使用されている正規表現はさまざまな拡張が入っているため複雑になっていますが、本来の正規表現にとって重要なパーツのみを扱います。

以下が正規表現を構成する要素です。`e_1`や`e_2`、`e`はそれ自体正規表現を表していることに注意が必要です。`a`は任意の文字1文字を表します。

```
a        文字
ε        空文字列
e_1 e_2  連接
e_1 | e_2 選択
e*       0回以上の繰り返し（クリーネ閉包）
```

正規表現はシンプルな規則によって構成されますが、多様なパターンを表現できます。以下は自然数を表現する正規表現です。

```
0|(1|2|3|4|5|6|7|8|9)(0|1|2|3|4|5|6|7|8|9)*
```

通常の正規表現エンジンでは文字クラスと呼ばれる機能を使って`0|[1-9][0-9]*`のように書くことができますが意味は同じです。

あるいは、7桁の郵便番号は次のような文字クラスを使って次のように表すことができます。文字クラスはシンタックスシュガーなので使わなくても同等の記述は可能ですが、説明を簡潔にするために以降では文字クラスを使って表現します：

```
[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]
```

これも`[0-9]{3}-[0-9]{4}`のように書くことができますが、`e{n}`で`e`の`n`回の繰り返しを表現するのは、文字クラスと同様に単なるシンタックスシュガーです。

正規表現は色々な分野で使われており、正規表現によって非常に幅広い範囲の文字列集合、つまり言語を表現できます。しかし、正規表現にも限界があります。

正規表現の集合で表現される言語クラスを本書では`RL`と表記します。`RL`で表せないことが証明されている典型的な言語の1つがDyck言語です。つまり、

`DK ∉ RL`

ここでDKは言語であり、RLは言語クラス（言語の集合）であることに注意してください。

さらに話を進めると、文脈自由文法が表す言語クラス（文脈自由言語と呼び、本書では`CFL`と表記します）と`RL`について次のような関係がなりたちます。

`RL ⊂ CFL`

これは、文脈自由文法では正規表現で表現可能なあらゆる文字列を表現可能だが、逆は成り立たないということです。

これは単に理論上の話ではなく実用上大きな問題として立ちはだかります。たとえば、プログラミング言語の構文解析ではDyck言語のような**括弧の対応がとれていなければエラー**という文法が頻繁に登場しますが、正規表現では書けないのです。

さて、Dyck言語に特徴づけられる**括弧の対応を計算できる**ことに文脈自由文法の利点があるわけですが、文脈自由文法だけであらゆる種類の文字列の集合を定義可能なのでしょうか？

これは自明ではありませんが、不可能であることが証明されています。たとえば、`a`を`n`回、`b`を`n`回、`c`を`n`回だけ（`n >= 0`）並べた文字列を表す言語`a^n b^n c^n`は、文脈自由文法で定義不可能です。

一方でこの言語は文脈依存言語（本書では`CSL`と表記）という言語クラスで定義可能で、`CFL`は`CSL`の真部分集合です。この事実は次のように表すことができます。

`CFL ⊂ CSL`

このように、言語クラスには階層があります。これまででてきた言語クラスを含めると、言語クラスの階層は次のようになります。

`RL ⊂ CFL ⊂ CSL`

言語クラスとしては`RL`（正規言語）よりも`CFL`（文脈自由言語）の方が強力であり、`CFL`より`CSL`（文脈依存言語）方が強力ということですね。

わかりやすく図として表現すると以下のようになります。

![言語クラスの階層](./img/chapter3/chomsky1.svg)

CSLよりさらに強力な言語クラスも存在しますが、実はもっとも強い言語クラスが存在しています。そのクラスは**帰納的加算言語**と呼ばれていて、現存する（ほぼ）すべてのプログラミング言語の能力と一致します。

（ほぼ）すべてのプログラミング言語はチューリング完全であるという意味で能力的に等しいということを聞いたことがあるプログラマーの方も多いでしょう。

形式言語の用語で言い換えれば、任意のプログラミング言語で生成可能な言語（＝文字列の集合）の全体である言語クラスは帰納的加算言語とちょうど一致するということになります。

## 4.4 生成規則と導出

文脈自由文法は生成規則の集まりからできていることを学びました。ところで、生成規則とはどういう意味なのでしょうか。上のDyck言語を表す文脈自由文法をもう一度眺めてみましょう。

```
D → P
P → ( P ) P
P → ε
```

非終端記号`D`はカッコの対応が取れた文字列の集合を表しています。見方を変えると、`D`から`()`, `(())`, `((()))`, `()()`などの文字列を生成することができるということです。文法から文字列を生成することを導出と呼びます。

この導出の仕方は大きく分けて

- 最左導出（Leftmost Derivation）
- 最右導出（Rightmost Derivation）

の2つがあります。以降の節では、この導出について詳しく説明します。

## 4.4.1 最左導出

最左導出は、生成規則を適用する際に常に一番左の非終端記号を展開する方法です。これにより導出過程が一意に決定されます。例として次の文脈自由文法を考えてみましょう。

```
S → AB
A → aA
A → a
B → bB
B → b
```

最左導出によって`S`から`aabb`を導出する過程を示します。

```
S  => AB    (S → ABを適用)
AB => aAB   (A → aAを適用)
aAB => aaB  (A → a適用)
aaB => aabB (B → bBを適用)
aabB => aabb (B → bを適用)
```

最左導出は、これ以上適用できる規則がなくなるまで、常に一番左の非終端記号を展開していきます。

## 4.4.2 最右導出

最右導出は、生成規則を適用する際に常に一番右の非終端記号を展開する方法です。最左導出と同様に導出過程が一意に決定されます。さきほどと同じ文脈自由文法を考えてみましょう。

```
S → AB
A → aA
A → a
B → bB
B → b
```

最右導出によって`S`から`aabb`を導出する過程を示します。

```
S   => AB    (S → ABを適用)
AB  => AbB   (B → bBを適用)
AbB => Abb   (B → bを適用)
Abb => aAbb  (A → aAを適用)
aAbb => aabb (A → aを適用)
```

最右導出は、これ以上適用できる規則がなくなるまで、常に一番右の非終端記号を展開します。

最左導出と最右導出では最終的に同じ文字列を導出することが可能です。しかし、導出過程が異なります。

先取りしておくと、形式言語における最左導出がいわゆる下向き構文解析に対応し、最右導出の逆操作が上向き構文解析に対応します。これらについては次の章で説明します。

生成規則から文字列を生成するために2つの導出方法を使い分けることができることを覚えておいてください。