
# 第4章 文脈自由文法の世界

第3章では、JSONの構文解析器を記述することを通して、構文解析のやり方を学びました。構文解析器についても、PEG型の構文解析器および字句解析器を使った2通りを作ってみることで、構文解析器といっても色々な書き方があるのがわかってもらえたのではないかと思います。

この第4章では、現代の構文解析を語る上で必須である、文脈自由文法という概念について学ぶことにします。「文脈自由文法」というと、一見、堅くて難しそうな印象を持つ方も多いかもしれません。

しかし、実は皆さんは既に文脈自由文法を使っているのです。Javaの`if`文やメソッド定義、JSONの入れ子構造など、プログラミングで日常的に扱っている「構造」はすべて文脈自由文法で表現されています。この章では、そんな身近な例から始めて、徐々に理論的な概念を理解していきましょう。

## 身近な例から始める文脈自由文法

まず、皆さんが普段書いているJavaコードを見てみましょう。以下はシンプルなif文です。

```java
if (x > 0) {
    System.out.println("正の数です");
}
```

このif文の構造を言葉で説明すると「`if`の後に条件式を括弧で囲み、その後に文のブロックが来る」となります。さらに、if文の中にif文を書くこともできます。

```java
if (x > 0) {
    if (x > 100) {
        System.out.println("100より大きい");
    }
}
```

この「入れ子にできる構造」こそが、文脈自由文法の本質なのです。

### 括弧の対応という根本問題

プログラミングで最も基本的で重要な構造の一つが「括弧の対応」です。JavaでもJSONでも、開き括弧と閉じ括弧は必ず対応していなければなりません。

たとえば、以下は正しい括弧の対応です：

```
()          // 1組の括弧
(())        // 入れ子になった括弧
(()())      // 入れ子と並列の組み合わせ
()()()      // 並列に並んだ括弧
```

一方、以下は正しくない例です：

```
)(          // 順序が逆
(()         // 閉じ括弧が不足
())         // 開き括弧が不足
```

このような「括弧の釣り合いが取れた文字列」を表す言語をDyck言語（「ディック言語」と読みます）と呼びます。「Dyck」は数学者の名前に由来しています。実は、この単純に見える問題が、構文解析の理論において極めて重要な位置を占めているのです。

### BNFで括弧の構造を表現する

さて、この括弧の対応をどのように文法として表現すればよいでしょうか？まずは皆さんに馴染みのあるBNFを使って考えてみましょう。

括弧の構造には以下の2つのパターンがあります：
1. 空文字列（括弧なし）
2. `(` + 内側の括弧構造 + `)` + 続きの括弧構造

これをBNFで書くと：

```text
D = P;
P = "(" P ")" P | "";
```

ここで`P`は「括弧のパターン」を表し、`D`は文法全体の開始地点（開始記号）です。この定義は再帰的になっていることに注目してください。`P`の定義の中に`P`自身が現れています。これこそが、入れ子構造を表現する鍵なのです。

### BNFから文脈自由文法へ

実は、上記のBNFは既に文脈自由文法の一種です。ただし、理論的な議論をする際には、より標準的な記法を使います。段階的に変換してみましょう。

**ステップ1: 選択を分離**

まず、`|`で区切られた選択肢を別々の規則に分けます：

```text
D = P;
P = "(" P ")" P;
P = "";
```

同じ`P`が2つの規則で定義されていますが、これは「Pは2つのパターンのどちらかになる」という意味です。

**ステップ2: 記号の変更**

次に、記法を数学的な標準形に近づけます：
- `=` を `→`（生成規則を表す矢印）に変更
- `""` を `ε`（イプシロン：空文字列を表す記号）に変更
- 文字を囲む引用符を削除

```text
D → P
P → ( P ) P
P → ε
```

これで文脈自由文法の標準的な記法になりました！

### ここで出てきた用語を整理しましょう

ここで重要な用語を整理しておきましょう：

- **生成規則**：`D → P` のような矢印で結ばれた規則
- **非終端記号**：`D`や`P`のような、さらに展開される記号（変数のようなもの）
- **終端記号**：`(`や`)`のような、これ以上展開されない記号（実際の文字）
- **開始記号**：文法の起点となる非終端記号（この例では`D`）

つまり、文脈自由文法とは：
- 生成規則の集まり
- 各生成規則は「非終端記号 → 記号の並び」の形
- 記号の並びは終端記号と非終端記号の組み合わせ（空文字列εも可）

実は、これだけのシンプルなルールで、プログラミング言語の複雑な構文を表現できるのです。

## 実例で理解する「言語」の概念

前の節で定義したDyck言語の文法をもう一度見てみましょう。

