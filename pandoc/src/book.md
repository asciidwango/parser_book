<!-- 
このファイルは自動生成されています。
直接編集せず、src/chapters/内の個別章ファイルを編集してください。
生成コマンド: ./merge_chapters.sh
-->

\newpage

<!-- Chapter 4: 第1章:構文解析の世界へようこそ -->

# 第1章 構文解析の世界へようこそ

皆さん、はじめまして！この本は「構文解析」というテーマについて扱った、一風変わった本です。これまで「構文解析」については、コンパイラや言語処理系を扱った書籍の一部で触れられる程度でした。「Parsing Techniques」という英語の書籍があるものの、英語圏ですら広く知られているとは言い難いですし、内容も網羅的ではあるものの平易とは言えません。

私がはじめて「構文解析」の入口に立ったのは高校三年生のときでした。当時、私はプログラミング言語に興味を持ち始め、いつかは自分のプログラミング言語を作ってみたいと思っていました。しかし、高校の図書館にあった「プログラミング言語を作る」本を借りて読んでみたものの、とても難しく当時の私には理解できませんでしたし、コンパイラ開発者のバイブルともよばれる「ドラゴンブック」[^1]も同様でした。

何がきっかけかは覚えていないのですが、いきなり大きな言語を作ろうとしても難しいということでまずは括弧を含む算術式を計算できる「電卓」アプリを作ることにしました。非常に単純なもので

```sh
(1 + 2) * (3 + 4) 
```

のようにテキストフィールドに入力して「計算」ボタンを押すと`21`と表示される、ただそれだけの代物です。今振り返れば、この電卓アプリはごく初歩的な「構文解析」と「インタプリタ」を実装したものとも言えます。

ただし、当時の私は言語処理系を作る際に必須の知識がほとんどなく、抽象構文木も典型的な構文解析のアルゴリズムも知らず、足りない知恵を振り絞って括弧の対応や演算子の優先順位を自力で計算したのでした。それは本当に拙いものでしたが、それでもなんとか動くものを作ることができたのです。

それから二十年余り。筆者は現在、研究職ではないものの構文解析の手法の一つである、Parsing Expression Grammar（PEG）を専門として、時折関連する論文の査読を引き受けたりしています。

現在の私は研究に未練を残しつつちょっとアカデミアに関わりがある微妙な立場ですが、そんな中でも折に触れて思うことがありました。構文解析はなぜ、一般の技術書であまり取り上げられないのだろうか、ということです。

言語処理系を扱う書籍の一部として構文解析が取り上げられることは珍しくありません。しかし、その扱いはあくまで「おまけ」であって、言語を作る上での通過点としてしか位置づけられていません。これについては、言語の本質は構文解析の「後」にあるのであり、構文は本質ではないというのが大きいでしょう。筆者もこの点に異論はありません。ただ、構文（正確には具象構文）はほんとうに「おまけ」なのでしょうか。ときどき疑問に思います。

プログラミング言語に携わる研究者の間では、プログラミング言語の「意味」は抽象構文木に対して定められるものであり、構文は「ガワ」に過ぎないという考え方の人が多いように思いますし、その考えも間違ってはいないと思います。

しかし、現実に我々が読み書きするのはプログラムの抽象構文木ではなく、プログラムの文字列です。構文はUIであると言えます。多くのアプリケーションにおいてUIが果たす役割は非常に大きく、UI自体が専門分野として存在しているくらいです。そのUIたる構文とUIを適切な内部構造に変換する構文解析は軽視されていいのだろうか。筆者が構文解析の本を書こうと思い立ったのはそんな「こだわり」からでした。

本書の読者の皆さんには、構文解析の世界を少しでも楽しんでいただければと思います。構文解析は非常に奥深いテーマであり、その奥深さを一冊の本で完全に網羅することはできません。しかし、本書を通じて構文解析の基礎を学び、その面白さを感じていただければと思います。

たとえば、そもそも構文解析とは何でしょうか。実はこの問いだけをとっても答えは1つではありません。

入力文字列を引数にとって、文法に沿っているかどうかを真偽値として返す関数を構文解析とみなす考え方があります。このような場合、構文解析は以下のようなメソッドとして表現できます。

```java
boolean parse(String input);
```

入力文字列を引数にとって、文法に沿っているならば抽象構文木を、そうでなければエラーを返す関数を構文解析とみなす考え方もあります。この場合、構文解析はJava 17から正式導入されたsealed interfaceとJava 16から正式導入されたrecordを使って、以下のようなメソッドとして表現できます（これらの機能は、パターンマッチングと組み合わせることで、より簡潔かつ安全に代数的データ型のような構造を表現するのに役立ちます）。

```java
interface Tree {}
sealed interface ParseResult permits ParseResult.Success, ParseResult.Failure {
  record Success(Tree ast) implements ParseResult {}
  record Failure(String errorMessage) implements ParseResult {}
}
ParseResult parse(String input);
```

その他にも色々な考え方があります。非自然言語の構文解析というテーマは大きく扱われることが少ないですが、奥が深いものです。

皆さんがもっとも身近に使っている言語の1つであるJavaScriptを例にとって、この問題の奥深さについて説明してみます。

以下のJavaScriptプログラムを構文解析することにします。

```js
x = 1 +
  2
```
このコードは、JavaScriptエンジンによって `x = 1 + 2;` と解釈され、直観的には以下のような抽象構文木が結果として返ってくるのが正しいように思われます（抽象構文木の説明は、いったんおいておきます）。

![](img/chapter1/ast1.svg){ width=50% }


では、次のJavaScriptプログラムはどうでしょうか？

```js
x = 1
+ 2
```
おそらく多くの方は先ほどと同じ構文木になることを期待するのではないでしょうか。

しかし、実際にはJavaScriptの自動セミコロン挿入（ASI: Automatic Semicolon Insertion）というルールにより、`x = 1; +2;` と解釈され、結果として以下のような2つの文として扱われます。

![](img/chapter1/ast2.svg){ width=50% }

`+`の後で改行するか、あるいは`+`の前に改行するかという一見**ささいな違い**によって、構文解析の結果が変わってしまうのです。JavaScriptのASIは、特定のルールに基づいて行末にセミコロンが自動的に挿入される機能ですが、そのルールは時として直感に反する結果を生むことがあります。例えば、`return`文の直後で改行すると、

```js
return
a + b;
```

これはASIにより `return; a + b;` と解釈され、意図しない結果（`undefined`が返される）になることがあります。ASIの主なルールには、「行終端文字の前に続くトークンが、文法的に許されないトークンである場合、セミコロンを挿入する」といったものがありますが、例外も存在します。このような複雑さが、構文解析器の実装を難しくする一因となります。ASIによる予期せぬ挙動を避けるために、行頭にセミコロンを記述するスタイルや、式の途中では改行しないといったコーディング規約を採用する開発者もいます。

2000年以降に登場して普及した言語は、このような特徴を持っていることが多いです。たとえば、Go、Swift、Kotlin、Scalaの文法はこのような特徴を持っています。

もっと古い言語でもRubyやPythonも同じ特徴を持っています。ちょっとした違いで構文解析結果が変わってしまう例は珍しくありません。

このような文法の進化の背景には、プログラマにとって「書きやすく読みやすい」文法を提供するという意図があります。このような「改行に敏感な」文法（より正確には、改行の有無によって自動的にセミコロンが挿入されるかどうかが変わる文法）は、構文解析器の実装の複雑さを増大させる要因の一つです。プログラミング言語の設計者にとっては考慮すべき点が増えますが、利用者にとってはセミコロンの入力を省略できるなどの利便性があるため、広く採用される傾向にあります。

しかし「構文解析の複雑さを増大させる」というのは一体どういうことでしょうか。ほとんどの方はピンと来ないのではないでしょうか。この本では、このような問いに対して一定の答えを提示することを目指します。「構文解析の複雑さ」と一言で言っても、その要因は様々です。例えば、文法が曖昧であるか（一つの文に対して複数の解釈が可能か）、解析にバックトラック（試行錯誤）が必要か、どれだけの先読みトークン（入力の一部を先に見る数）が必要か、生成される解析表のサイズはどの程度か、といった要素が複雑さに関わってきます。本書では、これらの概念に触れながら、構文解析の奥深さを探求していきます。これらの複雑さを理解する上で重要な役割を果たすのが、「文脈自由文法」という考え方です。文脈自由文法とは、簡単に言えば、プログラムの構造を定義するための一連の書き換え規則のことです。例えば、「式は、数値である」や「式は、式と演算子と式からなる」といったルールを形式的に記述するものです。詳細については第4章で詳しく解説しますが、この文脈自由文法という道具立てがあることで、構文解析の様々な側面を体系的に議論できるようになります。

読者の皆さんは既存の言語に歯がゆさを感じたことはないでしょうか。たとえば、昨今はJSONやYAMLを用いてDSL (Domain Specific Language)を提供することが一般的になっています。

しかし、これらのDSLはJSONやYAMLの枠に収めるために無理をしており、どうしても「不自然」な文法になってしまいます。JSONやYAMLは世界中に普及していますから、JSONやYAMLを使ったDSLを提供する合理性はあるもの、場合によってはJSONやYAMLに縛られないDSLの文法を考案することが求められることもあります。そのためには構文解析の知識が必要です。

構文解析は単に実用的であるにとどまらず非常に「楽しい」テーマです。読者の皆さんには本書を通じて、是非「構文解析の面白さ」を感じていただければと思います。

本書は次のような構成になっています。

第2章では簡単な算術式を例題にして、構文解析とはどういう処理かを体感してもらいます。定義を天下り式に提示するような本もありますが、構文解析については「まずは書いてみる」のが手っ取り早いというのが筆者の持論です。

第3章ではJSONの構文解析器を書いてもらいます。JSONは世界中で使われている非常に実用的なデータ形式（言語）でありながら、非常にシンプルです。そのシンプルなJSONを通して、実用的な言語の構文解析の基礎を学んでいただければと思います。

第4章では文脈自由文法（や言語）について解説します。文脈自由文法やそれに関する理論は構文解析の基礎になっています。括弧の対応を表現する言語を`Dyck`言語と言いますが、`Dyck`言語は文脈自由言語を特徴づけるものです。この章を理解することで文脈自由文法の直観的な理解が得られます。現代の構文解析は文脈自由文法を基盤としていますから、文脈自由言語の概念を理解することは非常に重要です。

第5章では現在の構文解析で広く採用されているアルゴリズムの内、主だったものを解説します。特に`LL(1)`や`LR(1)`といったアルゴリズムについてできるだけ平易にかつ詳しく説明します。また、`PEG`や`Packrat Parsing`という比較的新しい構文解析アルゴリズムについても詳しく説明します。

第6章では構文解析器生成系について解説します。`Yacc`のような古典的なものに留まらず、`ALL(*)`アルゴリズムを基盤にした`ANTLR`やPEGを基盤にしたパーザコンビネータなど、最新の構文解析器生成系について説明します。さらに、第6章では簡単なパーザコンビネータを自作します。パーザコンビネータは元々は関数型プログラミング言語から出てきたテクニックですが昨今では色々な言語でパーザコンビネータライブラリがあります。パーザコンビネータを自作する体験を通じて「文の定義から構文解析器を生成する」とはどういうことか理解してもらえるのではないかと思います。

第7章では従来の言語処理系についての本が取り扱わなかった「現実の構文解析」の話をします。従来の書籍に書かれている構文解析の世界はとても「綺麗」なものです。しかし、RubyでもPythonでもあるいはJavaScriptでも良いですが、現実の構文解析は必ずしもそこまで綺麗にはいかないものです。この章を通して現実の言語における構文解析はとても泥臭いものであること、その泥臭さを通して「書きやすく読みやすい」文法が実現されていることを実感してもらえるのではないかと思います。

第8章は締めくくりとしてこれまでの章を振り返りつつ、今後、みなさんが構文解析を学ぶにあたって参考になりそうな文献や資料について紹介します。この本は構文解析のみを取り扱った珍しい本ですが、それでも構文解析の世界は広く、本書で取り扱わなかったテーマも多々あります。この章を読んで、構文解析の世界により深く興味を持っていただければ幸いです。

さて、第1章を読み終えた皆さんは、構文解析というテーマに対してどのような印象を持たれたでしょうか。もしかしたら、「普段何気なく書いているプログラムの裏側では、こんな複雑なことが行われているのか」と驚かれたかもしれません。あるいは、「自分の手で言語のルールを定義し、それを解釈するプログラムを作るのは面白そうだ」と感じた方もいるかもしれません。あなたがこれまでに触れたことのある言語で、構文が原因で混乱した経験はありますか？もしあれば、それはなぜだったのか、この本を読み進める中でヒントが見つかるかもしれません。

次の第2章では、いよいよ具体的な構文解析の世界に足を踏み入れ、簡単な算術式を題材に、手を動かしながら構文解析の第一歩を体験していただきます。お楽しみに！

2025年xx月dd日、自室にて。水島宏太

[^1]: Alfred V. Aho, Monica S. Lam, Ravi Sethi, Jeffrey D. Ullman 著「コンパイラ 第2版: 原理・技法・ツール」（サイエンス社, 2009年）のこと。コンパイラ開発の標準的な教科書であり、表紙のデザインから「ドラゴンブック」の愛称で広く知られています。

\newpage

<!-- Chapter 7: 第2章:構文解析の基本 -->

# 第2章 構文解析の基本

この章からいよいよ構文解析についての説明を始めたいと思います。とはいっても本書を手に取った皆様は構文解析についてまだ馴染みがないかと思います。そこで、まずは簡単な算術式の構文解析を例にして、構文解析の基本について学ぶことにしましょう。

## 2.1 算術式の文法

ただ「算術式」といっただけだと人によってかなりイメージするものが異なります。本書では以下の条件を満たすものを算術式とします。

- 四則演算ができる
  - 足し算は`x+y`
  - 引き算は`x-y`
  - 掛け算は`x*y`
  - 割り算は`x/y`
- 優先順位は掛け算・割り算が高く、足し算・引き算が低い
  - 例：`1+2*3`は`1+(2*3)`と解釈される
- 同じ優先順位の演算子は左から右に結びつく
  - 例：`1+2-3`は`(1+2)-3`と解釈される
- 値は整数のみ
  - 例：`1+2.0`のような式はエラーになる
- 式の優先順位を変えるために括弧を使うことができる
  - 例：`1+2*3`は`1+(2*3)`の意味になるが、`(1+2)*3`と書くことで意味が変わる
- スペースは使えない
  - 例：`1+2`はOKだが、`1 + 2`はエラーになる

最後の「スペースは使えない」という制限は、字句解析（文字列を意味のある単位、トークンに分割する処理）を単純化し、構文解析の核となる考え方に集中するために設けています。実際の算術式ではスペースも使えてかつ無視されるのが一般的ですが、その処理は後の章で触れることにします。

この定義に従う算術式には以下のようなものが含まれます。

```text
100
1+2*3
(1+2)*3
3*(1+2)
12/3
1+3*4/2
```

普段、皆さんは何かしらのプログラミング言語を使ってプログラムを書いているはずですから、上のような算術式は馴染みが深いはずです。

しかし、上のような日本語を使った定義だけでは算術式の文法を表現するのには不十分です。たとえば「式の優先順位を変えるために括弧を使うことができる」といっても、なんとなくはわかるものの、定義としては曖昧です。もちろん、日本語で詳しく記述して曖昧さを少なくしていくこともできますが、いたずらに長くなるだけです。

曖昧さなく文法を表現するための文法である**形式文法**を使って、算術式の文法を表現することが一般的です。形式文法というと何かしらとても難しいもののように感じられますが、実際には簡単なものです。次節では形式文法の一つであり、もっともメジャーな表記法であるBNF（Backus-Naur Form、バッカス・ナウア記法）を使って、算術式の文法を表現してみましょう。

## 2.2 算術式のBNF

プログラミング言語の文法自体を表現する文法（メタ文法といいます）の一つに、BNFがあります。BNFは、プログラミング言語の文法をはじめ、インターネット上でのメッセージ交換フォーマットなど、様々な文法を表現するのに使われています。本書の読者の方にはBNFに馴染みのない方も多いと思うので、算術式のBNFの前にBNFについて説明します。本書では、記述を簡潔にするため、ISO/IEC 14977で仕様が策定されたEBNF[^1]で用いられる繰り返し（`{}`）、オプション（`[]`）、グループ化（`()`）といった拡張記法を一部取り入れ、これを広義のBNFとして扱います。BNFには歴史的に多くの方言が存在するため、本書で用いる記法について事前に説明しておきます。

### 2.2.1 BNFの概要

BNFはFortranの開発者でもある、John Backus（ジョン・バッカス）らが開発した記法です。BNFは「プログラミング言語」そのものの文法を記述するために開発されました。基本情報技術者試験でも出題されるので、そこで知った方もおられるかもしれません。

本書で用いる広義のBNF（EBNFの要素を取り入れたもの）の主要な記法は以下の通りです。

*   `=` : 左辺の規則名と右辺の定義を区切ります。
*   `|` : 選択を表します。例えば `A | B` は「AまたはB」を意味します。
*   `{}` : 0回以上の繰り返しを表します。例えば `A {B}` は「Aの後にBが0回以上続く」ことを意味します。これは純粋なBNFでは `X = A Y` と `Y = B Y | ε` のように再帰を使って表現されます。
*   `[]` : 0回または1回の出現（オプション）を表します。例えば `[A] B` は「Aがあるかもしれないし、ないかもしれないが、その後にBが続く」ことを意味します。これは純粋なBNFでは `X = A B | B` のように表現されます。
*   `()` : グループ化を表します。例えば `(A | B) C` は「AまたはBの後にCが続く」ことを意味します。
*   `'...'` または `"`...`"` : 終端記号（リテラル文字列）を表します。
*   規則名（例: `expression`, `term`）: 非終端記号を表します。

では早速、BNFの具体例を見て行きましょう。以下の例は2.1で出てきた算術式を元に、

- 扱える数値は一桁だけ

のように単純化したBNFです。

```text
expression = term { ('+' | '-') term };
term = factor { ('*' | '/') factor };
factor = NUMBER | '(' expression ')';
NUMBER = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9';
```

たくさんの記号が出てきましたが、順番に見ていきましょう。

### 2.2.2 expression

BNFでは、以下のような**生成規則**の集まりによって、文法を表現します。

 ```
expression = term { ('+' | '-') term };
 ```

`=`の左側である`expression`が**規則名**で、右側が**本体**になります。

ここでは 

```
term { ('+' | '-' ) term }
```

が本体になります。

本体の中に出てくる、他の規則を参照する部分（ここでは`term`)を**非終端記号**と呼び、これは同じBNF内で定義されている規則名と一致する必要があります。

また、`'+'`や`'-'`のように`'`で囲まれた記号や文字を**終端記号**と呼びます。これはそのままの文字（あるいは文字列）である必要があり、その文字自身を表します。

BNFにおいて`{}`で囲まれたものは、その中の要素が0回以上繰り返して出現することを示しています。したがって、`term { ('+' | '-') term }`という記述は、まず`term`が出現し、その後に「`+`または`-`とそれに続く`term`」が0回以上繰り返して出現することを示しています。0回以上という言い方がとくに重要です。というのは、`term`が1回だけ出現してその後は何も出現しない場合もあるからです。たとえば、`1`という式はこの規則にマッチしますが、`{}`で囲まれた部分は出現していません。
  
この規則を日本語で表現すると「`expression`という名前の規則は、右辺の定義 `term { ('+' | '-') term }` に従って構成される」と読むことができます。

なお、本来の（ISO/IEC）BNFでは

```
expression = term, { ('+' | '-'), term };
```

のように要素間をカンマで区切りますが、本書では可読性を考慮してスペースで区切るようにしています。

### 2.2.3 term

`term` は算術式の中で、掛け算や割り算を含んだ式を表す規則です。`factor`という規則を参照しています。

```text
term = factor { ('*' | '/') factor };
```

この規則によって`term`は、`factor`が`*`または`/`を挟んで0回以上繰り返して出現することを示しています。

### 2.2.4 factor

`factor`は算術式の中で、数値や括弧で囲まれた式を表す規則です。

```text
factor = NUMBER | '(' expression ')';
```

この規則によって`factor`は、

- `NUMBER`
- `(`と`)`に挟まれた`expression`

のどちらかであることを示しています。

### 2.2.5 NUMBER

`NUMBER`は数値を表す規則です。

```text
// 数値は1桁の整数に限定
NUMBER = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9';
```

`NUMBER`は`0`から`9`のどれか1文字であることを示しています。

## 2.3 BNFを使った解析プロセス

算術式の文法を規則`expression`を含むBNFによって表現することができました。この記述には**曖昧さがなく**、スペースを許さなことや演算子の優先順位などの概念も含まれています。

さて、この規則`expression`を使うと、式`1+2`はどのように解析できるのでしょうか？ここでは、その概要について簡単に説明します。

このBNFを使って解析を行う方法は一意ではなく、様々なやり方（手続き）があります。その個々の手続きがまさに構文解析アルゴリズムとなります。個々の構文解析アルゴリズムについては第5章で詳しく説明しますが、ここでは、BNFを使って**素直に**算術式を解析する方法の概要を説明します。

まず最初にBNFの規則を関数とみなします。たとえば、規則`expression`は関数`expression`に対応し、規則`term`は関数`term`に対応します。これらの規則に対応する関数は、解析したい文字列と文字列の添字を引数に取り、解析の結果を返します。

この関数の宣言をJavaライクな擬似コードで表すと、以下のようになります。

```java
ParseResult expression(String input, int index);
```

次に関数の呼び出しを構文解析とみなします。引数として解析したい文字列と、解析を開始する位置を渡すと、構文解析結果が返ってくるものとします。

たとえば、`expression("1+2", 0)`という関数呼び出しは、文字列`"1+2"`の先頭から解析を開始することを示します。まだ`expression`の本体がありませんが、結果としては、解析が成功した旨の情報がかえってきて欲しいでしょう。一方、`expression("1+", 0)`という関数呼び出しは、解析が失敗した旨の情報がかえってきて欲しいはずです。

関数の呼び出し結果は、

- 解析に成功した場合：成功したことを表す情報と、どこまで読み進んだかを示す位置（例えば、次の解析を開始すべき入力文字列中のインデックス）。これを`(SUCCESS, new_index)`と表す
- 失敗した場合：失敗を表す定数`FAIL`を返す

のどちらかであるものとします。

この前提を元に実際に`expression("1+2")`を解析してみましょう。

1. 規則`expression`を呼び出す

まず、最上位の規則`expression`を呼び出します。これは`expression("1+2")`となります。

```text
expression = term { ('+' | '-') term }
```

規則の本体では`term`が最初に出現するので、規則`term`を適用します。つまり、`term("1+2")`となります。ここで、`term`の呼び出しから戻った場合に備えて「続き」を次のように記憶しておきます。

```text
Stack: [ 
  expression = term ↑ { ('+' | '-') term }
]
```

この記法では規則とその現在位置を表す記号である`↑`がスタックに積まれていることを示しています。
この解析プロセスをより視覚的に追ってみましょう。

**入力: "1+2"**

1.  **`expression("1+2", 0)` を呼び出し**
    *   現在位置: `^1+2` ( `^` は現在の注目位置)
    *   適用規則: `expression = term { ('+' | '-') term }`
    *   アクション: `term` を解析するために `term("1+2", 0)` を呼び出す。
    *   スタック: `[ expression = .term { ('+' | '-') term } ]` (ドット `.` は現在解析中の位置)

2.  **`term("1+2", 0)` を呼び出し**
    *   現在位置: `^1+2`
    *   適用規則: `term = factor { ('*' | '/') factor }`
    *   アクション: `factor` を解析するために `factor("1+2", 0)` を呼び出す。
    *   スタック: `[ expression = .term ..., term = .factor { ('*' | '/') factor } ]`

3.  **`factor("1+2", 0)` を呼び出し**
    *   現在位置: `^1+2`
    *   適用規則: `factor = NUMBER | '(' expression ')'`
    *   アクション: 入力 "1" は `NUMBER` にマッチするので、`NUMBER("1+2", 0)` を呼び出す (または直接解釈)。
    *   スタック: `[ expression = .term ..., term = .factor ..., factor = .NUMBER ]`

4.  **`NUMBER("1+2", 0)` (または `factor` 内での `NUMBER` の解釈)**
    *   現在位置: `^1+2`
    *   適用規則: `NUMBER = '0' | ... | '9'`
    *   アクション: "1" が `NUMBER` の `'1'` にマッチ。消費し、位置を1進める。
    *   結果: `(SUCCESS, 1)` (消費した文字 "1", 次の位置はインデックス1)
    *   `factor` に戻る。`factor` の解析も成功。

5.  **`term` の解析を続行 (位置1から)**
    *   現在位置: `1^+2`
    *   適用規則: `term = factor . { ('*' | '/') factor }` (factorの解析は終わった)
    *   アクション: 次の入力 `+` は `*` でも `/` でもないため、`{...}` の繰り返しは0回として成功。
    *   結果: `(SUCCESS, 1)` (位置は変わらず)
    *   `expression` に戻る。`expression` の `term` の解析が成功。

6.  **`expression` の解析を続行 (位置1から)**
    *   現在位置: `1^+2`
    *   適用規則: `expression = term . { ('+' | '-') term }`
    *   アクション: 次の入力 `+` は `('+' | '-')` にマッチ。消費し、位置を2進める。次に `term` を解析するために `term("+2", 2)` (実際には `term("1+2", 2)`) を呼び出す。
    *   スタック: `[ expression = term { ('+' | '-') .term } ]`

7.  **`term("1+2", 2)` を呼び出し (入力は実質 "2")**
    *   (同様のプロセスで `NUMBER("2", 2)` が成功し、`(SUCCESS, 3)` が返る)
    *   `term` の `{...}` 部分はマッチせず0回繰り返しで成功。
    *   結果: `(SUCCESS, 3)`
    *   `expression` に戻る。

8.  **`expression` の解析を終了**
    *   現在位置: `1+2^` (入力終端)
    *   適用規則: `expression = term { ('+' | '-') term .}` (2回目のtermの解析が終わった)
    *   アクション: 入力終端なので `{...}` の繰り返しはこれ以上なし。`expression` 全体が成功。
    *   結果: `(SUCCESS, 3)`

このように、BNFの各規則が関数の呼び出しに対応し、入力文字列を消費しながら解析が進んでいく様子がイメージできたでしょうか。

2. 規則`term`を呼び出す

規則`term`は以下のようになっています。

```text
term = factor { ('*' | '/' ) factor }
```

`term`の本体では`factor`が最初に出現するので、規則`factor`を適用します。つまり、`factor("1+2")`となります。

スタックは次のようになります。

```text
Stack: [
  expression = term ↑ { ('+' | '-') term },
  term = factor ↑ { ('*' | '/' ) factor }
]
```

3. 規則`factor`を呼び出す

規則`factor`は以下のようになっています。

```text
factor = NUMBER | '(' expression ')'
```

`term`の本体は`NUMBER`か`'(' expression ')'`のどちらかですが、`"1+2"`の先頭は`NUMBER`になります。したがって、`NUMBER`を適用します。これは`NUMBER("1+2")`となります。

この時点でのスタックは次のようになります。

```text
Stack: [
  expression = term ↑ { ('+' | '-') term },
  term = factor ↑ { ('*' | '/' ) factor },
  factor = NUMBER ↑
]
```

ここで、`factor = NUMBER ↑`の部分は、つまり「やることは何もない」を意味しているので消去して以下のようにしても同じ意味です。プログラミング言語処理に詳しい方であれば「末尾呼び出しの除去」に相当すると言えばピンと来るかもしれません。

```text
Stack: [
  expression = term ↑ { ('+' | '-') term },
  term = factor ↑ { ('*' | '/' ) factor }
]
```

4. 規則`NUMBER`を適用

規則`NUMBER`は以下のようになっています。

```text
NUMBER = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
```

今、文字列の0番目と規則を照合しようとしているわけですが、`"1+2"`の0番目の文字は`1`です。したがって、`NUMBER`の本体の内、`1`との照合に成功します。

この結果、`NUMBER`の解析は成功し、入力文字列の次の解析開始位置は`+`の直前（インデックスで言えば1）になります。これを`(SUCCESS, 1)`のように表すことにします（ここでは残りの文字列そのものではなく、次の開始位置のインデックスを返すイメージです）。

解析が成功したので、`NUMBER`の呼び出しから戻ります。この時点でのスタックは次のようになっています。

```text
Stack: [
  expression = term ↑ { ('+' | '-') term },
  term = factor ↑ { ('*' | '/' ) factor }
]
```

スタックの一番上の要素をpopしてそこから解析を続行します。

5. 規則`term`の解析を続行

`NUMBER`から戻ってきた先は以下です。

```text
term = factor ↑ { ('*' | '/' ) factor }
```

これを使って解析を続行します。現在の解析位置から始まる文字列は`"+2"`です。この先頭文字`+`は、`'*'`でも`'/'`でもないため、`('*' | '/')`との照合に失敗します。

`{}`で囲まれた部分は0回以上の繰り返しを表し、その中身のパターン（ここでは `('*' | '/') factor`）が入力とマッチしない場合、この繰り返し部分は何も消費せずに（0回の繰り返しとして）成功となります。

したがって、この部分の解析は成功し、解析位置は変わらず、結果は`(SUCCESS, 1)`（先ほどの`NUMBER`解析成功時の次の開始位置）となります。

規則全体の呼び出しが成功し、`term`の呼び出しから戻ります。つまり、スタック

```text
Stack: [
  expression = term ↑ { ('+' | '-') term },
]
```

から要素をpopして、`expression`の解析を続行します。

6. 規則`expression`の解析を続行

`term`の呼び出しから戻ってきた先は以下です。

```text
expression = term ↑ { ('+' | '-') term }
```

現在の解析位置（インデックス1）から始まる文字列は`"+2"`なので、その先頭文字`+`は`('+' | '-')`との照合に成功します。つまり、結果は`(SUCCESS, 2)`です。次に`term`の解析に移ります。

7. 規則`term`を再び呼び出す

```text
expression = term { ('+' | '-') ↑ term }
```

現在の解析位置（インデックス2）から`term`の解析を開始します。つまり、`term("2", 2)`のような呼び出しのイメージです（第1引数は入力全体、第2引数は現在の開始位置）。

そこからは先程と同様に、規則の再帰的な呼び出しを経て、最終的に`NUMBER("2", 2)`で`NUMBER`の解析が成功し、入力文字列の終端に達するので、結果は`(SUCCESS, 3)`（3は終端の次の位置）となります。

8. 規則`expression`の解析を終了

7.が終わった時点で規則の以下の位置にいます。

```text
expression = term { ('+' | '-') term ↑}
```

ここでもう一回「繰り返す」かが問題ですが、既に入力文字列の終端に達しています。したがって、

```text
expression = term { ('+' | '-') term } ↑
```

のように`expression`の解析全体が成功し、`(SUCCESS, 3)`となります。

これが最終結果になるので、規則`expression`と文字列`1+2`はマッチすることがわかります。

## 2.4 BNFと解析結果

算術式の文法をBNFで表現し、実際に算術式を表す文字列と照合することができました。

しかし、これでは文字列が与えられたBNFにマッチするかどうかの判定しかできません。

皆さんおなじみのJSONがそうであるように、実用的には解析した結果を何らかのデータ構造に変換して格納しておく必要があります。

次の節では、BNFで表現された算術式を解析し、その結果を抽象構文木というデータ構造に変換する方法について説明します。

## 2.5 抽象構文木

抽象構文木とは何でしょうか？今、私達が欲しいのは

- 空白や括弧といった余分な情報が含まれず
- 演算子の優先順位を表現できる

ような構造です。**抽象構文木**（Abstract Syntax Tree）は、そのようなニーズを満たすデータ構造です。

抽象構文木は一般には任意個の子を持つ多分木として表現されます。

たとえば、`1 + 2 * 3`という算術式の抽象構文木は以下のようになります。

![](img/chapter2/ast1.svg){ width=50% }

抽象構文木の各ノードは、プログラムの構造を表現するためのデータ構造です。たとえば、`+`ノードは足し算を表し、`1`ノードは整数の`1`を表します。

抽象構文木（AST）では、各ノードはプログラムの構成要素を表し、親子関係によって演算子とオペランドの関係性を示します。抽象構文木には次のようなノードがあります。

### 2.5.1 内部ノード

演算子や制御構造など、他のノードを子として持つノードです。

先程の例でいうと、`+`ノードと`*`ノードが内部ノードです。

### 2.5.2 葉ノード

子を持たないノードです。例えば、`1`や`2`、`3`といった数値は葉ノードとなります。

一般的には、リテラルや変数など、それ以上分解できない最小単位のノードが葉ノードとなります。

### 2.5.3 根ノード

抽象構文木の最上位に位置するノードです。抽象構文木の根となるノードであり、プログラム全体を表します。数式の例でいえば、全体を表す`+`ノードが根ノードとなります。

内部ノードと根ノードは排他でないことに注意してください。たとえば、`+`ノードは内部ノードであり、同時に根ノードでもあります。

### 2.5.4 優先順位

改めて、先程の抽象構文木を見てみましょう。

![](img/chapter2/ast1.svg){ width=50% }

この木構造では、`+`がルートノードであり、その左の子が`1`、右の子が`*`です。`*`ノードの子として`2`と`3`が配置されています。これにより、演算の優先順位が明確に表現されるわけです。

この抽象構文木を見れば、`1 + (2 * 3)` という演算順序が表現されており、`(1 + 2) * 3` のような異なる解釈にはならないことが直感的に理解できるでしょう。

### 2.5.5 抽象構文木をJavaで表現する

抽象構文木は視覚的な表現としても便利ですが、その真価はプログラム上で表現・処理することにあります。ここではJavaで表現する方法を紹介します。

```java
// 式を表すインタフェース
sealed interface Exp permits Add, Sub, Mul, Div, Num {}
// 加算を表すレコード
record Add(Exp lhs, Exp rhs) implements Exp {}
// 減算を表すレコード
record Sub(Exp lhs, Exp rhs) implements Exp {}
// 乗算を表すレコード
record Mul(Exp lhs, Exp rhs) implements Exp {}
// 除算を表すレコード
record Div(Exp lhs, Exp rhs) implements Exp {}
// 数値を表すレコード
record Num(int value) implements Exp {}
```

インタフェース`Exp`は、抽象構文木のノードを表すインタフェースです。

`Add`、`Sub`、`Mul`、`Div`、`Num`は、それぞれ加算、減算、乗算、除算、数値を表すレコードです。これによって、抽象構文木をJavaで表現することができます。

試しに`1 + 2 * 3`の抽象構文木をJavaで表現してみましょう。

```java
// 1 + 2 * 3
Exp exp = new Add(
  new Num(1), new Mul(new Num(2), new Num(3))
);
```

各クラスのインスタンスを作成することで、抽象構文木を表現することができます。

### 2.5.6 抽象構文木を評価する

