# 4. 構文解析アルゴリズム古今東西

　これまで、第2章でJSONを例にしてPEGによる構文解析器と、単純な字句解析器を用いた構文解析器を実装しました。また、第3章でプログラミング言語の構文解析を説明するのに必要な文脈自由文法の概念を紹介しました。そして、ここまで来たようやく準備が整ったので、いよいよ本書の本丸である構文解析アルゴリズムの話が出来ます。

　と言われても、戸惑う読者の方が多いかもしれません。なにせ、これまで「構文解析アルゴリズム」について具体的な話はまったくなかったのでしたから。しかし、皆さんは既に、第2章で**二つ**の構文解析アルゴリズムを使ってJSONの構文解析器を書いているのです。

　多少用語として不正確なのを承知で言うなら、第2章で最初に実装したのは、バックトラックあり再帰下降構文解析器であり、後で実装したのは、LL(1)（っぽい）再帰下降構文解析器と言えます。この、「再帰下降」という言葉が見慣れないものなので、はてなと思われるかもしれませんが、その疑問は一端脇においておいて、第2章での実装が理解出来たなら、皆さんは既に直感的には構文解析アルゴリズムを理解していることになります。

　この章では、2021年8月現在までに発表された主要な（いくつかは筆者の独断と偏見が入っています）構文解析アルゴリズムについて解説していきます。実用的には、紹介する構文解析アルゴリズムのほとんどについて、その構文解析アルゴリズムを使った構文解析器を生成してくれる**構文解析器生成系**が存在するからです。たとえば、おそらく最もメジャーな構文解析器生成系は、`LALR(1)`アルゴリズムを用いたyacc（正確には、GNUによる再実装であるbisonが現在は主流）でしょう。yaccに似た構文解析器生成系はC向けのyaccの他に、Ruby向けのracc、Java向けのJay、OCaml向けのocamlyaccなど数多くのバリエーションがあります。

　他には、`LL(*)`アルゴリズムを用いたANTLRや`LL(k)`アルゴリズムを用いたJavaCCもよく使われています。構文解析器生成系では昔は圧倒的にyaccがメジャーでしたが（個人の感想です）、最近は`LL(k)`アルゴリズムやその拡張もよく見るようになってきました。また、2002年にBryan Fordが発表したPackrat Parsing（正確には、それを形式化したPEG）を用いた構文解析生成系も数多く登場しています。とりわけ、PEGは構文解析器生成系を作るのがとても簡単なこともあって、色々な言語向けの構文解析器生成系が多数公開されています。かくいう筆者も、大学院生時代にPEGおよびPackrat Parsingの研究をしており、その課程で実験用の構文解析器生成系を作ったものでした。

　あまり小難しいことばかり言うのは趣味ではないので、早速、構文解析アルゴリズムの世界を覗いて見ましょう！　

## 4.1 トップダウン構文解析とボトムアップ構文解析

　と言ったばかりなのに大変恐縮なのですが、具体的な構文解析アルゴリズムの解説に入る前に、構文解析アルゴリズムは大別して、

- 上から下へ（トップダウン）
- 下から上へ（ボトムアップ）

　の二つのアプローチがあることを理解しておきましょう。といっても、難しい話ではありません。

　まずはトップダウン構文解析法です。第3章で例に出てきたDyck言語の文法は以下のようなものでした。

```bnf
D = P
P = "(" P ")" | ""
```

　このBNFは、カッコが正しくネストした文字列を過不足無く表現しているわけですが、このBNFを元にして自力で構文解析器を作るにはどうすればいいか考えてみましょう。皆さんが素朴に思いつくのは以下のような実装ではないかと思います。

```java
public class Dyck {
    private final String input;
    public Dyck(String input) {
        this.input = input;
    }
    public boolean D () {
        P();
    }
    public boolean P() {
        while(hasNext()) {
            String first = peekToken();
            if(first.equals("(")) {
                nextToken();
                P();
                String end = nextToken();
                return end.equals(")");
            } else {
                return true;
            }
        }
    }
}
```

　このプログラムあるいはクラス`Dyck`はまさに`Dyck`言語を構文解析して、成功したなら`true`、そうでなければ`false`を返すものです。BNFと比較すると、

- 規則の名前と一対一になる関数が存在する
- 非終端記号への参照は規則の名前に対応する関数の**再帰呼び出し**として実現されている

のが特徴です。呼び出す規則を上、呼び出される規則を下とした時、上から下に再帰呼び出しが続いていくため再帰下降構文解析と呼ばれます。このような、「上から下に」構文解析を行っていくのがトップダウン型構文解析法の特徴です。注意しなければいけないのは、上から下へ解析を行うアルゴリズムは多数あり、その一つに再帰下降構文解析があるということです。その他のトップダウン型構文解析法については後々紹介していきますのでご安心ください。

　一方、ボトムアップ構文解析法はその逆です。といっても、こちらの方法はトップダウン型より直感的に理解しづらいかもしれません。ボトムアップ構文解析法では、まず文字列を左から右に読み込んでいき、順番にスタックにプッシュしていきます。これをシフト（shift）と呼びます。シフト動作を続けていく内に、規則の右辺の記号列とスタックトップにある記号列がマッチすれば、規則の左辺にマッチしたとして、スタックトップにある記号列を規則の左辺で置き換えます。これを還元（reduce）と呼びます。

　やや説明が抽象的過ぎるかもしれません。たとえば、先程と同様に下記の文法があったとします。ただし、入力の先頭と末尾を表すために `$` を使うものとします。

```bnf
D = $ P $
P = "()"
P = "(" P ")"
```

