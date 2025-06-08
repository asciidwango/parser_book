
# 第7章 現実の構文解析

ここまでで、LL法やLR法、Packrat Parsingといった、これまでに知られているメジャーな構文解析アルゴリズムを一通り取り上げてきました。これらの構文解析アルゴリズムは概ね文脈自由言語あるいはそのサブセットを取り扱うことができ、一般的なプログラミング言語の構文解析を行うのに必要十分な能力を持っているように思えます。

しかし、構文解析を専門としている人や実用的な構文解析器を書いている人は直感的に理解していることなのですが、実のところ、既存の構文解析アルゴリズムだけではうまく取り扱えない類の構文があります。一言でいうと、それらの構文は文脈自由言語（第4章で学んだCFG）から逸脱しているために、文脈自由言語を取り扱う既存の手法だけではうまくいかないのです。

このような、既存の構文解析アルゴリズムだけでは扱えない要素は多数あります。たとえば、Cのtypedefはその典型ですし、RubyやPerlのヒアドキュメントと呼ばれる構文もそうです。他には、Scalaのプレースホルダ構文やC++のテンプレート、Pythonのインデント文法など、文脈自由言語を逸脱しているがゆえに人間が特別に配慮しなければいけない構文は多く見かけられます。

また、これまでの章では、主に構文解析を行う手法を取り扱っていましたが、現実問題としては抽象構文木をうまく作る方法やエラーメッセージを適切に出す方法も重要になってきます。

この章では、巷の書籍ではあまり扱われない、しかし現実の構文解析では対処しなくてはならない構文や問題について取り上げます。皆さんが何かしらの構文解析器を作るとき、やはり理想どおりにはいかないことが多いと思います。この章がそのような現実の構文解析で遭遇する読者の方々の助けになれば幸いです。

## 字句要素が構文要素を含む文法

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

```{=latex}
\begin{center}
\begin{tikzpicture}[
  node distance=3cm,
  every node/.style={font=\small},
  % 状態ノードのスタイル
  state/.style={
    circle,
    draw,
    minimum size=1.8cm,
    font=\footnotesize
  },
  % 初期状態のスタイル
  initial state/.style={
    state,
    fill=green!10
  },
  % 遷移ラベルのスタイル
  transition/.style={
    font=\footnotesize\ttfamily,
    auto
  }
]
  
  % 状態ノード
  \node[initial state] (string) {文字列\textbackslash モード};
  \node[state, right=of string, fill=orange!10] (expr) {式\textbackslash モード};
  
  % 初期状態への矢印
  \draw[->, thick] ([xshift=-1cm]string.west) -- (string);
  
  % 状態遷移
  \draw[->, thick, bend left=25] (string) to node[transition, above] {\#\{} (expr);
  \draw[->, thick, bend left=25] (expr) to node[transition, below] {\}} (string);
  
  % 自己ループ
  \draw[->, thick] (string) to[loop above] node[transition] {通常文字} (string);
  \draw[->, thick] (expr) to[loop above] node[transition] {式トークン} (expr);
  
  % 例の説明
  \node[below=2.5cm of string, text width=10cm, align=center] {
    \footnotesize 例: \texttt{"abc\#\{1+2\}def"} の解析\\[0.2em]
    \begin{tabular}{cl}
      1. & 文字列モード: \texttt{"abc"} を消費 \\
      2. & \texttt{\#\{} を認識 → 式モードへ遷移 \\
      3. & 式モード: \texttt{1+2} を式として解析 \\
      4. & \texttt{\}} を認識 → 文字列モードへ復帰 \\
      5. & 文字列モード: \texttt{def"} を消費
    \end{tabular}
  };
  
  % 図のラベル
  \node[below=5cm of string, font=\footnotesize] {図7.1: 文字列補間の解析状態遷移};
\end{tikzpicture}
\end{center}
```

## インデント文法

Pythonではインデントによってプログラムの構造を表現します。たとえば、次のPythonプログラムを考えます。

```python
class Point:
  def __init__(self, x, y):
    self.x = x
    self.y = y
```

このPythonプログラムは次のような抽象構文木に変換されると考えられます。