抽象構文木を作成するだけでは、プログラムの実行結果を得ることはできません。抽象構文木を評価するためには、再帰的な処理を行うことが必要です。抽象構文木を辿りながら、各ノードの演算を行うことで、プログラムの実行結果を得ることができます。

以下は、算術式の抽象構文木を評価するJavaのコード例です。

```java
int eval(Exp e) {
  return switch(e){
    case Num t -> t.value();
    case Add t -> eval(t.lhs()) + eval(t.rhs());
    case Sub t -> eval(t.lhs()) - eval(t.rhs());
    case Mul t -> eval(t.lhs()) * eval(t.rhs());
    case Div t -> {
      int divisor = eval(t.rhs()); // 先に右辺を評価
      if(divisor == 0) { // 評価結果でゼロチェック
        throw new ArithmeticException("division by zero");
      }
      yield eval(t.lhs()) / divisor; // 左辺を評価して除算
    }
  };
}
```

ノードの種類に応じてswitch式で処理を分岐しています。
- `Num`ノードの場合: 格納されている数値 `t.value()` をそのまま返します。これが再帰のベースケースとなります。
- `Add`ノードの場合: 左の子 `t.lhs()` と右の子 `t.rhs()` をそれぞれ再帰的に `eval` し、その結果を足し算します。
- `Sub`、`Mul`ノードの場合: `Add` と同様に、左右の子を再帰的に評価し、それぞれの演算を行います。
- `Div`ノードの場合: まず右の子（除数）を `eval` し、その結果が0であれば `ArithmeticException` をスローします。0でなければ、次に左の子（被除数）を `eval` し、除算の結果を返します。ゼロ除算チェックは、実際の計算を行う前に行うことが重要です。また、`eval(t.rhs())` を2回呼び出すのを避けるため、一度評価した結果を変数に格納しています。

この`eval`メソッドの動作を `1 + 2 * 3` の抽象構文木 `new Add(new Num(1), new Mul(new Num(2), new Num(3)))` で追ってみましょう。

1.  `eval(new Add(new Num(1), new Mul(new Num(2), new Num(3))))` が呼び出される。
2.  `Add`ケースにマッチ。
    1.  `eval(t.lhs())` つまり `eval(new Num(1))` が呼び出される。
        *   `Num`ケースにマッチ。`1` を返す。
    2.  `eval(t.rhs())` つまり `eval(new Mul(new Num(2), new Num(3)))` が呼び出される。
        *   `Mul`ケースにマッチ。
            1.  `eval(t.lhs())` つまり `eval(new Num(2))` が呼び出される。
                *   `Num`ケースにマッチ。`2` を返す。
            2.  `eval(t.rhs())` つまり `eval(new Num(3))` が呼び出される。
                *   `Num`ケースにマッチ。`3` を返す。
            3.  `2 * 3` の結果である `6` を返す。
    3.  `1 + 6` の結果である `7` を返す。

このように、抽象構文木を再帰的に辿ることで、式の評価が実現されます。`Div` の場合のゼロ除算エラー処理は、プログラムの実行時エラーを防ぐために不可欠です。他の演算（`Add`, `Sub`, `Mul`）では、Javaの整数演算がオーバーフローする可能性はありますが、`ArithmeticException` のような実行時例外を直接引き起こす「不正な演算」は（ゼロ除算ほど明確には）定義されていないため、ここでは特にエラー処理を加えていません（もちろん、より堅牢な電卓を作る場合はオーバーフロー検知なども考慮に入れるべきです）。

この`eval`メソッドを使うことで、次のように抽象構文木を評価することができます。

```java
// 1 + 2 * 3
Exp exp = new Add(
  new Num(1), new Mul(new Num(2), new Num(3))
);
eval(exp); // 7
```

抽象構文木をデータとして表現することで、プログラムの構造を簡単に解析することができるのです。

## 2.6 まとめ

この章では、算術式の文法を例題としてBNFについて紹介し、BNFに基づいて算術式を解析する方法の概要について説明しました。また、抽象構文木についても紹介し、抽象構文木をJavaで表現する方法と、抽象構文木を評価する方法について説明しました。

しかし、今のままではBNFに基づく「構文解析器」は与えられた文字列が文法にマッチするかどうかを判定するだけで、抽象構文木を生成することができません。次章では、ここで学んだBNFの考え方を応用して、実際にJavaで動作するJSONの構文解析器を実装し、JSONの抽象構文木を生成する方法について詳しく説明します。

[^1]: 翻訳: ISO/IEC 14977:1996 Information technology — Syntactic metalanguage — Extended BNF https://hazm.at/mox/lang/meta-language/ebnf/iso-iec-14977-extended-bnf/index.html

\newpage

<!-- Chapter 2: 第3章:JSONの構文解析 -->

# 第3章 JSONの構文解析

2章で構文解析に必要な基本概念について学ぶことができました。この章ではJSONという実際に使われている言語を題材に、より実践的な構文解析のやり方を学んでいきます。

## 3.1 JSON（JavaScript Object Notation）の概要

JSONは、WebサービスにアクセスするためのAPIで非常に一般的に使われているデータフォーマットです。また、企業内サービス間で連携するときにも非常によく使われます。皆さんは何らかの形でJSONに触れたことがあるのではないかと思います。

JSONは元々は、JavaScriptのサブセットとして、オブジェクトに関する部分だけを切り出したものでしたが、現在はECMA-404[^1]で標準化されており、色々な言語でJSONを扱うライブラリがあります。また、JSONはデータ交換用フォーマットの中でも非常にシンプルであるという特徴があり、そのシンプルさ故か、同じ言語でもJSONを扱うライブラリが乱立する程です。今のWebアプリケーション開発に携わる開発者にとってJSONは避けて通れないといってよいでしょう。
 
以降では簡単なJSONのサンプルを通してJSONの概要を説明します。

### 3.1.1 オブジェクト

以下は、二つの名前/値のペアからなる**オブジェクト**です。

```js
{
  "name": "Kota Mizushima",
  "age":  41
}
```

このJSONは、`name`と`"Kota Mizushima"`という文字列の**ペア**と、`age`と`41`という数値の**ペア**からなる**オブジェクト**であることを示しています。

なお、用語については、ECMA-404の仕様書に記載されているものに準拠しています。名前/値のペアは、属性やプロパティと呼ばれることもあるので、適宜読み替えてください。
日本語で表現すると、このオブジェクトは、名前が`Kota Mizushima`、年齢が`41`という人物一人分のデータを表していると考えることができます。オブジェクトは、`{}`で囲まれた、`name:value`の対が`,`を区切り文字として続く形になります。後述しますが、`name`の部分は**文字列**である必要があります。

### 3.1.2 配列

別の例として、以下のJSONを見てみます。

```js
{
  "kind":"Rectangle",
  "points": [
    {"x":0,   "y":0  },
    {"x":0,   "y":100},
    {"x":100, "y":100},
    {"x":100, "y":0  },
  ]
}
```

このJSONは、
 
- `"kind"`と`"Rectangle"`のペア
- `"points`と`[...]`のペア

からなるオブジェクトです。さらに、`"points"`に対応する値が**配列**になっていて、その中に以下の4つの要素が含まれています。
 
- オブジェクト： `{"x":0,   "y":0}`
- オブジェクト： `{"x":0,   "y":100}`
- オブジェクト： `{"x":100, "y":100}`
- オブジェクト： `{"x":100, "y":0}`

配列は、`[]`で囲まれた要素の並びで、区切り文字は`,`です。

このオブジェクトは、種類が四角形で、それを構成する点が`(0, 0), (0, 100), (100, 100), (100, 0)`からなっているデータを表現しているとみることができます。
 
### 3.1.3 数値

これまで見てきたオブジェクトと配列は複合的なデータでしたが、既に出てきているように、JSONにはこれ以上分解できないデータもあります。先ほどから出てきている数値もそうです。数値は、

```js
1
10
100
1000
1.0
1.5
```

のような形になっており、整数または小数です。JSONでの数値の解釈は特に規定されていない点に注意してください。たとえば、`0.1`は2進法での小数だと解釈しても良いですし、10進法での小数と解釈しても構いません。つまり、特に、IEEEの浮動小数点数である、といった規定はありません。

### 3.1.4 文字列

JSONのデータには文字列もあります。

```js
"Hello, World"
"Kota Mizushima"
"hogehoge"
```

のように、`""`で囲まれたものが文字列となります。JSONの仕様では、オブジェクトのキーは必ずダブルクォーテーションで囲まれた文字列でなければなりません。たとえば、以下は**JavaScriptの**オブジェクトリテラルとしては許容される場合がありますが（キー `name` が識別子の命名規則に合致するため）、**JSON**の定義には従っていません。

```js
{
  name: "Kota Mizushima", // nameがダブルクォーテーションで囲まれていない！
  age:  41
}
```

このような形式は、多くのJSONパーサーではエラーとして扱われます。JavaScriptのオブジェクトリテラルとJSONの構文には違いがある点に注意してください。

### 3.1.5 真偽値

JSONには、多くのプログラミング言語にある真偽値もあります。JSONの真偽値は以下のように、`true`または`false`の二通りです。

```js
true
false
```

真偽値も解釈方法は定められていませんが、ほとんどのプログラミング言語で、該当するリテラル表現があるので、おおむねそのような真偽値リテラルにマッピングされます。

### 3.1.6 null

多くのプログラミング言語にある要素ですが、JSONには`null`もあります。多くのプログラミング言語のJSONライブラリでは、無効値に相当する値にマッピングされますが、JSONの仕様では`null`の解釈は定められていません。`null`に相当するリテラルがあればそれにマッピングされる事も多いですが、`Option`や`Maybe`といったデータ型によって`null`を表現する言語では、そのようなデータ型にマッピングされる事が多いようです。

### 3.1.7 JSONの全体像

ここまでで、JSONで現れる6つの要素について説明しましたが、JSONで使える要素は**これだけ**です。このシンプルさが、多くのプログラミング言語でJSONが使われる要因でもあるのでしょう。JSONで使える要素について改めて並べてみます。

- オブジェクト
- 配列
- 数値
- 文字列
- 真偽値
- `null`

次の節では、このJSONの**文法**が、どのような形で表現できるかについて見ていきます。

## 3.2 JSONのBNF

前の節でJSONの概要について説明し終わったところで、いよいよJSONの文法について見ていきます。JSONの文法はECMA-404の仕様書に記載されていますが、ここでは、それを若干変形したBNFで表現されたJSONの文法を見ていきます。

JSONのBNFによる定義を簡略化したものは以下で全てです。特に小数点以下の部分は煩雑になる割に本質的でないので削除しました。

```text
json = ws value ws;
object = LBRACE RBRACE | LBRACE pair {COMMA pair} RBRACE;
pair = STRING COLON value;
array = LBRACKET RBRACKET | LBRACKET value {COMMA value} RBRACKET ;
value = true | false | null | object | array | number | string;
string = ("\"\"" | "\"" CHAR+ "\"") ws;
number = INT ws;
true = "true" ws;
false = "false" ws;
null = "null" ws;

COMMA = "," ws;
COLON = ":" ws;
LBRACE = "{" ws;
RBRACE = "}" ws;
LBRACKET = "[" ws;
RBRACKET = "]" ws;

ws = (" " | "\t" | "\n" | "\r")* ;
CHAR = [^"\\] // "または\以外の文字 (バックスラッシュをエスケープ)
     | "\\" ("\"" | "\\" | "/" | "b" | "f" | "n" | "r" | "t") // エスケープ文字
     | "\\" "u" HEX HEX HEX HEX ; // \uXXXX の形式
HEX = [0-9a-fA-F];
INT = ["-"] ('0' | (`[1-9]` {`[0-9]`})) ; // 0 または 1-9で始まる数字列
```

これまで説明したJSONの要素と比較して見慣れない記号が出てきましたが、一つ一つ見て行きましょう。

### 3.2.1 json

一番上から読んでいきます。2章の復習になりますが、BNFでは、

 ```
json = ws value ws;
 ```
 
のような**規則**の集まりによって、文法を表現します。`=`の左側である`json`が**規則名**で、右側（ここでは `ws value ws`）が**本体**になります。さらに、本体の中に出てくる、他の規則を参照する部分（ここでは`value`や`ws`)を非終端記号と呼びます。非終端記号は同じBNFで定義されている規則名と一致する必要があります。
  
この規則を日本語で表現すると、「`json`という名前の規則は、`ws`の後に`value`が続き、その後`ws`になる」と読むことができます。`value`は、JSONの値を表しているので、jsonという規則は`ws`（空白文字）で囲まれたJSONの値を表しています。

### 3.2.2 object

`object`はJSONのオブジェクトを表す規則で、定義は以下のようになっています。

```
object = LBRACE RBRACE | LBRACE pair {COMMA pair} RBRACE;
```

`pair`の定義はのちほど出てきますので心配しないでください。

この規則によって`object`は

- ブレースで囲まれたもの（`LBRACE RBRACE`)である
  - `LBRACE`はLeft-Brace（開き波カッコ）の略で`{`を示しています
  - `RBRACE`はRight-Brace（閉じ波カッコ）の略で`}`を示しています
- `LBRACE`が来た後に、`pair`が1回出現して、さらにその後に、「`COMMA`（カンマ）とそれに続く`pair`」というペアが0回以上繰り返して出現した後、`RBRACE`が来る

のどちらかであることを表しています。

具体的なJSONを当てはめてみましょう。以下のJSONは`LBRACE RBRACE`にマッチします。

```js
{}
```

以下のJSONは`LBRACE pair {COMMA pair} RBRACE`にマッチします。

```js
{"x":1}
{"x":1,"y":2}
{"x":1,"y":2,"z":3}
```

しかし、以下のテキストは、`object`に当てはまらず、エラーになります。これは、規則の中を見ると、カンマ（`COMMA`）は区切り文字であるためです。

```js
{"x":1,} // ,で終わっている
```

### 3.2.3 pair

`pair`（ペア）は、JSONのオブジェクト内での`"x":1`に当たる部分を表現する規則です。`value`の定義については後述します。

```text
pair = string COLON value;
```

これによってペアは`:`（`COLON`）の前に文字列リテラル（`string`)が来て、その後にJSONの値（`value`）が来ることを表しています。`pair`にマッチするテキストとしては、

```
"x":1
"y":true
```

などがあります。一方で、以下のテキストは`pair`にマッチしません。JavaScriptのオブジェクトとJSONが違う点です。

```
x:1 // 文字列リテラルでないといけない
```

### 3.2.4 COMMA

`COMMA`は、カンマを表す規則です。カンマそのものを表すには、単に`","`と書けばいいのですが、任意個の空白文字が続くことを表現したいため、規則`ws`（後述）を参照しています。

```text
COMMA = "," ws;
```

### 3.2.5 array

`array`は、JSONの値の配列を表す規則です。

```text
array = LBRACKET RBRACKET | LBRACKET value {COMMA value} RBRACKET ;
```

`LBRACKET`は開き大カッコ（`[`）を、`RBRACKET`は閉じ大カッコ（`]`)を表しています。`value`の定義については後述します。

これによって`array`は、

- 大カッコで囲まれたもの（`LBRACKET RBRACKET`)である
- 開き大カッコ（`LBRACKET`）が来た後に、`value`が1回あらわれ、さらにその後に、「`COMMA`（カンマ）とそれに続く`value`」というペアが0回以上繰り返してあらわれた後、閉じ大カッコが来る（`RBRACKET`)

のどちらかであることを表しています。よく見ると、先程の`object`と同様の構造を持っていることがわかります。

`array`についても具体的なJSONを当てはめてみましょう。以下のJSONは`LBRACKET RBRACKET`にマッチします。

```js
[]
```

また、以下のJSONは`LBRACKET value {COMMA value} RBRACKET`にマッチします。

```js
[1]
[1, 2]
[1, 2, 3]
["foo"]
```

しかし、以下のテキストは、`array`に当てはまらず、エラーになります。`{COMMA pair}`とあるように、カンマは必ず後ろにペアを必要とするからです。

```js
[1,] // ,で終わっている
```

### 3.2.6 value

```text
value = true | false | null | number | string | object | array;
```

`value`はJSONの値を表現する規則です。これは、JSONの値は、

- 真（`true`）
- 偽（`false`）
- ヌル（`null`）
- 数値（`number`)
- 文字列（`string`)
- オブジェクト（`object`）
- 配列（`array`）

のいずれかでなければいけない事を示しています。JSONを普段使っている皆さんにはお馴染みでしょう。

### 3.2.7 true

`true`は、真を表すリテラルを表す規則です。

```text
true = "true" ws;
```

文字列 `true` が真を表すということでそのままですね。

### 3.2.8 false

`false`は、偽を表すリテラルを表す規則です。構造的には、`true`と同じです。

```text
false = "false" ws;
```

### 3.2.9 null

`null`は、ヌルリテラルを表す規則です。構造的には、`true`や`false`と同じです。

```text
null = "null" ws;
```

`null`は、ヌル値があるプログラミング言語だと、その値にマッピングされますが、ここではあくまでヌル値は`null`で表されることしか言っておらず、**意味は特に規定していない**ことに注意してください。

### 3.2.10 number

`number`は、数値リテラルを表す規則です。

```text
number = INT ws;
```

整数（`INT`）に続いて、`ws`が来るのが`number`であるということを表現しています。

### 3.2.11 string

`string`は文字列リテラルを表す規則です。

```text
string = ("\"\"" / "\"" CHAR+ "\"") ws;
```

`"`で始まって、`CHAR`で定義される文字が0個以上続いて、 `"` で終わります。`CHAR`の定義はBNF中に含まれており、エスケープシーケンスなどもここで定義されています。

### 3.2.12 JSONのBNFまとめ

JSONのBNFは、非常に少数の規則だけで表現することができます。読者の中には、あまりにも簡潔過ぎて驚かれた方もいるのではないでしょうか。しかし、これだけ単純であるにも関わらず、JSONのBNFは**再帰的に定義されている**ため、非常に複雑な構造も表現することができます。たとえば、

- 一要素の配列があり、その要素はオブジェクトであり、キー`"a"`に対応する要素の中に配列があって、その配列は空配列である

といったことも、JSONのBNFでは以下のように表現することができます。

```json
[{"a":[]}]
```

再帰的な規則は、構文解析において非常に重要な要素なので、これから本書を読み進める上でも念頭に置いてください。

## 3.3 JSONの構文解析器

JSONの定義と、文法について見てきました。この節では、BNFを元に、JSONのデータを**構文解析**するプログラムを考えてみます。とりあえずは、以下のようなインタフェース`JsonParser`インタフェースを実装したクラスを「JSONの構文解析器」と考えることにします。

```java
package parser;
interface JsonParser {
    public ParseResult<JsonAst.JsonValue> parse(String input);
}
```

クラス`ParseResult<T>`は以下のようなジェネリックなクラスになっています。`value`は解析結果の値です。これは任意の型をとり得るので、`T`としています。また、`input`は「構文解析の対象となる文字列」を表します。

```java
public record ParseResult<T>(T value, String input) {}
```

インタフェース`JsonParser`は`parse()`メソッドだけを持ちます。`parse()`メソッドは、文字列`input`を受け取り、`ParseResult<JsonAst.JsonValue>`型を返します。デザインパターンの中でも`Composite`パターンを使ったものですが、オブジェクト指向言語で、再帰的な木構造を表す時には`Composite`は定番のパターンです。

```java
public interface JsonAst {
    // value
    sealed interface JsonValue permits 
        JsonNull, JsonTrue, JsonFalse, 
        JsonNumber, JsonString, 
        JsonObject, JsonArray {}
    
    // NULL
    record JsonNull() implements JsonValue {
        @Override
        public String toString() {
            return "null";
        }
    }

    // TRUE
    record JsonTrue() implements JsonValue {
        @Override
        public String toString() {
            return "true";
        }
    }
    
    // FALSE
    record JsonFalse() implements JsonValue {
        @Override
        public String toString() {
            return "false";
        }
    }
    
    // NUMBER
    record JsonNumber(double value) implements JsonValue {
        @Override
        public String toString() {
            return "JsonNumber(" + value + '}';
        }
    }
    
    // STRING
    record JsonString(String value) implements JsonValue {
        @Override
        public String toString() {
            return "JsonString(\"" + value + "\")";
        }
    }
    
    // object
    record JsonObject(List<Pair<JsonString, JsonValue>> properties) 
        implements JsonValue {
        @Override
        public String toString() {
            return "JsonObject{" + properties + '}';
        }
    }
    
    // array
    record JsonArray(List<JsonValue> elements) 
        implements JsonValue {
        @Override
        public String toString() {
            return "JsonArray[" + elements + ']';
        }
    }
}
```

各クラスがBNFの規則名に対応しているのがわかるでしょうか。次の節では、各規則に対応するメソッドを実装することを通して、実際にJSONの構文解析器を組み上げていきます。

### 3.3.1 構文解析器の全体像

これから、JSONの構文解析器、つまり、JSONを表す文字列を受け取って、それに対応する上記の`JsonAst.JsonValue`型の値を返すメソッドを実装していくわけですが、先に構文解析器を表現するクラスの全体像を示しておきます。

```java
package parser;

import java.util.ArrayList;
import java.util.List;

public class PegJsonParser implements JsonParser {
    private int cursor;
    private String input;

    private int progressiveCursor;
    private ParseException progressiveException;

    private static class ParseException extends RuntimeException {
        public ParseException(String message) {
            super(message);
        }
    }

    public ParseResult<JsonAst.JsonValue> parse(String input) {
        this.input = input;
        this.cursor = 0;
        try {
            var value = parseValue();
            return new ParseResult<>(value, input.substring(this.cursor));
        } catch (ParseException e) {
            throw progressiveException;
        }
    }

    private void recognize(String literal) {
        if(input.substring(cursor).startsWith(literal)) {
            cursor += literal.length();
        } else {
            String substring = input.substring(cursor);
            int endIndex = cursor + (literal.length() > substring.length() ? substring.length() : literal.length());
            throwParseException("expected: " + literal + ", actual: " + input.substring(cursor, endIndex));
        }
    }

    private boolean isHexChar(char ch) {
        return ('0' <= ch && ch <= '9') || ('a' <= ch && ch <= 'f') || ('A' <= ch && ch <= 'F');
    }

    private void skipWhitespace() {
        OUTER:
        while(cursor < input.length()) {
            char currentCharacter = input.charAt(cursor);
            switch (currentCharacter) {
                // JSON (ECMA-404)で定義されている空白文字
                case ' ':       // Space
                case '\t':      // Horizontal Tab
                case '\n':      // Line Feed
                case '\r':      // Carriage Return
                    cursor++;
                    continue OUTER;
                default:
                    break OUTER;
            }
        }
    }

    private JsonAst.JsonValue parseValue() {
        int backup = cursor;
        try {
            return parseString();
        } catch (ParseException e) {
            cursor = backup;
        }

        try {
            return parseNumber();
        } catch (ParseException e) {
            cursor = backup;
        }

        try {
            return parseObject();
        } catch (ParseException e) {
            cursor = backup;
        }

        try {
            return parseArray();
        } catch (ParseException e) {
            cursor = backup;
        }

        try {
            return parseTrue();
        } catch (ParseException e) {
            cursor = backup;
        }

        try {
            return parseFalse();
        } catch (ParseException e) {
            cursor = backup;
        }

        return parseNull();
    }

    private JsonAst.JsonTrue parseTrue() {
        recognize("true");
        skipWhitespace();
        return new JsonAst.JsonTrue();
    }

    private JsonAst.JsonFalse parseFalse() {
        recognize("false");
        skipWhitespace();
        return new JsonAst.JsonFalse();
    }

    private JsonAst.JsonNull parseNull() {
        recognize("null");
        skipWhitespace();
        return new JsonAst.JsonNull();
    }

    private void parseLBrace() {
        recognize("{");
        skipWhitespace();
    }

    private void parseRBrace() {
        recognize("}");
        skipWhitespace();
    }

    private void parseLBracket() {
        recognize("[");
        skipWhitespace();
    }

    private void parseRBracket() {
        recognize("]");
        skipWhitespace();
    }

    private void parseComma() {
        recognize(",");
        skipWhitespace();
    }

    private void parseColon() {
        recognize(":");
        skipWhitespace();
    }

    private JsonAst.JsonString parseString() {
        if(cursor >= input.length()) {
            throwParseException("expected: \"" + " actual: EOF");
        }
        char ch = input.charAt(cursor);
        if(ch != '"') {
            throwParseException("expected: \"" + "actual: " + ch);
        }
        cursor++;
        var builder = new StringBuilder();
        OUTER:
        while(cursor < input.length()) {
            ch = input.charAt(cursor);
            switch(ch) {
                case '\\':
                    cursor++;
                    if(cursor >= input.length()) break OUTER;
                    char nextCh = input.charAt(cursor);
                    cursor++;
                    switch (nextCh) {
                        case 'b':
                            builder.append('\b');
                            break;
                        case 'f':
                            builder.append('\f');
                            break;
                        case 'n':
                            builder.append('\n');
                            break;
                        case 'r':
                            builder.append('\r');
                            break;
                        case 't':
                            builder.append('\t');
                            break;
                        case '\\':
                            builder.append('\\');
                            break;
                        case '"':
                            builder.append('"');
                            break;
                        case '/':
                            builder.append('/');
                            break;
                        case 'u':
                            if(cursor + 4 <= input.length()) {
                                char[] characters = input.substring(cursor, cursor + 4).toCharArray();
                                for(char character:characters) {
                                    if(!isHexChar(character)) {
                                        throwParseException("invalid unicode escape: " + character);
                                    }
                                }
                                char result = (char)Integer.parseInt(new String(characters), 16);
                                builder.append(result);
                                cursor += 4;
                            } else {
                                throwParseException("invalid unicode escape: " + input.substring(cursor));
                            }
                            break;
                        default:
                            throwParseException("expected: b|f|n|r|t|\"|\\|/ actual: " + nextCh);
                    }
                    break;
                case '"':
                    cursor++;
                    break OUTER;
                default:
                    builder.append(ch);
                    cursor++;
                    break;
            }
        }

        if(ch != '"') {
            throwParseException("expected: " + "\"" + " actual: " + ch);
        } else {
            skipWhitespace();
            return new JsonAst.JsonString(builder.toString());
        }
        throw new RuntimeException("never reach here");
    }

    private void throwParseException(String message) throws ParseException {
        var exception = new ParseException(message);
        if(progressiveCursor < cursor) {
            progressiveCursor = cursor;
            progressiveException = exception;
        }
        throw exception;
    }

    private JsonAst.JsonNumber parseNumber() {
        int start = cursor;
        char ch = 0;
        while(cursor < input.length()) {
            ch = input.charAt(cursor);
            if(!('0' <= ch && ch <= '9')) break;
            cursor++;
        }
        if(start == cursor) {
            throwParseException("expected: [0-9] actual: " + (ch != 0 ? ch : "EOF"));
        }
        return new JsonAst.JsonNumber(Integer.parseInt(input.substring(start, cursor)));
    }

    private Pair<JsonAst.JsonString, JsonAst.JsonValue> parsePair() {
        var key = parseString();
        parseColon();
        var value = parseValue();
        return new Pair<>(key, value);
    }

    private JsonAst.JsonObject parseObject() {
        int backup = cursor;
        try {
            parseLBrace();
            parseRBrace();
            return new JsonAst.JsonObject(new ArrayList<>());
        } catch (ParseException e) {
            cursor = backup;
        }

        parseLBrace();
        List<Pair<JsonAst.JsonString, JsonAst.JsonValue>> members = new ArrayList<>();
        var member = parsePair();
        members.add(member);
        try {
            while (true) {
                parseComma();
                member = parsePair();
                members.add(member);
            }
        } catch (ParseException e) {
            parseRBrace();
            return new JsonAst.JsonObject(members);
        }
    }

    public JsonAst.JsonArray parseArray() {
        int backup = cursor;
        try {
            parseLBracket();
            parseRBracket();
            return new JsonAst.JsonArray(new ArrayList<>());
        } catch (ParseException e) {
            cursor = backup;
        }

        parseLBracket();
        List<JsonAst.JsonValue> values = new ArrayList<>();
        var value = parseValue();
        values.add(value);
        try {
            while (true) {
                parseComma();
                value = parseValue();
                values.add(value);
            }
        } catch (ParseException e) {
            parseRBracket();
            return new JsonAst.JsonArray(values);
        }
    }
}
```

このクラス`PegJsonParser`で重要なことは、クラスがフィールドとして以下を保持していることです。

```java
public class PegJsonParser implements JsonParser {
    private int cursor;
    private String input;
    private int progressiveCursor;
    private ParseException progressiveException;
    // ...
}
```

構文解析器を実装する方法としては、同じ入力文字列を与えれば同じ解析結果が返ってくるような関数型の実装方法と、今回のように、現在どこまで読み進めたかによって解析結果が変わる手続き型の方法があるのですが、手続き型の方が説明しやすいので、本書では手続き型の実装方法を採用しています。

`progressiveCursor` と `progressiveException` フィールドは、主にエラー報告の質を向上させるために導入されています。`throwParseException` メソッド内で、現在の `cursor` がこれまでの `progressiveCursor` よりも進んでいれば、その位置で発生した例外を `progressiveException` として保存します。これにより、複数の解析経路を試行する中で最も深く（最も多くの文字を消費して）到達した箇所で発生したエラーを最終的なエラーとして報告することができます。例えば、`{"key": tru}` のような不正なJSONがあった場合、`parseValue` はまず `parseString` を試み、次に `parseNumber` を試み…と進み、最終的に `parseTrue` を試行します。この `parseTrue` の中で "tru" まで読み進んだ時点で "true" とのマッチに失敗し例外が発生します。このとき `progressiveCursor` は "tru" の末尾を指しているため、エラーメッセージにはより具体的なエラー位置（例: "expected: e, actual: EOF at position X" のように）を示す情報を含めることが可能になります。

また、`parseValue()` メソッド内の実装に注目してください。

```java
    private JsonAst.JsonValue parseValue() {
        int backup = cursor;
        try {
            return parseString();
        } catch (ParseException e) {
            cursor = backup;
        }

        try {
            return parseNumber();
        } catch (ParseException e) {
            cursor = backup;
        }
        // ... (以下同様に parseObject, parseArray, parseTrue, parseFalse, parseNull と続く)
        return parseNull();
    }
```
これは、PEGにおける「順序付き選択 (Ordered Choice)」の挙動を模倣しています。BNFの `value = string | number | object | array | true | false | null;` という定義に対し、PEGではこの選択肢を左から順番に試行し、最初に成功したものが解析結果として採用されます。このコードでは、`parseString()` を試し、失敗したらカーソルを元に戻して `parseNumber()` を試す、というように、定義された順序で各解析メソッドを呼び出しています。この順序が重要であり、例えば `parseTrue()` よりも先に `parseString()` が試行されるため、`"true"` という入力は文字列ではなく真偽値として正しく解析されます（`parseString` は `"` で始まらないため失敗し、次に試行される `parseTrue` が成功する）。

### 3.3.2 nullの構文解析メソッド

`null`の構文解析は、次のような　`parseNull()` メソッドとして定義します。

```java
private JsonAst.JsonNull parseNull() {
    recognize("null");
    skipWhitespace();
    return new JsonAst.JsonNull();
}

```

　このメソッドで行っていることを見ていきましょう。このメソッドでは、入力である`input`の現在位置が`"null"`という文字列で始まっているかをチェックします。もしそうなら、**JSONのnull**をあらわす`JsonAst.JsonNull`のインスタンスを返します。もし、先頭が`"null"`でなければ、構文解析は失敗なので例外を発生させますが、これは`recognize()`メソッドの中で行われています。`recognize()`の内部では、入力の現在位置と与えられた文字列を照合して、マッチしない場合例外を投げます。

次に、`skipWhitespace()`メソッドを呼び出して、「空白の読み飛ばし」を行っています。

　`recognize()`も`skipWhitespace()`も構文解析中に頻出する処理であるため、今回はそれぞれをメソッドにくくりだして、各構文解析メソッドの中で呼び出せるようにしました。

### 3.3.3 trueの構文解析メソッド

`true`の構文解析は、次のような `parseTrue()` メソッドとして定義します。

```java
private JsonAst.JsonTrue parseTrue() {
    recognize("true");
    skipWhitespace();
    return new JsonAst.JsonTrue();
}
```

　見ればわかりますが、`parseNull()`とほぼ同じです。固定の文字列を解析するという点で両者はほぼ同じ処理であり、引数を除けば同じ処理になるのです。

### 3.3.4 falseの構文解析メソッド

`false`の構文解析は、次のシグニチャを持つ `parseFalse()` メソッドとして定義します。

```java
private JsonAst.JsonFalse parseFalse() {
    recognize("false");
    skipWhitespace();
    return new JsonAst.JsonFalse();
}
```

　これも、`parseNull()`とほぼ同じですので、特に説明の必要はないでしょう。

### 3.3.5 数値の構文解析メソッド

数値の構文解析は、次のシグニチャを持つ `parseNumber()` メソッドとして定義します。

```java
    private JsonAst.JsonNumber parseNumber() {
        // 本書の実装では、JSONの数値型を整数のみに限定して扱います。
        // ECMA-404仕様では小数や指数表現も許容されますが、ここでは構文解析の基本を学ぶため単純化しています。
        int start = cursor;
        char ch = 0;
        // オプショナルなマイナス記号
        if (cursor < input.length() && input.charAt(cursor) == '-') {
            cursor++;
        }

        // 数字の連続 (0, または 1-9 で始まり数字が続く)
        int digitsStart = cursor;
        if (cursor < input.length()) {
            ch = input.charAt(cursor);
            if (ch == '0') {
                cursor++;
            } else if ('1' <= ch && ch <= '9') {
                cursor++;
                while (cursor < input.length()) {
                    ch = input.charAt(cursor);
                    if (!('0' <= ch && ch <= '9')) break;
                    cursor++;
                }
            } else {
                // 数字で始まらない場合はエラー
                throwParseException("expected: digit actual: " + (cursor < input.length() ? input.charAt(cursor) : "EOF"));
            }
        } else {
             throwParseException("expected: digit actual: EOF");
        }

        if (digitsStart == cursor && !(input.charAt(digitsStart-1) == '0' && (digitsStart > start && input.charAt(start) == '-'))) { // "0"単体または"-0"はOKだが、"-"のみや、"-A"などはだめ
             if(digitsStart > start && input.charAt(start) == '-'){ // "-" のみのケース
                 throwParseException("expected: digit after '-' actual: " + (cursor < input.length() ? input.charAt(cursor) : "EOF"));
             }
        }
        
        String numberStr = input.substring(start, cursor);
        try {
            // ここでは簡単のためdoubleとしていますが、より厳密にはBigDecimalなどを使うべきケースもあります。
            // また、この実装はECMA-404のnumberのBNFとは完全に一致していません（小数部、指数部を省略）。
            double value = Double.parseDouble(numberStr);
            skipWhitespace();
            return new JsonAst.JsonNumber(value);
        } catch (NumberFormatException e) {
            throwParseException("invalid number format: " + numberStr);
        }
        // Unreachable, but to satisfy compiler
        return null;
    }
```