```
D → P
P → ( P ) P
P → ε
```

### プログラマーにとっての「言語」とは

これまで「言語」という用語を使ってきましたが、プログラマーにとって「言語」とは何でしょうか？

日常会話では「言語」といえば日本語や英語などの自然言語を思い浮かべますが、プログラミングの世界では少し違います。プログラミング言語には**曖昧さがありません**。同じコードは必ず同じ意味を持ちます。

では、「Java言語」や「JavaScript言語」という時、それは何を指しているのでしょうか？

### 言語を「文字列の集合」として考える

形式的には、プログラミング言語を**その言語で書ける正しいプログラムすべての集合**として定義します。

具体例で考えてみましょう。以下はすべて正しいJavaScriptプログラムです：

```javascript
console.log("Hello, World!");
```

```javascript
console.log(3);
```

```javascript
console.log(3 + 5);
```

これらを集めていくと、JavaScriptという言語は次のような文字列の集合として表現できます：

```text
JavaScript = {
  "console.log(\"Hello, World!\");",
  "console.log(3);",
  "console.log(3 + 5);",
  "const x = 10;",
  "function add(a, b) { return a + b; }",
  ...（無限に続く）
}
```

JavaScriptで書ける正しいプログラムは無限にあるので、この集合は**無限集合**になります。

### Dyck言語も集合として理解する

同様に、Dyck言語（括弧の対応が取れた文字列）も集合として表現できます：

```text
Dyck = {
  "()",
  "(())",
  "((()))",
  "(()())",
  "()()",
  "()()()",
  ...（無限に続く）
}
```

### 集合として言語を扱うメリット

言語を集合として扱うと、数学の集合論で使う記号が使えるようになります。これには実用的なメリットがあります。

まず、基本的な記号の意味を説明します：
- `∈`：「含まれる」を意味します
- `∉`：「含まれない」を意味します
- `⊂`：「部分集合」を意味します（左の集合が右の集合に完全に含まれる）
- `∩`：「共通部分」を意味します（両方の集合に含まれる要素）

**例1：ある文字列が言語に含まれるかの判定**

```text
"()" ∈ Dyck         // "()"はDyck言語に含まれる
")(" ∉ Dyck         // ")("はDyck言語に含まれない
```

**例2：言語の後方互換性**

Java 8がJava 5の後方互換であることを、集合の包含関係で表現できます：

```text
Java5 ⊂ Java8      // Java 5で書けるプログラムはすべてJava 8でも書ける
```

**例3：言語の共通部分**

たとえば、「JavaScriptでもTypeScriptでも有効なプログラム」は：

```text
JavaScript ∩ TypeScript = {
  "console.log(123);",
  "const x = 5;",
  "function f() { return 1; }",
  ...
}
```

このように、言語を集合として扱うことで、言語間の関係を明確に表現できるようになります。これは単なる理論ではなく、言語設計や互換性の議論において非常に役立ちます。

## 正規表現の限界と文脈自由言語

### 身近な正規表現から考える

皆さんは日常的に正規表現を使っているでしょう。ファイル検索、テキスト処理、入力値の検証など、様々な場面で活躍しています。

たとえば、Javaで電話番号の形式をチェックする時：

```java
String phoneRegex = "\\d{3}-\\d{4}-\\d{4}";  // 例：090-1234-5678
if (phone.matches(phoneRegex)) {
    // 有効な電話番号
}
```

メールアドレスの簡易チェック：

```java
String emailRegex = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}";
```

### 正規表現でできないこと

しかし、正規表現には決定的な限界があります。それは**括弧の対応が取れているかチェックできない**ということです。

試しに、以下のような文字列を正規表現で判定することを考えてみましょう：

```
OK:  (), (()), (()(()))
NG:  )(, ((), ())
```

どんなに工夫しても、任意の深さの括弧の対応を正規表現で表現することはできません。なぜでしょうか？

### 正規表現の仕組みと限界

正規表現の基本的な構成要素は以下の通りです：

```
a        文字そのもの
ab       連続（aの後にb）
a|b      選択（aまたはb）
a*       繰り返し（0回以上のa）
```

これらを組み合わせて、たとえば：
- 自然数： `0|[1-9][0-9]*`
- 郵便番号： `[0-9]{3}-[0-9]{4}`

などが表現できます。

しかし、正規表現は本質的に「有限の状態」しか記憶できません。括弧が何重にネストしているかを覚えておくには、理論的に無限の状態が必要になるため、正規表現では表現できないのです。

### 正規表現の構成要素を詳しく見る

正規表現は、実は非常にシンプルな3つの基本演算から構成されています。現代の正規表現エンジンは多くの便利な記法を提供していますが、理論的にはすべて以下の基本演算に帰着できます。