```{=latex}
\begin{center}
\begin{tikzpicture}[
  node distance=1.2cm and 1.5cm,
  every node/.style={font=\small},
  % ノードスタイル定義
  astnode/.style={
    rectangle, 
    draw, 
    rounded corners=3pt, 
    minimum width=2.2cm, 
    minimum height=0.7cm,
    font=\ttfamily
  },
  classnode/.style={astnode, fill=blue!15},
  defnode/.style={astnode, fill=orange!15},
  namenode/.style={astnode, fill=green!15, minimum width=3cm},
  argsnode/.style={astnode, fill=purple!15},
  bodynode/.style={astnode, fill=red!15},
  paramnode/.style={astnode, fill=gray!10, minimum width=1.2cm, minimum height=0.5cm},
  stmtnode/.style={astnode, fill=yellow!10, minimum width=2.8cm, minimum height=0.5cm},
  edge/.style={->, >=stealth, thick}
]
  
  % ルートノード
  \node[classnode] (class) {class};
  
  % 第2レベル
  \node[namenode, below left=of class] (classname) {name: Point};
  \node[defnode, below right=of class] (def) {def};
  
  % 第3レベル（def の子ノード）
  \node[namenode, below=of def] (funcname) {name: \_\_init\_\_};
  \node[argsnode, left=of funcname] (args) {arguments};
  \node[bodynode, right=of funcname] (body) {body};
  
  % 第4レベル（パラメータ）
  \node[paramnode, below=0.8cm of args, xshift=-1.2cm] (self) {self};
  \node[paramnode, below=0.8cm of args] (x) {x};
  \node[paramnode, below=0.8cm of args, xshift=1.2cm] (y) {y};
  
  % 第4レベル（ステートメント）
  \node[stmtnode, below=0.8cm of body, xshift=-1.5cm] (stmt1) {self.x = x};
  \node[stmtnode, below=0.8cm of body, xshift=1.5cm] (stmt2) {self.y = y};
  
  % エッジの描画
  \draw[edge] (class) -- (classname);
  \draw[edge] (class) -- (def);
  \draw[edge] (def) -- (funcname);
  \draw[edge] (def) -- (args);
  \draw[edge] (def) -- (body);
  \draw[edge] (args) -- (self);
  \draw[edge] (args) -- (x);
  \draw[edge] (args) -- (y);
  \draw[edge] (body) -- (stmt1);
  \draw[edge] (body) -- (stmt2);
  
  % 図のラベル（必要に応じて）
  \node[below=3cm of class, font=\footnotesize] {図7: Pythonクラス定義の抽象構文木};
\end{tikzpicture}
\end{center}
```

インデントによってプログラムの構造を表現するというアイデアは秀逸ですが、一方で、インデントによる構造の表現は明らかに文脈自由言語の範囲を超えるものです。

Pythonでは字句解析のときにインデントを`<INDENT>`（インデントレベル増加）、インデントを「外す」のを`<DEDENT>`（インデントレベル減少）という特別なトークンに変換します。これにより、構文解析器自体はこれらのトークンをブロックの開始と終了のように扱うことができ、文脈自由文法の範囲で処理しやすくなります。

例えば、先の `Point` クラスの定義は、字句解析後には（簡略化すると）以下のようなトークン列として扱われるイメージです。

```
<CLASS> <NAME:Point> <COLON> <NEWLINE> <INDENT>
  <DEF> <NAME:__init__> 
    <LPAREN> <NAME:self> <COMMA> <NAME:x> <COMMA> <NAME:y> <RPAREN> 
    <COLON> <NEWLINE> <INDENT>
    <NAME:self> <DOT> <NAME:x> <ASSIGN> <NAME:x> <NEWLINE>
    <NAME:self> <DOT> <NAME:y> <ASSIGN> <NAME:y> <NEWLINE>
  <DEDENT>
<DEDENT>
```

（`<NAME:A>`は識別子A、`<COLON>`はコロン、`<NEWLINE>`は改行、`<ASSIGN>`は代入演算子を表すトークンとします。実際にはさらに詳細なトークン分割が行われます。）
このように、インデント/デデントトークンがブロック構造を示すため、構文解析器は括弧の対応付けに似た形で処理できます。

しかし、よくよく考えればわかるのですが、`<IDENT>`トークンと`<DEDENT>`トークンを切り出す処理が文脈自由ではありません。つまり、字句解析時に`<IDENT>`と`<DEDENT>`トークンを切り出すために特殊な処理をしていることになります。`<DEDENT>`トークンは`<IDENT>`トークンとスペースの数が同じでなければいけないため、切り出すためには正規表現でも文脈自由文法でも手に余ることは想像できるでしょう。