`parseNumber()` メソッド（PegJsonParser内）では、入力文字列から数値部分を読み取り、`Double.parseDouble` を用いて数値に変換しています。この実装は、ECMA-404で定義されるJSONの数値型の完全な仕様（小数部、指数部を含む）には対応しておらず、主に整数および一部の小数表現を扱えるように単純化されています。
ECMA-404仕様では、数値は整数部、小数部（オプション）、指数部（オプション）を持つことができます。例えば、`-0.123e+10` のような形式も許容されます。本書の実装では簡単のため整数のみを対象としていますが、より厳密なパーサーでは、これらの形式に対応するために `BigDecimal` クラスを使用したり、BNF定義に完全に準拠した数値解析ロジック（小数点の有無、`e` または `E` に続く指数部の解析など）を実装する必要があります。例えば、`JsonAst.JsonNumber` の型を `BigDecimal` に変更し、`parseNumber` 内で `new BigDecimal(numberStr)` を使用するように修正することが考えられます。ただし、本書では構文解析の基本的な流れを理解することを優先しています。

### 3.3.6 文字列の構文解析メソッド

文字列の構文解析は、次のシグニチャを持つ `parseString()` メソッドとして定義します。

```java
    private JsonAst.JsonString parseString() {
        if(cursor >= input.length()) {
            throwParseException("expected: \"" + " actual: EOF");
        }
        char ch = input.charAt(cursor);
        if(ch != '"') {
            throwParseException("expected: \"" + "actual: " + ch);
        }
        cursor++;
        var builder = new StringBuilder();
        OUTER:
        while(cursor < input.length()) {
            ch = input.charAt(cursor);
            switch(ch) {
                case '\\':
                    cursor++;
                    if(cursor >= input.length()) break OUTER;
                    char nextCh = input.charAt(cursor);
                    cursor++;
                    switch (nextCh) {
                        case 'b':
                            builder.append('\b');
                            break;
                        case 'f':
                            builder.append('\f');
                            break;
                        case 'n':
                            builder.append('\n');
                            break;
                        case 'r':
                            builder.append('\r');
                            break;
                        case 't':
                            builder.append('\t');
                            break;
                        case '\\':
                            builder.append('\\');
                            break;
                        case '"':
                            builder.append('"');
                            break;
                        case '/':
                            builder.append('/');
                            break;
                        case 'u':
                            if(cursor + 4 <= input.length()) {
                                char[] characters = input.substring(cursor, cursor + 4).toCharArray();
                                for(char character:characters) {
                                    if(!isHexChar(character)) {
                                        throwParseException("invalid unicode escape: " + character);
                                    }
                                }
                                char result = (char)Integer.parseInt(new String(characters), 16);
                                builder.append(result);
                                cursor += 4;
                            } else {
                                throwParseException("invalid unicode escape: " + input.substring(cursor));
                            }
                            break;
                        default:
                            throwParseException("expected: b|f|n|r|t|\"|\\|/ actual: " + nextCh);
                    }
                    break;
                case '"':
                    cursor++;
                    break OUTER;
                default:
                    builder.append(ch);
                    cursor++;
                    break;
            }
        }

        if(ch != '"') {
            throwParseException("expected: " + "\"" + " actual: " + ch);
        } else {
            skipWhitespace();
            return new JsonAst.JsonString(builder.toString());
        }
        throw new RuntimeException("never reach here");
    }
```

`while`文の中が若干複雑になっていますが、一つ一つ見ていきます。

まず、最初の部分では、

```java
        if(cursor >= input.length()) {
            throwParseException("expected: \"" + " actual: EOF");
        }
        char ch = input.charAt(cursor);
        if(ch != '"') {
            throwParseException("expected: \"" + "actual: " + ch);
        }
        cursor++;
```

- 入力が終端に達していないこと
- 入力の最初が`"`であること

をチェックしています。文字列は当然ながら、ダブルクォートで始まりますし、文字列リテラルは、最低長さが2あるので、それらの条件が満たされなければ例外が投げられるわけです。

`while`文の中では、最初が

- `\` であるか（エスケープシーケンスか）
- それ以外か

を`switch`文で判定して分岐しています。JSONで使えるエスケープシーケンスは、ECMA-404仕様で以下のように定義されています。

- `\"` (ダブルクォート)
- `\\` (バックスラッシュ)
- `\/` (スラッシュ)
- `\b` (バックスペース)
- `\f` (フォームフィード)
- `\n` (ラインフィード)
- `\r` (キャリッジリターン)
- `\t` (水平タブ)
- `\uXXXX` (4桁の16進数で表されるUnicode文字。サロゲートペアを表現する場合は `\uHHHH\uLLLL` のように2つのシーケンスを記述します)

`parseString` メソッド内の `switch` 文はこれらのエスケープシーケンスを処理しています。

そして、`while`文が終わったあとで、


```java
        if(ch != '"') {
            throwParseException("expected: " + "\"" + " actual: " + ch);
        } else {
            skipWhitespace();
            return new JsonAst.JsonString(builder.toString());
        }
        throw new RuntimeException("never reach here");
```

というチェックを入れることによって、ダブルクォートで文字列が終端している事を確認した後、空白を読み飛ばしています。

メソッドの末尾で`RuntimeException`を`throw`しているのは、ここに到達することは、構文解析器にバグが無い限りはありえないことを示しています。

### 3.3.7 配列の構文解析メソッド

配列の構文解析は、次のシグニチャを持つ `parseArray()` メソッドとして定義します。

```java
    public JsonAst.JsonArray parseArray() {
        int backup = cursor;
        try {
            parseLBracket();
            parseRBracket();
            return new JsonAst.JsonArray(new ArrayList<>());
        } catch (ParseException e) {
            cursor = backup;
        }

        parseLBracket();
        List<JsonAst.JsonValue> values = new ArrayList<>();
        var value = parseValue();
        values.add(value);
        try {
            while (true) {
                parseComma();
                value = parseValue();
                values.add(value);
            }
        } catch (ParseException e) {
            parseRBracket();
            return new JsonAst.JsonArray(values);
        }
    }
```

この`parseArray()`は多少複雑になります。まず、先頭に`"["`が来るかチェックする必要があります。これをコードにすると、以下のようになります。

```java
parseLBracket();
```

`parseLBracket()`は以下のように定義されています。

```java
 private void parseLBracket() {
    recognize("[");
    skipWhitespace();
}
```

`recognize()`で、現在の入力位置が`[`と一致しているかチェックをした後、空白を読み飛ばしています。
　
この`recognize()`は、与えられた文字列リテラルが入力先頭とマッチするかをチェックし、マッチするなら入力を前に進めて、マッチしないなら例外を投げます。内部の実装は以下のようになります。

```java
    private void recognize(String literal) {
        if(input.substring(cursor).startsWith(literal)) {
            cursor += literal.length();
        } else {
            String substring = input.substring(cursor);
            int endIndex = cursor + (literal.length() > substring.length() ? substring.length() : literal.length());
            throwParseException("expected: " + literal + ", actual: " + input.substring(cursor, endIndex));
        }
    }
```

　このようにすることで、マッチしない場合に例外を投げ、そうでなければ入力進めるという挙動を実装できます。`[`の次には任意の`JsonValue`または`"]"`が来る可能性があります。この時、まず最初に、`]`が来ると**仮定**するのがポイントです。

```java
        int backup = cursor;
        try {
            parseLBracket();
            parseRBracket();
            return new JsonAst.JsonArray(new ArrayList<>());
        } catch (ParseException e) {
            cursor = backup;
        }
```

もし、仮定が成り立たなかった場合、`ParseException`がthrowされるはずですから、それをcatchして、バックアップした位置に巻き戻します。

`]`が来るという仮定が成り立たなかった場合、再び最初に`[`が出現して、その次に来るのは任意の`JsonValue`ですから、以下のようなコードになります。

```java
        parseLBracket();
        List<JsonAst.JsonValue> values = new ArrayList<>();
        var value = parseValue();
        values.add(value);
```

ローカル変数`values`は、配列の要素を格納するためのものです。

配列の中で、最初の要素が読み込まれた後、次に来るのは、`,`か`]`のどちらかですが、ひとまず、`,`が来ると仮定して`while`ループで

```java
parseComma();
value = parseValue();
values.add(value);
```

を繰り返します。この繰り返しは、1回ごとに必ず入力を1以上進めます。失敗した時は、テキストが正しいJSONなら、`]`が来るはずなので、

```java
parseRBracket();
return new JsonAst.JsonArray(values);
```

とします。もし、テキストが正しいJSONでない場合、`parseRBracket()`から例外が投げられるはずですが、その例外は**より上位の層が適切にリカバーしてくれると期待して**放置します。JSONのような再帰的な構造を解析する時、このような、「自分の呼び出し元が適切にやってくれるはず」（何故なら、自分はその呼び出し元で適切にcatchしているのだから）という考え方が重要になります。

多少複雑になりましたが、`parseArray()`の定義が、EBNFにおける表記

```text
array = LBRACKET RBRACKET | LBRACKET {value {COMMA value}} RBRACKET ;
```

に対応していることがわかるでしょうか（ただし、ここでのBNFは `array = LBRACKET RBRACKET | LBRACKET value {COMMA value} RBRACKET ;` のように、最初の要素が必須である点に注意してください。これはコードの実装と一致しています）。読み方のポイントは、`|`の後を、例外をキャッチした後の処理ととらえることです。

### 3.3.8 オブジェクトの構文解析メソッド

オブジェクトの構文解析は、次のシグニチャを持つ `parseObject()` メソッドとして定義します。

```java
    private JsonAst.JsonObject parseObject() {
        int backup = cursor;
        try {
            parseLBrace();
            parseRBrace();
            return new JsonAst.JsonObject(new ArrayList<>());
        } catch (ParseException e) {
            cursor = backup;
        }

        parseLBrace();
        List<Pair<JsonAst.JsonString, JsonAst.JsonValue>> members = new ArrayList<>();
        var member = parsePair();
        members.add(member);
        try {
            while (true) {
                parseComma();
                member = parsePair();
                members.add(member);
            }
        } catch (ParseException e) {
            parseRBrace();
            return new JsonAst.JsonObject(members);
        }
    }
```

この定義を見て、ひょっとしたら、

「あれ？これ、`parseArray()`とほとんど同じでは」

と気づかれた読者の方が居るかも知れません。実際、`parseObject()`がやっていることは`parseArray()`と非常に類似しています。

最初に、

```java
parseLBrace();
parseRBrace();
return new JsonAst.JsonObject(new ArrayList<>());
```

としている箇所は、`{}`という形の空オブジェクトを読み取ろうとしていますが、これは、空配列`[]`を読み取るコードとほぼ同じです。

続くコードも、対応する記号が`{}`か`[]`の違いこそあるものの、基本的に同じです。唯一の違いは、オブジェクトの各要素は、`name:value`というペアなため、`parseValue()`の代わりに`parsePair()`を呼び出しているところくらいです。

そして、`parsePair()`は以下のように定義されています。

```java
    private Pair<JsonAst.JsonString, JsonAst.JsonValue> parsePair() {
        var key = parseString();
        parseColon();
        var value = parseValue();
        return new Pair<>(key, value);
    }
```

これはEBNFにおける以下の定義にそのまま対応しているのがわかるでしょう。

```
pair = string COLON value;
```

### 3.3.9 構文解析における再帰

配列やオブジェクトの構文解析メソッドを見るとわかりますが、

- `parseArray() -> parseValue() -> parseArray()`
- `parseArray() -> parseValue() -> parseObject()`
- `parseObject() -> parseValue() -> parseObject()`
- `parseObject() -> parseValue() -> parseArray()`

のような再帰呼び出しが起こり得ることがわかります。このような再帰呼び出しでは、各ステップで必ず構文解析が1文字以上進むため、JSONがどれだけ深くなっても（スタックが溢れない限り）うまく構文解析ができるのです。

### 3.3.10 構文解析とPEG

このようにしてJSONの構文解析器を実装することが出来ましたが、実は、この節で紹介した技法は古典的な構文解析の技法では**ありません**。

この節で解説した技法は、Parsing Expression Grammar(PEG)と呼ばれる手法に基づいています。

PEGは2004にBryan Ford（ブライアン・フォード）によって提案された形式文法であり、従来主流であったCFG(Context-Free Grammar)と違う特徴を持ちますが、プログラミング言語など曖昧性の無い言語の解析に使うのには便利であり、最近では色々な言語でPEGをベースにした構文解析器が実装されています。メジャーな言語だとPythonは3.9からPEGベースの構文解析器を使うようになりました。

PEGはとてもシンプルなので、先にPEGを使った技法を学ぶことで、構文解析についてスムーズに理解してもらえたのではないかと思います。ただし、従来の構文解析手法（という言い方は不適切で、依然として従来の手法の方がよく使われています）を学ぶのも重要な事ですので、次の節では、従来型の構文解析手法について解説します。

## 3.4 古典的な構文解析器

前節では、構文解析法の一種であるPEGを取り扱いましたが、通常の構文解析法では、字句解析という前処理を行ってから構文解析を行います。字句解析の字句は英語ではトークン（`token`）と言われるものです。たとえば、以下の英文があったとします。

```
We are parsers.
```

我々は構文解析器であるというジョーク的な文ですが、それはさておき、この文は

```
[We, are, parsers]
```

という三つのトークン（単語）に分解すると考えるのが字句解析の発想法です。

古典的な構文解析の世界では、字句解析が必須とされていましたが、それは後の章で説明される構文解析アルゴリズムの都合に加えて、空白のスキップという処理を字句解析で行えるからでもあります。

前節で出てきたJSONの構文解析器では`skipWhitespace()`の呼び出しが頻出していましたが、字句解析器を使う場合、空白を読み飛ばす処理を先に行うことで、構文解析器では空白の読み飛ばしという作業をしなくてよくなります。

この点はトレードオフがあって、たとえば、空白に関する規則がある言語の中でブレがある場合には、字句解析という前処理はかえってしない方が良いということすらあります。ともあれ、字句解析という前処理を通すことには一定のメリットがあるのは確かです。

以下では字句解析器を使った構文解析器の全体像を示します。まず最初に、JSONの字句解析器は次のようになります。

```java
package parser;

public class SimpleJsonTokenizer implements JsonTokenizer {
    private final String input;
    private int index;
    private Token fetched;

    public SimpleJsonTokenizer(String input) {
        this.input = input;
        this.index = 0;
    }

    public String rest() {
        return input.substring(index);
    }

    private static boolean isDigit(char ch) {
        return '0' <= ch && ch <= '9';
    }

    private boolean tokenizeNumber(boolean positive) {
        char firstChar = input.charAt(index);
        if(!isDigit(firstChar)) return false;
        int result = 0;
        while(index < input.length()) {
            char ch = input.charAt(index);
            if(!isDigit(ch)) {
                fetched = new Token(Token.Type.INTEGER, positive ? result : -result);
                return true;
            }
            result = result * 10 + (ch - '0');
            index++;
        }
        fetched = new Token(Token.Type.INTEGER, positive ? result : -result);
        return true;
    }

    private boolean tokenizeStringLiteral() {
        char firstChar = input.charAt(index);
        int beginIndex = index;
        if(firstChar != '"') return false;
        index++;
        var builder = new StringBuffer();
        while(index < input.length()) {
            char ch = input.charAt(index);
            if(ch == '"') {
                fetched = new Token(Token.Type.STRING, builder.toString());
                index++;
                return true;
            }
            if(ch == '\\') {
                index++;
                if(index >= input.length()) return false;
                char nextCh = input.charAt(index);
                switch(nextCh) {
                    case '\\':
                        builder.append('\\');
                        break;
                    case '"':
                        builder.append('"');
                        break;
                    case '/':
                        builder.append('/');
                        break;
                    case 't':
                        builder.append('\t');
                        break;
                    case 'f':
                        builder.append('\f');
                        break;
                    case 'b':
                        builder.append('\b');
                        break;
                    case 'r':
                        builder.append('\r');
                        break;
                    case 'n':
                        builder.append('\n');
                        break;
                    case 'u':
                        // \u の後に4文字の16進数が必要
                        if(index + 4 >= input.length()) { // index は 'u' の次の文字を指している
                            throw new TokenizerException("unicode escape sequence is too short: " + input.substring(index -1));
                        }
                        var unicodeEscape = input.substring(index, index + 4); // 'u'の次の文字から4文字取得
                        if(!unicodeEscape.matches("[0-9a-fA-F]{4}")) {
                            throw new TokenizerException("illegal unicode escape sequence: \\u" + unicodeEscape);
                        }
                        builder.append((char)Integer.parseInt(unicodeEscape, 16));
                        index += 4; // 4文字消費
                        break;
                }
            } else {
                builder.append(ch);
            }
            index++;
        }
        return false; // 閉じの " が見つからなかった場合
    }

    private void accept(String literal, Token.Type type, Object value) {
        String head = input.substring(index);
        if(head.indexOf(literal) == 0) {
            fetched = new Token(type, value);
            index += literal.length();
        } else {
            throw new TokenizerException("expected: " + literal + ", actual: " + head);
        }
    }

    @Override
    public Token current() {
        return fetched;
    }

    @Override
    public boolean moveNext() {
        LOOP:
        while(index < input.length()) {
            char ch = input.charAt(index);
            switch (ch) {
                case '[':
                    accept("[", Token.Type.LBRACKET, "[");
                    return true;
                case ']':
                    accept("]", Token.Type.RBRACKET, "]");
                    return true;
                case '{':
                    accept("{", Token.Type.LBRACE, "{");
                    return true;
                case '}':
                    accept("}", Token.Type.RBRACE, "}");
                    return true;
                case '(':
                    accept("(", Token.Type.LPAREN, "(");
                    return true;
                case ')':
                    accept(")", Token.Type.RPAREN, ")");
                    return true;
                case ',':
                    accept(",", Token.Type.COMMA, ",");
                    return true;
                case ':':
                    accept(":", Token.Type.COLON, ":");
                    return true;
                // true
                case 't':
                    accept("true", Token.Type.TRUE, true);
                    return true;
                // false
                case 'f':
                    accept("false", Token.Type.FALSE, false);
                    return true;
                case 'n': {
                    String actual;
                    if (index + 4 <= input.length()) {
                        actual = input.substring(index, index + 4);
                        if (actual.equals("null")) {
                            fetched = new Token(Token.Type.NULL, null);
                            index += 4;
                            return true;
                        } else {
                            throw new TokenizerException("expected: null, actual: " + actual);
                        }
                    } else {
                        actual = input.substring(index);
                        throw new TokenizerException("expected: null, actual: " + actual);
                    }
                }
                case '"':
                    return tokenizeStringLiteral();
                // whitespace (JSON仕様準拠)
                case ' ':       // Space
                case '\t':      // Horizontal Tab
                case '\n':      // Line Feed
                case '\r':      // Carriage Return
                    index++; // 現在の空白文字を消費
                    // 連続する空白を読み飛ばす
                    while(index < input.length()) {
                        char nextChar = input.charAt(index);
                        if (nextChar == ' ' || nextChar == '\t' || nextChar == '\n' || nextChar == '\r') {
                            index++;
                        } else {
                            break;
                        }
                    }
                    continue LOOP;
                default:
                    if('0' <= ch && ch <= '9') {
                        return tokenizeNumber(true);
                    } else if (ch == '+') {
                        index++;
                        return tokenizeNumber(true);
                    } else if (ch == '-') {
                        index++;
                        return tokenizeNumber(false);
                    } else {
                        throw new TokenizerException("unexpected character: " + ch);
                    }
            }
        }
        return false;
    }
}
```

これを利用した構文解析器のコードを示します。