#### 1. 連接（Concatenation）

2つの正規表現を続けて書くことを**連接**と呼びます。

```
正規表現: ab
マッチする文字列: "ab"
マッチしない文字列: "a", "b", "ba", "abc"
```

連接は最も基本的な演算で、「次に」という順序関係を表現します。

#### 2. 選択（Union/Alternation）

`|`記号を使って、複数の選択肢を表現します。

```
正規表現: a|b
マッチする文字列: "a", "b"
マッチしない文字列: "ab", "c", ""
```

より複雑な例：
```
正規表現: (ab|cd)
マッチする文字列: "ab", "cd"
マッチしない文字列: "ac", "bd", "abcd"
```

#### 3. 繰り返し（Kleene Star）

`*`記号は、直前の要素を0回以上繰り返すことを意味します。この演算は数学者Stephen Cole Kleeneにちなんで「Kleeneスター」と呼ばれます。

```
正規表現: a*
マッチする文字列: "", "a", "aa", "aaa", ...
マッチしない文字列: "b", "ab"
```

#### 派生的な演算子

現代の正規表現では、便利のために多くの派生的な演算子が追加されています：

```
a+       1回以上の繰り返し（aa*と同等）
a?       0回または1回（a|εと同等）
a{n}     ちょうどn回の繰り返し
a{n,m}   n回以上m回以下の繰り返し
[a-z]    文字クラス（a|b|c|...|zと同等）
.        任意の1文字
```

しかし、これらはすべて基本の3演算で表現できます。たとえば：
- `a+` は `aa*`
- `a?` は `a|ε`（εは空文字列）
- `[abc]` は `a|b|c`

### 正規表現の裏側にある仕組み

皆さんは正規表現を使っているとき、その裏側でどのような処理が行われているか考えたことはありますか？

実は、正規表現の限界を理解するには、その背後にある「オートマトン」という仕組みを知ることが役立ちます。「オートマトン」という名前は難しそうですが、要は「文字列を一文字ずつ読みながら状態を変えていく機械」のことです。

#### オートマトンを自動販売機で考える

オートマトンは「有限個の状態を持つ機械」です。難しく聞こえるかもしれませんが、自動販売機を例にするとわかりやすくなります：

- 初期状態：お金が入っていない
- 100円投入 → 100円状態へ遷移
- さらに100円投入 → 200円状態へ遷移
- 商品ボタンを押す → 商品を出して初期状態へ

#### 簡単な例：`ab*`を認識するオートマトン

正規表現 `ab*`（aの後に0個以上のb）を認識するオートマトンを考えてみましょう。

この正規表現は以下のような文字列にマッチします：
- `a`（bが0個）
- `ab`（bが1個）  
- `abb`（bが2個）
- `abbb`（bが3個）
- ...

```{=latex}
\begin{center}
\begin{tikzpicture}[
  >=stealth',
  node distance=3cm,
  state/.style={circle, draw, minimum size=10mm},
  accept/.style={state, double}
]
  % 状態の定義
  \node[state] (s0) {0};
  \node[accept] (s1) [right of=s0] {1};
  
  % 遷移の定義
  \draw[->] (s0) -- node[above] {$a$} (s1);
  \draw[->] (s1) edge[loop above] node[above] {$b$} ();
  
  % 開始状態の矢印
  \draw[->] ([xshift=-1cm]s0.west) -- node[above] {開始} (s0);
\end{tikzpicture}
\end{center}
```

- 状態0（開始状態）：最初の状態
- 状態1（受理状態）：この状態で入力が終わればマッチ成功
- 矢印：文字を読んだときの状態遷移

このオートマトンは以下のように動作します：
- 入力"a"：状態0→状態1（受理）✓
- 入力"ab"：状態0→状態1→状態1（受理）✓
- 入力"abb"：状態0→状態1→状態1→状態1（受理）✓
- 入力"b"：状態0で'b'を読めない ✗

#### 2種類のオートマトン

オートマトンには大きく分けて2種類あります。難しい名前ですが、それぞれの特徴を簡単に説明します：

**NFA（Non-deterministic Finite Automaton、非決定性有限オートマトン）**
- 「非決定性」とは、同じ文字を読んだときに複数の選択肢があることを意味します
- 文字を読まずに状態を移動できることもあります（ε遷移、イプシロン遷移）
- 正規表現から比較的簡単に作れます

**DFA（Deterministic Finite Automaton、決定性有限オートマトン）**  
- 「決定性」とは、各状態で各文字に対して次の状態が一意に決まることを意味します
- 文字を読まずに移動することはできません
- 実装が簡単で、実行速度が速いです