　この文法に対して`(())`という文字列がマッチするかを判定する問題を考えてみましょう。ボトムアップ解析では、まず最初の「1文字」を右から左にシフトします。ちょうど以下のようなイメージです。

```bnf
"("
```

　このブロックとルールPの右辺はマッチしないので、もう1文字をシフトしてみます。

```bnf
"("   "("
```

　まだマッチしませんね。さらにもう1文字シフトしてみます。すると、次のようになります。

```bnf
"("   "("   ")"
```

　`()`はPにマッチするので以下のように還元が行われます。

```bnf
"("    P
     /   \
   "("   ")"
```


　さらに1文字シフトすると以下のようになります。

```bnf
"("    P   ")"
     /   \
   "("   ")"
```

　`(P)`はPにマッチするので還元が行われます。

```bnf
        P
      / | \
     /  |  \
    /   |   \
   /    |    \
"("     P    ")"
      /   \
    "("   ")"
```

　既に全ての文字列がシフトされており、`D = $ P $`にマッチするため、PはDに還元されます。最終的に以下となります。

```bnf
         D
         |
         P
       / | \
      /  |  \
     /   |   \
    /    |    \
   /     |     \
"("      P      ")"
      /  |  \
    "("  P  ")"
         |
        ""
```

めでたく`"(())"`がDとマッチすることがわかりました。ボトムアップアップ構文解析法では基本的に、以下の動作を繰り返していきます。

1. 文字を入力文字列の内最も左から（leftmost）取り出してスタック上にプッシュする（シフト）
2. 規則を参照して、スタックの内最も上部（右）にマッチしたら、左辺の記号に置き換える（還元）


このような動作をJavaコードで表現することを考えてみます。まず必要なのは、規則を表すクラス`Rule`です。問題を単純化するために、

1. 規則の名前（左辺）は1文字
2. 規則の右辺は規則名または文字のどちらかからなる並びである

とします。このようなクラス`Rule`は以下のように表現することができます。

```java
public record Rule(char lhs, List<Elements.Element> rhs) {
    private static List<Elements.Element> toElements(String string) {
        List<Elements.Element> elements = new ArrayList<>();
        for(int i = 0; i < string.length(); i++) {
            elements.add(new Elements.Terminal(string.charAt(i)));
        }
        return elements;
    }
    public Rule(char lhs, String rhs) {
        this(lhs, toElements(rhs));
    }
    public boolean matches(String sequence) {
        return matches(toElements(sequence));
    }
    public boolean matches(List<Elements.Element> sequence) {
        for(int i = 1; i <= rhs.size(); i++) {
            var a = rhs.get(rhs.size() - i);
            if(sequence.size() - i < 0) return false;
            var b = sequence.get(sequence.size() - i);
            if(!a.equals(b)) return false;
        }
        return true;
    }
}
```

Java 17のレコード機能を使って、クラス`Rule`が左辺（`lhs`)と右辺（`rhs`）持っていることを表現しています。また、クラス`Elements.Element`は規則の右辺に出現できる要素を表す型で次のように表現されます。

```java
public class Elements {
    public sealed interface Element permits NonTerminal, Terminal {}
    public record NonTerminal(char name) implements Element {}
    public record Terminal(char value) implements Element {}
}
```

非終端記号（`NonTerminal`）は規則の名前を表す文字`name`を引数に取ります。また、文字そのものを表現する終端記号（`Terminal`）は文字そのものを表現する文字`value`を引数に取ります。

たとえば、`new Elements.NonTerminal('A')`は非終端記号`A`を表しますし、`new Elements.Terminal('a')`は終端記号`'a'`を表します。ここまでは特に難しいところはないと言えるでしょう。

これらのクラスを使ってシフトと還元を行うクラス`Dyck`は次のように定義することができます。

```java
public class Dyck {
    private String input;
    private int position;
    private final List<Rule> rules;

    private List<Elements.Element> symbols;

    public Dyck() {
        this.rules = List.of(
                new Rule('D', List.of(new Terminal('$'), new NonTerminal('P'), new Terminal('$'))),
                new Rule('P', "()"),
                new Rule('P', List.of(new Terminal('('), new NonTerminal('P'), new Terminal(')')))
        );
    }

    private Optional<Rule> findRule() {
        return rules.stream().filter(r -> r.matches(symbols)).findFirst();
    }

    private void shift() {
        symbols.add(new Elements.Terminal(input.charAt(position)));
        position++;
    }

    private void reduce(Rule rule) {
        for(int i = 1; i <= rule.rhs().size(); i++) {
            symbols.remove(symbols.size() - 1);
        }
        symbols.add(new Elements.NonTerminal(rule.lhs()));
    }

    public boolean parse(String source) {
        this.input = "$" + source + "$";
        this.position = 0;
        this.symbols = new ArrayList<>();

        while(true) {
            var optRule = findRule();
            if(optRule.isPresent()) {
                reduce(optRule.get());
                if(symbols.size() == 1) return true;
            } else {
                if(position >= input.length()) return false;
                shift();
            }
        }
    }
}
```
ボトムアップ型構文解析のJavaコード

メソッド`shift()`がシフト動作を`reduce()`が還元動作を表しています。`shift()`は以下のように、単に入力記号列`input`から一文字読み込んで`symbols`に追加しています。

```java
    private void reduce(Rule rule) {
        for(int i = 1; i <= rule.rhs().size(); i++) {
            symbols.remove(symbols.size() - 1);
        }
        symbols.add(new Elements.NonTerminal(rule.lhs()));
    }
```