```java
package parser;

import java.util.ArrayList;
import java.util.List;

public class SimpleJsonParser implements JsonParser {
    private SimpleJsonTokenizer tokenizer;

    public ParseResult<JsonAst.JsonValue> parse(String input) {
        tokenizer = new SimpleJsonTokenizer(input);
        tokenizer.moveNext();
        var value = parseValue();
        return new ParseResult<>(value, tokenizer.rest());
    }

    private JsonAst.JsonValue parseValue() {
        var token = tokenizer.current();
        switch(token.type) {
            case INTEGER:
                return parseNumber();
            case STRING:
                return parseString();
            case TRUE:
                return parseTrue();
            case FALSE:
                return parseFalse();
            case NULL:
                return parseNull();
            case LBRACKET:
                return parseArray();
            case LBRACE:
                return parseObject();
        }
        throw new RuntimeException("cannot reach here");
    }

    private JsonAst.JsonTrue parseTrue() {
        Token currentToken = tokenizer.current();
        if(currentToken.type == Token.Type.TRUE) {
            tokenizer.moveNext(); // トークンを消費
            return new JsonAst.JsonTrue();
        }
        throw new parser.ParseException("expected: true, actual: " + currentToken.value);
    }

    private JsonAst.JsonFalse parseFalse() {
        Token currentToken = tokenizer.current();
        if(currentToken.type == Token.Type.FALSE) {
            tokenizer.moveNext(); // トークンを消費
            return new JsonAst.JsonFalse();
        }
        throw new parser.ParseException("expected: false, actual: " + currentToken.value);
    }

    private JsonAst.JsonNull parseNull() {
        Token currentToken = tokenizer.current();
        if(currentToken.type == Token.Type.NULL) {
            tokenizer.moveNext(); // トークンを消費
            return new JsonAst.JsonNull();
        }
        throw new parser.ParseException("expected: null, actual: " + currentToken.value);
    }

    private JsonAst.JsonString parseString() {
        Token currentToken = tokenizer.current();
        if (currentToken.type == Token.Type.STRING) {
            tokenizer.moveNext(); // トークンを消費
            return new JsonAst.JsonString((String)currentToken.value);
        }
        throw new parser.ParseException("expected: string, actual: " + currentToken.value);
    }

    private JsonAst.JsonNumber parseNumber() {
        Token currentToken = tokenizer.current();
        // SimpleJsonTokenizerの実装では数値はToken.Type.INTEGERとして扱われる
        if (currentToken.type == Token.Type.INTEGER) {
            tokenizer.moveNext(); // トークンを消費
            // JsonNumberはdoubleを期待するが、tokenizerはintを返すのでキャスト
            return new JsonAst.JsonNumber(((Number)currentToken.value).doubleValue());
        }
        throw new parser.ParseException("expected: number, actual: " + currentToken.value);
    }

    private Pair<JsonAst.JsonString, JsonAst.JsonValue> parsePair() {
        // オブジェクトのキーは必ず文字列
        Token keyToken = tokenizer.current();
        if (keyToken.type != Token.Type.STRING) {
            throw new parser.ParseException("expected: string for object key, actual: " + keyToken.value);
        }
        JsonAst.JsonString key = new JsonAst.JsonString((String)keyToken.value);
        tokenizer.moveNext(); // キー文字列トークンを消費

        if(tokenizer.current().type != Token.Type.COLON) {
            throw new parser.ParseException("expected: `:`, actual: " + tokenizer.current().value);
        }
        tokenizer.moveNext();
        var value = parseValue();
        return new Pair<>(key, value);
    }

    private JsonAst.JsonObject parseObject() {
        if(tokenizer.current().type != Token.Type.LBRACE) {
            throw new parser.ParseException("expected `{`, actual: " + tokenizer.current().value);
        }

        tokenizer.moveNext();
        if(tokenizer.current().type == Token.Type.RBRACE) {
            return new JsonAst.JsonObject(new ArrayList<>());
        }

        List<Pair<JsonAst.JsonString, JsonAst.JsonValue>> members = new ArrayList<>();
        var pair= parsePair();
        members.add(pair);

        while(tokenizer.moveNext()) {
            if(tokenizer.current().type == Token.Type.RBRACE) {
                return new JsonAst.JsonObject(members);
            }
            if(tokenizer.current().type != Token.Type.COMMA) {
                throw new parser.ParseException("expected: `,`, actual: " + tokenizer.current().value);
            }
            tokenizer.moveNext();
            pair = parsePair();
            members.add(pair);
        }

        throw new parser.ParseException("unexpected EOF");
    }

    private JsonAst.JsonArray parseArray() {
        if(tokenizer.current().type != Token.Type.LBRACKET) {
            throw new parser.ParseException("expected: `[`, actual: " + tokenizer.current().value);
        }

        tokenizer.moveNext();
        if(tokenizer.current().type == Token.Type.RBRACKET) {
            return new JsonAst.JsonArray(new ArrayList<>());
        }

        List<JsonAst.JsonValue> values = new ArrayList<>();
        var value = parseValue();
        values.add(value);

        while(tokenizer.moveNext()) {
            if(tokenizer.current().type == Token.Type.RBRACKET) {
                return new JsonAst.JsonArray(values);
            }
            if(tokenizer.current().type != Token.Type.COMMA) {
                throw new parser.ParseException("expected: `,`, actual: " + tokenizer.current().value);
            }
            tokenizer.moveNext();
            value = parseValue();
            values.add(value);
        }

        throw new ParseException("unexpected EOF");
    }
}
```

構文解析器から呼び出されている`parserXXX()`メソッドを見るとわかりますが、字句解析器を導入したことによって、文字列の代わりにトークンの列を順に読み込んで、期待通りのトークンが現れたかを事前にチェックしています。また、この構文解析器には空白の読み飛ばしに関する処理が入っていないことに着目してください。

PEG版と異なり、途中で失敗したら後戻り（バックトラック）するという処理も存在しません。後戻りによって、文法の柔軟性を増すというメリットがある一方、構文解析器の速度が落ちるというデメリットもあるため、字句解析器を用いた構文解析器は一般により高速に動作します（ただし、実装者の力量の影響も大きいです）。

ここで、字句解析器と構文解析器の連携について、具体的なJSON文字列 `{"key": "value"}` を例に、その解析ステップを見てみましょう。

**入力:** `{"key": "value"}`

**1. `SimpleJsonParser.parse("{\"key\": \"value\"}")` が呼び出される。**
   - `tokenizer = new SimpleJsonTokenizer("{\"key\": \"value\"}")` が実行される。
   - `tokenizer.moveNext()` が呼び出される。
     - `SimpleJsonTokenizer.moveNext()`:
       - `index` は 0。`input.charAt(0)` は `{`。
       - `accept("{", Token.Type.LBRACE, "{")` が呼び出される。
       - `fetched` に `Token(LBRACE, "{")` が設定され、`index` は 1 になる。
       - `true` を返す。
   - `value = parseValue()` が呼び出される。

**2. `SimpleJsonParser.parseValue()` 内:**
   - `token = tokenizer.current()` により、`Token(LBRACE, "{")` を取得。
   - `switch(token.type)` で `LBRACE` ケースが選択され、`parseObject()` が呼び出される。

**3. `SimpleJsonParser.parseObject()` 内:**
   - `tokenizer.current().type` は `LBRACE` なので最初の `if` はパス。
   - `tokenizer.moveNext()` が呼び出される。
     - `SimpleJsonTokenizer.moveNext()`:
       - `index` は 1。`input.charAt(1)` は `"`。
       - `tokenizeStringLiteral()` が呼び出される。
         - `"key"` を読み取り、`fetched` に `Token(STRING, "key")` が設定され、`index` は 6 になる。
         - `true` を返す。
   - `tokenizer.current().type` は `RBRACE` ではない。
   - `pair = parsePair()` が呼び出される。

**4. `SimpleJsonParser.parsePair()` 内:**
   - `keyToken = tokenizer.current()` により `Token(STRING, "key")` を取得。
   - `key = new JsonAst.JsonString("key")` が作成される。
   - `tokenizer.moveNext()` が呼び出される。
     - `SimpleJsonTokenizer.moveNext()`:
       - `index` は 6。`input.charAt(6)` は `:`。
       - `accept(":", Token.Type.COLON, ":")` が呼び出される。
       - `fetched` に `Token(COLON, ":")` が設定され、`index` は 7 になる。
       - `true` を返す。
   - `tokenizer.current().type` は `COLON` なので `if` はパス。
   - `tokenizer.moveNext()` が呼び出される。
     - `SimpleJsonTokenizer.moveNext()`:
       - `index` は 7。`input.charAt(7)` は `"`。
       - `tokenizeStringLiteral()` が呼び出される。
         - `"value"` を読み取り、`fetched` に `Token(STRING, "value")` が設定され、`index` は 14 になる。
         - `true` を返す。
   - `value = parseValue()` が呼び出される。

**5. `SimpleJsonParser.parseValue()` (2回目) 内:**
   - `token = tokenizer.current()` により `Token(STRING, "value")` を取得。
   - `switch(token.type)` で `STRING` ケースが選択され、`parseString()` が呼び出される。

**6. `SimpleJsonParser.parseString()` 内:**
   - `currentToken.type` は `STRING` なので `if` はパス。
   - `tokenizer.moveNext()` が呼び出される。
     - `SimpleJsonTokenizer.moveNext()`:
       - `index` は 14。`input.charAt(14)` は `}`。
       - `accept("}", Token.Type.RBRACE, "}")` が呼び出される。
       - `fetched` に `Token(RBRACE, "}")` が設定され、`index` は 15 になる。
       - `true` を返す。
   - `new JsonAst.JsonString("value")` を返す。

**7. `SimpleJsonParser.parsePair()` に戻る:**
   - `value` に `JsonAst.JsonString("value")` が設定される。
   - `new Pair<>(key, value)` を返す。

**8. `SimpleJsonParser.parseObject()` に戻る:**
   - `members` に `Pair(JsonString("key"), JsonString("value"))` が追加される。
   - `tokenizer.moveNext()` が呼び出される。
     - `SimpleJsonTokenizer.moveNext()`:
       - `index` は 15。`input.length()` と等しいのでループを抜け `false` を返す。
   - `while` ループの条件が `false` になりループ終了。
   - `tokenizer.current().type` は `RBRACE` なので `if` はパス。
   - `new JsonAst.JsonObject(members)` を返す。

**9. `SimpleJsonParser.parseValue()` (1回目) に戻る:**
   - `parseObject()` の結果を返す。

**10. `SimpleJsonParser.parse()` に戻る:**
    - `value` に `JsonObject` が設定される。
    - `tokenizer.rest()` は `input.substring(15)` で空文字列 `""` を返す。
    - `new ParseResult<>(value, "")` を返す。

このように、`SimpleJsonTokenizer` が入力文字列をトークン列に順次変換し、`SimpleJsonParser` はそのトークン列を消費しながら構文構造を組み立てていきます。`SimpleJsonTokenizer` の `moveNext()` 内の `switch` 文で空白文字 (`' '`, `\t`, `\n`, `\r'`) が処理され `index` が進められるため、`SimpleJsonParser` は空白文字の存在を意識することなく、本質的な構文解析に集中できるというメリットがあります。

## 3.5 JSONの字句解析器

JSONの字句解析器について、この節では、主要な部分に着目して説明します。

### 3.5.1 ヘッダ部

まず、JSONの字句解析器を実装したクラスである`SimpleJsonTokenizer`の先頭（ヘッダ）部分を読んでみます。

```java
public class SimpleJsonTokenizer implements JsonTokenizer {
    private final String input;
    private int index;
    private Token fetched;

    public SimpleJsonTokenizer(String input) {
        this.input = input;
        this.index = 0;
    }
```

`String`型のフィールド`input`は、トークンに切り出す元となる文字列を表します。`int`型のフィールド`index`は、今、字句解析器が文字列の何番目を読んでいるかを表すフィールドで0オリジンです。`Token`型のフィールド`fetched`には、字句解析器が切り出したトークンが保存されます。

コンストラクタ中では、入力文字列`input`を受け取り、フィールドに格納および、`index`を0に初期化しています。

### 3.5.2 本体部

`SimpleTokenizer`の主要なメソッドは、

- `tokenizeNumber()`
- `tokenizeStringLiteral()`
- `accept()`
- `moveNext()`
- `current()`

となります。以下、これらのメソッドについて説明します。

### 3.5.3 tokenizeNumber

`tokenizeNumber()`メソッドは、文字列の現在位置から開始して、数値トークンを切り出すためのメソッドです。引数`positive`の値が`true`なら、正の整数を、`false`なら、負の整数をトークンとして切り出しています。返り値はトークンの切り出しに成功したか、失敗したかを表します。

### 3.5.4 tokenizeStringLiteral

`tokenizeStringLiteral()` メソッドは、文字列の現在位置から開始して、文字列リテラルトークンを切り出すためのメソッドです。返り値はトークンの切り出しに成功したか、失敗したかを表します。

### 3.5.5 accept

`accept()` メソッドは、文字列の現在位置から開始して、指定された文字列`literal`にマッチした場合に、対応する種類`type`と値`value`を持つトークンを生成し、内部状態（`fetched`フィールドと`index`フィールド）を更新します。このメソッドは主に`moveNext()`メソッド内部で、固定的なリテラル（例: `true`, `false`, `{`, `}` など）をトークン化する際に使用されます。

### 3.5.6 moveNext

`moveNext()` メソッドは、字句解析器の中核となるメソッドです。呼び出されると、次のトークンを発見するまで、文字列の位置を進め、トークンが発見されたら、トークンを`fetched`に格納して、`true`を返します。トークン列の終了位置に来たら`false`を返します。これは、`Iterator`パターンの一種とも言えますが、典型的な`Iterator`と異なり、`moveNext()`が副作用を持つ点がポイントでしょうか。この点は、.NETの`IEnumerator`のアプローチを参考にしました。

### 3.5.7 current

`current()`メソッドは、`moveNext()`メソッドが`true`を返したあとに呼び出すと、切り出せたトークンを取得することができます。`moveNext()`を次に呼び出すと、`current()`の値が変わってくる点に注意が必要です。

## 3.6 JSONの構文解析器

JSONの字句解析器である`SimpleTokenizer`はこのようにして実装しましたが、JSONの構文解析器である`SimpleJSONParser`はどのように実装されているのでしょうか。このクラスは、主に

- `parseTrue()`メソッド：規則`TRUE`に対応する構文解析メソッド
- `parseFalse()`メソッド：規則`FALSE`に対応する構文解析メソッド
- `parseNull()`メソッド：規則`NULL`に対応する構文解析メソッド
- `parseString()`メソッド：規則`STRING`に対応する構文解析メソッド
- `parseNumber()`メソッド：規則`NUMBER`に対応する構文解析メソッド
- `parseObject()`メソッド：規則`object`に対応する構文解析メソッド
- `parseArray()`メソッド：規則`array`に対応する構文解析メソッド
- `parseValue()`メソッド: 規則`value`に対応する構文解析メソッド

というメソッドからなっており、それぞれが内部で`SimpleTokenizer`クラスのオブジェクトのメソッドを呼び出しています。では、これらのメソッドについて順番に見て行きましょう。

### 3.6.1 parseTrue

`parseTrue()`メソッドは、規則`TRUE`に対応するメソッドで、JSONの`true`に対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
    private JsonAst.JsonTrue parseTrue() {
        if(!tokenizer.current().type.equals(Token.Type.TRUE)) {
            return JsonAst.JsonTrue.getInstance();
        }
        if(currentToken.type == Token.Type.TRUE) {
        throw new parser.ParseException("expected: true, actual: " + tokenizer.current().value);
    }
```

見るとわかりますが、`tokenizer`が保持している次のトークンの値が`true`だったら、`JsonAst.JsonTrue`のインスタンスを返しているだけですね。ほぼ、字句解析器に処理を丸投げしているだけですから、詳しい説明は不要でしょう。

### 3.6.2 parseFalse

`parseFalse()`メソッドは、規則`FALSE`に対応するメソッドで、JSONの`false`に対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
    private JsonAst.JsonFalse parseFalse() {
        if(!tokenizer.current().type.equals(Token.Type.FALSE)) {
            return JsonAst.JsonFalse.getInstance();
        }
        throw new parser.ParseException("expected: false, actual: " + tokenizer.current().value);
    }
```

実装については、`parseTrue()`とほぼ同様なので説明は省略します。

### 3.6.3 parseNull

`parseNull()`メソッドは、規則`NULL`に対応するメソッドで、JSONの`null`に対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
  private JsonAst.JsonNull parseNull() {
        if(tokenizer.current().type.equals(Token.Type.NULL)) {
            return JsonAst.JsonNull.getInstance();
        }
        throw new parser.ParseException("expected: null, actual: " + tokenizer.current().value);
    }
```

実装については、`parseTrue()`とほぼ同様なので説明は省略します。

### 3.6.4 parseString

`parseString()`メソッドは、規則`STRING`に対応するメソッドで、JSONの`"..."`に対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
   private JsonAst.JsonString parseString() {
        return new JsonAst.JsonString((String)tokenizer.current().value);
   }
```

実装については、`parseTrue()`とほぼ同様なので説明は省略します。

### 3.6.5 parseNumber

`parseNumber()`メソッドは、規則`NUMBER`に対応するメソッドで、JSONの`1, 2, 3, 4, ...`に対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
    private JsonAst.JsonNumber parseNumber() {
        var value = (Integer)tokenizer.current().value;
        return new JsonAst.JsonNumber(value);
    }
```

実装については、`parseTrue()`とほぼ同様なので説明は省略します。

### 3.6.6 parseObject

`parseObject()`メソッドは、規則`object`に対応するメソッドで、JSONのオブジェクトリテラルに対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
    private JsonAst.JsonObject parseObject() {
        if(tokenizer.current().type != Token.Type.LBRACE) {
            throw new parser.ParseException("expected `{`, actual: " + tokenizer.current().value);
        }

        tokenizer.moveNext();
        if(tokenizer.current().type == Token.Type.RBRACE) {
            return new JsonAst.JsonObject(new ArrayList<>());
        }

        List<Pair<JsonAst.JsonString, JsonAst.JsonValue>> members = new ArrayList<>();
        var pair= parsePair();
        members.add(pair);

        while(tokenizer.moveNext()) {
            if(tokenizer.current().type == Token.Type.RBRACE) {
                return new JsonAst.JsonObject(members);
            }
            if(tokenizer.current().type != Token.Type.COMMA) {
                throw new parser.ParseException("expected: `,`, actual: " + tokenizer.current().value);
            }
            tokenizer.moveNext();
            pair = parsePair();
            members.add(pair);
        }

        throw new parser.ParseException("unexpected EOF");
    }
```

まず、最初のif文で、次のトークンが`{`であることを確認した後に、

- その次のトークンが`}`であった場合：空オブジェクトを返す
- それ以外の場合： `parsePair()` を呼び出し、 `string:value` のようなペアを解析した後、以下のループに突入：
  - 次のトークンが`}`の場合、集めたペアのリストを引数として、`JsonAst.JsonObject()`オブジェクトを作って返す
  - それ以外で、次のトークンが`,`でない場合、構文エラーを投げて終了
  - それ以外の場合：次のトークンをフェッチして来て、`parsePair()`を呼び出して、ペアを解析した後、リストにペアを追加

のような動作を行います。実際のコードと対応付けてみると、より理解が進むでしょう。

### 3.6.7 parseArray

`parseArray()`メソッドは、規則`array`に対応するメソッドで、JSONの配列リテラルに対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
    private JsonAst.JsonArray parseArray() {
        if(tokenizer.current().type != Token.Type.LBRACKET) {
            throw new parser.ParseException("expected: `[`, actual: " + tokenizer.current().value);
        }

        tokenizer.moveNext();
        if(tokenizer.current().type == Token.Type.RBRACKET) {
            return new JsonAst.JsonArray(new ArrayList<>());
        }

        List<JsonAst.JsonValue> values = new ArrayList<>();
        var value = parseValue();
        values.add(value);

        while(tokenizer.moveNext()) {
            if(tokenizer.current().type == Token.Type.RBRACKET) {
                return new JsonAst.JsonArray(values);
            }
            if(tokenizer.current().type != Token.Type.COMMA) {
                throw new parser.ParseException("expected: `,`, actual: " + tokenizer.current().value);
            }
            tokenizer.moveNext();
            value = parseValue();
            values.add(value);
        }

        throw new ParseException("unexpected EOF");
    }
 ```

まず、最初のif文で、次のトークンが`[`であることを確認した後に、

- その次のトークンが`]`であった場合：空の配列 (`JsonAst.JsonArray`) を返す
- それ以外の場合： `parseValue()` を呼び出し、 `value`を解析した後、以下のループに突入：
  - 次のトークンが`]`の場合、集めた`values`のリストを引数として、`JsonAst.JsonArray()`オブジェクトを作って返す
  - それ以外で、次のトークンが`,`でない場合、構文エラーを投げて終了
  - それ以外の場合：次のトークンをフェッチして来て、`parseValue()`を呼び出して、`value`を解析した後、リストに`value`を追加

のような動作を行います。実際のコードと対応付けてみると、より理解が進むでしょう。

なお、`parseArray()`のコードを読めばわかるように、ほとんどのコードは、`parseObject()`と共通のものになっています。もしこれが気になるようであれば、共通部分をくくりだすことも出来ます。

## 3.7 まとめ

この章では、JSONの構文解析や字句解析を実際に作ってみることを通して、構文解析の基礎について学んでもらいました。特に、

- 3.1 JSONの概要
- 3.2 JSONのBNF
- 3.3 JSONの構文解析器（PEG版）
- 3.4 古典的な構文解析器の概要
- 3.5 JSONの字句解析器
- 3.6 JSONの構文解析器

といった順番で、JSONの定義から入って、PEGによるJSONパーザ、字句解析器を使った構文解析器の作り方について学んでもらいました。この書籍中で使ったJSONはECMA-404で定義されている正式なJSONのサブセットになっています。たとえば、浮動小数点数が完全に扱えないという制限がありますが、構文解析器全体から見ればささいなことなので、この章を理解出来れば、JSONの構文解析について理解できたと思って構いません。

次の章では、文脈自由文法（Context-Free Grammar, CFG）の考え方について学んでもらいます。文脈自由文法は、現在使われているほとんどの構文解析アルゴリズムの基盤となっている概念であって、CFGの理解なくしては、その後の構文解析の理解もおぼつかないからです。

逆に、CFGの考え方さえわかってしまえば、個別の構文解析アルゴリズム自体は、それほど難しいとは感じられなくなって来るかもしれません。

---

**演習問題**

1.  **コメントのサポート:**
    *   JSONのBNF定義を拡張し、`//` から行末までの単一行コメントと、`/*` から `*/` までの複数行コメントをサポートするようにしてください。
    *   `PegJsonParser` と `SimpleJsonTokenizer` の両方を修正し、これらのコメントを正しく無視するように実装してください。
    *   ヒント: `PegJsonParser` では `skipWhitespace` にコメントスキップのロジックを追加するか、各解析メソッドの適切な箇所でコメントを読み飛ばす処理を挟みます。`SimpleJsonTokenizer` では `moveNext` の `switch` 文に `/` のケースを追加し、そこからコメントの種別を判定して読み飛ばす処理を実装します。

2.  **数値型の拡張:**
    *   `PegJsonParser` の `parseNumber` メソッドと、`SimpleJsonTokenizer` の `tokenizeNumber` メソッドを修正し、ECMA-404仕様に準拠した数値型（小数部、指数部 `e` または `E` を含む）を正しく解析できるようにしてください。
    *   `JsonAst.JsonNumber` の `value` フィールドの型を `double` から `java.math.BigDecimal` に変更し、精度が失われないように対応してください。
    *   テストケースとして、`123`, `-0.5`, `1.2e3`, `0.4E-1` のような多様な数値表現を試してみてください。

[^1]: ECMA-404 The JSON data interchange syntax 2nd edition, December 2017.  https://ecma-international.org/publications-and-standards/standards/ecma-404/

\newpage

<!-- Chapter 6: 第4章:文脈自由文法の世界 -->

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
e_1 e_2  連接 (e_1 の後に e_2 が続く。例: `ab` は "ab" にマッチ)
e_1 | e_2 選択 (e_1 または e_2 のどちらかにマッチ。例: `a|b` は "a" または "b" にマッチ)
e*       0回以上の繰り返し（クリーネ閉包）。例: `a*` は "" (空文字列), "a", "aa", "aaa" などにマッチ。` (ab)*` は "", "ab", "abab" などにマッチ。
```

正規表現はシンプルな規則によって構成されますが、多様なパターンを表現できます。例えば、`a(b|c)*d` という正規表現は、"ad", "abd", "acd", "abbd", "accd", "abcbcd" といった文字列にマッチします。以下は自然数を表現する正規表現です。

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

正規表現の集合で表現される言語クラスを本書では`RL`（Regular Language、正規言語）と表記します。`RL`で表せないことが証明されている典型的な言語の1つがDyck言語です。これは、正規表現が基本的に有限の「状態」しか記憶できないためです。括弧の対応のように、任意に深くネストする可能性のある構造を正しく認識するには、無限の深さの情報を記憶できるメカニズム（例えばスタック）が必要になりますが、正規表現の背後にある計算モデル（有限オートマトン）はそのような能力を持ちません。したがって、

`DK ∉ RL`

ここでDKは言語であり、RLは言語クラス（言語の集合）であることに注意してください。

`DK ∉ RL`

ここでDKは言語であり、RLは言語クラス（言語の集合）であることに注意してください。

さらに話を進めると、文脈自由文法が表す言語クラス（文脈自由言語と呼び、本書では`CFL`と表記します）と`RL`について次のような関係がなりたちます。

`RL ⊂ CFL`

これは、文脈自由文法では正規表現で表現可能なあらゆる文字列を表現可能だが、逆は成り立たないということです。

これは単に理論上の話ではなく実用上大きな問題として立ちはだかります。たとえば、プログラミング言語の構文解析ではDyck言語のような**括弧の対応がとれていなければエラー**という文法が頻繁に登場しますが、正規表現では書けないのです。

さて、Dyck言語に特徴づけられる**括弧の対応を計算できる**ことに文脈自由文法の利点があるわけですが、文脈自由文法だけであらゆる種類の文字列の集合を定義可能なのでしょうか？

これは自明ではありませんが、不可能であることが証明されています。たとえば、`a`を`n`回、`b`を`n`回、`c`を`n`回だけ（`n >= 0`）並べた文字列を表す言語`a^n b^n c^n`（例: "abc", "aabbcc", "aaabbbccc" など）は、文脈自由文法で定義不可能です。直感的には、文脈自由文法の背後にある計算モデル（プッシュダウンオートマトン）はスタックを使って記号の数を数えることができますが、`a^n b^n` のように2種類の記号の数を一致させることはできても、`a^n b^n c^n` のように3種類以上の記号の数を同時に一致させることは一般に困難だからです。

一方でこの言語は文脈依存言語（Context-Sensitive Language、本書では`CSL`と表記）という言語クラスで定義可能で、`CFL`は`CSL`の真部分集合です。この事実は次のように表すことができます。

`CFL ⊂ CSL`

このように、言語クラスには階層があります。これまででてきた言語クラスを含めると、言語クラスの階層は次のようになります。

`RL ⊂ CFL ⊂ CSL`

言語クラスとしては`RL`（正規言語）よりも`CFL`（文脈自由言語）の方が強力であり、`CFL`より`CSL`（文脈依存言語）方が強力ということですね。

わかりやすく図として表現すると以下のようになります。

![言語クラスの階層](./img/chapter3/chomsky1.svg)

CSLよりさらに強力な言語クラスも存在しますが、実はもっとも強い言語クラスが存在しています。そのクラスは**帰納的加算言語**と呼ばれていて、現存する（ほぼ）すべてのプログラミング言語の能力と一致します。

（ほぼ）すべてのプログラミング言語はチューリング完全であるという意味で能力的に等しいということを聞いたことがあるプログラマーの方も多いでしょう。チューリング完全とは、その言語（または計算モデル）がチューリングマシンと等価な計算能力を持つことを意味します。

形式言語の用語で言い換えれば、任意のプログラミング言語で生成可能な言語（＝文字列の集合）の全体である言語クラスは帰納的加算言語（Recursively Enumerable Language）とちょうど一致するということになります。これは計算可能性理論における非常に重要な結果であり、「計算可能」という概念そのものと深く結びついています。

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

最左導出は、生成規則を適用する際に常に一番左の非終端記号を展開する方法です。これにより導出過程が一意に決定されます。例として次の文脈自由文法Gを考えてみましょう。この文法Gは、1個以上の`a`の後に1個以上の`b`が続く文字列の集合（言語 `a⁺b⁺`）を生成します。

```
G:
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

最右導出は、生成規則を適用する際に常に一番右の非終端記号を展開する方法です。最左導出と同様に導出過程が一意に決定されます。さきほどと同じ文脈自由文法Gを考えてみましょう。

```
G:
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

最左導出と最右導出では最終的に同じ文字列を導出することが可能です。しかし、導出過程が異なります。例えば、文字列 `ab` を導出する場合も見てみましょう。

**`ab` の最左導出:**
```
S  => AB    (S → AB)
AB => aB    (A → a)
aB => ab    (B → b)
```

**`ab` の最右導出:**
```
S  => AB    (S → AB)
AB => Ab    (B → b)
Ab => ab    (A → a)
```

これらの導出過程は、実は同じ**構文木（Parse Tree）**の異なる構築順序や辿り方に対応しています。例えば、`aabb` の構文木は以下のようになります（簡略図）。

```
      S
     / \
    A   B
   / \ / \
  a  A b  B
     |    |
     a    b
```
最左導出は、この木を左側の非終端記号から優先的に展開していくイメージ（深さ優先探索の行きがけ順に近い）であり、最右導出は右側の非終端記号から優先的に展開していくイメージです。どちらの導出方法を選んでも、最終的に得られる構文木は（曖昧性のない文法であれば）同じになります。

先取りしておくと、形式言語における最左導出がいわゆる下向き構文解析に対応し、最右導出の逆操作が上向き構文解析に対応します。これらについては次の章で説明します。

生成規則から文字列を生成するために2つの導出方法を使い分けることができることを覚えておいてください。

\newpage

<!-- Chapter 3: 第5章:構文解析アルゴリズム古今東西 -->

# 第5章 構文解析アルゴリズム古今東西

第2章で算術式を例にしてBNFや抽象構文木といった基礎概念を説明しました。第3章ではJSONの構文解析器の実装を通してPEGによる構文解析と単純な字句解析を用いた構文解析のやり方を学びました。第4章では文脈自由文法と形式言語の階層の話をしました。これでようやく準備が整ったので、本書の本丸である構文解析アルゴリズムの話ができます。

といっても、戸惑う読者の方が多いかもしれません。これまで「構文解析アルゴリズム」について具体的な話はまったくなかったのですから。しかし、皆さんは、第3章で二つの構文解析アルゴリズムを使ってJSONの構文解析器を**すでに**書いているのです。

第3章で最初に実装したのはPEGと呼ばれる手法の素朴な実装です。次に実装したのは*LL(1)*っぽい再帰下降構文解析器です。**再帰下降**という言葉は見慣れないものなので、疑問に思われる読者の方も多いと思います。その疑問は脇において、第3章での実装が理解できたのなら、皆さんはすでに直感的に構文解析アルゴリズムを理解していることになります。

この章では、2024年までに発表された主要な構文解析アルゴリズムについて、筆者の独断と偏見を交えて解説します。この章で紹介する構文解析アルゴリズムのほとんどについて、その構文解析アルゴリズムを使った構文解析器を生成してくれる構文解析器生成系が存在します。構文解析機生成系については第6章で説明しますが、ここではさわりだけを紹介しておきます。

たとえば、構文解析アルゴリズムとして有名な*LALR(1)*は、もっともメジャーな構文解析器生成系でCコードを生成するyacc（GNUによる再実装であるbisonが主流）で採用されています。*LL(1)*はJava向けの構文解析器生成系としてメジャーなJavaCCで採用されている方式です。*ALL(\*)*は、Javaをはじめとした多言語向け構文解析器生成系として有名なANTLRで採用されています。PEGを採用した構文解析器生成系も多数存在します。

このように、なにかの構文解析アルゴリズムがあれば、構文解析アルゴリズムに基づいた構文解析機生成系を作ることができます。余談ですが、筆者は大学院生時代にPEGおよびPackrat Parsingの研究をしており、その過程でPEGによる構文解析器生成系を作ったものです。

小難しいことばかり言うのは趣味ではないので、さっそく、構文解析アルゴリズムの世界を覗いてみましょう！　

## 5.1 下向き構文解析と上向き構文解析

具体的な構文解析アルゴリズムの説明に入る前に、構文解析アルゴリズムは大別して、

- 上から下へ（下向き）
- 下から上へ（上向き）

の二つのアプローチがあることを理解しておきましょう。下向き構文解析法と上向き構文解析法では真逆の発想で構文解析を行うからです。

## 5.2 下向き構文解析の概要

まずは下向き構文解析法です。下向き構文解析では予測型とバックトラック型で若干異なる方法で構文解析をしますが、ここでは予測型の下向き構文解析法を説明します。予測型の下向き構文解析法ではCFGの開始記号から構文解析を開始し、規則に従って再帰的に構文解析を行っていきます。

第4章で例に出てきたDyck言語を例にして、具体的な方法を説明します。Dyck言語の文法は以下のようなものでした。（`$`は入力の開始と終了を表す特別な記号、`ε`は空文字列を表します）

```
D -> $ P $
P -> ( P ) P
P -> ε
```

このCFGはカッコがネストした文字列の繰り返し（空文字列を含む）を過不足無く表現しているわけですが、`(())`という文字列がマッチするかを判定する問題を考えてみましょう。

まず最初に、開始記号が`D`で規則`D -> $ P $`があるので、解析を開始します。スタックを使って解析の進行状況を管理します。ドット `・` は現在注目している位置を示します。

```
入力: $ ( ( ) ) $
スタック: [ D -> ・$ P $ ]
```

次に最初の記号 `$` を入力文字列から読み込みます。

```
入力: ( ( ) ) $
スタック: [ D -> $・P $ ]
```

次に非終端記号 `P` を解析しようとします。次の入力は `(` なので、規則 `P -> ( P ) P` を適用することになります。スタックにこの規則を追加します。

```
入力: ( ( ) ) $
スタック: [ D -> $・P $, P -> ・( P ) P ]
```

次の入力 `(` とスタックトップの規則の期待する記号 `(` がマッチするので、入力を消費し、ドットを進めます。

```
入力: ( ) ) $
スタック: [ D -> $・P $, P -> (・P ) P ]
```

再び非終端記号 `P` を解析します。次の入力は `(` なので、規則 `P -> ( P ) P` を適用します。

```
入力: ( ) ) $
スタック: [ D -> $・P $, P -> (・P ) P, P -> ・( P ) P ]
```

次の入力 `(` とスタックトップの規則の期待する記号 `(` がマッチするので、入力を消費し、ドットを進めます。

```
入力: ) ) $
スタック: [ D -> $・P $, P -> (・P ) P, P -> (・P ) P ]
```

再び非終端記号 `P` を解析します。次の入力は `)` です。規則 `P -> ( P ) P` は `(` で始まるため適用できません。もう一つの規則 `P -> ε` を適用します。これは空文字列にマッチするので、入力は消費せず、ドットだけが進みます（εの解析が完了したとみなします）。

```
入力: ) ) $
スタック: [ D -> $・P $, P -> (・P ) P, P -> ( P・) P ]
```

次の入力 `)` とスタックトップの規則の期待する記号 `)` がマッチするので、入力を消費し、ドットを進めます。

```
入力: ) $
スタック: [ D -> $・P $, P -> (・P ) P, P -> ( P )・P ]
```

再び非終端記号 `P` を解析します。次の入力は `)` なので、規則 `P -> ε` を適用します。

```
入力: ) $
スタック: [ D -> $・P $, P -> (・P ) P, P -> ( P ) P・]
```

スタックトップの規則 `P -> ( P ) P` の解析が完了したので、スタックからこの規則を取り除きます。解析が完了した `P` が一つ上の規則 `P -> (・P ) P` の `P` に対応します。

```
入力: ) $
スタック: [ D -> $・P $, P -> ( P・) P ]
```

次の入力 `)` とスタックトップの規則の期待する記号 `)` がマッチするので、入力を消費し、ドットを進めます。

```
入力: $
スタック: [ D -> $・P $, P -> ( P )・P ]
```

再び非終端記号 `P` を解析します。次の入力は `$` なので、規則 `P -> ε` を適用します。

```
入力: $
スタック: [ D -> $・P $, P -> ( P ) P・]
```

スタックトップの規則 `P -> ( P ) P` の解析が完了したので、スタックから取り除きます。解析が完了した `P` が一番下の規則 `D -> $・P $` の `P` に対応します。

```
入力: $
スタック: [ D -> $ P・$ ]
```

次の入力 `$` とスタックトップの規則の期待する記号 `$` がマッチするので、入力を消費し、ドットを進めます。

```
入力: (空)
スタック: [ D -> $ P $・]
```

スタックトップの規則 `D -> $ P $` の解析が完了し、入力も終端に達したので、スタックから規則を取り除きます。

```
入力: (空)
スタック: [ ]
```

入力文字列の終端に到達し、スタックが空になったので、入力文字列 `(())` はDyck言語の文法に従っていることがわかりました。

この解析過程をより具体的に追跡すると以下のようになります。

| ステップ | 入力ポインタ        | 残り入力     | スタック                                     | アクション                                     |
| -------- | ------------------- | ------------ | -------------------------------------------- | ---------------------------------------------- |
| 1        | **`$`** ` ( ( ) ) $` | ` ( ( ) ) $` | `[ D -> ・$ P $ ]`                           | `$` を消費、`D -> $・P $`                      |
| 2        | `$ `**`(`**` ( ) ) $` | ` ( ) ) $`   | `[ D -> $・P $ ]`                           | `P` を展開、規則 `P -> ・( P ) P` をスタックに追加 |
| 3        | `$ `**`(`**` ( ) ) $` | ` ( ) ) $`   | `[ D -> $・P $, P -> ・( P ) P ]`             | `(` を消費、`P -> (・P ) P`                    |
| 4        | `$ ( `**`(`**` ) ) $` | ` ) ) $`     | `[ D -> $・P $, P -> (・P ) P ]`             | `P` を展開、規則 `P -> ・( P ) P` をスタックに追加 |
| 5        | `$ ( `**`(`**` ) ) $` | ` ) ) $`     | `[ D -> $・P $, P -> (・P ) P, P -> ・( P ) P ]` | `(` を消費、`P -> (・P ) P`                    |
| 6        | `$ ( ( `**`)`**` ) $` | ` ) $`       | `[ D -> $・P $, P -> (・P ) P, P -> (・P ) P ]` | `P` を展開、規則 `P -> ・ε` を選択             |
| 7        | `$ ( ( `**`)`**` ) $` | ` ) $`       | `[ D -> $・P $, P -> (・P ) P, P -> ( P・) P ]` | `ε` を消費（位置変わらず）、`P -> ( P・) P`      |
| 8        | `$ ( ( ) `**`)`**` $` | ` $`         | `[ D -> $・P $, P -> (・P ) P, P -> ( P )・P ]` | `)` を消費、`P -> ( P )・P`                    |
| 9        | `$ ( ( ) `**`)`**` $` | ` $`         | `[ D -> $・P $, P -> (・P ) P, P -> ( P ) P・]` | `P` を展開、規則 `P -> ・ε` を選択             |
| 10       | `$ ( ( ) `**`)`**` $` | ` $`         | `[ D -> $・P $, P -> (・P ) P, P -> ( P ) P・]` | スタックから `P -> ( P ) P・` を除去           |
| 11       | `$ ( ( ) `**`)`**` $` | ` $`         | `[ D -> $・P $, P -> ( P・) P ]`             | `)` を消費、`P -> ( P )・P`                    |
| 12       | `$ ( ( ) ) `**`$`**  |              | `[ D -> $・P $, P -> ( P )・P ]`             | `P` を展開、規則 `P -> ・ε` を選択             |
| 13       | `$ ( ( ) ) `**`$`**  |              | `[ D -> $・P $, P -> ( P ) P・]`             | スタックから `P -> ( P ) P・` を除去           |
| 14       | `$ ( ( ) ) `**`$`**  |              | `[ D -> $ P・$ ]`                           | `$` を消費、`D -> $ P $・`                      |
| 15       | `$ ( ( ) ) $`       | (空)         | `[ D -> $ P $・]`                           | スタックから `D -> $ P $・` を除去             |
| 16       | `$ ( ( ) ) $`       | (空)         | `[ ]`                                        | 受理                                           |

予測型の下向き構文解析では以下の動作を繰り返します。

1. 残りの文字列から、1文字とってきて先読み文字列に追加する
2. 次が非終端記号で、先読み文字列から適用すべき規則が決定できる場合スタックにその規則を積む。規則が決定できない場合はエラー。次が終端記号であれば、先読み文字列の先頭とマッチするかを確認し、マッチすれば文字列を消費し、マッチしない場合はエラーを返す
3. 規則の最後に到達した場合は、スタックから要素を取り除く

## 5.3 下向き構文解析法のJavaによる実装

このような動作をJavaコードで表現することを考えてみます。

```java
// D -> P
// P -> ( P ) P
// P -> ε
public class Dyck {
    private final String input;
    private int position;

    public Dyck(String input) { // コンストラクタ名を修正
        this.input = input;
        this.position = 0;
    }

    public boolean parse() {
        boolean result = D();
        return result && position == input.length();
    }

    private boolean D() {
        return P();
    }