### 正規表現からNFAへの変換

正規表現がどのようにオートマトンに変換されるか、具体的に見ていきましょう。この変換は「Thompson構成法」と呼ばれ、Ken Thompsonによって開発されました。

#### 基本的な変換規則

**1. 単一文字の場合**

正規表現 `a` は、以下のNFAになります：

```{=latex}
\begin{center}
\begin{tikzpicture}[
  >=stealth',
  node distance=3cm,
  state/.style={circle, draw, minimum size=8mm},
  accept/.style={state, double}
]
  \node[state] (s0) {0};
  \node[accept] (s1) [right of=s0] {1};
  
  \draw[->] (s0) -- node[above] {$a$} (s1);
  \draw[->] ([xshift=-1cm]s0.west) -- (s0);
\end{tikzpicture}
\end{center}
```

**2. 連接の場合**

正規表現 `AB`（AとBの連接）は、AのNFAとBのNFAを接続します：

```{=latex}
\begin{center}
\begin{tikzpicture}[
  >=stealth',
  node distance=2cm,
  state/.style={circle, draw, minimum size=8mm},
  accept/.style={state, double},
  nfa/.style={rectangle, draw, dashed, minimum width=2cm, minimum height=1.5cm}
]
  \node[nfa] (A) {A};
  \node[nfa] (B) [right=3cm of A] {B};
  
  \draw[->] ([xshift=-1cm]A.west) -- (A);
  \draw[->] (A) -- node[above] {$\varepsilon$} (B);
  \draw[->] (B) -- ([xshift=1cm]B.east);
\end{tikzpicture}
\end{center}
```

AのNFAの受理状態とBのNFAの開始状態をε遷移で結びます。

**3. 選択の場合**

正規表現 `A|B` は、新しい開始状態から両方への分岐を作ります：

```{=latex}
\begin{center}
\begin{tikzpicture}[
  >=stealth',
  node distance=2cm,
  state/.style={circle, draw, minimum size=8mm},
  accept/.style={state, double},
  nfa/.style={rectangle, draw, dashed, minimum width=2cm, minimum height=1.5cm}
]
  \node[state] (start) {0};
  \node[nfa] (A) [above right=1.5cm and 2cm of start] {A};
  \node[nfa] (B) [below right=1.5cm and 2cm of start] {B};
  \node[accept] (end) [right=5cm of start] {1};
  
  \draw[->] ([xshift=-1cm]start.west) -- (start);
  \draw[->] (start) -- node[above] {$\varepsilon$} (A);
  \draw[->] (start) -- node[below] {$\varepsilon$} (B);
  \draw[->] (A) -- node[above] {$\varepsilon$} (end);
  \draw[->] (B) -- node[below] {$\varepsilon$} (end);
\end{tikzpicture}
\end{center}
```

**4. 繰り返しの場合**

正規表現 `A*` は、ループとスキップの両方を許可します：

```{=latex}
\begin{center}
\begin{tikzpicture}[
  >=stealth',
  node distance=2cm,
  state/.style={circle, draw, minimum size=8mm},
  accept/.style={state, double},
  nfa/.style={rectangle, draw, dashed, minimum width=2cm, minimum height=1.5cm}
]
  \node[state] (start) {0};
  \node[nfa] (A) [right=2cm of start] {A};
  \node[accept] (end) [right=2cm of A] {1};
  
  \draw[->] ([xshift=-1cm]start.west) -- (start);
  \draw[->] (start) -- node[above] {$\varepsilon$} (A);
  \draw[->] (A) -- node[above] {$\varepsilon$} (end);
  \draw[->] (start) to[bend right=30] node[below] {$\varepsilon$} (end);
  \draw[->] (A) to[bend right=30] node[below] {$\varepsilon$} (start);
\end{tikzpicture}
\end{center}
```

#### 具体例：`(a|b)*abb` の構築

では、実際に `(a|b)*abb` という正規表現からNFAを構築してみましょう。

**ステップ1：`a|b` の部分**

まず、`a|b`のNFAを作ります：

```{=latex}
\begin{center}
\begin{tikzpicture}[
  >=stealth',
  node distance=2cm,
  state/.style={circle, draw, minimum size=7mm},
  accept/.style={state, double}
]
  \node[state] (s0) {0};
  \node[state] (s1) [above right of=s0] {1};
  \node[state] (s2) [below right of=s0] {2};
  \node[state] (s3) [right=3cm of s0] {3};
  
  \draw[->] (s0) -- node[above] {$\varepsilon$} (s1);
  \draw[->] (s0) -- node[below] {$\varepsilon$} (s2);
  \draw[->] (s1) -- node[above] {$a$} (s3);
  \draw[->] (s2) -- node[below] {$b$} (s3);
\end{tikzpicture}
\end{center}
```