```{=latex}
\begin{center}
\begin{tikzpicture}[
  node distance=0.3cm,
  every node/.style={font=\footnotesize},
  % コードラインのスタイル
  codeline/.style={
    rectangle,
    anchor=west,
    font=\ttfamily\footnotesize
  },
  % インデントトークンのスタイル
  indenttoken/.style={
    rectangle,
    draw,
    rounded corners=2pt,
    fill=blue!10,
    font=\footnotesize\ttfamily,
    minimum height=0.5cm
  },
  % スタック表示のスタイル
  stacknode/.style={
    rectangle,
    draw,
    minimum width=0.8cm,
    minimum height=0.5cm,
    font=\footnotesize
  }
]
  
  % 左側: ソースコード表示
  \node[codeline] (line1) at (0,0) {class Point:};
  \node[codeline] (line2) at (0.5,-0.6) {def \_\_init\_\_(self, x, y):};
  \node[codeline] (line3) at (1,-1.2) {self.x = x};
  \node[codeline] (line4) at (1,-1.8) {self.y = y};
  
  % 中央: インデントトークン
  \node[indenttoken, right=3cm of line1] (indent1) {INDENT};
  \node[indenttoken, right=2.5cm of line2] (indent2) {INDENT};
  \node[indenttoken, right=2.5cm of line4, yshift=-0.3cm] (dedent1) {DEDENT};
  \node[indenttoken, below=0.1cm of dedent1] (dedent2) {DEDENT};
  
  % 矢印
  \draw[->, gray] (line1.east) -- (indent1.west) node[midway, above, font=\tiny] {レベル0→2};
  \draw[->, gray] (line2.east) -- (indent2.west) node[midway, above, font=\tiny] {レベル2→4};
  \draw[->, gray] ([xshift=2cm]line4.east) -- (dedent1.west) node[midway, above, font=\tiny] {レベル4→2};
  \draw[->, gray] ([xshift=2cm]dedent1.east) -- (dedent2.west) node[midway, above, font=\tiny] {レベル2→0};
  
  % 右側: インデントスタックの状態
  \node[right=5.5cm of line1, anchor=west] (stack_label) {\textbf{インデントスタック}};
  
  % スタック状態1: [0]
  \node[stacknode, below=0.3cm of stack_label] (s1_0) {0};
  \node[right=0.2cm of s1_0] {← 初期状態};
  
  % スタック状態2: [0, 2]
  \node[stacknode, below=0.7cm of s1_0] (s2_0) {0};
  \node[stacknode, right=0 of s2_0] (s2_2) {2};
  \node[right=0.2cm of s2_2] {← class定義後};
  
  % スタック状態3: [0, 2, 4]
  \node[stacknode, below=0.7cm of s2_0] (s3_0) {0};
  \node[stacknode, right=0 of s3_0] (s3_2) {2};
  \node[stacknode, right=0 of s3_2] (s3_4) {4};
  \node[right=0.2cm of s3_4] {← def定義後};
  
  % スタック状態4: [0, 2]
  \node[stacknode, below=0.7cm of s3_0] (s4_0) {0};
  \node[stacknode, right=0 of s4_0] (s4_2) {2};
  \node[right=0.2cm of s4_2] {← defブロック終了};
  
  % スタック状態5: [0]
  \node[stacknode, below=0.7cm of s4_0] (s5_0) {0};
  \node[right=0.2cm of s5_0] {← classブロック終了};
  
  % 図のラベル
  \node[below=1cm of s5_0, font=\footnotesize] {図7.2: インデント文法のトークン化とスタック管理};
\end{tikzpicture}
\end{center}
```

## ヒアドキュメント

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

読者の方々はおそらく「確かに凄いけど、普通はこのような書き方をすることはほぼないのでは」と思われたのではないでしょうか。実際問題そうなのですが、Rubyはこのような複雑怪奇なプログラムもうまく構文解析できなければいけないのも事実です。

Rubyのヒアドキュメントを適切に構文解析するには直感的にはHTMLやXMLにおけるタグ名の対応付けと同じ処理が必要になりますが、これは明らかに文脈自由言語の範囲を超えています。Rubyのヒアドキュメントがこのような振る舞いをすることを初めて知ったのは筆者が大学院生の頃ですが、あまりに予想外の振る舞いに目眩がする思いだったのを覚えています。

Rubyのヒアドキュメントが実際にどのように実装されているかはさておき、筆者はかつて中田育男先生と共同でISO Rubyの試験的な構文解析器をScalaで実装した際に、このヒアドキュメントの扱いに非常に苦労しました。