    private boolean P() {
        // P -> ( P ) P
        if (position < input.length() && input.charAt(position) == '(') {
            position++; // '(' を読み進める
            if (!P()) return false;
            if (position < input.length() && input.charAt(position) == ')') {
                position++; // ')' を読み進める
                return P();
            } else {
                return false;
            }
        // P -> ε
        } else {
            // 空文字列にマッチ
            return true;
        }
    }
}
```

クラス`Dyck`は、Dyck言語を構文解析して、成功したら`true`、そうでなければ`false`を返すものです。BNFと比較すると、

- 規則の名前と一対一になるメソッドが存在する
- 非終端記号の参照は規則の名前に対応するメソッドの再帰呼び出しとして実現されている

のが特徴です。

呼び出す規則を上、呼び出される規則を下とした時、上から下に再帰呼び出しが続いていくため、再帰下降構文解析と呼ばれます。このように「上から下に」構文解析を行っていくのが下向き構文解析法の特徴です。

注意しなければいけないのは、下向き構文解析の方法は多数あり、その1つに再帰下降構文解析があるということです。

実際、後述するLL(1)の実装のときは構文解析のための表を作り、関数の再帰呼び出しは行わないこともあります。

## 5.4 上向き構文解析の概要

上向き構文解析は下向き構文解析とは真逆の発想で構文解析を行います。こちらの方法は下向き型より直感的に理解しづらいかもしれません。

上向き構文解析ー正確にはシフト還元構文解析として知られているものーでは、文字列を左から右に読み込んでいき、順番にスタックにプッシュしていきます。これをシフト（shift）と呼びます。

シフト動作を続けていくうちに、規則の右辺の記号列とスタックトップにある記号列がマッチすれば、規則の左辺にマッチしたとして、スタックトップにある記号列を規則の左辺で置き換えます。これを還元（reduce）と呼びます。

具体例を挙げてみます。以下のCFGがあったとしましょう。ただし、入力の先頭と末尾を表すために`$`を使うものとします。

```
D -> $ P $
P -> ( P ) P
P -> ε
```

これは下向き構文解析で扱ったDyck言語の文法です。上向き構文解析の説明の都合上、上記と等価な以下の文法を考えます。

```
D -> $ P $
D -> $ ε $
P -> P X
P -> X
X -> ( X )
X -> ()
```

このCFGに対して`(())`という文字列がマッチするかを判定する問題を考えてみましょう。上向き構文解析では、まず最初の「1文字」を左から右にシフトします。以下のようなイメージです。スタックに要素をプッシュすると右に要素が追加されていくものとします。

```
スタック: [ $, ( ]
```

このスタックは`P`にも`D`にもマッチしません。そこで、もう1文字をシフトしてみます。

```
スタック: [ $, (, ( ]
```

まだマッチしませんね。さらにもう1文字シフトしてみます。

```
スタック: [ $, (, (, ) ]
```

規則`X -> ()`を使って還元を行います。

```
スタック: [ $, (, X ]
```

この状態でもう1文字シフトしてみます。

```
スタック: [ $, (, X, ) ]
```

規則`X -> (X)`を使って還元を行います。

```
スタック: [ $, X ]
```

さらに規則`P -> X`を使って還元を行います。

```
スタック: [ $, P ]
```

文字列の末尾にきたので、`$`をシフトします。

```
スタック: [ $, P, $ ]
```

このスタックは規則`D -> $ P $`にマッチします。還元が行われ、最終的にスタックの状態は次のようになります。

```
スタック: [ D ]
```

めでたく`(())`が`D`とマッチすることがわかりました。このシフト還元の過程をより詳しく見てみましょう。

| ステップ | 入力ポインタ        | 残り入力     | スタック          | アクション                               |
| -------- | ------------------- | ------------ | ----------------- | ---------------------------------------- |
| 1        | **`$`** ` ( ( ) ) $` | ` ( ( ) ) $` | `[ ]`             | shift `$`                                |
| 2        | `$ `**`(`**` ( ) ) $` | ` ( ) ) $`   | `[ $ ]`           | shift `(`                                |
| 3        | `$ ( `**`(`**` ) ) $` | ` ) ) $`     | `[ $, ( ]`        | shift `(`                                |
| 4        | `$ ( ( `**`)`**` ) $` | ` ) $`       | `[ $, (, ( ]`    | shift `)`                                |
| 5        | `$ ( ( ) `**`)`**` $` | ` $`         | `[ $, (, (, ) ]` | reduce by `X -> ()` (スタックは `[ $, (, X ]`) |
| 6        | `$ ( ( ) `**`)`**` $` | ` $`         | `[ $, (, X ]`    | shift `)`                                |
| 7        | `$ ( ( ) ) `**`$`**  |              | `[ $, (, X, ) ]` | reduce by `X -> ( X )` (スタックは `[ $, X ]`) |
| 8        | `$ ( ( ) ) `**`$`**  |              | `[ $, X ]`        | reduce by `P -> X` (スタックは `[ $, P ]`)   |
| 9        | `$ ( ( ) ) `**`$`**  |              | `[ $, P ]`        | shift `$`                                |
| 10       | `$ ( ( ) ) $`       | (空)         | `[ $, P, $ ]`     | reduce by `D -> $ P $` (スタックは `[ D ]`)  |
| 11       | `$ ( ( ) ) $`       | (空)         | `[ D ]`           | 受理                                     |

上向き構文解析では以下の手順を繰り返していきます。

1. 残りの文字があれば、入力文字をシフトしてスタックにプッシュする（シフト）
2. スタックの記号列が規則の右辺にマッチすれば、左辺の非終端記号で置き換える（還元）

4章の最後で少しだけ述べましたが、還元はちょうど、最右導出における導出の逆向きの操作になります。

## 5.5 上向き構文解析のJavaによる実装

このような動作をJavaコードで表現することを考えてみます。まず必要なのは、規則を表すクラス`Rule`です。問題を単純化するために、

1. 規則の名前（左辺）は1文字
2. 規則の右辺は終端記号または非終端記号のリストである

とします。このようなクラス`Rule`は以下のように表現できます。

```java
import java.util.List;
import java.util.ArrayList;

// ElementインターフェースとTerminal, NonTerminalレコードは5.4節で定義済みとする

public record Rule(char lhs, List<Element> rhs) {
    public Rule(char lhs, Element... rhs) {
        this(lhs, List.of(rhs));
    }
    public boolean matches(List<Element> stack) {
        if (stack.size() < rhs.size()) return false;
        for (int i = 0; i < rhs.size(); i++) {
            Element elementInRule = rhs.get(rhs.size() - i - 1);
            Element elementInStack = stack.get(stack.size() - i - 1);
            if (!elementInRule.equals(elementInStack)) {
                return false;
            }
        }
        return true;
    }
}
```

可変長引数を受け取るコンストラクタは規則を簡単に記述するためのものです。`matches`メソッドはスタックの状態と規則がマッチするかを判定します。

`Element`は終端記号や非終端記号を表すクラスで、以下のように定義されます。

```java
public sealed interface Element
    permits Element.Terminal, Element.NonTerminal {
    public record Terminal(char symbol) implements Element {}
    public record NonTerminal(char name) implements Element {}
}
```

これらのクラスを使ってシフトと還元を行うクラス`DyckShiftReduce`は次のように定義できます。（クラス名を`Dyck`から変更）

```java
import java.util.List;
import java.util.ArrayList;

public class DyckShiftReduce { // クラス名を変更
    private final String input;
    private int position;
    private final List<Rule> rules;

    private final List<Element> stack = new ArrayList<>();

    public DyckShiftReduce(String input) { // コンストラクタ名を変更
        this.input = input;
        this.position = 0;
        this.rules = List.of(
            // D -> $ P $
            new Rule('D', new Element.Terminal('$'), new Element.NonTerminal('P'), new Element.Terminal('$')),
            // D -> $ $ (εの代わりに空の右辺を表現)
            new Rule('D', new Element.Terminal('$'), new Element.Terminal('$')),
            // P -> P X
            new Rule('P', new Element.NonTerminal('P'), new Element.NonTerminal('X')),
            // P -> X
            new Rule('P', new Element.NonTerminal('X')),
            // X -> ( X )
            new Rule('X', new Element.Terminal('('), new Element.NonTerminal('X'), new Element.Terminal(')')),
            // X -> ()
            new Rule('X', new Element.Terminal('('), new Element.Terminal(')'))
        );
    }

    public boolean parse() {
        stack.add(new Element.Terminal('$')); // 開始記号を追加
        while (true) {
            if (!tryReduce()) { // まず還元を試みる
                if (position < input.length()) { // 還元できなければシフト
                    stack.add(new Element.Terminal(input.charAt(position)));
                    position++;
                } else { // シフトもできなければループ終了
                    break;
                }
            }
        }
        // 入力の終端記号を追加
        stack.add(new Element.Terminal('$'));
        // 可能な限り還元を試みる
        while (tryReduce()) {
            // 還元を試みる (ループ条件で実行)
        }
        // 最終的にスタックが [D] になれば成功
        return stack.size() == 1 && stack.get(0).equals(new Element.NonTerminal('D'));
    }

    private boolean tryReduce() {
        for (Rule rule : rules) {
            if (rule.matches(stack)) {
                // マッチしたら右辺の長さ分スタックから削除
                for (int i = 0; i < rule.rhs().size(); i++) {
                    stack.remove(stack.size() - 1);
                }
                // 左辺の非終端記号をスタックに追加
                stack.add(new Element.NonTerminal(rule.lhs()));
                return true; // 還元成功
            }
        }
        return false; // 還元できる規則がなかった
    }
}
```

このプログラムでは、入力文字列を1文字ずつシフトしながら、還元を行っています。規則にマッチする場合はスタックから右辺の要素を取り除き、左辺の非終端記号をプッシュします。最終的にスタックに`NonTerminal('D')`だけが残れば、入力文字列が文法に従っていることが確認できます。

## 5.6 下向き構文解析と上向き構文解析の比較

下向き構文解析法と上向き構文解析法は得手不得手があります。

下向き型は規則と関数を対応付けるのが容易なので手書きの構文解析器を書くのに向いています。実際、驚くほど多くのプログラミング処理系の構文解析器は手書きの再帰下降構文解析で実装されています。

下向き型は、関数の引数として現在の情報を渡して、引数に応じて構文解析の結果を変化させることが比較的容易です。これは文脈に依存した文法を持った言語を解析するときに有利な性質です。しかし、下向き型は左再帰という形の文法をそのまま処理できないという欠点があります。

たとえば、以下のBNFは上向き型だと普通に解析できますが、工夫なしに下向き型で実装すると無限再帰に陥ってスタックオーバーフローします。

```
A -> A "a" | ε // 左再帰を含む文法の例 (εは空文字列)
```

このような問題を下向き型で解決する方法も存在します。
例えば、直接左再帰 `A -> A α | β` （ここで `β` は `A` で始まらない）は、以下のように等価な右再帰の文法に書き換えることで除去できます。

```
A  -> β A'
A' -> α A' | ε
```
この変換により、下向き構文解析で問題となる無限再帰を避けることができます。ただし、文法の書き換えは常に簡単とは限りません。

さて、上向き型は左再帰を問題なく処理できるので、このような文法をそのまま解析できるわけです、では上向き型はすべての文法に対して有利なのでしょうか？ことはそう単純ではありません。

たとえば、それまでの文脈に応じて構文解析のルールを切り替えたくなることがあります。最近の言語によく搭載されている文字列補間などはその最たる例です。

`"`の中は文字列リテラルとして特別扱いされますが、その中で`#{`が出てきたら（Rubyの場合）、通常の式を構文解析するときのルールに戻る必要があります。

このように、文脈に応じて適用するルールを切り替えるのは下向き型が得意です。もちろん、上向き型でも実現できないわけではありません。実際、Rubyの構文解析機はYaccの定義ファイルから生成されるようになっていますが、Yaccが採用しているのは代表的な上向き構文解析法である`LALR(1)`です。

ともあれ、下向きと上向きには異なる利点と欠点があります。

次からは具体的なアルゴリズムの説明に移ります。

## 5.7 LL(1) - 代表的な下向き構文解析アルゴリズム

下向き型構文解析法の中でおそらくもっとも古典的で、よく知られているのは`LL(1)`法です。`LL`は**L**eft-to-right, **L**eftmost derivationの略で、左から右へ文字列をスキャンしながら**最左導出**を行うことを意味しています。最左導出は第4章で説明しましたね。

`LL(1)`の`1`は「1トークン先読み」を意味しています。つまり、`LL(1)`法は、次の1トークンを見て、最左導出を行うような構文解析手法です。この手法は手書きの**再帰下降構文解析**によって簡単に実装できるため、構文解析手法の中でも単純なものと言えるでしょう。字面が一見小難しく見えますが、`LL(1)`のアイデアは意外に簡単なものです。

たとえば、以下のようなJava言語のif文があったとします。

```java
if(age < 18) {
    System.out.println("18歳未満です");
} else {
    System.out.println("18歳以上です");
}
```

我々はどのようにしてこれを見て「if文がある」と認識するのでしょうか。もちろん「人それぞれ」なのですが、最初にキーワード`if`が現れたからif文だと考える人も多いのではないかと思います。

`LL(1)`構文解析アルゴリズムはまさにこのイメージを元にした手法です。プログラムをトークン列に区切った後に、「最初の1トークン」を見て、「これはif文だ」とか「これはwhile文だ」とか認識するようなものですね。

イメージとしては簡単なのですが、アルゴリズムとして実行可能なようにするためには考えなければいけない論点がいくつかあります。以下では、`LL(1)`を実装するに当たって考えなければいけない課題について論じます。

### 課題1 - ある構文の最初のトークンが複数種類ある場合

先程の例ではある構文、たとえばif文が始まるには`if`というキーワードが必須で、それ以外の方法でif文が始まることはありえませんでした。

つまり、`if`というトークンが先頭に来たら、それはif文であると確定できるわけです。

しかし、問題はそう単純ではありません。if文の他に符号付き整数および加減乗除のみからなる算術式を構文解析をすることを考えてみましょう。

算術式は以下のいずれかで始まります。

- `(`
- `-`
- `+`
- 整数リテラル（`<int_literal>`）

つまり、算術式の始まりは複数のトークンで表されます。このような場合、最初のトークンとの一致比較だけでは「これは算術式だ」と確定できません。

あるトークンが算術式の始まりである事を確定するためには、トークンの集合という概念が必要になります。

たとえば、算術式の始まりは以下のようなトークンの集合で表されます。

```text
{"(", "-", "+", <int_literal>}
```

このように、ある構文が始まるかを決定するために必要なトークンの集合のことを**FIRST集合**と呼びます。

**FIRST集合**は非終端記号ごとに定義されます。以降では、非終端記号`N`に対して定義されるFIRST集合を`FIRST(N)`と表します。

たとえば、規則 `A` の右辺が複数あって以下のようになっているとします。

```
A -> B
A -> C
```

このとき、

```
FIRST(B) intersection FIRST(C) = empty set
```

が成り立てば、先頭１トークンだけを「先に見て」`B` を選ぶか `C` を選ぶかを安全に決定することができます。

この「先を見る」（Lookahead）という動作がLL(1)のキモです。

バックトラックしない下向き型の場合「あ。間違ってたので別の選択肢をためそう」ということができませんから、必然的に一つ先を読んで分岐する必要があるのです。

一つ先を読んで安全に分岐を選べるためには、分岐の先頭にあるトークンがお互いに重なっていないことが必要条件になります。この「お互いに重なっていない」というのが、「`FIRST(B)` と `FIRST(C)` の積集合が空集合である」という条件です。

### 課題2 - 省略可能な要素の扱い

if文であるかどうかは、先頭の1トークンを見ればわかります。しかし、if文であるとして、if-else文なのかelseがない単純なif文であるかどうかを判定するのはどうすればいいでしょうか。たとえば、以下の文は正当です。

```java
if (age < 18) {
    System.out.println("18歳未満です");
}
```

以下の文も正当です。

```java
if (age < 18) {
    System.out.println("18歳未満です");
} else {
    System.out.println("18歳以上です");
}
```

最初のif文の後に、

- 前者はelseが出現しない
- 後者はelseが出現する

という違いがあります。

つまり、elseが出現するかどうかで、どの規則を適用するかを決定する必要があります。このような場合、次のトークンを見て、elseならif-else文、そうでなければ単純なif文と解釈します。

この判断を行うためには**FIRST集合**だけでは不十分です。elseが省略される可能性があるためです。elseが省略可能かどうかを示す情報が必要です。

ある要素が省略可能かどうかを示す情報を**nullable**と呼びます。**nullable**は非終端記号が空文字列を生成可能かどうかを示す情報です。たとえば、以下の規則があるとします。

```
A -> a
A -> b
A -> ε
```

`A` は空文字列 `ε` を生成可能です。このような場合、`A` は nullable であると言います。

さて、この言い方に従うと

```java
else {
    System.out.println("18歳以上です");
}
```

この部分は**nullable**であると言えます。

このような**nullable**な要素の次に出現し得るトークンの集合を**FOLLOW集合**と呼びます。**FOLLOW集合**は非終端記号ごとに定義されます。以降では、非終端記号`N`に対して定義される**FOLLOW集合**を`FOLLOW(N)`と表します。

次の項では、**FIRST集合**と**FOLLOW集合**の概念についてより厳密に説明します。

### FIRST集合とFOLLOW集合の計算

LL(1)をアルゴリズムとしてきちんと定義しようとするなら、この二つの概念が必要であることはわかってもらえたのではないかと思います。しかし、この二つですが、プログラム上でどう計算すれば良いのでしょうか？この問いに答えることがLL(1)アルゴリズムをきちんと理解することであり、逆にきちんと理解できれば、自力でLL(1)アルゴリズムによるパーサを記述できるようになるでしょう。

まずはFIRST集合について考えてみます。単純化のために以下のような規則を仮定します。

```
A -> α1
A -> α2
...
A -> αn
```

`α_i` は終端記号や非終端記号の並びです。`FIRST(A)` を求めるには以下の手順を用います。

1. FIRST集合を空集合に初期化する。
2. 各生成規則 `A -> α_i` について、次を行う：
 - `α_i` の最初の記号 `X_1` が終端記号ならば、`FIRST(A)` に `X_1` を追加する。
 - `X_1` が非終端記号の場合、`FIRST(X1)` を計算し、`FIRST(A)` に `FIRST(X1)` (εを除く) を追加する。
 - `X_1` が nullable である場合、次の記号 `X_2` について同様の処理を行う。`α_i` のすべての記号が nullable ならば、ε を `FIRST(A)` に追加する。

`nullable`については先程軽く述べましたが、ある非終端記号が空文字列を生成可能かどうかを示すものです。`nullable`の計算は以下の手順で行います。

1. 全ての非終端記号 `N` について `nullable(N)` を false に初期化する。
2. 生成規則 `A -> ε` があれば `nullable(A)` を true に設定する。
3. 生成規則 `A -> X1 X2 ... Xk` について、すべての `Xi` (1 <= i <= k) が nullable ならば `nullable(A)` を true に設定する。
4. 値が変化しなくなるまで2と3を繰り返す。

次に**FOLLOW集合**の計算です。`FOLLOW(A)`は、非終端記号`A`の後に現れる可能性のある終端記号の集合です。計算手順は以下の通りです。

1. すべての非終端記号 `N` について `FOLLOW(N)` を空集合で初期化する。
2. 開始記号 `S'` の `FOLLOW(S')` に入力終了記号 `$` を追加する。
3. 文法中の各規則 `B -> αAβ` について、
    *   `FIRST(β)` に含まれる `ε` 以外のすべての終端記号を `FOLLOW(A)` に追加する。
    *   もし `β` が `ε` を導出可能（`nullable(β)` が真）ならば、`FOLLOW(B)` のすべての記号を `FOLLOW(A)` に追加する。
4. 新しい記号が追加されなくなるまで、ステップ3を繰り返す。

この`FIRST`と`FOLLOW`を用いて、LL(1)構文解析表を作成します。

### LL(1)構文解析表の作成

構文解析表は、非終端記号と入力の次のトークン（終端記号）の組み合わせで、次にどの生成規則を適用すべきかを示すものです。構文解析表の作成手順は以下の通りです。

1. 各生成規則 `A -> α` について、次を行う：
  - `FIRST(α)` に含まれる各終端記号 `a` (εを除く) に対して、表の項目 `Table[A, a]` に規則 `A -> α` を入れる。
  - もし `ε` が `FIRST(α)` に含まれるなら（つまり `α` が nullable なら）、`FOLLOW(A)` に含まれる各終端記号 `b` ( `$ `も含む) に対して、表の項目 `Table[A, b]` に規則 `A -> α` を入れる。
2. 構文解析表のいずれかの項目 `Table[A, a]` に複数の規則が入る場合、その文法はLL(1)ではない。

つまり、LL(1)構文解析表が作成できるかどうかは、その文法がLL(1)であるかどうかの判定に等しいと言えます。

### LL(1)の問題点と限界

`LL(1)`は古典的でありかつ実用的でもありますが、アルゴリズムがシンプルである故の問題点や限界も存在します。この節では`LL(1)`の抱える問題点について述べます。

### 問題点1 - 最初の1トークンで構文要素を決められないことがある

例えば、以下の文法を考えてみましょう。

```
S -> a B
S -> a C
B -> b
C -> c
```

`S` から始まる場合、最初のトークンは常に `a` です。`a` の後に `b` が来れば `S -> a B` を、`c` が来れば `S -> a C` を選択すべきですが、最初の `a` だけではどちらの規則を適用すべきか決められません。これは `FIRST(a B)` と `FIRST(a C)` がともに `{a}` であり、積集合が空でないためです。

この問題は**左因子化**（left factoring）によって解決できます。左因子化では共通部分をくくり出すことで、LL(1)で解析可能な文法に変換します。

```
S  -> a S'
S' -> B
S' -> C
B  -> b
C  -> c
```

しかし、左因子化は常に適用できるわけではありません。

### 問題点2 - 左再帰の問題

$LL(1)$では左再帰を含む文法を扱うことができません。例えば、以下の文法は左再帰を含んでいます。

```
E -> E + T
E -> T
```

この文法は `E` の定義の最初に `E` 自身が出現しています（直接左再帰）。LL(1)パーサでこれをそのまま実装しようとすると、`E` を解析するために `E` を呼び出す…という無限再帰に陥ってしまいます。

左再帰は、以下のように文法を書き換えることで除去できます。

```
E  -> T E'
E' -> + T E'
E' -> ε
```

左再帰の除去は多くの場合に可能ですが、変換作業が煩雑になることも少なくありません。

## 5.8 LL(k) - LL(1)の拡張

LL(1)の限界を克服するために、LL(k)という概念が導入されました。kは先読みするトークン数を示します。kを増やすことで、より複雑な文法を扱えるようになりますが、解析表のサイズや計算量が増加します。

しかし、LL(k)でもすべての文脈自由言語を扱えるわけではありません。たとえば、文脈自由言語の例として以下のようなものがあります。

`a^i b^j (i >= j >= 1)`

これは `a` が `i` 回、その後に `b` が `j` 回現れる文字列で、`a` の数 `i` が `b` の数 `j` 以上であるような言語です。この言語はLL(k)文法では表現できませんが、後述するLR(1)文法では表現可能です。これは、LL(k)が解析できる言語のクラスがLR(1)よりも狭いことを示唆しています。

## 5.9 LR(0) - 最も単純な上向き構文解析

LR法は、**L**eft-to-right（左から右へ入力をスキャン）と**R**ightmost derivation（最右導出の逆をたどる）の略であり、上向き構文解析の代表的な手法群です。その中でも**LR(0)**は最も基本的なアルゴリズムであり、他のLR系の手法（SLR(1), LR(1), LALR(1)）の基礎となります。

LR法の基本的な考え方は、5.4節で説明した**シフト還元構文解析**です。入力を左から読み込み（シフト）、スタック上の記号列が文法規則の右辺と一致したら、それを左辺の非終端記号に置き換える（還元）という操作を繰り返します。

LR(0)を含むLR系の構文解析器は、このシフトと還元の判断を**構文解析表（Parsing Table）**に基づいて効率的に行います。構文解析表は、現在の**状態**と次に入力される**記号**（終端記号）に応じて、次に取るべき**アクション**（シフト、還元、受理、エラー）を決定します。

構文解析表を作成するためには、まず文法から**LR(0)項目（LR(0) item）**の集合を構築し、それらを**状態**として管理する必要があります。

### LR(0)項目と項目集合（状態）

**LR(0)項目**とは、文法規則の右辺の任意の位置にドット（・）を挿入したものです。ドットは、その規則の右辺のどこまでを認識したかを示すマーカーの役割を果たします。

例えば、`E -> E + T` という規則からは、以下の4つのLR(0)項目が生成されます。

- `E -> ・E + T` : まだ何も認識していない状態
- `E -> E・+ T` : `E` を認識し、次に `+` を期待する状態
- `E -> E +・T` : `E +` を認識し、次に `T` を期待する状態
- `E -> E + T・` : `E + T` をすべて認識し、還元可能な状態

LR(0)構文解析では、これらのLR(0)項目の**集合**を**状態**として扱います。構文解析器は、入力を読み進めながら、これらの状態間を遷移していきます。

### 閉包（Closure）とGOTO関数

状態（LR(0)項目集合）を構築するためには、**閉包（Closure）**と**GOTO関数**という二つの操作が必要です。

#### 閉包（Closure）

ある状態（項目集合）`I` の閉包 `closure(I)` は、その状態から遷移せずに認識できる可能性のあるすべての項目を含む集合です。具体的には、以下の手順で計算します。

1.  `closure(I)` を `I` で初期化する。
2.  `closure(I)` 内の項目 `[A -> α・Bβ]` （`B`は非終端記号）について、`B` から始まるすべての規則 `B -> γ` に対して、項目 `[B -> ・γ]` を `closure(I)` に追加する。
3.  新しい項目が追加されなくなるまで、ステップ2を繰り返す。

閉包操作により、ある状態において次に非終端記号 `B` が期待される場合、`B` を導出するために必要なすべての規則の初期状態（ドットが左端にある項目）がその状態に含まれることになります。

#### GOTO関数

GOTO関数 `goto(I, X)` は、状態 `I` において記号 `X` （終端記号または非終端記号）を読み込んだときに遷移する先の状態を計算します。

1.  状態 `I` 内のすべての項目 `[A -> α・Xβ]` について、ドットを一つ右に移動させた項目 `[A -> αX・β]` を集める。
2.  これらの新しい項目の集合に対して閉包操作を行い、結果を `goto(I, X)` とする。

### LR(0)状態機械の構築

文法からLR(0)構文解析器の状態機械（オートマトン）を構築する手順は以下の通りです。

1.  **文法の拡張**: 元の文法の開始記号を `S` とすると、新しい開始記号 `S'` と規則 `S' -> S` を追加します。これは、解析の終了（受理）を明確にするためです。
2.  **初期状態の作成**: 拡張された文法の初期項目 `[S' -> ・S]` を含む閉包 `closure({[S' -> ・S]})` を計算し、これを初期状態 `I0` とします。
3.  **状態の構築**:
    *   既に構築された状態 `I` と、文法中の各記号 `X` について `goto(I, X)` を計算します。
    *   `goto(I, X)` が空でなく、まだ状態として登録されていない新しい項目集合であれば、それを新しい状態として登録します。
    *   すべての状態からすべての記号に対するGOTO関数を計算し尽くすまで、このプロセスを繰り返します。

これにより、LR(0)項目の集合をノードとし、GOTO関数をエッジとする状態遷移図（LR(0)オートマトン）が構築されます。

### LR(0)構文解析表の作成

構築した状態機械（各状態 `Ii` と GOTO関数）から、構文解析表（ACTION表とGOTO表）を作成します。

1.  **ACTION表**:
    *   **シフト**: `goto(Ii, a) = Ij` （`a` は終端記号）の場合、`ACTION[i, a] = "shift j"` とします。これは、状態 `i` で終端記号 `a` を読み込んだら、スタックに `a` と状態 `j` をプッシュ（シフト）することを示します。
    *   **還元**: 状態 `Ii` に項目 `[A -> α・]` （`A ≠ S'`）が含まれる場合、**すべての**終端記号 `a` に対して `ACTION[i, a] = "reduce A -> α"` とします。これは、状態 `i` に到達し、規則 `A -> α` の右辺をすべて認識したので、スタックから `α` に対応する要素を取り除き、`A` をプッシュ（還元）することを示します。
    *   **受理**: 状態 `Ii` に項目 `[S' -> S・]` が含まれる場合、`ACTION[i, $]` （`$` は入力終了記号）に `"accept"` を設定します。
2.  **GOTO表**:
    *   `goto(Ii, A) = Ij` （`A` は非終端記号）の場合、`GOTO[i, A] = j` とします。これは、還元によって非終端記号 `A` がスタックにプッシュされた後、次に遷移すべき状態が `j` であることを示します。

### LR(0)の限界：コンフリクト

LR(0)構文解析表を作成する際、ACTION表の同じマスに複数のアクションが書き込まれることがあります。これを**コンフリクト**と呼び、LR(0)法では解析できない文法であることを示します。

-   **シフト/還元コンフリクト (Shift/Reduce Conflict)**: 同じマスに `shift` アクションと `reduce` アクションが入る場合。入力記号をシフトして解析を続けるべきか、規則を還元すべきか決定できません。
-   **還元/還元コンフリクト (Reduce/Reduce Conflict)**: 同じマスに複数の `reduce` アクションが入る場合。どの規則で還元すべきか決定できません。

LR(0)法は、還元を決定する際に次に入力される記号（先読み記号）を全く考慮しないため、多くの実用的な文法でコンフリクトが発生します。

### 具体例：LR(0)状態機械と解析表の構築

簡単な文法を使って、LR(0)の状態機械と解析表を構築してみましょう。

**文法 G1:**

```
(0) S' -> E
(1) E -> E + T
(2) E -> T
(3) T -> id
```

**LR(0)項目集合（状態）:**

-   **I0**: `closure({[S' -> ・E]})` = `{ [S' -> ・E], [E -> ・E + T], [E -> ・T], [T -> ・id] }`
-   **I1**: `goto(I0, E)` = `closure({[S' -> E・], [E -> E・+ T]})` = `{ [S' -> E・], [E -> E・+ T] }`
-   **I2**: `goto(I0, T)` = `closure({[E -> T・]})` = `{ [E -> T・] }`
-   **I3**: `goto(I0, id)` = `closure({[T -> id・]})` = `{ [T -> id・] }`
-   **I4**: `goto(I1, +)` = `closure({[E -> E + ・T]})` = `{ [E -> E + ・T], [T -> ・id] }`
-   **I5**: `goto(I4, T)` = `closure({[E -> E + T・]})` = `{ [E -> E + T・] }`
-   **I6**: `goto(I4, id)` = `closure({[T -> id・]})` = `{ [T -> id・] }` ( = I3 )

**構文解析表:**

| 状態 | ACTION        |       |      | GOTO |   |
| :--- | :------------ | :---- | :--- | :--- | :- |
|      | **id**        | **+** | **$** | **E** | **T** |
| **0** | s3            |       |      | 1    | 2  |
| **1** |               | s4    | acc  |      |    |
| **2** | r2            | r2    | r2   |      |    |  <-- 状態2 (`[E -> T・]`) で `+` が来ると `shift 4` (I1から+) と `reduce E->T` でS/Rコンフリクト
| **3** | r3            | r3    | r3   |      |    |  <-- 状態3 (`[T -> id・]`) は還元のみ
| **4** | s6            |       |      |      | 5  |
| **5** | r1            | r1    | r1   |      |    |  <-- 状態5 (`[E -> E + T・]`) は還元のみ
| **6** | r3            | r3    | r3   |      |    |  <-- 状態6 (`[T -> id・]`) は還元のみ (I3と同じ)

（`si` は shift i, `rj` は reduce j (規則jを使用), `acc` は accept）

この表を見ると、状態2において、項目 `[E -> T・]` が存在するため、LR(0)の規則では終端記号 `id`, `+`, `$` のいずれに対しても `reduce E -> T` (r2) を行います。しかし、もし状態1から `+` を読み込んで状態4 (`I4: E -> E + ・T ...`) に遷移するパスがある場合、状態2で `+` が入力されたときに `shift` すべきか `reduce` すべきか判断できません（シフト/還元コンフリクト）。この例では、`I1` から `+` で `I4` に遷移するため、状態2で `+` が来た場合に `reduce E->T` を行うか、あるいは別の解釈（例えば `E+T` の一部として `T` の後に `+` が続くケースを先読みしてシフトを優先するなど）をするかでコンフリクトが生じます。LR(0)では先読みを行わないため、この種のコンフリクトを解決できません。

このように、LR(0)は非常に単純ですが、扱える文法のクラスは限定的です。このコンフリクトを解消するために、次に説明するSLR(1)法では**FOLLOW集合**という先読み情報を利用します。

## 5.10 SLR(1) - FOLLOW集合でコンフリクト解消を試みる

**SLR(1)**（Simple LR(1)）法は、LR(0)法のコンフリクトを解消するために、**FOLLOW集合**という先読み情報を導入する手法です。LR(0)では、還元アクション `reduce A -> α` を決定する際、次の入力記号に関わらず、項目 `[A -> α・]` を含む状態では常に還元を試みていました。これがコンフリクトの主な原因でした。

SLR(1)では、還元 `reduce A -> α` を行う条件をより限定します。具体的には、状態 `Ii` に項目 `[A -> α・]` が含まれていても、次の入力記号 `a` が **`FOLLOW(A)`** （非終端記号 `A` の後に現れうる終端記号の集合）に含まれている場合にのみ、還元アクション `ACTION[i, a] = "reduce A -> α"` を設定します。

### FOLLOW集合の計算

FOLLOW集合の計算方法は、5.7節のLL(1)で説明したものと同じです。簡単に復習しましょう。

1.  すべての非終端記号 `A` について `FOLLOW(A)` を空集合で初期化する。
2.  開始記号 `S'` の `FOLLOW(S')` に入力終了記号 `$` を追加する。
3.  文法中の各規則 `B -> αAβ` について、
    *   `FIRST(β)` に含まれる `ε` 以外のすべての終端記号を `FOLLOW(A)` に追加する。
    *   もし `β` が `ε` を導出可能（`nullable(β)` が真）ならば、`FOLLOW(B)` のすべての記号を `FOLLOW(A)` に追加する。
4.  新しい記号が追加されなくなるまで、ステップ3を繰り返す。

### SLR(1)構文解析表の作成

SLR(1)の構文解析表の作成手順は、LR(0)とほとんど同じですが、**還元アクションの決定方法**だけが異なります。

1.  **文法の拡張**: LR(0)と同様。
2.  **LR(0)項目集合（状態）の構築**: LR(0)と同様に、閉包とGOTO関数を用いて状態機械を構築します。
3.  **FOLLOW集合の計算**: 上記の手順で、すべての非終端記号のFOLLOW集合を計算します。
4.  **構文解析表の作成**:
    *   **ACTION表**:
        *   **シフト**: `goto(Ii, a) = Ij` （`a` は終端記号）の場合、`ACTION[i, a] = "shift j"`。 (LR(0)と同じ)
        *   **還元**: 状態 `Ii` に項目 `[A -> α・]` （`A ≠ S'`）が含まれる場合、**`FOLLOW(A)` に含まれる各終端記号 `a` に対してのみ**、`ACTION[i, a] = "reduce A -> α"` を設定します。 (ここがLR(0)と異なる！)
        *   **受理**: 状態 `Ii` に項目 `[S' -> S・]` が含まれる場合、`ACTION[i, $]` に `"accept"` を設定します。 (LR(0)と同じ)
    *   **GOTO表**: `goto(Ii, A) = Ij` （`A` は非終端記号）の場合、`GOTO[i, A] = j`。 (LR(0)と同じ)

### SLR(1)によるコンフリクト解消の例

先ほどの文法 G1 でSLR(1)構文解析表を作成してみましょう。

**文法 G1:**

```
(0) S' -> E
(1) E -> E + T
(2) E -> T
(3) T -> id
```

**FOLLOW集合:**

-   `FOLLOW(S')` = `{ $ }`
-   `FOLLOW(E)` = `{ +, $ }` （規則1より `+`、規則0とS'のFOLLOW集合より `$`）
-   `FOLLOW(T)` = `{ +, $ }` （規則1より `FOLLOW(E)` を継承、規則2より `FOLLOW(E)` を継承）

**SLR(1)構文解析表:**

| 状態 | ACTION        |       |      | GOTO |   |
| :--- | :------------ | :---- | :--- | :--- | :- |
|      | **id**        | **+** | **$** | **E** | **T** |
| **0** | s3            |       |      | 1    | 2  |
| **1** |               | s4    | acc  |      |    |
| **2** |               | **r2** | **r2** |      |    |  <-- `FOLLOW(E)` = {+, $} のみ還元
| **3** |               | **r3** | **r3** |      |    |  <-- `FOLLOW(T)` = {+, $} のみ還元
| **4** | s6            |       |      |      | 5  |
| **5** |               | **r1** | **r1** |      |    |  <-- `FOLLOW(E)` = {+, $} のみ還元
| **6** |               | **r3** | **r3** |      |    |  <-- `FOLLOW(T)` = {+, $} のみ還元 (I3と同じ)

LR(0)ではコンフリクトが発生していた状態2, 3, 5, 6を見てみましょう。

-   **状態2**: 項目 `[E -> T・]` を含む。`FOLLOW(E) = {+, $}` なので、`+` と `$` の列にのみ `r2` を設定します。`id` の列にはアクションが設定されず、コンフリクトは解消されました。
-   **状態3**: 項目 `[T -> id・]` を含む。`FOLLOW(T) = {+, $}` なので、`+` と `$` の列にのみ `r3` を設定します。同様にコンフリクトは解消されました。
-   **状態5**: 項目 `[E -> E + T・]` を含む。`FOLLOW(E) = {+, $}` なので、`+` と `$` の列にのみ `r1` を設定します。コンフリクトは解消されました。
-   **状態6**: 項目 `[T -> id・]` を含む。状態3と同じ理由でコンフリクトは解消されました。

このように、SLR(1)はFOLLOW集合を用いることで、LR(0)よりも多くの文法（SLR(1)文法）を解析できるようになります。

### SLR(1)の限界

しかし、SLR(1)でもコンフリクトを解消できない場合があります。FOLLOW集合は、文法全体から見てその非終端記号の後に何が来るかを示すものであり、特定の状態における文脈を十分に考慮できていないためです。

**例：SLR(1)でコンフリクトが発生する文法 G2**

```
(0) S' -> S
(1) S -> L = R
(2) S -> R
(3) L -> * R
(4) L -> id
(5) R -> L
```

この文法は、代入文のような構造を表します。この文法でLR(0)項目集合を作成し、SLR(1)解析表を構築しようとすると、以下のような状況でコンフリクトが発生します。

まず、LR(0)項目集合（状態）を構築していくと、ある状態 `Ii` が `{[S -> L・= R], [R -> L・]}` のような項目を含むことがあります（簡単のため、閉包の一部のみを示しています）。
ここで、`FOLLOW(R)` を計算すると、規則 `S -> L = R` からは FOLLOW(R) に `$` (S'のFOLLOW) が入り、規則 `S -> R` からも FOLLOW(R) に `$` が入ります。また、もし `R` が他の規則の右辺の末尾以外にも出現し、その後に `=` が続くような文脈があれば、`FOLLOW(R)` に `=` が含まれる可能性があります（このG2文法では、`S -> L = R` で `R` は末尾なので、直接的には `=` は `FOLLOW(R)` には入りにくいですが、より複雑な文法では起こりえます。ここでは仮に `FOLLOW(R) = {=, $}` となったとします）。

この状態でSLR(1)解析表の `ACTION[i, =]` を決定しようとすると、
- 項目 `[S -> L・= R]` から: `shift` アクション (仮に `shift j` とする)
- 項目 `[R -> L・]` と `FOLLOW(R)` に `=` が含まれることから: `reduce by R -> L` (規則5)
となり、シフト/還元コンフリクトが発生します。

このコンフリクトは、状態 `Ii` において `R -> L` で還元した後、次が `=` であることは文法的にありえない（例えば、`R` が文全体の右辺に来る場合など）にも関わらず、`FOLLOW(R)` という文法全体から導かれる大域的な情報だけでは、その状態における局所的な文脈（`L` の後に `=` が続くべきか、それとも文末か）を区別できないために発生します。

この問題を解決するには、各状態におけるより詳細な文脈情報、すなわち「その項目に到達した際に、次に何が来ることを期待しているか」という情報が必要になります。これが次に説明するLR(1)法のアイデアです。

## 5.11 LR(1) - より強力な先読み情報を持つ項目

**LR(1)**法は、SLR(1)法の限界を克服するために、各項目に**先読み記号（lookahead symbol）**という、より強力な文脈情報を付加する手法です。これにより、SLR(1)では区別できなかった状態を区別し、コンフリクトを解消することが可能になります。LR(1)法は、理論上、LR(k)文法（k≧1）の中で最も強力な解析能力を持ちます。

### LR(1)項目

LR(1)項目は、LR(0)項目に先読み記号（終端記号）を追加したもので、以下の形式で表されます。

```text
[A -> α・β, a]
```

-   `A -> α・β`: LR(0)項目部分。`α` を認識し、次に `β` を期待する状態。
-   `a`: 先読み記号。この項目が最終的に還元 `A -> αβ` に成功した場合、その直後に入力されることが期待される終端記号。

例えば、`[E -> E・+ T, $]` というLR(1)項目は、「`E` を認識し、次に `+` を期待しており、もしこの `E` が最終的に開始記号 `S'` まで還元された場合、入力の終わり `$` が来るはずだ」という文脈情報を含んでいます。

### LR(1)閉包（Closure）とGOTO関数

LR(1)項目集合（状態）を構築するための閉包とGOTO関数も、先読み記号を考慮するように拡張されます。

#### LR(1)閉包

状態 `I` のLR(1)閉包 `closure(I)` は、以下の手順で計算します。

1.  `closure(I)` を `I` で初期化する。
2.  `closure(I)` 内の各項目 `[A -> α・Bβ, a]` （`B`は非終端記号）について、`B` から始まるすべての規則 `B -> γ` に対して、**`FIRST(βa)` に含まれる各終端記号 `b`** について、項目 `[B -> ・γ, b]` を `closure(I)` に追加する。
    *   `FIRST(βa)` は、`β` の後に `a` が続く記号列から導かれうる最初の終端記号の集合です。`β` が `ε` を含めば `a` も含まれます。
3.  新しい項目が追加されなくなるまで、ステップ2を繰り返す。

LR(0)閉包との違いは、新しい項目 `[B -> ・γ, b]` を追加する際に、元の項目の `β` と先読み記号 `a` から計算される `FIRST(βa)` を使って、新しい項目の先読み記号 `b` を決定する点です。これにより、より正確な文脈情報が伝播します。

#### LR(1) GOTO関数

GOTO関数 `goto(I, X)` の計算方法はLR(0)と似ていますが、LR(1)項目を扱います。

1.  状態 `I` 内のすべての項目 `[A -> α・Xβ, a]` について、ドットを一つ右に移動させた項目 `[A -> αX・β, a]` を集める。
2.  これらの新しい項目の集合に対して **LR(1)閉包** 操作を行い、結果を `goto(I, X)` とする。

### LR(1)構文解析表の作成

LR(1)構文解析表の作成手順もSLR(1)と似ていますが、還元アクションの決定にFOLLOW集合ではなく、**LR(1)項目の先読み記号**を使用します。

1.  **文法の拡張**: LR(0)と同様。
2.  **LR(1)項目集合（状態）の構築**:
    *   初期状態 `I0` は `closure({[S' -> ・S, $]})` とする。
    *   GOTO関数を用いて、到達可能なすべてのLR(1)状態を構築する。
3.  **構文解析表の作成**:
    *   **ACTION表**:
        *   **シフト**: 状態 `Ii` に項目 `[A -> α・aβ, b]` が含まれ、`goto(Ii, a) = Ij` （`a` は終端記号）の場合、`ACTION[i, a] = "shift j"`。
        *   **還元**: 状態 `Ii` に項目 `[A -> α・, a]` （`A ≠ S'`）が含まれる場合、**その項目の先読み記号 `a` に対してのみ**、`ACTION[i, a] = "reduce A -> α"` を設定します。 (ここがSLR(1)と異なる！)
        *   **受理**: 状態 `Ii` に項目 `[S' -> S・, $]` が含まれる場合、`ACTION[i, $]` に `"accept"` を設定します。
    *   **GOTO表**: `goto(Ii, A) = Ij` （`A` は非終端記号）の場合、`GOTO[i, A] = j`。 (LR(0)/SLR(1)と同じ)

### LR(1)によるコンフリクト解消の例

先ほどSLR(1)でコンフリクトが発生した文法 G2 をLR(1)で解析してみましょう。

**文法 G2:**

```
(0) S' -> S
(1) S -> L = R
(2) S -> R
(3) L -> * R
(4) L -> id
(5) R -> L
```

SLR(1)でコンフリクトが発生したのは、ある状態（仮に `Ik` とする）に `[R -> L・]` という項目があり、次の入力が `=` の場合でした。SLR(1)では、`FOLLOW(R)` に基づいて還元を決定します。文法G2において、`FOLLOW(R)` には（`S -> R` という規則と `S' -> S` により）`$` が含まれます。また、`S -> L = R` という規則があるため、もし `L` が `R` を導出するような別の経路があれば、`FOLLOW(R)` に `=` が含まれる可能性も出てきます。

LR(1)では、項目自体に先読み記号が付与されるため、より精密な判断が可能です。
例えば、状態 `Ik` に対応するLR(1)状態を考えると、
- `S -> L・= R` という文脈から `R -> L` の還元に至る場合、`L` の直後に期待されるのは `=` です。このため、項目は `[R -> L・, =]` のようになります。
- `S -> R` という文脈から `R -> L` の還元に至る場合、`L` (つまり`R`) の直後に期待されるのは `$` です。このため、項目は `[R -> L・, $]` のようになります。

このように、同じLR(0)コア `R -> L・` を持っていても、先読み記号が異なるため、LR(1)では異なる状態（または同じ状態内の異なる項目）として扱われます。
その結果、LR(1)構文解析表では、
- `[R -> L・, =]` を含む状態 `Ij` では、`ACTION[j, =]` に `reduce by R -> L` が設定されます。
- `[R -> L・, $]` を含む状態 `Ik` では、`ACTION[k, $]` に `reduce by R -> L` が設定されます。

もし、状態 `Ij` に `[S -> L・= R, $]` (先読みは `$`）のようなシフトアクションにつながる項目が含まれていても、`reduce by R -> L` は入力 `=` の場合にのみ適用されるため、`=` におけるシフト/還元コンフリクトは発生しません。同様に、`$` におけるコンフリクトも、先読み記号が一致する場合にのみアクションが定義されるため、解消される可能性が高まります。

このように、LR(1)は項目ごとに正確な先読み記号を持つことで、SLR(1)よりも精密な判断が可能になり、より多くの文法（LR(1)文法）を解析できます。

### LR(1)の欠点：解析表のサイズ

LR(1)法の最大の欠点は、状態数が非常に多くなることです。LR(0)項目が同じでも、先読み記号が異なれば別のLR(1)状態となるため、状態数はSLR(1)（LR(0)状態数と同じ）に比べて大幅に増加する傾向があります。これは、構文解析表のサイズが巨大になることを意味し、メモリ使用量や生成時間の観点から実用的でない場合があります。

この問題を解決するために、次に説明するLALR(1)法が考案されました。

## 5.12 LALR(1) - 実用性と解析能力のバランス

**LALR(1)**（Look-Ahead LR）法は、LR(1)法の強力な解析能力を維持しつつ、構文解析表のサイズをSLR(1)法と同程度に抑えることを目的とした、実用的な上向き構文解析アルゴリズムです。多くの構文解析器生成系（YaccやBisonなど）で採用されている標準的な手法です。

### LALR(1)のアイデア：状態のマージ

LALR(1)法の基本的なアイデアは、LR(1)状態の中で、**LR(0)項目部分（コア）が全く同じ状態を一つにマージ（統合）する**ことです。

LR(1)状態は `[A -> α・β, a]` の形式でした。このうち `A -> α・β` の部分を**コア (core)** と呼びます。LALR(1)では、コアが同じである複数のLR(1)状態を一つのLALR(1)状態にまとめます。

例えば、LR(1)で以下のような二つの状態があったとします。

-   状態 `I`: `{ [A -> α・, a], [B -> γ・, c] }`
-   状態 `J`: `{ [A -> α・, b], [B -> γ・, d] }`

これらの状態は、コア `A -> α・` と `B -> γ・` が共通です。LALR(1)では、これらを一つの状態 `K` にマージします。マージ後の状態 `K` に含まれる項目の先読み記号は、マージ元のすべての先読み記号を合わせたものになります。

-   状態 `K`: `{ [A -> α・, a/b], [B -> γ・, c/d] }`
    （ここで `a/b` は先読み記号が `a` または `b` であることを示す）

このように状態をマージすることで、LALR(1)の状態数はLR(0)の状態数と同じになります。

### LALR(1)構文解析表の作成

LALR(1)構文解析表は、マージされたLALR(1)状態に基づいて作成されます。

1.  **LR(1)状態の構築**: まず、LR(1)法のアルゴリズムに従って、すべてのLR(1)状態（項目集合）を構築します。
2.  **状態のマージ**: コア（LR(0)項目部分）が同じLR(1)状態を特定し、それらを一つのLALR(1)状態にマージします。マージ後の項目の先読み記号は、マージ元の項目の先読み記号の和集合となります。
3.  **構文解析表の作成**: マージ後のLALR(1)状態を用いて、LR(1)と同様の手順でACTION表とGOTO表を作成します。
    *   **シフト**: LR(1)と同様。
    *   **還元**: 状態 `Ii` に項目 `[A -> α・, a]` が含まれる場合、先読み記号 `a` に対して `ACTION[i, a] = "reduce A -> α"` を設定します。マージによって一つの項目に複数の先読み記号が含まれる場合（例：`[A -> α・, a/b]`）、`a` と `b` の両方の列に還元アクションを設定します。
    *   **受理**: LR(1)と同様。
    *   **GOTO**: LR(1)と同様（マージされた状態への遷移となります）。

### LALR(1)の利点と欠点

#### 利点

-   **解析表サイズ**: LALR(1)の解析表のサイズ（状態数）は、LR(0)やSLR(1)と同程度であり、LR(1)に比べて大幅に小さくなります。これにより、メモリ使用量や生成時間の点で実用的です。
-   **解析能力**: ほとんどの実用的なプログラミング言語の文法はLALR(1)で解析可能です。SLR(1)よりも強力であり、LR(1)で解析可能な文法の大部分をカバーします。

#### 欠点

-   **還元/還元コンフリクトの可能性**: LR(1)状態をマージする際に、異なる先読み記号を持つ還元項目が同じLALR(1)状態にまとめられることがあります。もし、マージ元のLR(1)状態では異なるアクション（例えば、異なる規則での還元）が割り当てられていた場合、マージ後のLALR(1)状態では同じ入力記号に対して複数の還元アクションが設定され、**還元/還元コンフリクト**が発生する可能性があります。これはLR(1)では発生しなかったコンフリクトです。
    *   ただし、このようなコンフリクトが発生する文法は稀であり、実用上問題になることは少ないとされています。
-   **シフト/還元コンフリクト**: LALR(1)では、LR(1)で解決されていたシフト/還元コンフリクトが解消されるとは限りません（ただし、新たに発生することもありません）。

### LALR(1)の位置づけ

LALR(1)は、LR(1)の強力な解析能力と、SLR(1)のコンパクトな解析表サイズという、両者の利点を高いレベルで両立させた、非常にバランスの取れた実用的なアルゴリズムです。そのため、Yacc、Bison、PLY（Python Lex-Yacc）など、多くの構文解析器生成系で標準的に採用されています。

もしLALR(1)でコンフリクトが発生した場合、文法を修正するか、より強力な（しかし一般的には効率が劣るか、実装が複雑な）GLR（Generalized LR）などのアルゴリズムを検討することになります。

---

ここまでで、代表的な上向き構文解析アルゴリズムであるLR(0), SLR(1), LR(1), LALR(1)について、その基本的な考え方、構築手順、利点、限界を順に見てきました。次は、近年注目を集めている別のアプローチ、Parsing Expression Grammar (PEG) について見ていきましょう。

## 5.13 - Parsing Expression Grammar(PEG) - 構文解析アルゴリズムのニューカマー

2000年代に入るまで、構文解析手法の主流はLR法の変種であり、上向き構文解析アルゴリズムでした。その理由の一つに、先読みを前提とする限り、従来のLL法はLR法より表現力が弱いという弱点がありました。下向き型でもバックトラックを用いれば幅広い言語を表現できることは比較的昔から知られていましたが、バックトラックによって解析時間が最悪で指数関数時間になるという弱点があります。そのため、コンパイラの教科書として有名な、いわゆるドラゴンブックでも現実的ではないといった記述がありました（初版にはあったはずだが、第二版にも該当記述があるかは要確認）。しかし、2004年にBryan Fordによって提案されたParsing Expression Grammar（PEG）はそのような状況を変えました。

PEGはおおざっぱに言ってしまえば、無制限な先読みとバックトラックを許す下向き型の構文解析手法の一つです。決定的文脈自由言語に加えて一部の文脈依存言語を取り扱うことができますし、Packrat Parsingという最適化手法によって線形時間で構文解析を行うことが保証されているというとても良い性質を持っています。さらに、LL法やLR法でほぼ必須であった字句解析器が要らず、アルゴリズムも非常にシンプルであるため、ここ十年くらいで解析表現手法をベースとした構文解析生成系が数多く登場しました。

他人事のように書いていますが、筆者が大学院時代に専門分野として研究していたのがまさしくこのPEGでした。Python 3.9ではPEGベースの構文解析器が採用されるなど、PEGは近年採用されるケースが増えています。

3章で既にPEGを用いた構文解析器を自作したのを覚えているでしょうか。たとえば、配列の文法を表現した以下のPEGがあるとします (第3章のBNF定義 `array = LBRACKET RBRACKET | LBRACKET value {COMMA value} RBRACKET ;` と同じ意味です)。

```text
array <- LBRACKET (value (COMMA value)*)? RBRACKET
// 上記は以下と同等とも解釈できる (PEGでは / が順序付き選択)
// array <- LBRACKET RBRACKET / LBRACKET value (COMMA value)* RBRACKET
// ここでは第3章のコード実装に合わせた以下の定義で考えます。
// array = LBRACKET RBRACKET | LBRACKET value {COMMA value} RBRACKET ;
```

　このPEGの考え方（特に `|` による選択と、失敗時のバックトラック）に対応するJavaの構文解析器（メソッド）は以下のようになるのでした。

```java
    public Ast.JsonArray parseArray() {
        int backup = cursor;
        try {
            // LBRACKET RBRACKET
            parseLBracket();
            parseRBracket();
            return new Ast.JsonArray(new ArrayList<>());
        } catch (ParseException e) {
            cursor = backup;
        }

        // LBRACKET
        parseLBracket();
        List<Ast.JsonValue> values = new ArrayList<>();
        // value
        var value = parseValue();
        values.add(value);
        try {
            // {value {COMMA value}}
            while (true) {
                parseComma();
                value = parseValue();
                values.add(value);
            }
        } catch (ParseException e) {
            // RBRACKET
            parseRBracket();
            return new Ast.JsonArray(values);
        }
    }
```

PEGの特色は、

```java
        int backup = cursor;
```

という行によって、解析を始める時点でのソースコード上の位置を保存しておき、もし解析に失敗したら以下のように「巻き戻す」ところにあります。「巻き戻した」位置から次の分岐を試そうとするのです。

```java
        } catch (ParseException e) {
            cursor = backup;
        }
        // LBRACKET
        parseLBracket();
        // ...
```

なお、PEGの挙動を簡単に説明するために3章および本章では例外をスロー/キャッチするという実装にしていますが、現実にはこのような実装にするとオーバーヘッドが大きすぎるため、実用的なPEGパーザでは例外を使わないことが多いです。

一般化すると、PEGの挙動は以下の8つの要素を使って説明することができます。

1. 空文字列： ε
2. 終端記号： t
3. 非終端記号： N
4. 連接： e1 e2
5. 選択： e1 / e2
6. 0回以上の繰り返し： e*
7. 肯定述語： &e
8. 否定述語： !e
  
  次節以降では、この8つの要素がそれぞれどのような意味を持つかを説明していきます。説明のために

```java
match(e, v) == Success(consumed, rest) 
```

や

```java
match(e, v) == Failure
```

というJava言語ライクな記法を使います。

たとえば、

```java
match("x", "xy") == Success("x", "y")`
```

は式`x`が文字列`"xy"`にマッチして残りの文字列が`"y"`であることを示します。また、

```java
match("xy", "x") == Failure
```

は式`"xy"`が文字列`"x"`にマッチしないことを表現します。

### 空文字列

空文字列εは0文字**以上**の文字列にマッチします。たとえば、

```java
match(ε, "") == Success("", "")
```

が成り立つだけでなく、

```java
match(ε, "x") ==  Success("", "x")
```

や

```java
match(ε, "xyz") == Success("", "xyz")
```

も成り立ちます。εは**あらゆる文字列**にマッチすると言い換えることができます。

### 終端記号

終端記号`t`は1文字以上の長さで特定のアルファベットで**始まる**文字列にマッチします。たとえば、

```java
match(x, "x") == Success("x", "")
```

や

```java
match(x, "xy") == Success("x", "y")
```

が成り立ちます。一方、

```java
match(x, "y") == Failure
```

ですし、

```java
match(x, "") == Failure
```

です。εの場合と同じく「残りの文字列」があってもマッチする点に注意してください。

### 選択

`e1`と`e2`は共に式であるものとします。このとき、


```text
e1 / e2
```

に対する`match(e1 / e2, s)`は以下のような動作を行います。

1. `match(e1, s)`を実行する
2. 1.が成功していれば、sのサフィックスを返し、成功する
3. 1.が失敗した場合、`match(e2, s)`を実行し、結果を返す

### 連接

`e1`と`e2`は共に式であるものとします。このとき、

```text
e1 e2
```

　に対する`match(e1 e2, s)`は以下のような動作を行います。

1. `match(e1, s)`を実行する
2. 1.が成功したとき、結果を`Success(s1,s2)`とする。この時、`match(e2,s2)`を実行し、結果を返す
3. 1.が失敗した場合、その結果を返す

### 非終端記号

あるPEGの規則Nがあったとします。

```text
N <- e
```

`match(N, s)`は以下のような動作を行います。

1. `N`に対応する規則を探索する（`N <- e`が該当）
2. `N`の呼び出しから戻って来たときのために、スタックに現在位置`p`を退避
3. `match(e, s)`を実行する。結果を`M`とする。
4. スタックに退避した`p`を戻す
5. `M`を全体の結果とする

### 0回以上の繰り返し

`e`は式であるものとします。

```text
e*
```

このとき、eと文字列sの照合を行うために以下のような動作を行います。

1. `match(e,s)`を実行する
2. 1.が成功したとき（`n`回目）、結果を`Success(s_n,s_(n+1))`とする。`s`を`s_(n+1)`に置き換えて、1.に戻る
3. 1.が失敗した場合（`n`回目）、結果を`Success(s_1...s_n, s[n...])`とする

`e*`は「0回以上の繰り返し」を表現するため、一回も成功しない場合でも全体が成功するのがポイントです。なお、`e*`は規則

```
H <- e H / ε
```

に対して`H`を呼び出すことの構文糖衣であり、全く同じ意味になります。

### 肯定述語

`e`は式であるものとします。このとき、

```text
&e
```
　
は`match(&e,s)`を実行するために、以下のような動作を行います。

1. `match(e,s)`を実行する
2-1. 1.が成功したとき：結果を`Success("", s)`とする
2-2. 1.が失敗した場合：結果は`Failure()`とする

肯定述語は成功したときにも「残り文字列」が変化しません。肯定述語`&e`は後述する否定述語`!!`を二重に重ねたものに等しいことが知られています。


### 否定述語

`e`は式であるものとします。このとき、

```text
!e
```
　
は`match(!e,s)`を実行するために以下のような動作を行います。

1. `match(e,s)`を実行する
2-1. 1.が成功したとき：結果を`Failure()`とする
2-2. 1.が失敗した場合：結果は`Success("", s)`とする

否定述語も肯定述語同様、成功しても「残り文字列」が変化しません。

前述した`&e = !!e`は論理における二重否定の除去に類似するものということができます。

### PEGの操作的意味論

ここまでで、PEGを構成する8つの要素について説明してきましたが、実際のところは厳密さに欠けるものでした。より厳密に説明すると以下のようになります（Ford:04を元に改変）。先程までの説明では、`Success(s1, s2)`を使って、`s1`までは読んだことを、残り文字列が`s2`であることを表現してきました。ここではペア`(k, y)`で結果を表しており、`k`は消費した文字数（またはステップ数、文献により異なる）、`y`は残り文字列または特別な失敗値`f`となります。`⇒`記号は、左の状態から右の状態への遷移（評価ステップ）を表します。

(記号の簡単な説明: `x, y` は入力文字列の一部、`a, b` は終端記号、`e, e1, e2` はPEGの式、`A` は非終端記号、`R` は規則の集合、`VT` は終端記号の集合、`V*T` は終端記号の任意の（空を含む）列を表します。`o` は成功時の消費文字列または失敗値 `f` を表します。)

```
1. 空文字列: 
  (ε, x) ⇒ (0, x)  (消費文字数0、残りx)
2. 終端記号(成功した場合): 
  (a, ax) ⇒ (length(a), x) (a ∈ VT, x ∈ V*T)
3. 終端記号(失敗した場合):
  (a, bx) ⇒ (0, f)  iff a ≠ b (a, b ∈ VT)
  (a, ε) ⇒ (0, f)   (入力が空の場合)
4. 非終端記号:
  (A, x) ⇒ (k, y)  iff (e, x) ⇒ (k, y)  (ここで A ← e ∈ R)
5. 連接(成功した場合): 
  (e1, x) ⇒ (k1, x') かつ (e2, x') ⇒ (k2, x'') のとき、
  (e1 e2, x) ⇒ (k1 + k2, x'')
6. 連接(失敗した場合１): 
  (e1, x) ⇒ (k1, f) ならば (e1 e2, x) ⇒ (k1, f)
7. 連接(失敗した場合２): 
  (e1, x) ⇒ (k1, x') かつ (e2, x') ⇒ (k2, f) ならば (e1 e2, x) ⇒ (k1 + k2, f)
8. 選択(場合１): 
  (e1, x) ⇒ (k1, y) (y ≠ f) ならば (e1 / e2, x) ⇒ (k1, y)
9. 選択(場合２): 
  (e1, x) ⇒ (k1, f) かつ (e2, x) ⇒ (k2, y) ならば (e1 / e2, x) ⇒ (k1 + k2, y)
10. 0回以上の繰り返し (繰り返しの場合): 
  (e, x) ⇒ (k1, x') (x' ≠ f) かつ (e*, x') ⇒ (k2, x'') ならば
  (e*, x) ⇒ (k1 + k2, x'')
11. 0回以上の繰り返し (停止の場合): 
  (e, x) ⇒ (k, f) ならば (e*, x) ⇒ (0, x) (消費0で成功)
12. 否定述語（場合１、eが成功）: 
  (e, x) ⇒ (k, y) (y ≠ f) ならば (!e, x) ⇒ (k, f)
13. 否定述語（場合２、eが失敗）: 
  (e, x) ⇒ (k, f) ならば (!e, x) ⇒ (k, x) (消費0で成功)
```
(注意: 上記はFordの論文の操作的意味論を簡略化・解釈したものであり、ステップ数カウンタ `n` の扱いや消費文字数の表現は元論文と完全に同一ではありません。正確な定義は元論文を参照してください。)

## 5.14 - Packrat Parsing

素のPEGは非常に単純でいて、とても幅広い範囲の言語を取り扱うことができます。しかし、PEGには一つ大きな弱点があります。最悪の場合、解析時間が指数関数時間になってしまうことです。現実的にはそのようなケースは稀であるという指摘ありますが（論文を引用）、原理的にはそのような弱点があります。Packrat Parsingはメモ化という技法を用いることでPEGで表現される言語を線形時間で解析可能にします。

メモ化という技法自体をご存じでない読者の方も多いかもしれないので、まずメモ化について説明します。

### fibメソッド

　メモ化の例でよく出てくるのはN番目のフィボナッチ数を求める`fib`関数です。この書籍をお読みの皆様ならお馴染みかもしれませんが、N番目のフィボナッチ数F(n)は次のようにして定義されます：

```
F(0) = 1
F(1) = 1
F(n) = F(n - 1) + F(n - 2)
```

　この再帰的定義を素朴にJavaのメソッドとして書き下したのが以下のfibメソッドになります。

```java
public class Main {
    public static long fib(long n) {
        if(n == 0) return 0L; // F(0)=0
        if(n == 1) return 1L; // F(1)=1
        else return fib(n - 1) + fib(n - 2); 
    }
    public static void main(String[] args) {
        // F(0)=0, F(1)=1, F(2)=1, F(3)=2, F(4)=3, F(5)=5
        System.out.println(fib(5)); // 5
    }
}
```

このプログラムを実行すると、`fib(5)` の結果として `5` が出力されます。しかし、このfibメソッドには重大な欠点があります。それは、nが増えると計算量が指数関数的に増えてしまうことです。たとえば、上のfibメソッドを使うと`fib(30)`くらいまではすぐに計算することができます。しかし、`fib(50)`を求めようとすると皆さんのマシンではおそらく数十秒から数分はかかるでしょう。

　フィボナッチ数を求めたいだけなのに数十秒もかかってはたまったものではありません。

### fib関数のメモ化

そこで出てくるのがメモ化というテクニックです。一言でいうと、メモ化とはある引数nに対して計算した結果f(n)をキャッシュしておき、もう一度同じnに対して呼び出されたときはキャッシュした結果を返すというものです。早速、fibメソッドをメモ化してみましょう。

メモ化されたfibメソッドは次のようになります。

```java
import java.util.*;
public class Main {
    private static Map<Long, Long> cache = new HashMap<>();
    public static long fib(long n) {
        Long value = cache.get(n);
        if(value != null) return value;

        long result;
        if(n == 0) {
            result = 0L;
        } else if (n == 1) {
            result = 1L;
        } else {
            result = fib(n - 1) + fib(n - 2);
        }
        cache.put(n, result);
        return result;
    }
    public static void main(String[] args) {
        // F(50) = 12586269025 (F(0)=0, F(1)=1 の場合)
        System.out.println(fib(50)); 
    }
}
```

`fib(50)`の結果は非常に大きな数になりますが、メモ化されたバージョンでは一瞬で結果が返ってくるのがわかると思います。メモ化されたfibメソッドでは同じnに対する計算は二度以上行われないので、nが増えても実行時間は実質的に線形にしか増えません。

ただし、計算量に詳しい識者の方は「おいおい。整数同士の加算が定数時間で終わるという仮定はおかしいんじゃないかい？」なんてツッコミを入れてくださるかもしれませんが、そこを議論するとややこしくなるので整数同士の加算はたかだか定数時間で終わるということにします。

`fib`メソッドのメモ化でポイントとなるのは、記憶領域（`cache`に使われる領域）と引き換えに最悪計算量を指数関数時間から線形時間に減らせるということです。また、メモ化する対象となる関数は一般的には副作用がないものに限定されます。というのは、メモ化というテクニックは「同じ引数を渡せば同じ値が返ってくる」ことを暗黙の前提にしているからです。

次の項ではPEGをナイーヴに実装した`parse`関数をまずお見せして、続いてそれをメモ化したバージョン（Packrat parsing）をお見せすることにします。`fib`メソッドのメモ化と同じようにPEGによる構文解析もメモ化できることがわかるでしょう。

### parseメソッド

　ここからは簡単なPEGで記述された文法を元に構文解析器を組み立てていくわけですが、下記のような任意個の`()`で囲まれた`0`の構文解析器を作ります。

```
A <- "(" A ")"
   / "(" A A ")"
   / "0"
```

　単純過ぎる例にも思えますが、メモ化の効果を体感するにはこれで十分です。早速構文解析器を書いていきましょう。

```java
sealed interface ParseResult permits ParseResult.Success, ParseResult.Failure {
    public abstract String rest();
    record Success(String value, String rest) implements ParseResult {}
    record Failure(String rest) implements ParseResult {}
}
class ParseError extends RuntimeException {
    public final String rest;
    public String rest() {
        return rest;
    }
    ParseError(String rest) {
        this.rest = rest;
    }
}
public class Parser {
    private static boolean isEnd(String string) {
        return string.length() == 0;
    }
    public static ParseResult parse(String input) {
        String start = input;
        try {
            // "(" A ")"
            if(isEnd(input) || input.charAt(0) != '(') {
                throw new ParseError(input);
            }

            var result = parse(input.substring(1));
            if(!(result instanceof ParseResult.Success)) {
                throw new ParseError(result.rest());
            }

            var success = (ParseResult.Success)result;

            input = success.rest();
            if(isEnd(input) || input.charAt(0) != ')') {
                throw new ParseError(input);
            }

            return new ParseResult.Success(success.value(), input.substring(1));
        } catch (ParseError error) {
            input = start;
        }

        try {
            // "(" A A ")"
            if((isEnd(input)) || input.charAt(0) != '(') {
                throw new ParseError(input);
            }

            var result = parse(input.substring(1));
            if(!(result instanceof ParseResult.Success)) {
                throw new ParseError(result.rest());
            }

            var success = (ParseResult.Success)result;
            input = success.rest();

            result = parse(input);

            if(!(result instanceof ParseResult.Success)) {
                throw new ParseError(result.rest());
            }

            success = (ParseResult.Success)result;
            input = success.rest();

            if(isEnd(input) || input.charAt(0) != ')') {
                throw new ParseError(input);
            }

            return new ParseResult.Success(success.value(), success.rest().substring(1));
        } catch (ParseError error) {
            input = start;
        }

        if(isEnd(input) || input.charAt(0) != '0') {
            return new ParseResult.Failure(input);
        }

        return new ParseResult.Success(input.substring(0, 1), input.substring(1));
    }
}
```

このプログラムを使うと以下のように構文解析を行うことが出来ます。

```java
jshell> Parser.parse("(");
$25 ==> Failure[rest=]
jshell> Parser.parse("()");
$26 ==> Failure[rest=)] // "0" がないので失敗
jshell> Parser.parse("(0)");
$27 ==> Success[value=0, rest=] // "0" がマッチし、valueに "0" が入ることを期待
```
　
しかし、この構文解析器には弱点があります。`(((((((((((((((((((((((((((0)))`のようなカッコのネスト数が深いケースで急激に解析にかかる時間が増大してしまうのです。これはまさにPEGだからこそ起こる問題点だと言えます。

### parseメソッドのメモ化 - Packrat Parsing

前のコードをもとに`parse`メソッドをメモ化してみましょう。コードは以下のようになります。

```java
import java.util.*;
sealed interface ParseResult permits ParseResult.Success, ParseResult.Failure {
    public abstract String rest();
    record Success(String value, String rest) implements ParseResult {}
    record Failure(String rest) implements ParseResult {}
}
class ParseError extends RuntimeException {
    public final String rest;
    public String rest() {
        return rest;
    }
    ParseError(String rest) {
        this.rest = rest;
    }
}
class PackratParser {
    private Map<String, ParseResult> cache = new HashMap<>();
    private boolean isEnd(String string) {
        return string.length() == 0;
    }
    public ParseResult parse(String input) {
        String start = input;
        try {
            // "(" A ")"
            if(isEnd(input) || input.charAt(0) != '(') {
                throw new ParseError(input);
            }

            input = input.substring(1);
            ParseResult result;
            result = cache.get(input);
            if(result == null) {
                result = parse(input);
                cache.put(input, result);
            }

            if(!(result instanceof ParseResult.Success)) {
                throw new ParseError(result.rest());
            }

            var success = (ParseResult.Success)result;

            input = success.rest();
            if(isEnd(input) || input.charAt(0) != ')') {
                throw new ParseError(input);
            }

            return new ParseResult.Success(success.value(), input.substring(1));
        } catch (ParseError error) {
            input = start;
        }

        try {
            // "(" A A ")"
            if((isEnd(input)) || input.charAt(0) != '(') {
                throw new ParseError(input);
            }

            input = input.substring(1);
            ParseResult result;
            result = cache.get(input);
            if(result == null){
                result = parse(input);
                cache.put(input, result);
            } 

            if(!(result instanceof ParseResult.Success)) {
                throw new ParseError(result.rest());
            }

            var success = (ParseResult.Success)result;
            input = success.rest();

            result = cache.get(input);
            if(result == null) {
                result = parse(input);
                cache.put(input,result);
            }

            if(!(result instanceof ParseResult.Success)) {
                throw new ParseError(result.rest());
            }

            success = (ParseResult.Success)result;
            input = success.rest();

            if(isEnd(input) || input.charAt(0) != ')') {
                throw new ParseError(input);
            }

            return new ParseResult.Success(success.value(), input.substring(1));
        } catch (ParseError error) {
            input = start;
        }

        if(isEnd(input) || input.charAt(0) != '0') {
            return new ParseResult.Failure(input);
        }

        return new ParseResult.Success(input.substring(0, 1), input.substring(1));
    }
}
```

```java
    private Map<String, ParseResult> cache = new HashMap<>();
```

というフィールドが加わったことです。このフィールド`cache`がパーズの途中結果を保持してくれるために計算が高速化されるのです。
例えば、入力 `(((((0)))))` のようなネストが深い場合を考えます。
メモ化なしの `Parser.parse` では、`A <- "(" A ")"` の規則を解析する際、内側の `A` を解決するために `parse` が再帰的に呼び出されます。同じ部分文字列（例えば `"0"` や `"(0)"`）に対する `parse` が何度も呼び出される可能性があります。特に `A <- "(" A A ")"` のような規則では、同じ部分問題が指数関数的に発生し得ます。
一方、メモ化ありの `PackratParser.parse` では、一度 `parse(input)` の結果（成功または失敗）が出ると、それが `cache` に `input` をキーとして保存されます。次回同じ `input` で `parse` が呼び出された際には、`cache.get(input)` で即座に結果が返され、再計算が行われません。これにより、例えば `parse("0")` の呼び出しは実質1回で済み、`parse("(0)")` もその構成要素である `parse("0")` の結果を再利用できます。
結果として、PEGでは最悪指数関数時間かかっていたものがPackrat Parsingでは入力長に対してたかだか線形時間で解析できるようになりました。

PEGは非常に強力な能力を持っていますが、同時に線形時間で構文解析を完了できるわけで、これはとても良い性質です。そういった理由もあってか、PEGやPackrat Parsingを用いた構文解析器や構文解析器生成系はここ10年くらいで大幅に増えました。

## 5.15 - 構文解析アルゴリズムの計算量と表現力の限界 

　LL parsing、LR parsing、PEG、Packrat parsingについてこれまで書いてきましたが、計算量的な性質についてまとめておきましょう。なお、`n`は入力文字列長を表します。

| アルゴリズム        | 時間計算量     | 空間計算量 (解析表またはメモ化テーブル) | 備考                                   |
| ------------------- | ------------- | --------------------------------------- | -------------------------------------- |
| LL(1)               | O(n)          | O(\|N\| * \|T\|)                        | \|N\|:非終端記号数, \|T\|:終端記号数     |
| LL(k)               | O(n)          | O(\|N\| * \|T\|^k)                      | kが大きくなると表サイズが指数的に増大   |
| SLR(1)              | O(n)          | O(状態数_LR0 * (\|T\|+\|N\|))           | 状態数_LR0: LR(0)オートマトンの状態数  |
| LR(1)               | O(n)          | O(状態数_LR1 * (\|T\|+\|N\|))           | 状態数_LR1: LR(1)オートマトンの状態数  |
| LALR(1)             | O(n)          | O(状態数_LR0 * (\|T\|+\|N\|))           | 状態数はLR(0)と同程度 (LR(1)より小さい)|
| PEG                 | O(2^n) (最悪) | O(n) (バックトラック用スタック)         | Packrat Parsingで線形時間に改善可能    |
| Packrat Parsing     | O(n)          | O(n * \|P\|)                            | \|P\|: PEGの規則数（または解析関数種類数）|

**表中の記号の説明:**
- `n`: 入力文字列の長さ
- `|N|`: 非終端記号の数
- `|T|`: 終端記号の数
- `|P|`: CFGの生成規則の総数、またはPEGの規則（解析関数）の数
- `状態数_LR0`: LR(0)オートマトンの状態数
- `状態数_LR1`: LR(1)オートマトンの状態数

PEGを除いて、これまで紹介した全ての手法において線形時間で解析を終えられます。といっても、Packrat Parsing自体がPEGの最適化手法なので、PEGも線形時間で解析を終えられることになります。さらに、PEGは最悪指数関数時間がかかるといっても、多くのケースでは経験的には線形時間＋多少のメモ化で解析を終えられるため、実用上は問題ないことが多いです。

一方、空間計算量については、LL系およびLR系のアルゴリズムでは、解析表のサイズは入力長 `n` に依存しません（文法のサイズに依存します）。これに対し、Packrat Parsingではメモ化テーブルのために `O(n * |P|)` の空間が必要となり、入力長に比例した空間計算量となります。実用的な文法については不要なメモ化をしない（選択的メモ化）という発展的な手法もありますが、ナイーブなPackrat Parsingではこの点に注意が必要です。LLやLR系の手法では空間計算量は入力長に依存しないため、構文解析表のサイズが極端に大きくならないケースではメモリの心配は不要です。

## 5.16 - まとめ

この章では構文解析アルゴリズムの中で比較的メジャーな手法について、そのアイデアと概要を含めて説明しました。その他にも多数の手法がありますが、いずれにせよ、「上から下に」向かって解析する下向きの手法と「下から上に」向かって解析する上向きの手法のどちらかに分類できると言えます。

LL(1)やLALR(1)、PEGのパーサジェネレータは多数存在するため、基本的な動作原理について押さえておいて損はありません。また、余裕があれば各構文解析手法を使って実際のパーサジェネレータを実装してみるのも良いでしょう。実際にパーサジェネレータを実装することで、より深く構文解析手法を理解することもできます。

\newpage

<!-- Chapter 8: 第6章:構文解析器生成系の世界 -->

# 第6章 構文解析器生成系の世界

　第5章では現在知られている構文解析手法について、アイデアと提案手法の概要について説明しました。実は、構文解析の世界ではよく知られていることなのですが、第5章で説明した各種構文解析手法は毎回プログラマが手で実装する必要はありません。

　というのは、CFGやPEG（その類似表記も含む）によって記述された文法定義から特定の構文解析アルゴリズムを用いた構文解析器を生成する構文解析器生成系というソフトウェアがあるからです。もちろん、それぞれの構文解析アルゴリズムや生成する構文解析器の言語ごとに別のソフトウェアを書く必要がありますが、ひとたびある構文解析アルゴリズムのための構文解析器生成系を誰かが書けば、その構文解析アルゴリズムを知らないプログラマでもその恩恵にあずかることができるのです。

　構文解析器生成系でもっとも代表的なものはyaccあるいはその互換実装であるGNU bisonでしょう。yaccはLALR(1)法を利用したCの構文解析器を生成してくれるソフトウェアであり、yaccを使えばプログラマはLALR(1)法の恩恵にあずかることができます。

　この章では構文解析器生成系という種類のソフトウェアの背後にあるアイデアからはじまり、LL(1)、LALR(1）、PEGのための構文解析器を作る方法や多種多様な構文解析器生成系についての紹介などを行います。

　また、この章の最後ではある意味構文解析生成系の一種とも言えるパーザコンビネータの実装方法について踏み込んで説明します。構文解析生成系はいったん対象となるプログラミング言語のソースコードを生成します。この時、対象言語のコードを部分的に埋め込む必要性が出てくるのですが、この「対象言語のコードを埋め込める必要がある」というのは結構曲者でして、実用上ほぼ必須だけど面倒くささと伴うので、構文解析系をお手軽に作るとは行かない部分があります。

　一方、パーザコンビネータであれば、いわゆる「ラムダ式」を持つほとんどのプログラミング言語で比較的簡単に実装できます。本書で利用しているJava言語でも同様です。というわけで、本章を読めば皆さんもパーザコンビネータを明日から自前で実装できるようになります。

## 6.1 Dyck言語の文法とPEGによる構文解析器生成

これまで何度も登場したDyck言語は明らかにLL(1)法でもLR(1)法でもPEGによっても解析可能な言語です。（第4章でDyck言語のBNFやCFGを紹介しましたが、具体的な手書きPEGパーザのコードは第5章の再帰下降パーザが近い考え方です）。しかし、手書きでパーザを実装しようとすると、退屈な繰り返しコードが多くなりがちです。

実際のところ、Dyck言語を表現する文法があって、構文解析アルゴリズムがPEGということまで分かれば対応するJavaコードを**機械的に生成する**ことも可能そうに見えます。特に、構文解析はコード量が多いわりには退屈な繰り返しコードが多いものですから、文法からJavaコードを生成できれば劇的に工数を削減できそうです。

このように「文法と構文解析手法が決まれば、後のコードは自動的に決定可能なはずだから、機械に任せてしまおう」という考え方が構文解析器生成系というソフトウェアの背後にあるアイデアです。

早速ですが、以下のようにDyck言語を表す文法（第4章で示した `P -> ( P ) P | ε` に近いもの）がPEGで与えられたとして、構文解析器を生成する方法を考えてみましょう。

```text
D <- P;
P <- "(" P ")" P / ""; // "" は空文字列εを表す
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

## 6.2 JSONの構文解析器を生成する

LL(1)構文解析器生成系で、JSONのパーザが作れることを示す。これを通じて、構文解析器生成系が実用的に使えることを理解してもらう。

## 6.3 構文解析器生成系の分類

構文解析器生成系は1970年代頃から研究の蓄積があり、数多くの構文解析生成系がこれまで開発されています。基本的には構文解析器生成系と採用しているアルゴリズムは対応するので、たとえば、JavaCCはLL(1)構文解析器を出力するため、LL(1)構文解析器生成系であると言ったりします。

一般的な構文解析器生成系の処理フローは、おおむね以下のようになります。

```mermaid
graph LR
    A[文法定義ファイル (.g, .y, .jjなど)] --> B{構文解析器生成系};
    B -- 字句解析ルール --> C[字句解析器コード生成部];
    C --> D[生成された字句解析器コード (.java, .cなど)];
    B -- 構文解析ルール --> E[構文解析器コード生成部];
    E --> F[生成された構文解析器コード (.java, .cなど)];
    G[ユーザー定義コード/アクション] --> H{コンパイラ};
    D --> H;
    F --> H;
    H --> I[実行可能なパーサー];
```
*図6.X 一般的な構文解析器生成系の処理フロー*

Yacc/Lexのように、字句解析器生成系（Lex）と構文解析器生成系（Yacc）が別々のツールとして提供され、連携して動作するケースもあります。

```mermaid
graph LR
    A[Lex定義ファイル (.l)] --> B[Lex];
    B --> C[字句解析器 Cコード (lex.yy.c)];
    D[Yacc定義ファイル (.y)] --> E[Yacc];
    E --> F[構文解析器 Cコード (y.tab.c)];
    E --> G[ヘッダファイル (y.tab.h)];
    C --> H[Cコンパイラ];
    F --> H;
    G -- #include --> C;
    G -- #include --> F;
    I[ユーザーコード (main関数など)] --> H;
    H --> J[実行ファイル];
```
*図6.Y Yacc/Lexの連携フロー*

同様に、yacc(bison)はLALR(1)構文解析器生成系を出力するので、LALR(1)構文解析器生成系であると言ったりもします。ただし、例外もあります。bisonはyaccと違って、LALR(1)より広いGLR構文解析器を生成できるので、GLR構文解析器生成系であるとも言えるのです。実際には、yaccを使う場合、ほとんどはLALR(1)構文解析器を出力するので、GLRについては言及されることは少ないですが、そのようなことは知っておいても損はないでしょう。

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

## 6.4 JavaCC：Javaの構文解析生成系の定番

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
    r=primary() ( <MULTIPLY> v=primary() { r *= v; }| <DIVIDE> v=primary() { r /= v; })* { // 修正: DIVIDE の右辺も v=primary()
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


## 6.5 Yacc (GNU Bison)：構文解析器生成系の老舗

YaccはYet another compiler compilerの略で、日本語にすると「もう一つのコンパイラコンパイラ」といったところでしょうか。yaccができた当時は、コンパイラを作るためのコンパイラについての研究が盛んだった時期で、構文解析器生成系もそのための研究の副産物とも言えます。1970年代にAT&Tのベル研究所にいたStephen C. Johnsonによって作られたソフトウェアで、非常に歴史がある構文解析器生成系です。YaccはLALR(1)法をサポートし、lexという字句解析器生成系と連携することで構文解析器を生成することができます（もちろん、lexを使わない実装も可能）。Yacc自体は色々な構文解析器生成系に多大な影響を与えており、現在使われているGNU BisonはYaccのGNUによる再実装でもあります。

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

## 6.6 ANTLR：多言語対応の強力な下向き構文解析生成系

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

## 6.7 SComb

手前味噌ですが、拙作のパーザコンビネータである[SComb](https://github.com/kmizu/scomb)も紹介しておきます。これまで紹介してきたものはすべて構文解析器生成系です。つまり、独自の言語を用いて作りたい言語の文法を記述し、そこから**対象言語**（CであったりJavaであったり様々ですが）で書かれた構文解析器を生成するものだったわけですが、パーザコンビネータは少々違います。

パーザコンビネータでは対象言語のメソッドや関数、オブジェクトとして構文解析器を定義し、演算子やメソッドによって構文解析器を組み合わせることで構文解析器を組み立てていきます。パーザコンビネータではメソッドや関数、オブジェクトとして規則自体を記述するため、特別にプラグインを作らなくてもIDEによる支援が受けられることや、対象言語が静的型システムを持っていた場合、型チェックによる支援を受けられることがメリットとして挙げられます。

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

各メソッドに対応するBNFによる規則をコメントとして付加してみましたが、BNFと比較しても簡潔に記述できているのがわかります。Scalaは記号をそのままメソッドとして記述できるなど、元々DSLに向いている特徴を持った言語なのですが、その特徴を活用しています。`chainl`というメソッドについてだけは見慣れない読者の方は多そうですが、これは

```
// M ::= P ("+" P | "-" P)* 
```

のような二項演算を簡潔に記述するためのコンビネータ（メソッド）です。パーザコンビネータの別のメリットとして、BNF（あるいはPEG）に無いような演算子をこのように後付で導入できることも挙げられます。構文規則からの値（意味値）の取り出しもScalaのfor式を用いて簡潔に記述できています。

筆者は自作言語Klassicの処理系作成のためにSCombを使っていますが、かなり複雑な文法を記述できるにも関わらず、SCombのコア部分はわずか600行ほどです。それでいて高い拡張性や簡潔な記述が可能なのは、Scalaという言語の能力と、SCombがベースとして利用しているPEGという手法のシンプルさがあってのものだと言えるでしょう。

## 6.8 パーザコンビネータJCombを自作しよう！

コンパイラについて解説した本は数えきれないほどありますし、その中で構文解析アルゴリズムについて説明した本も少なからずあります。しかし、構文解析アルゴリズムについてのみフォーカスした本はParsing Techniquesほぼ一冊といえる現状です。その上でパーザコンビネータの自作まで踏み込んだ書籍はほぼ皆無と言っていいでしょう。読者の方には「さすがにちょっとパーザコンビネータの自作は無理があるのでは」と思われた方もいるのではないでしょうか。

しかし、驚くべきことに、現代的な言語であればパーザコンビネータを自作するのは本当に簡単です。きっと、多くの読者の方々が拍子抜けしてしまうくらいに。この節ではJavaで書かれたパーザコンビネータJCombを自作する過程を通じて皆さんにパーザコンビネータとはどのようなものかを学んでいただきます。パーザコンビネータと構文解析器生成系は物凄く雑に言ってしまえば近縁種のようなものですし、パーザコンビネータの理解は構文解析器生成系の仕組みの理解にも役立つはずです。きっと。

まず復習になりますが、構文解析器というのは文字列を入力として受け取って、解析結果を返す関数（あるいはオブジェクト）とみなせるのでした。これはパーザコンビネータ、特にPEGを使ったパーザコンビネータを実装するときに有用な見方です。この「構文解析器はオブジェクトである」を文字通りとって、以下のようなジェネリックなインタフェース`JParser<R>`を定義します。

```java
interface JParser<R> {
  Result<R> parse(String input);
}
```

ここで構文解析器を表現するインタフェース`JParser<R>`は型パラメータ`R`を受け取ることに注意してください。一般に構文解析の結果は抽象構文木になりますが、インタフェースを定義する時点では抽象構文木がどのような形になるかはわかりようがないので、型パラメータにしておくのです。`JParser<R>`はたった一つのメソッド`parse()`を持ちます。`parse()`は入力文字列`input`を受け取り、解析結果を`Result<R>`として返します。

`JParser<R>`の実装は一体全体どのようなものになるの？という疑問を脇に置いておけば理解は難しくないでしょう。次に解析結果`Result<V>`をレコードとして定義します。

```java
record Result<V>(V value, String rest){}
```

レコード`Result<V>`は解析結果を保持するクラスです。`value`は解析結果の値を表現し、`rest`は解析した結果「残った」文字列を表します。

このインタフェース`JParser<R>`は次のように使えると理想的です。

```java
JParser<Integer> calculator = ...;
Result<Integer> result = calculator.parse("1+2*3");
assert 7 == result.value();
```

パーザコンビネータは、このようなどこか都合の良い`JParser<R>`を、BNF（あるいはPEG）に近い文法規則を連ねていくのに近い使い勝手で構築するための技法です。前の節で紹介した`SComb`もパーザコンビネータでしたが基本的には同じようなものです。

この節では最終的に上のような式を解析できるパーザコンビネータを作るのが目標です。

### 6.8.1 部品を考えよう

これからパーザコンビネータを作っていくわけですが、パーザコンビネータの基本となる「部品」を作る必要があります。

まず最初に、文字列リテラルを受け取ってそれを解析できる次のような`string()`メソッドは是非とも欲しいところです。

```java
assert new Result<String>("123", "").equals(string("123").parse("123"));
```

これはBNFで言えば文字列リテラルの表記に相当します。

次に、解析に成功したとしてその値を別の値に変換するための方法もほしいところです。たとえば、`123`という文字列を解析したとして、これは最終的に文字列ではなくintに変換したいところです。このようなメソッドは、ラムダ式で変換を定義できるように、次のような`map()`メソッドとして提供したいところです。

```java
<T, U> JParser<U> map(Parser<T> parser, Function<T, U> function);
assert (new Result<Integer>(123, "")).equals(map(string("123"), v -> Integer.parseInt(v)).parse("123"));
```

これは構文解析器生成系でセマンティックアクションを書くのに相当すると言えるでしょう。

BNFで`a | b`、つまり選択を書くのに相当するメソッドも必要です。これは次のような`alt()`メソッドとして提供します。

```java
<T> JParser<T> alt(JParser<T> p1, JParser<T> p2); // 引数名と型名を修正
assert (new Result<String>("bar", "")).equals(alt(string("foo"), string("bar")).parse("bar")); // .parse() を追加
```

同様に、BNFで`a b`、つまり連接」を書くのに相当するメソッドも必要ですが、これは次のような`seq()`メソッドとして提供します。

```java
record Pair<A, B>(A a, B b){}
<A, B> JParser<Pair<A, B>> seq(JParser<A> p1, JParser<B> p2); // 型パラメータを修正
assert (new Result<>(new Pair<>("foo", "bar"), "")).equals(seq(string("foo"), string("bar")).parse("foobar")); // .parse() を追加
```

最後に、BNFで`a*`、つまり0回以上の繰り返しに相当する`rep0()`メソッド
（注意: `string("")` を `rep0` に渡すと無限ループの可能性があるため、アサーション例はより安全なものに変更するか、`string("")` の挙動を明確にする必要があります。ここではアサーション例をコメントアウトします。）
```java
<T> JParser<List<T>> rep0(JParser<T> p);
// assert (new Result<List<String>>(List.of(), "abc")).equals(rep0(string("x")).parse("abc")); // "x" がマッチしない場合
// assert (new Result<List<String>>(List.of("a","a"), "bc")).equals(rep0(string("a")).parse("aabc"));
```

や`a+`、つまり1回以上の繰り返しに相当する`rep1()`メソッドもほしいところです。

```java
<T> JParser<List<T>> rep1(JParser<T> p);
assert (new Result<List<String>>(List.of("a", "a", "a"), "")).equals(rep1(string("a")).parse("aaa")); // .parse() を追加し、引数を修正
```

この節ではこれらのプリミティブなメソッドの実装方法について説明していきます。

### 6.8.2 `string()`メソッド

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

リテラルを表すフィールド`literal`が`input`の先頭とマッチした場合、`literal`と残りの文字列からなる`Result<String>`を返します。そうでない場合は返すべき`Result`がないので`null`を返します。簡単ですね。あとはこのクラスのインスタンスを返す`string()`メソッドを作成するだけです。なお、使うときの利便性のため、以降では各種メソッドはクラス`JComb`のstaticメソッドとして実装していきます。

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

### 6.8.3 `alt()`メソッド

次に二つのパーザを取って「選択」パーザを返すメソッド`alt()`を実装します。先程のようにクラスを実装してもいいですが、メソッドは一つだけなのでラムダ式にします。

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

### 6.8.4 `seq()`メソッド

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

#### 6.8.5 `rep0()`, `rep1()`メソッド

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

### 6.8.6 `map()`メソッド

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

(1)で`f.apply(result.value())`として値を加工しているのがポイントでしょうか。

### 6.8.7 `lazy()`メソッド

パーザを遅延評価するためのメソッド`lazy()`も導入します。Javaはデフォルトでは遅延評価を採用しない言語なので、再帰的な規則を記述するときにこのようなメソッドがないと無限に再帰してスタックオーバーフローを起こしてしまいます。

```java
public class JComb {
    public static <A> JParser<A> lazy(Supplier<JParser<A>> supplier) {
        return (input) -> supplier.get().parse(input);
    }
}
```
`lazy`メソッドの必要性について補足します。Javaは先行評価を行う言語であるため、再帰的な文法規則を直接メソッド呼び出しで表現しようとすると、パーサオブジェクトの構築時に無限再帰が発生し `StackOverflowError` となることがあります。例えば、算術式の文法で `expression` が `additive` を呼び出し、`additive` が `primary` を呼び出し、`primary` が括弧表現の中で再び `expression` を呼び出すような相互再帰構造を考えてみましょう。
```java
// JComb を使った算術式のパーサ定義（簡略版・lazyなしのイメージ）
// public static JParser<Integer> expression = additive(); // 仮に直接代入しようとすると...
// public static JParser<Integer> additive = primary();   // ここでprimaryがexpressionを...
// public static JParser<Integer> primary = alt(number, seq(string("("), expression(), string(")"))); // expressionが未初期化
```
上記のように単純にメソッド呼び出しでパーサを組み合わせようとすると、`expression` の初期化時に `additive` が必要になり、その `additive` の初期化に `primary` が、さらにその `primary` の初期化に `expression` が必要となり、循環参照によって初期化が終わらなくなります。
`lazy` は `Supplier<JParser<A>>` を引数に取ることで、実際の `JParser<A>` オブジェクトの取得（`supplier.get()`）を、そのパーサが実際に `parse()` メソッドで使われるときまで遅延させます。これにより、相互再帰するパーサ定義でも、オブジェクト構築時の無限再帰を避けることができます。算術式の例では、`expression` の定義内で `additive` を呼び出す部分を `lazy(() -> additive())` のように記述することで、この問題を解決します。
```

### 6.8.8 `regex()`メソッド

せっかくなので正規表現を扱うメソッド`regex()`も導入してみましょう。

```java
public class JComb {
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
}
```

引数として与えられた文字列を`Pattern.compile()`で正規表現に変換して、マッチングを行うだけです。これは次のようにして使うことができます。

```java
var number = regex("[0-9]+").map(v -> Integer.parseInt(v));
assert (new Result<Integer>(10, "")).equals(number.parse("10"));
```

### 6.8.9 算術式のインタプリタを書いてみる

ここまでで作ったクラス`JComb`と`JParser`などを使っていよいよ簡単な算術式のインタプリタを書いてみましょう。仕様は次の通りです。

- 扱える数値は整数のみ
- 演算子は加減乗除（`+|-|*|/`）のみ
- `()`によるグルーピングができる

実装だけを提示すると次のようになります。

```java
public class Calculator {
   // expression は加減算を担当 (左結合)
   // PEG: expression <- additive ( ( "+" / "-" ) additive )*
   public static JParser<Integer> expression() {
        return seq( // additive と (( "+" / "-" ) additive )* の連接
                lazy(() -> additive()), // 左辺の additive (乗除の項)
                rep0( // 0回以上の繰り返し
                        seq( // ( "+" / "-" ) と additive の連接
                                alt(string("+"), string("-")), // "+" または "-"
                                lazy(() -> additive()) // 右辺の additive
                        )
                )
        ).map(p -> { // 解析結果を処理するラムダ式
            // p は Pair<Integer, List<Pair<String, Integer>>> 型
            // p.a() は最初の additive の結果 (例: 1)
            // p.b() は ( ( "+" / "-" ) additive )* の結果のリスト (例: [Pair("+", 2), Pair("*", 3)] ではなく、加減算のみなので [Pair("+",結果)])
            // 例えば "1+2-3" の場合:
            // p.a() = 1
            // p.b() = [ Pair("+", 2), Pair("-", 3) ]
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

    // additive は乗除算を担当 (左結合) - メソッド名は term や multiplicative の方が適切かもしれない
    // PEG: additive <- primary ( ( "*" / "/" ) primary )*
    public static JParser<Integer> additive() {
        return seq( // primary と ( ( "*" / "/" ) primary )* の連接
                lazy(() -> primary()), // 左辺の primary
                rep0( // 0回以上の繰り返し
                        seq( // ( "*" / "/" ) と primary の連接
                                alt(string("*"), string("/")), // "*" または "/"
                                lazy(() -> primary()) // 右辺の primary
                        )
                )
        ).map(p -> { // 解析結果を処理するラムダ式
            // p は Pair<Integer, List<Pair<String, Integer>>> 型
            // 例えば "2*3/4" の場合:
            // p.a() = 2
            // p.b() = [ Pair("*", 3), Pair("/", 4) ]
            var left = p.a(); // 初期値 (最初の因子)
            var rights = p.b(); // 残りの演算子と因子のペアのリスト
            for (var rightPair : rights) {
                var op = rightPair.a(); // 演算子 ( "*" または "/" )
                var rightValue = rightPair.b(); // 因子の値
                if (op.equals("*")) {
                    left *= rightValue;
                } else { // op.equals("/")
                    if (rightValue == 0) throw new ArithmeticException("Division by zero"); // ゼロ除算チェック
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
                        lazy(() -> expression()) // 括弧内の式 (expressionを再帰呼び出し)
                ).flatMap(p1 -> // p1 は Pair<String, Integer>型 ("(" と expressionの結果)
                    seq(
                        p1.b(), // expressionの結果 (Integer) を次のseqの左側にする
                        string(")")  // 閉じ括弧
                    ).map(p2 -> p2.a()) // p2は Pair<Integer, String>型、その最初の要素(Integer)を返す
                )
                // 上記のflatMapとmapを使った部分は、以下のように書くこともできます。
                // seq(string("("), lazy(() -> expression())).seq(string(")")).map(p -> p.a().b())
                // ただし、seqがネストするとPairのネストも深くなるため、flatMapで調整するか、
                // mapの処理を工夫する必要があります。
                // ここでは、より明示的にするためにflatMapを使用しました。
                // もしくは、以下のように括弧と式を別々に解析し、式の結果だけを取り出す方法もあります。
                // string("(").seq(lazy(() -> expression())).seq(string(")")).map(pair -> pair.a().b())
                // もっとシンプルには、括弧で囲まれた式の値だけを取り出す専用のコンビネータを作ることも考えられます。
                // 例: between(JParser<O> open, JParser<C> close, JParser<T> p) { return open.seq(p).seq(close).map(res -> res.a().b()); }
                // JCombの例では、より直接的な map(p -> p.b().a()) を使っていますが、
                // これは seq(string("("), seq(lazy(() -> expression()), string(")"))) の結果が
                // Pair<String, Pair<Integer, String>> となることを前提としています。
                // ここでは、より段階的な処理を示すためにflatMapを使用しました。
        );
    }
    
    // number <- [0-9]+ (PEGの正規表現リテラルに対応)
    private static JParser<Integer> number = regex("[0-9]+").map(Integer::parseInt);
}
```

表記は冗長なもののほぼPEGに一対一に対応しているのがわかるのではないでしょうか？
`expression`メソッドを例に、`map`内のラムダ式がどのように動作するかを "1+2*3" (これは`additive`で処理されるべきだが、ここでは`expression`の左結合のロジックを説明するため、仮に "1+2-3" のような入力を想定) で見てみましょう。

入力: "1+2-3"
1.  `lazy(() -> additive())` が "1" を解析し、結果 `1` (Integer) を返します。これが `p.a()` になります。
2.  `rep0(...)` が `+2-3` の部分を解析します。
    *   最初の `seq(alt(string("+"), string("-")), lazy(() -> additive()))` が `+2` を解析し、`Pair("+", 2)` を生成します。
    *   次の `seq(...)` が `-3` を解析し、`Pair("-", 3)` を生成します。
    *   結果として `p.b()` は `List [Pair("+", 2), Pair("-", 3)]` となります。
3.  `map` のラムダ式が実行されます。
    *   `left` は `p.a()` なので `1` で初期化されます。
    *   ループ1回目: `rightPair` は `Pair("+", 2)`。`op` は `"+"`, `rightValue` は `2`。`left` は `1 + 2 = 3` になります。
    *   ループ2回目: `rightPair` は `Pair("-", 3)`。`op` は `"-"`, `rightValue` は `3`。`left` は `3 - 3 = 0` になります。
    *   最終的に `0` が返されます。

これに対してJUnitを使って以下のようなテストコードを記述してみます。無事、意図通りに解釈されていることがわかります。

```java
assertEquals(new Result<>(7, ""), Calculator.expression().parse("1+2*3")); // テストをパス (実際には additive で処理される)
assertEquals(new Result<>(0, ""), Calculator.expression().parse("1+2-3")); // テストをパス
```

DSLに向いたScalaに比べれば大幅に冗長になったものの、手書きで再帰下降パーザを組み立てるのに比べると大幅に簡潔な記述を実現することができました。しかも、JComb全体を通しても500行にすら満たないのは特筆すべきところです。Javaがユーザ定義の中置演算子をサポートしていればもっと簡潔にできたのですが、そこは向き不向きといったところでしょうか。

### 6.9 まとめ

パーザコンビネータを使うと、手書きでパーザを書いたり、あるいは、対象言語に構文解析器生成系がないようなケースでも、比較的気軽にパーザを組み立てるためのDSL（Domain Specific Language）を定義できるのです。また、それだけでなく、特にJavaのような静的型付き言語を使った場合ですが、IDEによる支援も受けられますし、BNFやPEGにはない便利な演算子を自分で導入することもできます。

パーザコンビネータはお手軽なだけあって各種プログラミング言語に実装されています。たとえば、Java用なら[jparsec](https://github.com/jparsec/jparsec)があります。しかし、筆者としては、パーザコンビネータが動作する仕組みを理解するために、是非とも**自分だけの**パーザコンビネータを実装してみてほしいと思います。

\newpage

<!-- Chapter 5: 第7章:現実の構文解析 -->

# 第7章 現実の構文解析

ここまでで、LL法やLR法、Packrat Parsingといった、これまでに知られているメジャーな構文解析アルゴリズムを一通り取り上げてきました。これらの構文解析アルゴリズムは概ね文脈自由言語あるいはそのサブセットを取り扱うことができ、一般的なプログラミング言語の構文解析を行うのに必要十分な能力を持っているように思えます。

しかし、構文解析を専門としている人や実用的な構文解析器を書いている人は直感的に理解していることなのですが、実のところ、既存の構文解析アルゴリズムだけではうまく取り扱えない類の構文があります。一言でいうと、それらの構文は文脈自由言語から逸脱しているために、文脈自由言語を取り扱う既存の手法だけではうまくいかないのです。

このような、既存の構文解析アルゴリズムだけでは扱えない要素は多数あります。たとえば、Cのtypedefはその典型ですし、RubyやPerlのヒアドキュメントと呼ばれる構文もそうです。他には、Scalaのプレースホルダ構文やC++のテンプレート、Pythonのインデント文法など、文脈自由言語を逸脱しているがゆえに人間が特別に配慮しなければいけない構文は多く見かけられます。

また、これまでの章では、主に構文解析を行う手法を取り扱っていましたが、現実問題としては抽象構文木をうまく作る方法やエラーメッセージを適切に出す方法も重要になってきます。

この章では、巷の書籍ではあまり扱われない、しかし現実の構文解析では対処しなくてはならない構文や問題について取り上げます。皆さんが何かしらの構文解析器を作るとき、やはり理想どおりにはいかないことが多いと思います。この章がそのような現実の構文解析で遭遇する読者の方々の助けになれば幸いです。

## 7.1 字句要素が構文要素を含む文法

最近の多くの言語は文字列補間(String Interpolation)と呼ばれる機能を持っています。

たとえば、Rubyでは以下の文字列を評価すると、`"x + y = x + y"`ではなく`"x + y = 3"`になります。

```ruby
x = 1; y = 2
"x + y = #{x + y}" # "x + y = 3"
```

つまり、`#{`と`}`で囲まれた範囲をRubyの式として評価した結果を文字列として埋め込んでくれるわけです。

Scalaでも同じことを次のように書くことができます。

```scala
val x = 1; val y = 2
s"x + y = ${x + y}" // "x + y = 3"
```

Swiftだと次のようになります。

```swift
let x = 1
let y = 2
"x + y = \(x + y)"
```


同様の機能はKotlin、Python(3.6以降)、JavaScript（TypeScriptも）など様々な言語に採用されています。比較的新しい言語や、既存言語の新機能として採用するのがすっかり普通になった機能と言えるでしょう。

文字列補間はとても便利な機能ですが、構文解析という観点からは少々やっかいな存在です。文字列リテラルは従来はトークンとして扱われており、正規言語の範囲に収まるように設計されていたため、正規表現で取り扱えたのです。これは字句解析と構文解析を分離し、かつ、字句解析を可能な限り単純化するという観点で言えばある意味当然とも言えますが、文字列補間は従来は字句であり正規表現で表現できたものを文脈自由文法を取り扱わなければいけない存在にしてしまいました。

たとえば、少々極端な例ですが、Rubyでは以下のように`#{}`の中にさらに文字列リテラルを書くことができ、その中には`#{}`を……といった具合に無限にネストできるのです。これまでの章を振り返ればわかるようにこれは明らかに正規言語を逸脱しており文脈自由言語の扱う範疇です。

```ruby
x = 1; y = 2
"expr1 (#{"expr2 (#{x + y})"})" # "expr1 (expr2 (3))"
```

しかし、従来の手法では文字列リテラルは字句として取り扱わなければいけないため、各言語処理系の実装者はad hocな形で構文解析器に手を加えています。たとえば、Rubyの構文解析器はbisonを使って書かれていますが、字句解析器に状態を持たせることでこの問題に対処しています。文字列リテラル内に`#{"が出現したら状態を式モードに切り替えて、その中で文字列リテラルがあらわれたら文字列リテラルモードに切り替えるといった具合です。

一方、PEGでは字句解析と構文解析が分離されていないため、特別な工夫をすることなく文字列補間を実装することができます。以下はRubyの文字列補間と同じようなものをPEGで記述する例です。

```text
string <- "\"" ("#{" expression "}" / .)* "\""
expression <- 式の定義
```

文字列補間を含む文字列リテラルは分解可能という意味で厳密な意味では字句と言えないわけですが、PEGは字句解析を分離しないおかげで文字列リテラルを殊更特別扱いする必要がないわけです。

PEGの利用例が近年増えてきているのは、言語に対してこのようにアドホックに構文を追加したいというニーズがあるためではないかと筆者は考えています。

<!-- 図7.X: 文字列補間の解析状態遷移図のプレースホルダ -->
<!-- 例: "abc#{1+2}def" の解析時
1. 通常文字列モード: "abc" を消費
2. 式モードへ遷移: '#{' を認識
3. 式モード: 1+2 を式として解析
4. 通常文字列モードへ復帰: '}' を認識
5. 通常文字列モード: "def" を消費
-->

## 7.2 インデント文法

Pythonではインデントによってプログラムの構造を表現します。たとえば、次のPythonプログラムを考えます。

```python
class Point:
  def __init__(self, x, y):
    self.x = x
    self.y = y
```

このPythonプログラムは次のような抽象構文木に変換されると考えられます。

![](img/chapter7/py-ast.svg){ width=70% }

インデントによってプログラムの構造を表現するというアイデアは秀逸ですが、一方で、インデントによる構造の表現は明らかに文脈自由言語の範囲を超えるものです。

Pythonでは字句解析のときにインデントを`<INDENT>`（インデントレベル増加）、インデントを「外す」のを`<DEDENT>`（インデントレベル減少）という特別なトークンに変換します。これにより、構文解析器自体はこれらのトークンをブロックの開始と終了のように扱うことができ、文脈自由文法の範囲で処理しやすくなります。

例えば、先の `Point` クラスの定義は、字句解析後には（簡略化すると）以下のようなトークン列として扱われるイメージです。

```
<CLASS> <NAME:Point> <COLON> <NEWLINE> <INDENT>
  <DEF> <NAME:__init__> <LPAREN> <NAME:self> <COMMA> <NAME:x> <COMMA> <NAME:y> <RPAREN> <COLON> <NEWLINE> <INDENT>
    <NAME:self> <DOT> <NAME:x> <ASSIGN> <NAME:x> <NEWLINE>
    <NAME:self> <DOT> <NAME:y> <ASSIGN> <NAME:y> <NEWLINE>
  <DEDENT>
<DEDENT>
```
（`<NAME:A>`は識別子A、`<COLON>`はコロン、`<NEWLINE>`は改行、`<ASSIGN>`は代入演算子を表すトークンとします。実際にはさらに詳細なトークン分割が行われます。）
このように、インデント/デデントトークンがブロック構造を示すため、構文解析器は括弧の対応付けに似た形で処理できます。

しかし、よくよく考えればわかるのですが、`<IDENT>`トークンと`<DEDENT>`トークンを切り出す処理が文脈自由ではありません。つまり、字句解析時に`<IDENT>`と`<DEDENT>`トークンを切り出すために特殊な処理をしていることになります。`<DEDENT>`トークンは`<IDENT>`トークンとスペースの数が同じでなければいけないため、切り出すためには正規表現でも文脈自由文法でも手に余ることは想像できるでしょう。

<!-- 図7.Y: インデント文法のトークン化とブロック構造のプレースホルダ -->
<!-- 例:
class Point:
  INDENT (レベル1)
  def __init__(self, x, y):
    INDENT (レベル2)
    self.x = x
    DEDENT (レベル1に戻る)
  DEDENT (レベル0に戻る)
インデントレベルのスタック: [0] -> [0, 2] -> [0, 2, 4] -> [0, 2] -> [0] のような変化
-->

## 7.3 ヒアドキュメント

ヒアドキュメントは複数行に渡る文字列を記述するための文法で、従来はbashなどのシェル言語で採用されていましたが、PerlやRubyもヒアドキュメントを採用しました。たとえば、RubyでHTMLの文字列をヒアドキュメントで以下のように書くことができます。

```ruby
html = <<HTML
<html>
  <head><title>Title</title></head>
  <body><p>Hello</p></body>
</html>
HTML
```

特筆すべきは、`<<HTML`と`HTML`のように対応している間だけが文字列として解釈されることです。これだけなら文脈自由言語の範囲内です。実際には問題はもっと複雑です。ヒアドキュメントは**ネストが可能**なのです。たとえば、以下のようなヒアドキュメントは正しいRubyプログラムです。

```ruby
here = <<E1 + <<E2
ここはE1です
E1
ここはE2です
E2
```

これは以下の内容の文字列として解釈されます。

```ruby
ここはE1です
ここはE2です
```

ヒアドキュメント内では文字列補間が使えるのでさらに複雑です。以下のようなヒアドキュメントもOKなのです。

```ruby
a = 100
b = 200
here = <<A + <<B
aは#{a}です
A
bは#{b}です
B
```

これは次の文字列として解釈されます。

```
aは100です
bは200です
```

読者の方々はおそらく「確かに凄いけど、普通はこのような書き方をすることはほぼないのでは」と思われたのではないでしょうか。実際問題そうなのですば、Rubyはこのような複雑怪奇なプログラムもうまく構文解析できなければいけないのも事実です。

Rubyのヒアドキュメントを適切に構文解析するには直感的にはHTMLやXMLにおけるタグ名の対応付けと同じ処理が必要になりますが、これは明らかに文脈自由言語の範囲を超えています。Rubyのヒアドキュメントがこのような振る舞いをすることを初めて知ったのは筆者が大学院生の頃ですが、あまりに予想外の振る舞いに目眩がする思いだったのを覚えています。

Rubyのヒアドキュメントが実際にどのように実装されているかはさておき、筆者はかつて中田育男先生と共同でISO Rubyの試験的な構文解析器をScalaで実装した際に、このヒアドキュメントの扱いに非常に苦労しました。

その際の実装の詳細は、中田先生の[ruby_scalaリポジトリ](https://github.com/inakata/ruby_scala/blob/3f54cc6f80678e30a211fb1374280246f08182ed/src/main/scala/com/github/inakata/ruby_scala/Ruby.scala#L1383)で確認できますが、ヒアドキュメントの開始デリミタを記憶し、対応する終了デリミタが現れるまでを特別に処理する、といった複雑なロジックが必要でした。

このときはScalaのパーザコンビネータを使ってヒアドキュメントを再現したのですが、引数を取ってコンビネータを返すメソッドを定義することで問題を解決しました。形式言語の文脈でいうのなら、PEGの規則が引数を持てるように拡張することでヒアドキュメントを解釈できるようになったと言うことができます。

PEGを拡張して規則が引数を持てるようにするという試みは複数ありますが、筆者もMacro PEGというPEGを拡張したものを提案しました。ヒアドキュメントという当たり前に使われている言語機能ですら、構文解析を正しく行うためには厄介な処理をする必要があるのです。

<!-- 図7.Z: ヒアドキュメントのデリミタ対応の概念図プレースホルダ -->
<!-- 例:
<<E1
  ...
  <<E2
    ...
  E2
  ...
E1
デリミタスタック: [] -> [E1] -> [E1, E2] -> [E1] -> []
-->

以下に、これまで見てきたような文脈自由言語の範囲を超える構文上の課題と、それに対する一般的な解決策をまとめます。

| 問題点                               | 解決策の例                                   | メリット                                                                 | デメリット                                                                 | 主な適用例                               |
| ------------------------------------ | -------------------------------------------- | ------------------------------------------------------------------------ | -------------------------------------------------------------------------- | ---------------------------------------- |
| **文字列補間**                       | 字句解析器の状態管理                         | 既存のLR系パーサーなどと比較的連携しやすい                               | 字句解析器が複雑化し、状態管理が煩雑になる                                 | Ruby, Perl                               |
|                                      | PEG / スキャナレスパーザ                     | 文法定義が直感的で、文字列リテラルと式を統一的に扱える                   | Packrat Parsingの場合、メモ化によるメモリ消費増。バックトラックの可能性も。    | Python (3.9+), Scala (パーザコンビネータ) |
| **インデント文法**                   | INDENT/DEDENTトークンによる前処理            | 構文解析器自体は通常のCFGとして扱える                                    | 字句解析器でのインデントレベル管理とトークン挿入ロジックが必須             | Python, Haskell (layout rule)            |
|                                      | PEG / スキャナレスパーザ                     | 文法定義にインデントレベルのチェックを直接組み込める可能性がある         | 実装の複雑さ、パフォーマンスへの影響                                       | (原理的には可能、F#など一部で採用例あり) |
| **ヒアドキュメント (ネスト対応)**      | 字句解析器の状態管理とデリミタスタック       |                                                                          | 字句解析器が非常に複雑化                                                   | Ruby, Perl                               |
|                                      | 引数付きPEG規則 / マクロPEG                  | より宣言的に複雑な対応関係を記述できる可能性がある                       | PEG自体の拡張が必要、対応ツールが限定的                                    | (研究段階、一部のパーザコンビネータ)     |
| **改行終端可能文法**                 | 字句解析器の状態管理 (例: 式モード/文モード) | 特定の文脈で改行の扱いを切り替えられる                                   | 状態遷移が複雑になりがち                                                   | Ruby, Scala (一部の挙動)                 |
|                                      | PEG / スキャナレスパーザ                     | 改行の扱いを構文規則レベルでより柔軟かつ宣言的に定義可能                 |                                                                            | Python, Klassic (本書の例)                 |
| **Cのtypedefのような文脈依存性**     | シンボルテーブルと構文解析器の連携           | 構文解析中に型情報を参照し、識別子の解釈を動的に変更できる                 | 構文解析器と意味解析部が密結合し、実装の独立性やモジュール性が低下する     | C, C++                                   |
|                                      | (限定的なケースでは)パラメータ化された文法規則 |                                                                          | 汎用性は低い                                                               |                                          |

## 7.4 改行終端可能文法

C、C++、Java、C#などの言語では、解釈・実行の基本単位は**文**(Statement)と呼ばれるものになります。また、文はセミコロンなどの終端子と呼ばれるもので終わるか、区切り文字で区切られるのが一般的です。一方、セミコロンが文の区切りになるのがPascalなどの言語です。厳密には違いますが、関数型プログラミング言語Standard MLのセミコロンも似たような扱いです。

Javaでは次のように書くことで、A、B、Cを順に出力することができます。

```java
System.out.println("A");
System.out.println("B");
System.out.println("C");
```

このように文が終端子（Terminator)で終わる文法には、文の途中に改行が挟まっても単なるスペースと同様に取り扱えるという利点があります。先程のプログラムを次のように書き換えても意味は代わりません。

```java
System.out.println(
  "A");
System.out.println(
  "B");
System.out.println(
  "C");
```

大抵の場合、文は一行で終わるのですから、毎回セミコロンをつけなければいけないのも面倒くさいものです。そういったニーズを反映してか、Scala、Kotlin、Swift、Goなどの比較的新しい言語では（Scalaの初期バージョン
が2003ですから、そこまで新しいのかという話もありますが）、文はセミコロンで終わることもできるが、改行でも終わることができます。より古い言語でもPython、Ruby、JavaScriptも改行で文が終わることができます。

たとえば、先程のJavaプログラムに相当するScalaプログラムは次のようになります。

```scala
println("A")
println("B")
println("C")
```

見た目にもすっきりしますし、改行を併用するコーディングスタイルが大半であることを考えても、無駄なタイピングが減るしでいいことずくめです。Scalaではそれでいて、次のように文の途中で改行が入っても問題なく解釈・実行することができます。

```scala
println(
  "A")
println(
  "B")
println(
  "C")
```

Scalaでも一行の文字数が増えれば分割したくなりますから、このような機能があるのは自然でしょう。

ここで一つの疑問が湧きます。「文は改行で終わる」という規則なら改行が来たときに「文の終わり」とみなせばよいですし、「文はセミコロンで終わる」という規則なら、セミコロンが来たときに「文の終わり」とみなせば問題ありません。しかしながら、このような文法を実現するためには「セミコロンが来れば文が終わるが、改行で文が終わることもある」というややこしい規則に基づいて構文解析をしなければいけません。

このような文法を実現するのは案外ややこしいものです。Javaの`System.out.println("A");`という文は正確には「式文」と呼ばれますが、この式文は次のように定義されます。

```text
expression_statement ::= expression <SEMICOLON>
```

`<SEMICOLON>`はセミコロンを表すトークンです。では、Scala式の文法を「改行でもセミコロンでも終わることができる」と考えて次のように記述しても大丈夫でしょうか。

```text
expression_statement ::= expression <SEMICOLON>
                       | expression <LINE_TERMINATOR>
```


`<LINE_TERMINATOR>`は改行を表すトークンです。プラットフォームによって改行コードは異なるので、このように定義しておくと楽でしょう。このような規則でうまく先程の例全てをうまく取り扱えるかといえば、端的に言って無理です。

```scala
println(
  "A")
```

C系の言語では行コメントなどの例外を除き、字句解析時に改行もスペースも同じ扱いで処理しているので、このような「式の途中で改行が来る」ケースも特に工夫する必要がありませんでした。しかし、Scalaなどの言語における「改行」は式の途中では無視されるが文末では終端子にもなり得るという複雑な存在です。

言い換えると「文脈」を考慮して改行を取り扱う必要がでてきたのです。このような文法はどのようにすれば取り扱えるでしょうか。なかなか難しい問題ですが、大きく分けて二つの戦略があります。

一つ目は字句解析器に文脈情報を持たせる方法です。たとえば、「式」モードでは改行は無視されるが、「文」モードだと無視されないという風にした上で、式が終わったら「文」モードに切り替えを行い、式が開始したら「式」モードに切り替えを行います。この方式を採用している典型的な言語がRubyで、Cで書かれた字句解析器には実に多数の文脈情報を持たせています。

```c
// https://github.com/ruby/ruby/blob/v3_2_0/parse.y#L161-L181
/* examine combinations */
enum lex_state_e {
#define DEF_EXPR(n) EXPR_##n = (1 << EXPR_##n##_bit)
    DEF_EXPR(BEG),
    DEF_EXPR(END),
    DEF_EXPR(ENDARG),
    DEF_EXPR(ENDFN),
    DEF_EXPR(ARG),
    DEF_EXPR(CMDARG),
    DEF_EXPR(MID),
    DEF_EXPR(FNAME),
    DEF_EXPR(DOT),
    DEF_EXPR(CLASS),
    DEF_EXPR(LABEL),
    DEF_EXPR(LABELED),
    DEF_EXPR(FITEM),
    EXPR_VALUE = EXPR_BEG,
    EXPR_BEG_ANY  =  (EXPR_BEG | EXPR_MID | EXPR_CLASS),
    EXPR_ARG_ANY  =  (EXPR_ARG | EXPR_CMDARG),
    EXPR_END_ANY  =  (EXPR_END | EXPR_ENDARG | EXPR_ENDFN),
    EXPR_NONE = 0
};
```

「改行で文が終わる」以外にもRubyはかなり複雑な構文解析を行っているため、このように多数の状態を字句解析器に持たせる必要があります。Rubyの文法は私が知る限り**もっとも複雑なものの一つ**なのでややこれは極端ですが、字句解析器に状態を持たせるアプローチは他の言語も採用していることが多いようです。

別のアプローチとして既出のPEGを使うという方法があります。PEGでは字句解析という概念自体がありませんから、式の途中に改行が入るというのも構文解析レベルで処理できます。Pythonでは3.9からPEGベースのパーサーが導入され、3.10以降も継続して使用されています。これにより、Pythonのパーサーは改行の扱いなど、より柔軟な構文規則を以前よりも直接的に記述しやすくなりました。

例として拙作のプログラミング言語Klassicでは次のようにして式の合間に改行を挟むことができるようにしています。

```scala
//add ::= term {"+" term | "-" term}
lazy val add: Parser[AST] = rule{
  chainl(term)(
    (%% << CL(PLUS)) ^^ { location => (left: AST, right: AST) => BinaryExpression(location, Operator.ADD, left, right) } |
    (%% << CL(MINUS)) ^^ { location => (left: AST, right: AST) => BinaryExpression(location, Operator.SUBTRACT, left, right) }
  )
}
```

関数`CL()`は次のように定義されます。

```scala
 def CL[T](parser: Parser[T]): Parser[T] = parser << SPACING
```

Klassicの構文解析器は自作のパーザコンビネータライブラリで構築されているので少々ややこしく見えますが、要約すると、`CL()`は引数に与えたものの後に任意個のスペース（改行）が来るという意味で、キーワードである`PLUS`や`MINUS`の後にこのような規則を差し込むことで「式の途中での改行は無視」が実現できています。

現在ある言語で採用されているかはわかりませんが、GLR法のようにスキャナレス構文解析と呼ばれる他の手法を使う方法もあります。スキャナレスということは字句解析が無いということですが、字句解析器を別に必要としない構文解析法の総称を指します。PEGも字句解析器を必要としませんから、PEGもスキャナレス構文解析の一種と言えます。

ともあれ、私達が普通に使っている「改行で文が終わる」ようにできる処理一つとっても厄介な問題だということです。

## 7.5 Cのtypedef

C言語の`typedef`文は既存の型に別名をつける機能です。C言語をバリバリ書いているプログラマの型ならお馴染みの機能でしょう。Cのtypdefは

- 移植性を高める
- 関数ポインタを使ったよみづらい宣言を読みやすくする

といった目的で使われますが、この`typedef`文が意外に曲者だったりします。以下は`i`をint型の別名として定義するものですが、同時にローカル変数`i`を`i`型として定義しています。

```c
typedef int i;
int main(void) {
        i i = 100; // OK
        int x = (i)'a'; // ERROR
        return 0;
}
```

現実にこのようなコードの書き方をするかはともかく、`i i = 100;`は明らかにOKな表現として解析してあげなければいけません。一方で、`int x = (i)'a';`は構文解析エラーになります。`i i = 100;`という宣言がなければこの文も通るのですが、合わせて書けば構文解析エラーです。それ以前の文脈である識別子がtypedefされたかどうかで構文解析の結果が変わるのですからとてもややこしいです。

C言語ではこのようなややこしい構文を解析するために、typdefした識別子を連想配列の形で持っておいて、構文解析時にそれを使うという手法を採用しています。

## 7.6 Scalaでの「文頭に演算子が来る場合の処理」

7.4 で改行で文を終端する文法について説明しましたが、Scalaはさらにややこしい入力を処理できなければいけません。たとえば、以下のような文を解釈できる必要があります。

```scala
val x = 1
      + 2
println(x) // 3
```

ここで、xを3とちゃんと解釈するには`val x = 1`が改行で終わったから「文が終わった」と解釈せず、次のトークンである`+`まで見てから文が終わるか判定する必要があります。これまで試した限り、同じことができるのはJavaScriptくらいで、Ruby、Python、Kotlin、Go、Swiftなどの言語ではエラーになるか、`x = 1`で文が終わったと解釈され、`+ 2`は別の文として解釈されるケースばかりでした。

この処理について、Scala言語仕様内の[1.2 Newline Characters](https://scala-lang.org/files/archive/spec/2.13/01-lexical-syntax.html)に関連する記述があります。

> Scala is a line-oriented language where statements may be terminated by semi-colons or newlines. A newline in a Scala source text is treated as the special token “nl” if the three following criteria are satisfied:
>   1. The token immediately preceding the newline can terminate a statement.
>   2. The token immediately following the newline can begin a statement.
>   3. The token appears in a region where newlines are enabled.
> The tokens that can terminate a statement are: literals, identifiers and the following delimiters and reserved words:

これを意訳すると、通常の場合はScalaの文はセミコロンまたは改行で終わることができるが、次の三つの条件**全て**を満たしたときのみ、特別なトークン`nl`として扱われることになる、ということになります。

1. 改行の直前のトークンが「文を終わらせられる」ものである場合
2. 改行の直後のトークンが「文を始められる」ものである場合
3. 改行が「利用可能」になっている箇所にあらわれたものである場合

たとえば、以下のScalaプログラムについていうと、最初の改行は`nl`トークンになりませんが、何故かというと条件1が満たされても条件2が満たされないからです。

```scala
val x = 1
      + 2
```

ちなみに、調査を開始する時点ではScalaの文法の基本文法を継承したKotlinでも同じようになっていると思っていたのですが、一行目で文が終わると解釈されてしまいました。

```kotlin
val x = 1
      + 2 // + 2は単独の式として解釈されてしまう
println(x) // 1
```

## 7.7 プレースホルダー構文

Scalaにはプレースホルダー構文、正確にはPlaceholder Syntax for Anonymous Functionと呼ばれる構文があります。これは最近の言語ではすっかり普通に使えるようになったいわゆる**ラムダ式**を簡易表記するための構文です。

たとえば、Scalaで`[1, 2, 3, 4]`というリストの各要素をインクリメントする処理はラムダ式（Scalaでは無名関数とも呼ばれます）を使って次のように書くことができます。

```scala
List(1, 2, 3, 4).map(x => x + 1)
```

ラムダ式を普段から使っておられる読者には大体雰囲気で伝わると思うのですが、`map`は多くの言語で採用されている高階関数です。`map`は引数で渡された無名関数をリストの各要素に適用して、その結果できた新しいリストを返します。たとえば、上のプログラムだと実行結果は次のようになります。


```scala
List(2, 3, 4, 5)
```

しかし、`map()`に渡す無名関数を毎回`x => x + 1`のように書かないといけないのも冗長です。というわけで、Scalaでは次のように無名関数を簡易表記することができます。

```scala
List(1, 2, 3, 4).map(_ + 1)
```

これは構文解析のときに、先程の

```scala
List(1, 2, 3, 4).map(x => x + 1)
```

に展開されます。出てくる`_`のことをプレースホルダ（placeholder）と呼びます。例によってこの構文は非常に扱いが厄介です。何故かというと、`_`がどのような無名関数を表すかを構文解析時に決定するのはかなり困難なのです。すぐに思いつくのは、`_`はそれを囲む「最小の式」を無名関数に変換すると定義するという方法です。しかし、これはプレースホルダが二つ以上出てくると破綻します。

たとえば、別の高階関数`foldLeft()`を使った例を見てみます。

```scala
List(1, 2, 3, 4).foldLeft(0)(_ + _)
```

リスト`[1, 2, 3, 4]`の合計値である`10`を計算してくれます。このプレースホルダ構文は次のように変換されます。

```scala
List(1, 2, 3, 4).foldLeft(0)((x, y) => x + y)
```

このケースでは、`(_ + _)`が`((x, y) => x + y)`という無名関数に変換されたわけですが、プレースホルダが複数出現するとややこしい問題になります。


また、そもそもプレースホルダが単一であっても解釈が難しい問題もあります。たとえば、次の式は考えてみます。

```scala
List(1, 2, 3, 4).map(_ * 2 + 3)
```

これは以下のScalaプログラムに変換されます。

```scala
List(1, 2, 3, 4).map(x => x * 2 + 3)
````

もし、`_`を含む「最小の式」を無名関数にするという方式だと`(_ * 2)`が`(x => x * 2)`という無名関数に変換されても良さそうですがそうはなっていません。また、ユーザーのニーズを考えてもそうなっては欲しくありません。

Scalaではこのプレースホルダ構文をどう扱っているかというと非常に複雑で一言では説明しきれない部分があるのですが、あえておおざっぱに要約すると、次のようになります。

1. `_` をアンダースコアセクション（underscore section）と呼ぶ
2. 無名関数になる範囲の式`e`は構文カテゴリ（syntactic category）`Expr`に属しており、アンダースコアセクション`u`について次の条件を満たす必要がある：
  2-1. `e`は真に（property）`u`を含んでいる
  2-2. `e`の中に構文カテゴリ`Expr`に属する式は存在しない

といっても、これだけだとわかりませんよね。たとえば、

```
map(_ * 2 + 3)
```

では`_ * 2 + 3`までが「無名関数化」される範囲ですが、これをいったん括弧つきで表記すると`(_ * 2) + 3`となります。Scalaの構文解析上のルールでは、演算子を使った式は単独では構文カテゴリ`Expr`に属しません。メソッドの引数になっている`(_ * 2 + 3)`まで来て初めて、この式は構文カテゴリ`Expr`になります。

端的に言って、この時点で既に目眩がするような内容です。というのは、構文カテゴリという情報自体が構文解析の途中でなければ取り出せない情報であり、つまり、Scalaでは構文解析の*途中*にうまくプレースホルダを処理する必要があるのです。このプレースホルダ構文をきっちり解説するのは本書の内容を超えますが、やはりこの問題も文脈自由言語の範囲で扱うことができません。

Scala処理系内部でプレースホルダ構文がどのように実装されているかも読んだことがありますが、とてもややこしくいものでした。C言語のtypedefは構文解析の途中で連想配列に名前を登録すればいいだけまだマシですが、さらに厄介だというのが正直な印象です。

なお、プレースホルダ構文について「きちんとした定義」を参照されたい方は、[Scala Language Specification 6.23.2: Placeholder Syntax for Anonymous Function](https://www.scala-lang.org/files/archive/spec/2.13/06-expressions.html#placeholder-syntax-for-anonymous-functions)を読んでいただければと思います。

## 7.8 エラーリカバリ

構文解析の途中でエラーが起きることは（当然ながら）普通にあります。構文解析中のエラーリカバリについては多くの研究があるものの、コンパイラの教科書で構文解析アルゴリズでのエラーリカバリについて言及されることは稀です。推測ですが、構文解析において２つ目以降のエラーは大抵最初のエラーに誘発されて起こるということや、どうしても経験則に頼った記述になりがちなため、教科書で言及されることは少ないのでしょう。また、大抵の言語処理系で構文解析中のエラーリカバリについては大したことをしていなかったという歴史的事情もあるかもしれません。

しかし、現在は別の観点から構文解析中のエラーリカバリが重要性を増してきています。それは、テキストエディタの拡張としてIDEのような「構文解析エラーになるが、それっぽくなんとか構文解析をしなければいけない」というニーズがあるからです。ユーザーがコードを書いている最中は、一時的に文法的に正しくない状態になることが頻繁にあります。IDEがそのような状況でも構文ハイライト、コード補完、リアルタイムのエラー表示などの機能を提供し続けるためには、エラーが発生しても即座に解析を中断するのではなく、可能な限り解析を継続し、後続のエラーも検出できるような仕組み、すなわちエラーリカバリ機構が不可欠です。

エラーリカバリにはいくつかの代表的な手法があります。

- **パニックモード (Panic Mode):** 最も単純な手法の一つです。エラーを検出したら、セミコロン（`;`）や閉じ波括弧（`}`）のような、文やブロックの区切りとなる「同期トークン」が見つかるまで、入力トークンを読み飛ばします。同期トークンが見つかったら、そこから解析を再開します。

   C言語風のコード `x = a + * b; y = c;` で、`*` が予期しないトークンとしてエラーになった場合、パニックモードでは `*` と `b` を読み飛ばし、次の同期トークンである `;` を見つけて解析を再開します。これにより、`y = c;` の解析は行われますが、`* b` に関するエラーの詳細は失われる可能性があります。

- **フレーズレベルリカバリ (Phrase-Level Recovery):** エラー箇所の周辺で、局所的な修正を試みる手法です。例えば、不足しているセミコロンを補ったり、予期しないトークンを削除したり、期待されるトークンに置き換えたりします。

  `x = a + b y = c;` というコードで、`b` と `y` の間にセミコロンが欠落している場合、パーサは `y` が予期しないトークンであると判断します。フレーズレベルリカバリでは、「文の終わりにはセミコロンが期待される」という知識に基づき、`b` の後にセミコロンを挿入して `x = a + b; y = c;` として解析を試みるかもしれません。例えば、Javaのメソッド呼び出しで `myObject.method(arg1 arg2)` のようにカンマが抜けている場合、`arg1` と `arg2` の間にカンマを補って `myObject.method(arg1, arg2)` として解釈を試みる、といった具合です。あるいは、JSON の配列 `[1, , 2]` で余分なカンマがある場合、それを削除して `[1, 2]` として解析を続けるかもしれません。パニックモードよりは洗練されていますが、どのような修正を行うかの判断が難しく、実装が複雑になりがちです。

- **エラー生成規則 (Error Productions):** 文法にあらかじめよくあるエラーパターンに対応する生成規則を追加しておく手法です。例えば、「`if (condition) statement`」という正しい規則に加えて、「`if condition) statement`」（開き括弧が欠落）のようなエラー用の規則を定義しておきます。これにより、特定のエラーを「受理」し、解析を継続できます。

  Yaccのようなツールでは、`error` トークンを使ってエラー規則を定義できます。

```text
statement: IF '(' expr ')' statement
         | IF error ')' statement { yyerror("Missing opening parenthesis in if statement"); }
         | /* ... other rules ... */
         ;
```

この例では、`if` の後に開き括弧 `(` がない場合に `error` トークンがマッチし、エラーメッセージを出力しつつ、`)` 以降の解析を継続しようとします。多くのエラーパターンを網羅しようとすると文法が複雑になりますが、特定のエラーに対しては効果的です。

- **グローバルコレクション (Global Correction):** 理論的には最も強力な手法で、入力文字列全体に対して、最小限の修正（挿入、削除、置換）で文法的に正しい文字列に変換する方法を探します。

  `if x > 0) { ... }` という入力に対し、グローバルコレクションは開き括弧 `(` を挿入するのが最小の修正であると判断するかもしれません。しかし、入力全体を考慮して最適な修正を見つけるのは計算量的に非常に困難であり、実用的なコンパイラやIDEでこの手法が全面的に採用されることは稀です。

IDEのような環境では、これらの手法を組み合わせたり、部分的な構文木（エラー箇所を含むかもしれないが、解析できた部分）を構築したり、インクリメンタルな解析（変更箇所だけを再解析する）を行ったりすることで、ユーザーが編集中でも可能な限り正確な情報を提供しようと試みています。例えば、ユーザーが `class MyClass { public void myMethod() { ... }` と入力し、最後の閉じ括弧 `}` を入力し忘れている場合でも、IDEは `myMethod` の本体部分についてはある程度解析を試み、メソッド内の変数に対するコード補完や型チェックを行おうとします。これは、エラーリカバリ機構が、エラー箇所を特定しつつも、それ以外の部分については解析を継続し、部分的な構文情報を抽出しているためです。エラーリカバリは、単にエラーを見つけるだけでなく、その後の解析をどう継続し、ユーザーにどのようなフィードバックを与えるかという、より実践的で奥深い問題領域なのです。

## 7.9 まとめ

7章では現実の構文解析で遭遇する問題について、いくつかの例を挙げて説明しました。筆者が大学院博士後期課程に進学した頃「構文解析は終わった問題」と言われたのを覚えていますが、実際にはその後もANTLRの`LL(*)`アルゴリズムのような革新が起きていますし、細かいところでは今回の例のように従来の構文解析法単体では取り扱えない部分をアドホックに各プログラミング言語が補っている部分があります。

このような問題が起きるのは結局のところ、当初の想定と違って「プログラミング言語は文脈自由言語として表せ」なかったという事です。より厳密には当然、文脈自由言語の範囲に納めることもできますが、便利な表記を許していくとどうしても文脈自由言語から「はみ出て」しまうということです。このような「現実のプログラミング言語の文脈依存性」については専門の研究者以外には案外知られていなかったりしますが、ともあれこのような問題があることを知っておくのは、既存言語の表記法を取り入れた新しい言語を設計するときにも有益でしょう。

\newpage

<!-- Chapter 1: 第8章:おわりに -->

# 第8章 おわりに

ここまでで構文解析の世界を概観してみましたがいかがでしたか？構文解析、特に非自然言語の構文解析というのは地味なもので、パーザジェネレータの発展などもあり「構文解析はもう終わった問題だ」という人もいます。ただ、その一方で2000年代以降になってもPEGの発明（再発見）があり、Pythonの構文解析器に採用されるまでにつながりましたし、`LL(*)`や`ALL(*)`のような革新的なアルゴリズムが生み出されています。それも、どちらかといえば主流であった上向き型の構文解析でなく下向き型の構文解析で、です。

とはいえやはり地味なものは地味であり、プログラミング言語処理系を構成するコンポーネントという観点から言っても「脇役」という印象は否めません。ただ、わたしたちはプログラミング言語を書いているときは、コンパイラの内部表現や抽象構文木と対話しているわけではありません。プログラマーが直接対話する相手はプログラミング言語の具象構文であり、具象構文はプログラミング言語の「UI」を担当する部分といえるでしょう。通常のアプリケーションでUIが軽視されるべきでないのと同様にやはり具象構文も軽視されるべきでないと私は思いますし、よりよい具象構文の設計には構文解析の知識が助けになると信じています。

ところで、ここまで、構文解析の基盤を支える「形式言語」の世界についてはあえてはしょった説明に留めました。何故なら構文解析を学ぶという点からすると本筋から外れ過ぎてしまいますし、何より形式言語理論を学ぶのは骨が折れる作業でもあるからです。

とはいえ、せっかくなので、この章では形式言語理論のほんの導入だけでも紹介したいと思います。形式言語理論は、言語の構造を数学的に研究する分野であり、構文解析の理論的基盤となっています。

例えば、第4章で触れた「正規言語」や「文脈自由言語」といった言語クラスは、それぞれ異なる計算モデル（機械）によって認識できることが知られています。
-   **正規言語:** 有限オートマトンという、有限個の状態しか持たない単純な機械で認識できます。正規表現は正規言語を記述するための便利な記法です。しかし、括弧の対応のように無限のネスト構造を持つものは扱えません。
-   **文脈自由言語:** プッシュダウンオートマトンという、有限オートマトンにスタック（無限の深さを持つメモリ）を追加した機械で認識できます。これにより、括弧の対応のような再帰的な構造を扱えるようになります。本書で紹介した多くの構文解析アルゴリズムは、この文脈自由言語を対象としています。
-   **文脈依存言語:** 文脈自由言語よりも強力なクラスで、例えば `a^n b^n c^n`（n個のa、n個のb、n個のcがこの順で並ぶ文字列の集合）のような言語を記述できます。これはプッシュダウンオートマトンでは認識が困難です。
-   **帰納的可算集合（チューリングマシンが認識する言語）:** 最も強力な言語クラスで、私たちが普段使うほとんどのプログラミング言語で書けるアルゴリズム（計算可能な問題）が認識できる言語の範囲に対応します。

<!-- 図8.X: オートマトンの階層と言語クラスの対応図 (簡略版) のプレースホルダ -->
<!-- 例: 入れ子円で、外側からチューリングマシン(帰納的可算集合)、線形拘束オートマトン(文脈依存言語)、プッシュダウンオートマトン(文脈自由言語)、有限オートマトン(正規言語) を示す -->

形式言語理論を学ぶと、「なぜある種のパターンは正規表現で書けるのに、別のパターンは書けないのか？」や「なぜ `a^n b^n` は文脈自由言語なのに `a^n b^n c^n` はそうではないのか？」といった疑問に、より深いレベルで答えることができるようになります。これらの問いは、計算モデルの能力の限界と深く関わっています。

幸い、形式言語理論を学ぶための良質な教科書はいくつもあります。もしこの本を読み終えて、言語の理論的な側面にさらに興味を持った方は、ぜひ専門書を手に取ってみてください。

## さらに学ぶために：参考文献と資料

本書で扱った内容は構文解析の入門的な側面に過ぎません。より深く学びたい読者のために、いくつかの参考文献や資料を紹介します。

### 古典的名著・専門書

*   **Alfred V. Aho, Monica S. Lam, Ravi Sethi, Jeffrey D. Ullman. *Compilers: Principles, Techniques, & Tools (2nd Edition)*** (通称「ドラゴンブック」)
    *   コメント: コンパイラ構築に関する標準的な教科書。字句解析、構文解析（LL、LR）、意味解析、コード生成など、コンパイラの全般的なトピックを網羅。理論的背景もしっかり解説されています。中級者以上向け。
*   **Dick Grune, Ceriel J.H. Jacobs. *Parsing Techniques: A Practical Guide (2nd Edition)***
    *   コメント: 書名通り、様々な構文解析技術に特化した書籍。LL、LRだけでなく、アーリー法、GLR、CYK法など、より高度なアルゴリズムや曖昧性のある文法の扱いについても詳しい。構文解析を専門的に深めたい方向け。
*   **John E. Hopcroft, Rajeev Motwani, Jeffrey D. Ullman. *Introduction to Automata Theory, Languages, and Computation (3rd Edition)*** (通称「アホ本」「カエル本」など)
    *   コメント: 形式言語とオートマトンの理論に関する標準的な教科書。正規言語、文脈自由言語、チューリングマシン、計算可能性と計算の複雑さの理論などを網羅。数学的な厳密さを求める方向け。

### 特定の技術に関する論文・資料

*   **Bryan Ford. "Parsing Expression Grammars: A Recognition-Based Syntactic Foundation" (2004)**
    *   コメント: PEGを提案したオリジナルの論文。PEGの形式的な定義、操作的意味論、Packrat Parsingについて解説。理論的な背景を深く理解したい方向け。 (オンラインで検索すれば見つかるはずです)
*   **Terence Parr. *The Definitive ANTLR 4 Reference***
    *   コメント: ANTLR v4の作者自身による解説書。ANTLRの文法定義、使い方、ALL(*)アルゴリズムの概要、実践的なパーサー構築のテクニックが豊富。ANTLRを使いこなしたいなら必読。
*   **ANTLR公式サイト (antlr.org)**
    *   コメント: ANTLRのドキュメント、チュートリアル、文法リポジトリなど。最新情報やコミュニティのサポートも得られます。
*   **JavaCC公式サイト (javacc.github.io/javacc/)**
    *   コメント: JavaCCのドキュメント、チュートリアル、FAQなど。
*   **GNU Bisonマニュアル (www.gnu.org/software/bison/manual/)**
    *   コメント: Bison (Yacc互換) の詳細なマニュアル。LALR(1)やGLRパーサーの生成方法、文法定義の書き方などが学べます。

### オンラインリソース・コミュニティ

*   各種プログラミング言語のパーザコンビネータライブラリのドキュメント (例: Scalaの`scala-parser-combinators`, Haskellの`Parsec`, Pythonの`pyparsing`など)
    *   コメント: 各言語でパーザコンビネータを使って手軽にパーサーを構築する方法を学べます。
*   Stack OverflowなどのQ&Aサイト
    *   コメント: 特定の構文解析の問題やツールの使い方について、具体的な質問と回答が見つかることがあります。

これらの資料を通じて、構文解析の世界への探求をさらに深めていただければ幸いです。

## 最後に

本書を通じて、構文解析の基本的な考え方や、様々なアルゴリズム、そして現実のプログラミング言語が抱える課題の一端に触れていただきました。
「よりよい具象構文の設計には構文解析の知識が助けになる」と冒頭で述べましたが、これは例えば、あなたが新しいドメイン固有言語（DSL）を設計する際に、利用者が直感的に理解しやすく、かつパーサーが効率的に解析できるような構文（例: 演算子の優先順位、予約語の選択、ブロック構造の表現方法など）を選ぶ上で、本書で学んだLL/LRの特性やPEGの柔軟性といった知識が役立つでしょう。

また、「構文解析は終わった問題ではない」という点も強調しておきたいと思います。プログラミング言語は進化を続けており、async/awaitのような非同期処理の構文、パターンマッチングの高度化、型システムの進化に伴う構文の複雑化など、新しい言語機能は依然として構文解析技術に新たな課題を提示し続けています。これらの課題に取り組む上で、本書で得た知識が何らかの形で皆さんの力になることを願っています。

構文解析の世界は奥深く、そして面白いものです。この本が、その面白さを少しでも伝えることができたなら、著者としてこれ以上の喜びはありません。

2025年xx月dd日、自室にて。水島宏太

\newpage

<!-- Chapter : 参考文献 -->

# 参考文献

- [ECMA-404 The JSON data interchange syntax](https://ecma-international.org/publications-and-standards/standards/ecma-404/)