**ステップ2：`(a|b)*` の部分**

次に、Kleeneスターを適用します：

```{=latex}
\begin{center}
\begin{tikzpicture}[
  >=stealth',
  node distance=1.8cm,
  state/.style={circle, draw, minimum size=6mm},
  accept/.style={state, double}
]
  \node[state] (start) {S};
  \node[state] (s0) [right of=start] {0};
  \node[state] (s1) [above right of=s0] {1};
  \node[state] (s2) [below right of=s0] {2};
  \node[state] (s3) [right=2.5cm of s0] {3};
  \node[state] (end) [right of=s3] {E};
  
  \draw[->] (start) -- node[above] {$\varepsilon$} (s0);
  \draw[->] (s0) -- node[above] {$\varepsilon$} (s1);
  \draw[->] (s0) -- node[below] {$\varepsilon$} (s2);
  \draw[->] (s1) -- node[above] {$a$} (s3);
  \draw[->] (s2) -- node[below] {$b$} (s3);
  \draw[->] (s3) -- node[above] {$\varepsilon$} (end);
  \draw[->] (s3) to[bend right=40] node[below] {$\varepsilon$} (s0);
  \draw[->] (start) to[bend left=70] node[above] {$\varepsilon$} (end);
\end{tikzpicture}
\end{center}
```

**ステップ3：`abb` を追加**

最後に、`abb`の部分を連接します。これが最終的なNFAです（前述の図と同じ）。

#### 正規表現 (a|b)*abb のNFA

```{=latex}
\begin{center}
\begin{tikzpicture}[
  >=stealth',
  node distance=2.5cm,
  state/.style={circle, draw, minimum size=7mm},
  accept/.style={state, double}
]
  % 状態の定義
  \node[state] (s0) {0};
  \node[state] (s1) [above right of=s0] {1};
  \node[state] (s2) [below right of=s0] {2};
  \node[state] (s3) [right of=s1] {3};
  \node[state] (s4) [right of=s2] {4};
  \node[state] (s5) [below right of=s3] {5};
  \node[state] (s6) [right of=s5] {6};
  \node[state] (s7) [right of=s6] {7};
  \node[accept] (s8) [right of=s7] {8};
  
  % 遷移の定義
  \draw[->] (s0) -- node[above left] {$\varepsilon$} (s1);
  \draw[->] (s0) -- node[below left] {$\varepsilon$} (s2);
  \draw[->] (s1) -- node[above] {$a$} (s3);
  \draw[->] (s2) -- node[below] {$b$} (s4);
  \draw[->] (s3) -- node[above right] {$\varepsilon$} (s5);
  \draw[->] (s4) -- node[below right] {$\varepsilon$} (s5);
  \draw[->] (s5) -- node[above] {$a$} (s6);
  \draw[->] (s6) -- node[above] {$b$} (s7);
  \draw[->] (s7) -- node[above] {$b$} (s8);
  
  % ループバック
  \draw[->] (s5) to[bend right=60] node[below] {$\varepsilon$} (s0);
  
  % 開始状態の矢印
  \draw[->] ([xshift=-1cm]s0.west) -- (s0);
\end{tikzpicture}
\end{center}
```

このNFAは「aまたはbを任意回繰り返した後、abbで終わる」文字列を認識します。

### NFAからDFAへの変換：部分集合構成法

NFAは実装が複雑なので、多くの場合DFAに変換して使用します。この変換には**部分集合構成法**（Subset Construction）という手法を使います。

#### 部分集合構成法の考え方

NFAの問題点は「同時に複数の状態にいる可能性がある」ことです。部分集合構成法は、この「複数の状態の組み合わせ」を1つのDFA状態として扱います。

たとえば、NFAで「状態0または状態6にいる」という状況を、DFAでは「状態{0,6}にいる」と表現します。

#### 変換の手順

1. **ε-閉包の計算**：ある状態からε遷移だけで到達できるすべての状態を求める
2. **開始状態の決定**：NFAの開始状態のε-閉包がDFAの開始状態
3. **遷移の計算**：各DFA状態から各文字での遷移先を計算
4. **新しい状態の発見**：未処理の状態がなくなるまで繰り返す

#### 具体例：簡単なNFAの変換

まず、簡単な例で部分集合構成法を理解しましょう。正規表現 `a(b|c)*` のNFAを考えます：