一方、`reduce()`は`rule`を引数にとり、`rule`の右辺の長さ分を`symbols`の末尾から削除した後に左辺の非終端記号を追加しています。

最後に`parse()`では入力の末尾位置に到達するまで、シフトと還元動作を繰り返します。クラス`Dyck`の行数は50行程度ですが、最も単純なボトムアップ構文解析法はこのくらい単純に書くことができるのです。

もちろんこれはあくまで基本であり、ボトムアップ型の構文解析アルゴリズムも実用上はここまで単純ではなく、もう少し改良を加えたLR法やLALR法が使われています。構文解析器生成系の中で最も著名であると思われるyacc(bison)が採用しているLALR(1)もボトムアップ型の構文解析アルゴリズムの一つです。

トップダウン構文解析法とボトムアップ構文解析法はそれぞれ得手不得手があります。トップダウン型は規則と関数を対応付けるのが容易なので手書きの構文解析器を書くのに向いています。また、関数の引数として現在の情報を渡して、引数に応じて構文解析の結果を変化させることが比較的容易です。これは複雑で文脈に依存した文法を持った言語を解析するときに有利な性質です。しかし、トップダウン型は左再帰という形の文法をそのまま処理できないという欠点があります。

たとえば、以下のBNFは、ボトムアップ型だと`a*`に相当する言語を普通に解析出来ますが、工夫なしにトップダウン型で実装すると無限再帰に陥ってスタックオーバーフローします。

```
A = A "a"
A = "";
```

このような問題をトップダウン型で解決する方法も存在します。端的に言うと「再帰をループに置き換える」アプローチです。たとえば、上の文法を以下のように書き換えればトップダウン型でも問題なく解析できるようになります。このような処理を左再帰の除去と呼びます。

```
A = "a" A
  | "";
```

では、左再帰を問題なく処理できるボトムアップ型が一方的に有利なのかというとそう単純ではないのが面白いところです。ボトムアップ型は一般的に構文解析エラーが読み取りづらくなるという欠点があります。トップダウン型が得意とする、前後の文脈に応じて構文解析結果を切り替えるのは比較的苦手です。

さて、トップダウン型とボトムアップ型の概要を説明したところで、からは具体的なアルゴリズムの説明に移ります。

## 4.2 LL(1) - 代表的なトップダウン構文解析アルゴリズム

トップダウン型構文解析アルゴリズムの中でおそらくもっとも古典的で、よく知られているのは`LL(1)`構文解析アルゴリズムです。字面が一見小難しく見えますよね。しかし、`LL(1)`のアイデアは意外に簡単なものです。

たとえば、以下のようなJava言語のif文があったとします。

```java
if(age < 18) {
    System.out.println("18歳未満です");
} else {
    System.out.println("18歳以上です");
}
```

非常に簡単です。しかし、我々はどのようにしてこれを見て「if文がある」と認識するのでしょうか。もちろん「人それぞれ」なのですが、最初に`if`が現れたからif文だと考える人も多いのではないかと思います。

`LL(1)`構文解析アルゴリズムはまさにこのイメージを元にした手法です。プログラムをトークン列に区切った後に、「最初の1トークン」を見て、「あ、これはif文だ」とか「あ、これはwhile文だ」とか認識するようなものですね。

イメージとしては簡単なのですが、アルゴリズムとして実行可能なようにするためには考えなければいけない論点がいくつかあります。以下では、`LL(1)`を実装するに当たって考えなければいけない課題について論じます。

### 課題1 - ある構文の最初のトークンが複数種類ある場合

先程の例ではある構文、たとえばif文が始まるには`if`というキーワードが必須で、それ以外の方法でif文が始まることはありえませんでした。しかし、たとえば、算術式を考えてみると、問題はそう単純ではないことがわかります。少し考えただけでも、以下のような例が思い浮かびます。

- `(`で算術式が始まる場合
- `-`で算術式が始まる場合
- `+`で算術式が始まる場合
- 整数リテラル（`<integer_literal>`）で算術式が始まる場合
- 浮動小数点数リテラル（`<floating_point_literal>`）で算術式が始まる場合

つまり、次のトークンが算術式の始まりである事を確定するためには、トークンの集合という概念が必要になります。たとえば、算術式の始まりは

```
{"(", "-", "+", <integer_literal>, <floating_point_literal>, ...}
```

のようなトークンの集合であると考える事が出来ます。このような、ある構文が始まるかを決定するために必要なトークンの集合のことを**FIRST集合**と呼びます。

### 課題2 - 省略可能な要素の扱い

if文の例は、次の1トークンを見ればどんな構文かわかる例でした。しかし、if文にelseが出てこない場合に、if文からif-else文か正確に決定するにはどうすればいいのでしょうか？たとえば、以下の文は正当です。

```java
if(age < 18) {
    System.out.println("18歳未満です");
};
if(age >= 18) {
    System.out.println("18歳未満です");
}
```

他方で以下の文も正当です。

```java
if(age < 18) {
    System.out.println("18歳未満です");
}
if(age >= 18) {
    System.out.println("18歳未満です");
}
```

最初のif文の後に、

- 前者は`;`が出現する
- 後者は`if`が出現する

という違いがあるわけですが、どちらの場合にしても、それらが出現した時点で最初のif文が終わるのは明らかでしょう。以下の場合、`System`が出現した時点で最初のif文が終了したことはわかります。

```java
if(age < 18) {
    System.out.println("18歳未満です");
}
System.out.println("終了します");
```

まとめると、

- 直後に`else`が出現すればif-else文である
- それ以外で、かつ構文エラーにならないあらゆるトークンが出てきた場合、if文である