その際の実装の詳細は、中田先生の[ruby_scalaリポジトリ](https://github.com/inakata/ruby_scala/blob/3f54cc6f80678e30a211fb1374280246f08182ed/src/main/scala/com/github/inakata/ruby_scala/Ruby.scala#L1383)で確認できますが、ヒアドキュメントの開始デリミタを記憶し、対応する終了デリミタが現れるまでを特別に処理する、といった複雑なロジックが必要でした。

このときはScalaのパーザコンビネータを使ってヒアドキュメントを再現したのですが、引数を取ってコンビネータを返すメソッドを定義することで問題を解決しました。形式言語の文脈でいうのなら、PEGの規則が引数を持てるように拡張することでヒアドキュメントを解釈できるようになったと言うことができます。

PEGを拡張して規則が引数を持てるようにするという試みは複数ありますが、筆者もMacro PEGというPEGを拡張したものを提案しました。ヒアドキュメントという当たり前に使われている言語機能ですら、構文解析を正しく行うためには厄介な処理をする必要があるのです。

```{=latex}
\usetikzlibrary{decorations.pathreplacing}
\begin{center}
\begin{tikzpicture}[
  node distance=0.4cm,
  every node/.style={font=\footnotesize},
  % ヒアドキュメントのスタイル
  heredoc/.style={
    rectangle,
    anchor=west,
    font=\ttfamily\footnotesize
  },
  % デリミタのスタイル
  delimiter/.style={
    rectangle,
    draw,
    rounded corners=2pt,
    fill=yellow!20,
    font=\ttfamily\footnotesize,
    minimum height=0.5cm,
    minimum width=1cm
  },
  % スタック要素のスタイル
  stackitem/.style={
    rectangle,
    draw,
    fill=orange!10,
    minimum width=1cm,
    minimum height=0.5cm,
    font=\footnotesize\ttfamily
  },
  % ブレースのスタイル
  brace/.style={
    decorate,
    decoration={brace, amplitude=5pt},
    thick
  }
]
  
  % 左側: ヒアドキュメントの構造
  \node[heredoc] (line1) at (0,0) {<<E1};
  \node[heredoc] (line2) at (0.3,-0.5) {...};
  \node[heredoc] (line3) at (0.3,-1) {<<E2};
  \node[heredoc] (line4) at (0.6,-1.5) {...};
  \node[heredoc] (line5) at (0.3,-2) {E2};
  \node[heredoc] (line6) at (0.3,-2.5) {...};
  \node[heredoc] (line7) at (0,-3) {E1};
  
  % デリミタのハイライト
  \node[delimiter, right=2cm of line1] (delim1_start) {E1開始};
  \node[delimiter, right=2cm of line3] (delim2_start) {E2開始};
  \node[delimiter, right=2cm of line5] (delim2_end) {E2終了};
  \node[delimiter, right=2cm of line7] (delim1_end) {E1終了};
  
  % 矢印
  \draw[->, gray] (line1.east) -- (delim1_start.west);
  \draw[->, gray] (line3.east) -- (delim2_start.west);
  \draw[->, gray] (line5.east) -- (delim2_end.west);
  \draw[->, gray] (line7.east) -- (delim1_end.west);
  
  % ブレースで範囲を示す
  \draw[brace] ([xshift=-3mm]line1.west) -- ([xshift=-3mm]line7.west) 
    node[midway, left=5mm, text width=1cm, align=center] {E1の\\範囲};
  \draw[brace] ([xshift=-1mm]line3.west) -- ([xshift=-1mm]line5.west) 
    node[midway, left=3mm, text width=1cm, align=center] {E2の\\範囲};
  
  % 右側: デリミタスタックの状態変化
  \node[right=5cm of line1, anchor=west] (stack_title) {\textbf{デリミタスタック}};
  
  % 状態1: []
  \node[below=0.3cm of stack_title, anchor=west] (state1) {[ ]};
  \node[right=0.5cm of state1] {← 初期状態};
  
  % 状態2: [E1]
  \node[below=0.5cm of state1, anchor=west] (state2_bracket) {[};
  \node[stackitem, right=0 of state2_bracket, anchor=west] (state2_e1) {E1};
  \node[right=0 of state2_e1, anchor=west] (state2_close) {]};
  \node[right=0.5cm of state2_close] {← <<E1 認識};
  
  % 状態3: [E1, E2]
  \node[below=0.5cm of state2_bracket, anchor=west] (state3_bracket) {[};
  \node[stackitem, right=0 of state3_bracket, anchor=west] (state3_e1) {E1};
  \node[right=0.1cm of state3_e1, anchor=west] (state3_comma) {,};
  \node[stackitem, right=0.1cm of state3_comma, anchor=west] (state3_e2) {E2};
  \node[right=0 of state3_e2, anchor=west] (state3_close) {]};
  \node[right=0.5cm of state3_close] {← <<E2 認識};
  
  % 状態4: [E1]
  \node[below=0.5cm of state3_bracket, anchor=west] (state4_bracket) {[};
  \node[stackitem, right=0 of state4_bracket, anchor=west] (state4_e1) {E1};
  \node[right=0 of state4_e1, anchor=west] (state4_close) {]};
  \node[right=0.5cm of state4_close] {← E2 終了};
  
  % 状態5: []
  \node[below=0.5cm of state4_bracket, anchor=west] (state5) {[ ]};
  \node[right=0.5cm of state5] {← E1 終了};
  
  % 図のラベル
  \node[below=1cm of state5, font=\footnotesize] {図7.3: ヒアドキュメントのデリミタ対応とスタック管理};
\end{tikzpicture}
\end{center}
```

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
| **C++のテンプレート構文**             | 文脈依存の字句解析                          | `>>`を状況に応じて異なるトークンとして解釈できる                        | 字句解析器が構文解析の文脈を追跡する必要がある                             | C++11以降                                |
| **正規表現リテラルの曖昧性**          | 前のトークンに基づく解釈切り替え             | `/`が正規表現か除算演算子かを適切に判断できる                            | 字句解析器が前のトークンの種類を記憶する必要がある                         | JavaScript, Perl                         |
| **マクロ展開**                       | プリプロセッサによる前処理                   | 強力なコード生成と抽象化が可能                                           | 構文エラーの位置特定困難、デバッグの複雑化、意図しない副作用               | C, C++                                   |
| **エスケープシーケンスと生文字列**     | 状態付き字句解析器                          | 通常文字列と生文字列を適切に区別して処理できる                           | 複数の文字列モードと終端検出ロジックの管理が必要                           | Python (r""), C++11 (R"()"), JavaScript  |

## 改行終端可能文法

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
    (%% << CL(PLUS)) ^^ { location => (left: AST, right: AST) => 
        BinaryExpression(location, Operator.ADD, left, right) 
    } 
  | (%% << CL(MINUS)) ^^ { location => (left: AST, right: AST) => 
        BinaryExpression(location, Operator.SUBTRACT, left, right) 
    }
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

## Cのtypedef

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

## Scalaでの「文頭に演算子が来る場合の処理」

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

## プレースホルダー構文

Scalaにはプレースホルダー構文、正確にはPlaceholder Syntax for Anonymous Functionと呼ばれる構文があります。これは最近の言語ではすっかり普通に使えるようになったいわゆる**ラムダ式**（無名関数）を簡易表記するための構文です。

ラムダ式は、Javaでも8以降で使えるようになった「名前のない関数」のことです。JavaだとComparatorを定義する時などに `(a, b) -> a.compareTo(b)` のように書きますね。

たとえば、Scalaで`[1, 2, 3, 4]`というリストの各要素をインクリメントする処理はラムダ式（Scalaでは無名関数とも呼ばれます）を使って次のように書くことができます。

```scala
List(1, 2, 3, 4).map(x => x + 1)
```

`map`は多くの言語で採用されている高階関数（関数を引数に取る関数）です。JavaのStream APIでも同様の機能があり、`.stream().map(...)`のように使いますね。`map`は引数で渡された無名関数をリストの各要素に適用して、その結果できた新しいリストを返します。たとえば、上のプログラムだと実行結果は次のようになります。


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

このケースでは、`(_ + _)`が`((x, y) => x + y)`という無名関数に変換されたわけですが、プレースホルダが複数出現するとややこしい問題になります。ここで重要なのは、`_`が出現する順番に対応して、引数の順番が決まるということです。最初の`_`が第1引数、2番目の`_`が第2引数に対応します。

また、そもそもプレースホルダが単一であっても解釈が難しい問題もあります。たとえば、次の式を考えてみます。

```scala
List(1, 2, 3, 4).map(_ * 2 + 3)
```

これは以下のScalaプログラムに変換されます。

```scala
List(1, 2, 3, 4).map(x => x * 2 + 3)
````

もし、`_`を含む「最小の式」を無名関数にするという方式だと`(_ * 2)`が`(x => x * 2)`という無名関数に変換されても良さそうですがそうはなっていません。また、ユーザーのニーズを考えてもそうなっては欲しくありません。

Scalaではこのプレースホルダ構文をどう扱っているかというと非常に複雑で一言では説明しきれない部分があるのですが、あえて大雑把に要約すると、次のようになります。

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

Scala処理系内部でプレースホルダ構文がどのように実装されているかも読んだことがありますが、とてもややこしいものでした。C言語のtypedefは構文解析の途中で連想配列に名前を登録すればいいだけまだマシですが、さらに厄介だというのが正直な印象です。

なお、プレースホルダ構文について「きちんとした定義」を参照されたい方は、[Scala Language Specification 6.23.2: Placeholder Syntax for Anonymous Function](https://www.scala-lang.org/files/archive/spec/2.13/06-expressions.html#placeholder-syntax-for-anonymous-functions)を読んでいただければと思います。

## C++のテンプレート構文

C++のテンプレートは型パラメータを使ったジェネリックプログラミングを可能にする強力な機能ですが、その構文は構文解析の観点から見ると興味深い問題を含んでいます。特に有名なのが「`>>`の曖昧性」です。

Javaのジェネリクスでいうと `List<List<String>>` のような書き方に相当しますが、C++では歴史的な経緯から特別な問題がありました。

C++03までは、次のようなネストしたテンプレートの宣言はコンパイルエラーになりました：

```cpp
std::vector<std::vector<int>> matrix;  // C++03ではエラー
```

何故かというと、`>>`が右シフト演算子として解釈されてしまうからです。そのため、C++03では次のようにスペースを入れる必要がありました：

```cpp
std::vector<std::vector<int> > matrix;  // C++03ではOK
```

この問題は単純な字句解析の問題のように見えますが、実はそうではありません。次の例を考えてみましょう：

```cpp
template<int N>
struct A {
    static const int value = N;
};

// これは A<1>::value >> 2 （右シフト）
int x = A<1>::value >> 2;

// これは vector<vector<int>> （テンプレートの終端）
std::vector<std::vector<int>> v;
```

同じ`>>`という文字列が、文脈によって右シフト演算子として解釈されたり、テンプレート引数リストの終端記号2つとして解釈されたりする必要があるのです。これは明らかに文脈自由文法の範囲を超えており、構文解析器は現在の文脈（テンプレート引数リストの中にいるかどうか）を追跡する必要があります。

C++11以降では、この問題に対処するため、構文解析器がテンプレート引数リストの文脈では`>>`を`> >`として解釈するように標準が変更されました。しかし、これは構文解析器の実装をより複雑にします。例えば、次のような入れ子になったケースも正しく処理する必要があります：

```cpp
std::map<int, std::vector<std::vector<int>>> nested;  // C++11以降はOK
```

さらに複雑なのは、`>>=`（右シフト代入演算子）や`>>>`（一部の拡張で使われる）なども考慮する必要があることです。構文解析器は、テンプレート引数リストの文脈を正確に追跡し、適切にトークンを分割する必要があります。

## 正規表現リテラルの曖昧性

JavaScriptには正規表現リテラルという便利な記法があります。Javaでは `Pattern.compile("[a-z]+", Pattern.CASE_INSENSITIVE)` のように書くところを、JavaScriptでは以下のように簡潔に書けます：

```javascript
const pattern = /[a-z]+/i;  // 大文字小文字を区別しない英字のパターン
```

しかし、この`/`記号は除算演算子としても使われるため、構文解析上の曖昧性が生じます：

```javascript
// これは正規表現リテラル
const regex = /ab+c/;

// これは除算演算
const result = a / b + c / d;
```

さらに厄介なのは、次のようなケースです：

```javascript
// これは何でしょう？
return /regex/i.test(str);  // 正規表現リテラル
return a / b / c;            // 除算演算
```

この曖昧性を解決するには、構文解析器は現在の文脈を理解する必要があります。JavaScriptの仕様では、正規表現リテラルが現れることができる位置と、除算演算子が現れることができる位置を厳密に定義しています。

一般的なルールとして：

- 式の開始位置では`/`は正規表現リテラルの開始
- 式の途中では`/`は除算演算子

しかし、実際にはもっと複雑で、前のトークンが何であるかによって判断する必要があります：

```javascript
// 前のトークンが ) の場合は除算
func() / 2

// 前のトークンが = の場合は正規表現
const x = /pattern/

// 前のトークンが return の場合は正規表現
return /pattern/g
```

JavaScriptの構文解析器は、前のトークンの種類を記憶し、それに基づいて`/`の解釈を切り替える必要があります。これは字句解析と構文解析が密接に連携する必要があることを示す好例です。

## マクロ展開

C/C++のプリプロセッサマクロは、構文解析の前に展開される強力な機能ですが、構文解析を複雑にする要因の一つです。

Javaには存在しない機能ですが、C/C++では `#define` を使ってテキストレベルの置換を定義できます：

```c
#define BEGIN {
#define END }

int main() BEGIN
    printf("Hello, World!\n");
END
```

このコードは、プリプロセッサによって次のように展開されます：

```c
int main() {
    printf("Hello, World!\n");
}
```

マクロは単純なテキスト置換に見えますが、実際には非常に複雑な問題を引き起こします。例えば、マクロは構文的に不完全なコード片を定義できます：

```c
#define IF_DEBUG if (debug_mode)

void foo() {
    IF_DEBUG
        printf("Debug mode\n");
}
```

これは次のように展開されます：

```c
void foo() {
    if (debug_mode)
        printf("Debug mode\n");
}
```

さらに複雑なのは、マクロが引数を取る場合です：

```c
#define MAX(a, b) ((a) > (b) ? (a) : (b))

int x = MAX(y++, z++);  // y++とz++が複数回評価される可能性
```

マクロ展開の問題点は：

1. **構文エラーの位置特定が困難**: マクロ展開後のコードでエラーが発生した場合、元のソースコードのどこが原因かを特定するのが難しい

2. **デバッグの困難さ**: マクロ内でのステップ実行ができない

3. **意図しない副作用**: 上記の`MAX`マクロのように、引数が複数回評価される

4. **スコープの問題**: マクロは単純なテキスト置換なので、変数のスコープなどを考慮しない

現代的なアプローチとして、C++ではテンプレートやインライン関数、`constexpr`などを使ってマクロの使用を減らす方向にありますが、既存のコードベースでは依然として多用されています。

構文解析の観点から見ると、マクロ展開は「前処理」フェーズで行われるため、構文解析器は展開後のコードを見ることになります。しかし、エラーメッセージやデバッグ情報のために、元のソースコードの位置情報を保持する必要があり、これが実装を複雑にしています。

## 文字列内のエスケープシーケンス

プログラミング言語の文字列リテラルには、特殊文字を表現するためのエスケープシーケンスが存在します。これは一見単純な機能に見えますが、実は様々な複雑さを含んでいます。

Javaでも `\n`（改行）、`\t`（タブ）、`\"`（ダブルクォート）、`\\`（バックスラッシュ）などのエスケープシーケンスを日常的に使っていますね。

基本的なエスケープシーケンスは多くの言語で共通です：

```c
"Hello\nWorld"    // 改行
"Tab\there"       // タブ
"Quote: \""       // ダブルクォート
"Backslash: \\"   // バックスラッシュ
```

しかし、言語によってエスケープシーケンスの扱いは大きく異なります。例えば、Pythonには「生文字列」（raw string）という機能があります：

```python
# 通常の文字列
path1 = "C:\\Users\\name\\file.txt"  # バックスラッシュをエスケープ

# 生文字列
path2 = r"C:\Users\name\file.txt"    # エスケープ不要
```

生文字列では、バックスラッシュは特別な意味を持ちません。ただし、完全にエスケープを無効にするわけではなく、文字列の終端を示すクォートの前のバックスラッシュは特別扱いされます：

```python
# これはエラー
raw = r"This is a raw string\"

# これはOK（最後の文字がバックスラッシュでない）
raw = r"This is a raw string\\"
```

C++11では、より柔軟な生文字列リテラルが導入されました：

```cpp
// 基本的な生文字列
const char* path = R"(C:\Users\name\file.txt)";

// デリミタ付き生文字列
const char* regex = R"delimiter(
    \d{3}-\d{4}  # 電話番号のパターン
    )"delimiter";
```

C++の生文字列では、独自のデリミタを指定できるため、文字列内に`)`が含まれていても問題ありません：

```cpp
const char* text = R"xxx(
    This contains ) and )" and even )xxx but not )xxx"
)xxx";
```

これらの機能は構文解析を複雑にします：

1. **状態管理**: 通常文字列モード、生文字列モード、エスケープ処理中など、複数の状態を管理する必要がある

2. **終端の検出**: 特に生文字列では、カスタムデリミタを認識して適切に終端を検出する必要がある

3. **エラー処理**: 不正なエスケープシーケンスや、終端していない文字列の検出

4. **Unicode対応**: `\u{1F600}`のようなUnicodeエスケープシーケンスの処理

さらに、テンプレート文字列や文字列補間と組み合わさると、より複雑になります：

```javascript
// JavaScriptのテンプレート文字列
const message = `Line 1\nLine 2 with ${variable} and \${escaped}`;

// タグ付きテンプレート（生文字列として扱える）
const query = String.raw`SELECT * FROM users WHERE name = 'John\'s'`;
```

これらの機能を正しく実装するには、字句解析器が高度な状態管理を行い、文脈に応じて適切にトークンを生成する必要があります。

## エラーリカバリ

構文解析の途中でエラーが起きることは（当然ながら）普通にあります。構文解析中のエラーリカバリについては多くの研究があるものの、コンパイラの教科書で構文解析アルゴリズムでのエラーリカバリについて言及されることは稀です。推測ですが、構文解析において２つ目以降のエラーは大抵最初のエラーに誘発されて起こるということや、どうしても経験則に頼った記述になりがちなため、教科書で言及されることは少ないのでしょう。また、大抵の言語処理系で構文解析中のエラーリカバリについては大したことをしていなかったという歴史的事情もあるかもしれません。

しかし、現在は別の観点から構文解析中のエラーリカバリが重要性を増してきています。それは、テキストエディタの拡張としてIDEのような「構文解析エラーになるが、それっぽくなんとか構文解析をしなければいけない」というニーズがあるからです。ユーザーがコードを書いている最中は、一時的に文法的に正しくない状態になることが頻繁にあります。IDEがそのような状況でも構文ハイライト、コード補完、リアルタイムのエラー表示などの機能を提供し続けるためには、エラーが発生しても即座に解析を中断するのではなく、可能な限り解析を継続し、後続のエラーも検出できるような仕組み、すなわちエラーリカバリ機構が不可欠です。

エラーリカバリにはいくつかの代表的な手法があります。

- **パニックモード (Panic Mode):** 最も単純な手法の一つです。エラーを検出したら、セミコロン（`;`）や閉じ波括弧（`}`）のような、文やブロックの区切りとなる「同期トークン」が見つかるまで、入力トークンを読み飛ばします。同期トークンが見つかったら、そこから解析を再開します。

   C言語風のコード `x = a + * b; y = c;` で、`*` が予期しないトークンとしてエラーになった場合、パニックモードでは `*` と `b` を読み飛ばし、次の同期トークンである `;` を見つけて解析を再開します。これにより、`y = c;` の解析は行われますが、`* b` に関するエラーの詳細は失われる可能性があります。

- **フレーズレベルリカバリ (Phrase-Level Recovery):** エラー箇所の周辺で、局所的な修正を試みる手法です。例えば、不足しているセミコロンを補ったり、予期しないトークンを削除したり、期待されるトークンに置き換えたりします。

  `x = a + b y = c;` というコードで、`b` と `y` の間にセミコロンが欠落している場合、パーサは `y` が予期しないトークンであると判断します。フレーズレベルリカバリでは、「文の終わりにはセミコロンが期待される」という知識に基づき、`b` の後にセミコロンを挿入して `x = a + b; y = c;` として解析を試みるかもしれません。
  
  Javaのメソッド呼び出しで `myObject.method(arg1 arg2)` のようにカンマが抜けている場合、`arg1` と `arg2` の間にカンマを補って `myObject.method(arg1, arg2)` として解釈を試みる、といった具合です。あるいは、JSONの配列 `[1, , 2]` で余分なカンマがある場合、それを削除して `[1, 2]` として解析を続けるかもしれません。パニックモードよりは洗練されていますが、どのような修正を行うかの判断が難しく、実装が複雑になりがちです。

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

IDEのような環境では、これらの手法を組み合わせたり、部分的な構文木（エラー箇所を含むかもしれないが、解析できた部分）を構築したり、インクリメンタルな解析（変更箇所だけを再解析する）を行ったりすることで、ユーザーが編集中でも可能な限り正確な情報を提供しようと試みています。

例えば、Javaのクラスを書いている途中で `class MyClass { public void myMethod() { ... }` と入力し、最後の閉じ括弧 `}` を入力し忘れている場合でも、IDEは `myMethod` の本体部分についてはある程度解析を試み、メソッド内の変数に対するコード補完や型チェックを行おうとします。これは、エラーリカバリ機構が、エラー箇所を特定しつつも、それ以外の部分については解析を継続し、部分的な構文情報を抽出しているためです。

エラーリカバリは、単にエラーを見つけるだけでなく、その後の解析をどう継続し、ユーザーにどのようなフィードバックを与えるかという、より実践的で奥深い問題領域なのです。

## まとめ

7章では現実の構文解析で遭遇する問題について、いくつかの例を挙げて説明しました。筆者が大学院博士後期課程に進学した頃「構文解析は終わった問題」と言われたのを覚えていますが、実際にはその後もANTLRの`LL(*)`アルゴリズムのような革新が起きていますし、細かいところでは今回の例のように従来の構文解析法単体では取り扱えない部分をアドホックに各プログラミング言語が補っている部分があります。

このような問題が起きるのは結局のところ、当初の想定と違って「プログラミング言語は文脈自由言語として表せ」なかったという事です。より厳密には当然、文脈自由言語の範囲に納めることもできますが、便利な表記を許していくとどうしても文脈自由言語から「はみ出て」しまうということです。このような「現実のプログラミング言語の文脈依存性」については専門の研究者以外には案外知られていなかったりしますが、ともあれこのような問題があることを知っておくのは、既存言語の表記法を取り入れた新しい言語を設計するときにも有益でしょう。