```{=latex}
\begin{center}
\begin{tikzpicture}[
  >=stealth',
  node distance=2cm,
  state/.style={circle, draw, minimum size=8mm},
  accept/.style={state, double}
]
  \node[state] (s0) {0};
  \node[state] (s1) [right of=s0] {1};
  \node[accept] (s2) [right of=s1] {2};
  \node[state] (s3) [above right of=s2] {3};
  \node[state] (s4) [below right of=s2] {4};
  
  \draw[->] ([xshift=-1cm]s0.west) -- (s0);
  \draw[->] (s0) -- node[above] {$a$} (s1);
  \draw[->] (s1) -- node[above] {$\varepsilon$} (s2);
  \draw[->] (s2) -- node[above left] {$\varepsilon$} (s3);
  \draw[->] (s2) -- node[below left] {$\varepsilon$} (s4);
  \draw[->] (s3) -- node[above right] {$b$} (s2);
  \draw[->] (s4) -- node[below right] {$c$} (s2);
\end{tikzpicture}
\end{center}
```

**ステップ1：ε-閉包を計算**

各状態のε-閉包（ε遷移だけで到達できる状態の集合）：
- ε-closure(0) = {0}
- ε-closure(1) = {1, 2, 3, 4}（1からε遷移で2へ、2からε遷移で3,4へ）
- ε-closure(2) = {2, 3, 4}
- ε-closure(3) = {3}
- ε-closure(4) = {4}

**ステップ2：DFAの構築**

開始状態：{0}

遷移表を作成：

| DFA状態 | a | b | c |
|---------|---|---|---|
| {0} | {1,2,3,4} | ∅ | ∅ |
| {1,2,3,4} | ∅ | {2,3,4} | {2,3,4} |
| {2,3,4} | ∅ | {2,3,4} | {2,3,4} |
| ∅ | ∅ | ∅ | ∅ |

結果のDFA：

```{=latex}
\begin{center}
\begin{tikzpicture}[
  >=stealth',
  node distance=3.5cm,
  state/.style={circle, draw, minimum size=12mm},
  accept/.style={state, double}
]
  \node[state] (s0) {\{0\}};
  \node[accept] (s1234) [right of=s0] {\{1,2,3,4\}};
  \node[accept] (s234) [right of=s1234] {\{2,3,4\}};
  
  \draw[->] ([xshift=-1cm]s0.west) -- (s0);
  \draw[->] (s0) -- node[above] {$a$} (s1234);
  \draw[->] (s1234) to[bend left=20] node[above] {$b,c$} (s234);
  \draw[->] (s234) edge[loop right] node[right] {$b,c$} ();
\end{tikzpicture}
\end{center}
```

#### 複雑な例：`(a|b)*abb` の変換

では、前述の `(a|b)*abb` のNFAをDFAに変換してみましょう。

**ステップ1：NFAの状態に番号を付け直す**

分かりやすくするため、状態に0から8までの番号を付けます。

**ステップ2：ε-閉包の計算**

開始状態0のε-閉包：{0, 1, 2, 5}（ε遷移で到達可能なすべての状態）

**ステップ3：遷移表の構築**

| DFA状態 | a | b |
|---------|---|---|
| A={0,1,2,5} | B={0,1,2,3,5,6} | C={0,1,2,4,5} |
| B={0,1,2,3,5,6} | B={0,1,2,3,5,6} | D={0,1,2,4,5,7} |
| C={0,1,2,4,5} | B={0,1,2,3,5,6} | C={0,1,2,4,5} |
| D={0,1,2,4,5,7} | B={0,1,2,3,5,6} | E={0,1,2,4,5,8} |
| E={0,1,2,4,5,8} | B={0,1,2,3,5,6} | C={0,1,2,4,5} |

ここで、状態8を含む集合Eが受理状態となります。

#### 同じ正規表現のDFA（簡略化後）

実際には、到達不可能な状態を除去し、状態名を簡略化すると：

```{=latex}
\begin{center}
\begin{tikzpicture}[
  >=stealth',
  node distance=3cm,
  state/.style={circle, draw, minimum size=12mm},
  accept/.style={state, double}
]
  % 状態の定義
  \node[state] (s0) {\{0\}};
  \node[state] (s06) [right of=s0] {\{0,6\}};
  \node[state] (s07) [right of=s06] {\{0,7\}};
  \node[accept] (s08) [right of=s07] {\{0,8\}};
  
  % 遷移の定義
  \draw[->] (s0) -- node[above] {$a$} (s06);
  \draw[->] (s0) edge[loop below] node[below] {$b$} ();
  
  \draw[->] (s06) -- node[above] {$b$} (s07);
  \draw[->] (s06) edge[loop below] node[below] {$a$} ();
  
  \draw[->] (s07) -- node[above] {$b$} (s08);
  \draw[->] (s07) to[bend left=30] node[above] {$a$} (s06);
  \draw[->] (s07) to[bend right=50] node[below] {$b$} (s0);
  
  \draw[->] (s08) to[bend left=40] node[above] {$a$} (s06);
  \draw[->] (s08) to[bend right=60] node[below] {$b$} (s0);
  
  % 開始状態の矢印
  \draw[->] ([xshift=-1cm]s0.west) -- (s0);
\end{tikzpicture}
\end{center}
```