ということが出来そうです。しかし「あらゆるトークン」と言われても漠然としていて、アルゴリズムとしては不完全です。アルゴリズムとしては、以下のようになっていなければ困ります。

- 直後に`else`が出現すればif-else文である
- トークン `{";", <identifier>, "if", ...}`が出てきた場合、if文である

`LL(1)`をきちんと考えようとすると、「省略可能なトークンの次のトークンの集合」について考える必要があるわけです。このような「～の次のトークンの集合」も、ある構文がどう始まるかを決定するのに必要になります。これを**FOLLOW集合**と呼びます。

先の項で出てきた**FIRST集合**と**FOLLOW集合**は`LL(1)`にとって重要な概念です。次の項以降では、この**FIRST集合**と**FOLLOW集合**の概念についてより厳密に説明します。

### FIRST集合とFOLLOW集合の計算

`LL(1)`をアルゴリズムとしてきちんと定義しようとするなら、この二つの概念が必要であることはわかってもらえたと思います。しかし、この二つですが、一体プログラム上でどう計算すれば良いのでしょうか？この問いに答える事が`LL(1)`アルゴリズムをきちんと理解する事であり、逆にきちんと理解出来れば、自力で`LL(1)`アルゴリズムによるパーザを記述出来るようになるでしょう。

まずはFIRST集合について考えてみます。(WIP)

次にFOLLOW集合について考えてみます。(WIP)

## LL(1)の問題点と限界

`LL(1)`は古典的でありかつそれなりに実用的でもありますが、アルゴリズムがシンプルである故の問題点や限界も存在します。この後では`LL(1)`の抱える問題点について述べます。

### 問題点1 - 最初の1トークンで構文要素を決められないことがある

先の節では明らかに最初の1トークンで「これはif文」とか「これはwhile文」とか決められる場合のみを対象にしてきました。しかし、現実にはそれだけではどうにもならない場合があります。

たとえば、Java 7で導入されたダイヤモンド演算子について考えてみます。以下のようにして、ジェネリクスの型パラメータ指定を省略出来る機能です。

```java
List<Person> people;
person = new ArrayList<>();
```

2行目の右辺を仮にBNFにすると以下のようになるでしょうか。

```bnf
new_object = new id ("<" ... ">" /* 普通のnew演算子 */ | "<" ">" /* ダイヤモンド演算子 */) params
```

ここで、右辺の`new ArrayList<>`について注目してみましょう。`<`はJava言語ではそれだけで一つのトークンですが、`ArrayList`の直後にある`<`を見ただけではダイヤモンド演算子を使っていることはわかりません。これは次の例をみるとわかります。

``java
List<Person> people;
person = new ArrayList<Person>();
```

上の例を見ればわかる通り、`ArrayList<`を読んだ時点では、`new ArrayList<>()`の可能性も`new ArrayList<Person>()`の可能性のどっちも考えられるのです。

この問題は、`<`が出現した時点では、ダイヤモンド演算子かどうかは決めずに、次のトークンが`>`ならダイヤモンド演算子、そうでないなら通常のインスタンス生成とする回避方法が使えます。BNFにすると以下のようになるでしょうか。

```bnf
new_object = "new" id type_params params
type_params = "<" type_params_suffix
type_params_suffix  = ">" | id ("," id)* ">" // ">"が来たらダイヤモンド演算子、そうでないなら通常のインスタンス生成 

このような、「先頭の1トークン」をくくりだす方法をleft factoringと呼びます。経験上、`LL(1)`の制限の多くはleft factoringによって回避することが出来ます。

### 問題点2 - left factoringで変形しても次の構文要素を決められない場合

問題点1は、最初の1トークンで次の構文要素を決められないというものでした。前述したようにこの点についてはleft factoringによって容易に解決する事が可能ですが、それでも次の構文要素を決められない場合もあります。例えば、次のような変数宣言を考えます。

```java
hogep.foop.barp.Piyo piyo;
```

この時、先頭にあるパッケージ名の部分はいくらでも長くなる可能性があります。さらに、型宣言を読んでいる時点では、実は以下のようにメソッド呼び出しであったという可能性は捨てきれません。

```java
hogep.foop.barp.Piyo()
```

これはleft factoringだけでは簡単に解決出来ません（解決が不可能とまでは証明できませんが困難です）。先頭の共通部分をくくりだそうにも、共通部分の長さが不明確なのですから。この問題は割と本質的なものなので、実用上は構文解析の後か前に処理を追加して解決することが多いです。たとえばドット（`.`）で繋がった名前の連なりを`fqn`という規則でくくり出すという手段を使うことが出来ます。この手法には特に名前はついていませんが、構文解析の先送りとでも呼ぶのがいいかもしれません。

```java
fqn = id ("." id)*
```

本質的にはこのようなパターンは文脈依存言語を扱っているという事ができ、CFGでもPEGでも取り扱いがやや難しいものです。さしあたって、一見構文解析の問題に見える事は必ずしも構文解析の段階で解決出来るわけではないということを認識しておいてください。

## 4.3 LL(k) - LL(1)の拡張

前節で紹介したLL(1)アルゴリズムには次のような欠点がありました。

1. 1トークン先読みでは出現する構文要素を決定できない場合がある
2. left factoringを行ってもなお1トークン先読みでは出現する構文要素を決定できない場合がある

この二つの欠点の内、前者を解決するのがLL(k)アルゴリズムです。kは1以上の整数で、具体的な数値を決定することでアルゴリズムが決まります。

たとえば、2トークン先読みするのはLL(2)、3トークン先読みするのはLL(3)といった具合です。さて、とにもかくにも具体例です。わかりやすいように、LL(1)アルゴリズムでは解析できないがLL(2)アルゴリズムでは解析できる例を考えてみます。もちろん、そのような文法はほぼ常にleft factoringすることでLL(1)で解析可能なように変形可能ですが、プログラマがそのような作業をするのは手間ですから、あらかじめ構文解析器が適切に先読みしてくれればそれに越したことはないでしょう。


少し恣意的な例ですが、CやJava風味の型宣言を持った言語を考えてみます。ただし、議論しやすいようにするために、型名は必ず1トークンになるものとします。また、CやJavaのように式文があるとします。そのような言語で、型宣言`user_type x;`と式文`foo;`を区別するにはどうすれば良いでしょうか？

まず、明らかにLL(1)では二つを区別することができません。なぜなら、最初のトークンが`user_type`だったとして果たしてこれが型名なのか変数名なのかを区別することは出来ないからです。もちろん、型名のテーブルを持っていれば可能ですがそれでは文脈自由言語の範囲を逸脱してしまいます。

ここで、LL(1)ではなくLL(2)アルゴリズムを使うとしてみます。すると、`user_type x`という二つのトークンが来た場合は明らかに型宣言であることがわかありますし、`foo ;`という二つのトークンが来た場合は式文であることがわかります。

つまり、先読みトークン数を1から2に増やすことでより広い範囲の文法を認識できるようになったわけです。

さらに、kは任意の整数で良いのですから、kを3に増やしても4に増やしてもいいわけです。後述するようにkの数を増やし過ぎることは消費する記憶領域や実行性能面での問題があるのですが、それをひとまずおいておけばkを増やすことでより広い範囲の文法を認識できるようになっていく、と言えるわけです。

## 4.4 LL(k)の限界

LL(k)ではkの数を増やしていくことで表現能力を拡張できることがわかったわけですが、ここで一つの疑問が出てきます。LL(k)のkをいくらでも増やしていくことによって、任意の文脈自由言語を認識できるように拡張可能なのだろうか、というものです。この疑問に答えるためには複雑な議論が必要ですが、端的に答えだけをいうとNOです。文脈自由言語であるがLL(k)では認識できない言語は必ず存在します。

たとえば、a^i b^j （i >= j >= 1）、つまりaがi回あらわれてその後にbがj回（i回以上）あらわれるような言語はLL(k)言語ではありません（後述しますが、LR(1)言語ではあります）。

## 4.5 Precedence parsing - ボトムアップ構文解析アルゴリズムの基本形

ここまでLL(1)からはじまるトップダウン型構文解析アルゴリズムについて解説してきました。トップダウン型構文解析アルゴリズムは人間の直感に合致してることやエラーメッセージの出しやすさなどの利点があるのですが、素朴なLL(1)やそれを拡張したLL(k)でも表現力に限界があります。この点ではボトムアップ型の典型であるLR parsingやその派生系のアルゴリズムに一日の長があります。ただし、LR parsingはやや複雑です。その前にボトムアップ型の中でもっとも古典的でLR parsingにもつながるPrecedence parsing（演算子順位法）について学びましょう。

演算子順位法の基本的なアイデアは、数式の内のいわゆる演算子に着目して、優先順位をきちんと処理できるように`()`を挿入するというものです。

まず、元になる数式の文法を定義しましょう。算術式の文法を定義する方法はいくつもありますが、典型的には以下のようになります。

```
S = E 
E = ( E + T )
E = T
T = ( T * F )
T = F
F = n
```

ここで、nは任意の一桁の整数を表すものとします。

たとえば、以下の式があったとします。

```
4 + 5 * 6 + 8
```

この式は算術式としては以下のように解析されるべきです。

```
(4 + (5 * 6) + 8)
```

私達が適切に数式に括弧をつけることが出来るのは、`*`の方が`+`より優先順位が高いことを知っているからですが、演算子の優先順位という概念を組み込むことで、単純なボトムアップ型の問題であった、シフトすべきか還元すべきかが事前に判定できないという問題が解決されます。これが演算子順位法の基本的なアイデアです。さて、では早速演算子順位法を用いて数式を解析してみましょう。

TBD: コード例

## 4.5 LR Parsing - ボトムアップ構文解析アルゴリズムの基本

ここまでLL(1)からはじまるトップダウン型構文解析アルゴリズムについて解説してきました。トップダウン型構文解析アルゴリズムは人間の直感に合致してることやエラーメッセージの出しやすさなどの利点があるのですが、悲しいことに素朴なLL(k)アルゴリズムでは表現力に限界があります。

そのようなこともあって、構文解析の世界ではより表現力の高いLR(1)アルゴリズムあるいはその変種が広く使われています。ただし、そのような認識が支配的だったのは2000年代はじめ頃までであって、現代ではLL(k)をより拡張したLL(*)やALL(*)を実装したANTLRも広く使われていますし、トップダウン型のアルゴリズムという意味では「お仲間」とも言えるPEGもさまざまな場面で使われるようになってきています。ともあれ、LR(1)アルゴリズムの変種が構文解析の世界で広く使われているのも間違いありません。