このDFAは、「aまたはbを任意回繰り返した後、abbで終わる」文字列を正確に認識します。

状態3と4が統合され、より簡潔なDFAになりました。

#### なぜ括弧の対応は無理なのか

さて、正規表現は結局のところDFAに変換できることがわかりました。では、なぜオートマトン（正規表現）では括弧の対応がチェックできないのでしょうか？

括弧の対応を確認するには、以下のような処理が必要です：
- `(`を読んだら、「今までに読んだ開き括弧の数」を1増やす
- `)`を読んだら、「対応する開き括弧があるか」確認して、1減らす

ここで問題になるのは、括弧は何重にでもネスト（入れ子）できるということです。たとえば：
- `(())`：2重
- `((()))`：3重  
- `(((())))`：4重
- ...無限に続く

オートマトンは「有限個の状態」しか持てないので、「無限に増える可能性がある括弧の数」を記憶できません。これが正規表現の根本的な限界です。

### 言語の階層：正規表現 < 文脈自由文法 < ...

実は、表現できる言語の能力には階層があります。

**正規言語（RL: Regular Language）**
- 正規表現で表現できる言語の集合
- 例：電話番号、メールアドレス、識別子

**文脈自由言語（CFL: Context-Free Language）**  
- 文脈自由文法で表現できる言語の集合
- 例：プログラミング言語の構文、JSON、XML
- 正規言語をすべて含む（RL ⊂ CFL）

つまり、文脈自由文法は正規表現の上位互換です。正規表現でできることはすべて文脈自由文法でもでき、さらに括弧の対応のような複雑な構造も扱えます。

### 実用上の意味

この違いは実用上極めて重要です：

**正規表現で十分な例：**
- URLの検証
- 電話番号のフォーマットチェック  
- 単純なトークンの切り出し

**文脈自由文法が必要な例：**
- プログラミング言語の構文解析
- JSONやXMLのパース
- 数式の評価（括弧を含む）

だからこそ、構文解析器を作る時には正規表現だけでなく、文脈自由文法の理解が必要になるのです。

### さらに上の階層

実は言語の階層はさらに続きます。ここでは簡単に紹介します：

**文脈依存言語（CSL: Context-Sensitive Language）**
- 例：`a^n b^n c^n`（aがn個、bがn個、cがn個ずつが同じ数だけ並ぶ）
- より複雑な制約を表現できます

**帰納的可算言語（Recursively Enumerable Language）**
- コンピュータで計算できるすべてのもの
- JavaやPythonなどのプログラミング言語の計算能力はこのレベル

階層を図にすると：

```{=latex}
\begin{center}
\begin{tikzpicture}
  % 最外側の楕円 (CSL)
  \draw[fill=blue!10,draw=blue!60,thick] (0,0) ellipse (4.5cm and 3cm);
  \node at (3.5,0) {\textcolor{blue!60}{\large CSL}};
  
  % 中間の楕円 (CFL)
  \draw[fill=green!10,draw=green!60,thick] (0,0) ellipse (3.25cm and 2.125cm);
  \node at (2.5,-0.5) {\textcolor{green!60}{\large CFL}};
  
  % 最内側の楕円 (RL)
  \draw[fill=orange!10,draw=orange!60,thick] (0,0) ellipse (2cm and 1.25cm);
  \node at (0,0) {\textcolor{orange!60}{\large RL}};
\end{tikzpicture}
\end{center}
```

プログラミング言語の**構文**は文脈自由文法で記述できますが、プログラミング言語自体の**計算能力**はチューリング完全（最上位）です。この違いを理解することが重要です。

## 文法から文字列を作る：導出の仕組み

### 生成規則の意味

文脈自由文法は「生成規則」の集まりでした。では、この「生成」とは何でしょうか？

Dyck言語の文法をもう一度見てみましょう：

```
D → P
P → ( P ) P
P → ε
```

これらの規則は「置き換えルール」として読むことができます：
- `D → P`：「Dを見たらPに置き換えてよい」
- `P → ( P ) P`：「Pを見たら( P ) Pに置き換えてよい」
- `P → ε`：「Pを見たら空文字列に置き換えてよい」