　たとえば、この本をお読みの読者ならyacc(その互換製品であるbison。以後yaccで統一します)という名前を一度は聞いたことがあるかもしれません。yaccはもっとも広く使われている構文解析器生成系であり、LALR(1)アルゴリズムを採用しています。yaccは[Rubyの構文解析器](https://github.com/ruby/ruby/blob/db6b23c76cbc7888cd9a9912790c2068703afdd0/parse.y)を作るためなど、言語処理系の構文解析器を生成するために使われています。

　LR parsingはTexで有名なDonald Knuthによって提案されました。LR parsingの基本的なアイデアは次のようなものです。

TBD

## 4.6 LALR(1) - 現実的に取り扱いやすいボトムアップ構文解析アルゴリズム

　「素の」LR parsingは非常に幅広い範囲の文法を取り扱うことができますが、構文解析表が巨大化してしまうなどの問題があります（2020年代に入った現在では必ずしも当てはまらないかもしれません）。多くの構文解析生成系ではLR parsingの変種であるLALR法、特に先読み数が1であるLALR(1) parsingが利用されています。

TBD

## 4.7 - LR(k)の限界

　LR(1) parsingで受理可能な言語とLR(k) parsingで受理可能な言語は等しいことが知られています。つまり、原理的にはLR(1) parsingがあればLR(k)言語を受理可能であり、LR(k)言語はDCFL（決定的文脈自由言語）とも等しいです。これはLR(k)法が非常に強力なアルゴリズムであることを示唆していますが、LR(k)言語でも表現できない文脈自由言語が存在しています。

TBD（コメント：書いていて、ここはちょっと難しいなと実感。というのは、DCFLでない言語で文脈自由というのは自然言語処理みたいな曖昧性を許す文脈であれば意味があっても、そうでない文脈であれば大差ないとも言えるので）

## 4.8 - Parsing Expression Grammar(PEG) - 構文解析アルゴリズムのニューカマー

　2000年代に入るまで、構文解析手法の主流はLR法の変種であり、つまるところボトムアップ構文解析アルゴリズムでした。その理由の一つに、先読みを前提とする限り、従来のLL法はLR法より表現力が弱いという弱点がありました。トップダウン型でもバックトラックを用いればより幅広い言語を表現できることは比較的昔から知られていましたが、バックトラックによって解析時間が最悪で指数関数時間になるため、コンパイラの教科書として採用されることが多い、いわゆるドラゴンブックでも現実的ではないといった記述がありました（記憶に頼ったもので、出典が曖昧。現在のドラゴンブックにも該当記述があるかは要確認）。しかし、2004年に提案されたParsing Expression Grammar（PEG）はそのような状況を変えました（Ford:2004）。

　PEGはおおざっぱに言ってしまえば、無制限な先読みとバックトラックを許すトップダウン型の構文解析手法の一つです。DCFL＋一部の文脈依存言語を取り扱うことができますし、その上、Packrat Parsingという手法によって線形時間で構文解析を行うことが保証されているというとても良い性質を持っています。さらに、実質的にLL法やLR法で必須であった字句解析器と構文解析器の分離が要らず、アルゴリズムも非常にシンプルであるため、ここ十年くらいで解析表現手法をベースとした構文解析生成系が数多く登場しました。

　他人事のように書いていますが、ほかならぬ筆者が大学院時代に専門分野として研究していたのがまさしくこのPEGでした。さらに、Python 3.9ではPEGベースの構文解析器が採用されるなど、着々と採用されるケースが増えています。

　2章で既にPEGを用いた構文解析器を自作したのを覚えているでしょうか。たとえば、配列の文法を表現した以下のPEGがあるとします。

```bnf
array = LBRACKET RBRACKET | LBRACKET {value {COMMA value}} RBRACKET ;
```

　このPEGに対応するJavaの構文解析器（メソッド）は以下のようになるのでした。

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

　という行によって、解析を始める時点でのソースコード上の位置を保存しておき、もし解析に失敗したら以下のように「巻き戻す」ところにあります。そして、「巻き戻した」位置から次の分岐を試そうとするのです。

```java
        } catch (ParseException e) {
            cursor = backup;
        }
        // LBRACKET
        parseLBracket();
        // ...
```

　なお、PEGの挙動を簡単に説明するために2章および本章では例外をスロー/キャッチするという実装にしていますが、現実にはこのような実装にするとオーバーヘッドが大きすぎるため、実用的なPEGパーザでは例外を使わないことが多いです。

　より一般化すると、PEGの挙動は以下の8つの要素を使って説明することができます。

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


```peg
e1 / e2
```

に対する`match(e1 / e2, s)`は以下のような動作を行います。

1. `match(e1, s)`を実行する
2. 1.が成功していれば、sのサフィックスを返し、成功する
3. 1.が失敗した場合、`match(e2, s)`を実行し、結果を返す

### 選択

`e1`と`e2`は共に式であるものとします。このとき、

```peg
e1 e2
```

　に対する`match(e1 e2, s)`は以下のような動作を行います。

1. `match(e1, s)`を実行する
2. 1.が成功したとき、結果を`Success(s1,s2)`とする。この時、`match(e2,s2)`を実行し、結果を返す
3. 1.が失敗した場合、その結果を返す

### 非終端記号

あるPEGの規則Nがあったとします。

```peg
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

```peg
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

```peg
&e
```
　
は`match(&e,s)`を実行するために、以下のような動作を行います。

1. `match(e,s)`を実行する
2-1. 1.が成功したとき：結果を`Success("", s)`とする
2-2. 1.が失敗した場合：結果は`Failure()`とする

肯定述語は成功したときにも「残り文字列」が変化しません。肯定述語`&e`は後述する否定述語`!!`を二重に重ねたものに等しいことが知られています。


### 否定述語

`e`は式であるものとします。このとき、

```peg
!e
```
　
は`match(!e,s)`を実行するために以下のような動作を行います。

1. `match(e,s)`を実行する
2-1. 1.が成功したとき：結果を`Failure()`とする
2-2. 1.が失敗した場合：結果は`Success("", s)`とする

否定述語も肯定述語同様、成功しても「残り文字列」が変化しません。

前述した`&e = !!e`は論理における二重否定の除去に類似するものということができます。

### PEGの操作的意味論

ここまでで、PEGを構成する8つの要素について説明してきましたが、実際のところは厳密さに欠けるものでした。より厳密に説明すると以下のようになります（Ford:04を元に改変）。先程までの説明では、`Success(s1, s2)`を使って、`s1`までは読んだことを、残り文字列が`s2`であることを表現してきました。ここではペア`(n, x)`で結果を表しており、`n`はカウンタで`x`は残り文字列または`f`（失敗を表す値）となります。

```
1. 空文字列: 
  (ε,x) ⇒ (1,ε) （全ての x ∈ V ∗ Tに対して）。
2. 終端記号(成功した場合): 
  (a,ax) ⇒ (1,a) （a ∈VT , x ∈V ∗ T である場合）。
3. 終端記号(失敗した場合):
  (a,bx) ⇒ (1, f) もし a ≠ b かつ (a,ε) ⇒ (1, f)。
4. 非終端記号:
  (A,x) ⇒ (n + 1,o) もし A ← e ∈ R かつ(e,x) ⇒ (n,o)。
5. 連接(成功した場合): 
  もし (e1,x1x2y) ⇒ (n1,x1) かつ　(e2,x2y) ⇒ (n2,x2) のとき、 (e1e2,x1x2y) ⇒ (n1 +n2 +1,x1x2)。
6. 連接(失敗した場合１): 
  もし (e1,x) ⇒ (n1, f) ならば　(e1e2,x) ⇒ (n1 + 1, f). もし　e1が失敗したならば、e1e2はe2を試すことなく失敗する。
7. 連接(失敗した場合２): 
  もし (e1,x1y) ⇒ (n1,x1) かつ　(e2,y) ⇒ (n2, f) ならば (e1e2,x1y) ⇒ (n1 + n2 + 1, f)。
8. 選択(場合１): 
  もし (e1,xy) ⇒ (n1,x) ならば (e1/e2,xy) ⇒ (n1 +1,x)。
9. 選択(場合２): 
  もし (e1,x) ⇒ (n1, f) かつ (e2,x) ⇒ (n2,o) ならば (e1/e2,x) ⇒ (n1 + n2 + 1,o)。
10. 0回以上の繰り返し (繰り返しの場合): 
  もし (e,x1x2y) ⇒ (n1,x1) かつ　(e∗,x2y) ⇒ (n2,x2) ならば (e∗,x1x2y) ⇒ (n1 + n2 +1,x1x2)。
11. 0回以上の繰り返し (停止の場合）: 
  もし (e,x) ⇒ (n1, f) ならば (e∗,x) ⇒ (n1 +1,ε)。
12. 否定述語（場合１): 
  もし (e,xy) ⇒ (n,x) ならば (!e,xy) ⇒ (n + 1, f)。
13. 否定述語（場合２): 
  もし (e,x) ⇒ (n, f) ならば (!e,x) ⇒ (n + 1,ε)。
```

## 4.9 - Packrat Parsing

素のPEGは非常に単純でいて、とても幅広い範囲の言語を取り扱うことができます。しかし、PEGには一つ大きな弱点があります。最悪の場合、解析時間が指数関数時間になってしまうことです。現実的にはそのようなケースは稀であるという指摘ありますが（論文を引用）、原理的にはそのような弱点があります。Packrat Parsingはメモ化という技法を用いることでPEGで表現される言語を線形時間で解析可能にします。

メモ化という技法自体をご存じでない読者の方も多いかもしれないので、まずメモ化について説明します。

### 4.9.1 fibメソッド

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
        if(n == 0 || n == 1) return 1L;
        else return fib(n - 1) + fib(n - 2); 
    }
    public static void main(String[] args) {
        System.out.println(fib(5)); // 120
    }
}
```

　このプログラムを実行すると、コメントにある通り120が出力されます。しかし、このfibメソッドには重大な欠点があります。それは、nが増えると計算量が指数関数的に増えてしまうことです。たとえば、上のfibメソッドを使うと`fib(30)`くらいまではすぐに計算することができます。しかし、`fib(50)`を求めようとすると皆さんのマシンではおそらく数十秒はかかるでしょう。

　フィボナッチ数を求めたいだけなのに数十秒もかかってはたまったものではありません。

### 4.9.2 fib関数のメモ化

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
        if(n == 0 || n == 1) {
            result = 1L;
        } else {
            result = fib(n - 1) + fib(n - 2);
        }
        cache.put(n, result);
        return result;
    }
    public static void main(String[] args) {
        System.out.println(fib(50)); // 20365011074
    }
}
```

　`fib(50)`の結果はコメントにある通りですが、今度は一瞬で結果がかえってきたのがわかると思います。メモ化されたfibメソッドでは同じnに対する計算は二度以上行われないので、nが増えても実行時間は線形にしか増えません。つまり、fib(50)の実行時間は概ねfib(25)の二倍であるということです。

　ただし、計算量に詳しい識者の方は「おいおい。整数同士の加算が定数時間で終わるという仮定はおかしいんじゃないかい？」なんてツッコミを入れてくださるかもしれませんが、そこを議論するとややこしくなるので整数同士の加算はたかだか定数時間で終わるということにします。

　`fib`メソッドのメモ化でポイントとなるのは、記憶領域（`cache`に使われる領域）と引き換えに最悪計算量を指数関数時間から線形時間に減らせるということです。また、メモ化する対象となる関数は一般的には副作用がないものに限定されます。というのは、メモ化というテクニックは「同じ引数を渡せば同じ値が返ってくる」ことを暗黙の前提にしているからです。

　次の項ではPEGをナイーヴに実装した`parse`関数をまずお見せして、続いてそれをメモ化したバージョン（Packrat parsing）をお見せすることにします。`fib`メソッドのメモ化と同じようにPEGによる構文解析もメモ化できることがわかるでしょう。