### 実際に文字列を生成してみる

`()`という文字列を生成する過程を追ってみましょう：

```
D               // 開始記号から始める
→ P             // D → P を適用
→ ( P ) P       // P → ( P ) P を適用
→ ( ε ) P       // 最初のPに P → ε を適用
→ ( ) P         // εは空文字列なので消える
→ ( ) ε         // 2番目のPに P → ε を適用  
→ ( )           // εは空文字列なので消える
```

このように、規則を順番に適用して文字列を作ることを**導出**と呼びます。

### 複数の導出方法

実は、同じ文字列を生成する方法は複数あります。たとえば、簡単な文法で考えてみましょう：

```
S → AB
A → a
B → b
```

この文法から`ab`を導出する時、どちらから先に展開するかで2通りの方法があります：

**方法1（左から展開）：**
```
S → AB → aB → ab
```

**方法2（右から展開）：**
```
S → AB → Ab → ab
```

### 最左導出と最右導出

導出方法を統一するため、2つの標準的な方法が定義されています：

**最左導出**：常に一番左の非終端記号を展開
**最右導出**：常に一番右の非終端記号を展開

より複雑な例で見てみましょう。以下の文法は「1個以上のa」の後に「1個以上のb」が続く文字列を表します：

```
S → AB
A → aA | a
B → bB | b
```

`aabb`を導出する場合：

**最左導出：**
```
S  
→ AB      (S → AB)
→ aAB     (A → aA)  
→ aaB     (A → a)
→ aabB    (B → bB)
→ aabb    (B → b)
```

**最右導出：**
```
S
→ AB      (S → AB)
→ AbB     (B → bB)
→ Abb     (B → b)  
→ aAbb    (A → aA)
→ aabb    (A → a)
```

### 構文木との関係

どちらの導出方法でも、最終的に同じ**構文木**が得られます：

```{=latex}
\begin{center}
\begin{tikzpicture}[
  level distance=1.5cm,
  level 1/.style={sibling distance=3cm},
  level 2/.style={sibling distance=1.5cm},
  every node/.style={circle, draw, minimum size=8mm}
]
  \node {S}
    child {node {A}
      child {node[circle, draw=none] {a}}
      child {node {A}
        child {node[circle, draw=none] {a}}
      }
    }
    child {node {B}
      child {node[circle, draw=none] {b}}
      child {node {B}
        child {node[circle, draw=none] {b}}
      }
    };
\end{tikzpicture}
\end{center}
```

最左導出は木を左から右へ構築し、最右導出は右から左へ構築するイメージです。

### なぜ2つの導出方法が重要か

実は、これらは構文解析の2大手法に対応しています：

- **最左導出** → **下向き構文解析**（トップダウン）
- **最右導出の逆** → **上向き構文解析**（ボトムアップ）

第3章で作ったJSONパーサーは下向き構文解析の一種でした。次章では、これらの手法についてより詳しく学んでいきます。

## まとめ

この章では、文脈自由文法について学びました。最初は難しく感じたかもしれませんが、実は私たちが普段書いているプログラムと深く関わっている概念です。

### 学んだこと

1. **文脈自由文法の基礎**
   - Javaのif文やJSONの構造など、プログラミングの「入れ子構造」は文脈自由文法で表現される
   - BNFから文脈自由文法への変換は記法の違いに過ぎない
   - 生成規則、非終端記号、終端記号という基本要素で構成される

2. **言語を集合として理解する**
   - プログラミング言語は「正しいプログラムの集合」として定義できる
   - 集合論の記法を使って言語間の関係を厳密に議論できる
   - 後方互換性なども集合の包含関係として表現可能

3. **言語の階層**
   - 正規表現（正規言語）< 文脈自由文法（文脈自由言語）< ...
   - 正規表現では括弧の対応をチェックできない
   - プログラミング言語の構文解析には文脈自由文法が必要

4. **導出の仕組み**
   - 生成規則を適用して文字列を生成する過程が導出
   - 最左導出と最右導出という2つの標準的な方法がある
   - これらは下向き/上向き構文解析に対応する

### なぜこれが重要か

文脈自由文法の理解は、以下の場面で役立ちます：

- **構文解析器の実装**：第5章以降で学ぶ様々な構文解析アルゴリズムの基礎
- **言語設計**：新しいDSLやプログラミング言語を設計する際の指針
- **エラーメッセージの理解**：コンパイラのエラーメッセージがなぜそう言っているかの理解
- **ツールの選択**：正規表現で十分か、パーサーが必要かの判断

次章では、この文脈自由文法を基に、実際の構文解析アルゴリズムについて詳しく見ていきます。