### 4.9.3 parseメソッド

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
$26 ==> $26 ==> Failure[rest=)]
jshell> Parser.parse("(0)");
$27 ==> Success[value=), rest=]
```
　
しかし、この構文解析器には弱点があります。`(((((((((((((((((((((((((((0)))`のようなカッコのネスト数が深いケースで急激に解析にかかる時間が増大してしまうのです。これはまさにPEGだからこそ起こる問題点だと言えます。

### 4.9.4 parseメソッドのメモ化 - Packrat Parsing

4.9.3のコードをもとに`parse`メソッドをメモ化してみましょう。コードは以下のようになります。

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

というフィールドが加わったことです。このフィールド`cache`がパーズの途中結果を保持してくれるために計算が高速化されるのです。結果として、PEGでは最悪指数関数時間かかっていたものがPackrat Parsingでは入力長に対してたかだか線形時間で解析できるようになりました。

PEGは非常に強力な能力を持っていますが、同時に線形時間で構文解析を完了できるわけで、これはとても良い性質です。そういった理由もあってか、PEGやPackrat Parsingを用いた構文解析器や構文解析器生成系はここ10年くらいで大幅に増えました。

## 4.10 - Generalized LR (GLR) Parsing

Generalized LR(GLR) parsingはTomitaらによって1991年に提案された手法です（Tomita:1991）。Generalized LRという名前の通り、非決定的で曖昧なCFGを取り扱えるようにLR parsingを拡張したアルゴリズムです。

TBD

## 4.11 - Generalized LL (GLL) Parsing

Generalized LL(GLL) parsingはScottらによって2010年に提案された手法です（Scott:2010）。Generalizd LLという名前の通りLL parsingを拡張したものですが、先行するGLR parsingの影響を受けたアルゴリズムです。

元々、LLパーサの弱点の一つに左再帰を扱えないというものがありました。左再帰というのは、

```
A ::= A a
```

という風に書けるという性質で、非終端記号Aはa,aa,aaa,....を表します。LR parsingないしそれをベースにしたTomitaのRNGLR parserは任意の文脈自由言語を取り扱えますが、これらはボトムアップ型の手法なため、文法をトップダウンで考えた方がいい場合には使いづらいです。

そのようなわけで、

- トップダウンである
- 任意の文脈自由言語を取り扱える
- 計算量が現実的である（O(n^3)）
- 左再帰を適切に取り扱える
- 非決定性を取り扱える

手法が待ち望まれていたのですが、長らくこのようなLLパーサは実現できないと思われていました（Dick:2007）。GLL parserはこれらの望ましい性質を全て実現することができたところに特徴があります。

　さて、そのGLL parserはAycockらのRIGLR parserの影響を受けています。AycockらはGLR parserを改良してRIGLR parserを開発したものですが、LL parserの拡張でありながら反対であるボトムアップ型の影響を色濃く受けている点が興味深いところです。

## 4.12 - Parsing with Derivatives (PwD)

Parsing with derivatives(PwD)はMightらによって2011年に提案された手法です（Might:2011）。

## 4.13 - 構文解析アルゴリズムの計算量と表現力の限界 

　LL parsing、LR parsing、PEG、Packrat parsing、GLR parsing、GLL parsingについてこれまで書いてきましたが、計算量的な性質についてまとめておきましょう。なお、`n`は入力文字列長を表します。

- LL(1)
  - 時間計算量：`O(n)`
  - 空間計算量：`O(N*T)`
    - `N = |S|`
      - `|S|`は開始記号列のサイズ
    - `T = |V|`
      `|V|`は終端記号の数
    - `m`は規則の呼び出しグラフの深さ
- SLR:
  - 時間計算量： `O(n)`
  - 空間計算量： `O(N * P * T)`
    - `N`は規則の右辺のサイズ
- LR(1)
  - 時間計算量：`O(n)`
  - 空間計算量：`O(N*P*T*T)`
- LALR(1):
  - 時間計算量：`O(n)`
  - 空間計算量：`O(N * P * T)`
- PEG with packrat parsing
  - 時間計算量：`O(n)`
  - 空間計算量：`O(n * s)`
    - `s `は規則の数
- GLR parsing
  - 時間計算量：`O(n^3)`
  - 空間計算量：TBD
- GLL parsing
  - 時間計算量：`O(n^3)`
  - 空間計算量：TBD
- PwD

## 4.14 - まとめ

　この章では構文解析アルゴリズムの中で比較的メジャーな手法について、そのアイデアと概要を含めて説明しました。その他にも多数の手法がありますが、いずれにせよ、「上から下に」向かって解析するトップダウンの手法と「下から上に」向かって解析するボトムアップの手法のどちらかに分類できると言えます。

　GLRやGLL、PwDについては普段触れる機会はそうそうありませんが、LLやLR、PEGのパーザジェネレータは多数存在するため、基本的な動作原理についておさえておいて損はありません。また、余裕があれば各構文解析手法を使って実際のパーザジェネレータを実装してみるのも良いでしょう。実際にパーザジェネレータを実装することで、より深く構文解析手法を理解することもできます。
