# 2. 身近な構文解析器

　この章から、構文解析についての説明を始めたいと思います。この本を読んでいる読者の方は何らかの形で「構文解析器」または「構文解析」という用語に触れたことがあるのではないかと思います。この用語が意味するものはいったんおいておくとして、この章では、JSON（JavaScript Object Notation）を例にして、典型的な構文解析について説明していきます。

## 2.1 JSON（JavaScript Object Notation）の定義

　JSONは、特に、WebサービスにアクセスするためのAPIで非常に一般的に使われているデータフォーマットです。また、企業内サービス間で連携するときにも非常によく使われます。皆さんは何らかの形でJSONに触れたことがあるのではないかと思います。

　JSONは元々は、JavaScriptのサブセットとして、オブジェクトに関する部分だけを切り出したものでしたが、現在はECMAで標準化されており、色々な言語でJSONを扱うライブラリがあります。また、JSONはデータ交換用フォーマットの中でも非常にシンプルであるという特徴があり、そのシンプルさ故か、同じ言語でもJSONを扱うライブラリが乱立する程です。
 
 とにかく、まずは、簡単なJSONのサンプルを見てみましょう。

### 2.1.1 オブジェクト

　以下は、二つの名前/値のペアからなる**オブジェクト**です。

```js
{
  "name":"Kota Mizushima",
  "age":36
}
```

　このJSONは、`name`という名前と、`"Kota Mizushima"`という文字列の**ペア**と、`age`という名前と`36`という値のペアからなる**オブジェクト**であることを示しています。なお、用語については、ECMA-404の仕様書に記載されているものに準拠しています。名前/値のペアは、属性やプロパティを呼ばれることもあるので、適宜読み替えてください。

　日本語で表現すると、このオブジェクトは、名前が`Kota Mizushima`、年齢が`36`という人物一人分のデータを表していると考えることができます。オブジェクトは、`{}`で囲まれた、`name:value`の対が`,`を区切り文字として続く形になります。後述しますが、`name`の部分は**文字列**である必要があります。

### 2.1.2 配列

　別の例として、以下のJSONを見てみます。

```js
{
  "kind":"Rectangle",
  "points": [
    {"x":0, "y":0},
    {"x":0, "y":100},
    {"x":100, "y":100},
    {"x":100, "y":0},
  ]
}
```

　このJSONは、
 
- "kind":"Rectangle"のペア
- "points":`[...]`のペア

　からなるオブジェクトです。さらに、`"point"`に対応する値が**配列**になっていて、その要素は
 
- 名前が`"x"`で値が`0`、名前が`"y"`で値が`0`のペアからなるオブジェクト
- 名前が`"x"`で値が`0`、名前が`"y"`で値が`100`のペアからなるオブジェクト
- 名前が`"x"`で値が`100`、名前が`"y"`で値が`100`のペアからなるオブジェクト
- 名前が`"x"`で値が`100`、名前が`"y"`で値が`0`のペアからなるオブジェクト

　配列は、`[]`で囲まれた要素の並びで、区切り文字は`,`です。

　このオブジェクトは、種類が四角形で、それを構成する点が`(0, 0), (0, 100), (100, 100), (100, 0)`からなっているデータを表現しているとみることができます。
 
### 2.1.3 数値

　これまで見てきたオブジェクトと配列は複合的なデータでしたが、既に出てきているように、JSONにはプリミティブな（これ以上分解できない）データもあります。たとえば、先ほどから出てきている数値もそうです。数値は、

```js
1
10
100
1000
1.0
1.5
```

　のような形になっており、整数または小数です。JSONでの数値の解釈は特に規定されていない点に注意してください。たとえば、`0.1`は2進法での小数だと解釈しても良いですし、10進法での小数と解釈しても構いません。つまり、特に、IEEEの浮動小数点数である、といった規定はありません。

### 2.1.4 文字列

　先ほどから出てきていますが、JSONのデータには文字列もあります。

```js
"Hello, World"
"Kota Mizushima"
"hogehoge"
```

　のように、`""`で囲まれたのものが文字列となります。オブジェクトのキーになれるのは文字列のみです。たとえば、以下は**JavaScriptの**オブジェクトとしては正しいですが、**JSON**のオブジェクトとしては正しくありません。

```js
{
  name:"Kota Mizushima", //nameが"で囲まれていない！
  age:36
}
```

　このような誤ったJSONは、他言語のJSONライブラリではエラーになりますが、JavaScriptの一部として、そのまま書いてもエラーにならないので、注意してください。

### 2.1.5 真偽値

　JSONには、多くのプログラミング言語にある真偽値もあります。JSONの真偽値は以下のように、`true`または`false`の二通りです。

```js
true
false
```

　真偽値も特に解釈方法は定められていませんが、ほとんどのプログラミング言語で、該当するリテラル表現があるので、他の言語で取り扱う時は、おおむねそのよな真偽値リテラルにマッピングされます。

### 2.1.6 null

　多くのプログラミング言語にある要素ですが、JSONには`null`を含むことができます。多くのプログラミング言語のJSONライブラリでは、無効値に相当する値にマッピングされますが、JSONの仕様では`null`の解釈は定められていません。`null`に相当するリテラルがあればそれにマッピングされる事も多いですが、`Option`や`Maybe`といったデータ型によって`null`を表現する言語では、そのようなデータ型にマッピングされる事が多いようです。

### 2.1.7 JSONの全体像

　ここまでで、JSONで現れる6つの要素について説明しましたが、JSONで使える要素は**これだけ**です。このシンプルさが、多くのプログラミング言語でJSONが使われる要因でもあるのでしょう。JSONで使える要素について改めて並べてみます。

- オブジェクト
- 配列
- 数値
- 文字列
- 真偽値
- null

　次の節では、このJSONの**文法**が、どのような形で表現できるかについて見ていきます。

## 2.2 JSONとBNは

　プログラミング言語の文法自体を表現する文法（メタ文法といいます）の一つに、BNFがあります。BNFは、プログラミング言語の文法をはじめ、インターネット上でのメッセージ交換フォーマットなど、様々な文法を表現するのに使われています。とはえ、本書の読者の方にはBNFに馴染みのない方もいると思うので、まず次の節で簡単にBNFについて説明した後、JSONを表現するBNFについて説明します。なお、本書ではISO/IEC 14977で仕様が策定されたEBNFの事を指してBNFと呼ぶことにします。BNFは歴史的に、かなり多くの方言があり、どの記法を使うか事前に説明しておかないと読みづらいためです。

### 2.2.1 BNF

BNFは、正式にはBackus-Naur Form（バッカス・ナウア記法）と言います。Fortranの開発者でもある、John Backus（ジョン・バッカス）らが開発した記法であるBNFは、「プログラミング言語」そのものの文法を記述するために開発されました。基本情報技術者試験でも出題されるので、ひょっとしたらそこで知った方もおられるかもしれません。

とはいっても、これだけではチンプンカンプンかもしれませんので具体例を見て行きましょう。

たとえば、Java言語のローカル変数を宣言するプログラムの断片を考えてみると、以下のようになるでしょう。

```java 
// int型の変数x1を宣言して初期値を与えない
int x1;
// int型の変数x2を宣言して1を代入
int x2 = 1;
// String型の変数y1を宣言して初期値を与えない
String y1;
// String型の変数y2を宣言して"Hello, World"を代入
String y2 = "Hello, World"; 
// Double型の変数z1を宣言して初期値を与えない
Double z1;
// Double型の変数z2を宣言して1.0を代入
Double z2 = 1.0;
```

ローカル変数の宣言をよく見て行くと、以下のような形をしていることがわかります。

```text
型 変数名 ('=' 初期値)? ';'
```

`(E)?`は`E`が省略可能であることを示しています。`'='`はその記号自体がでてくることを示しています。

変数宣言の最初にはまず、型名が来て、その次に変数名、続いて省略可能な初期値が来ることを示しています。ローカル変数宣言はセミコロンで終わることも示しています。このように、プログラミング言語の文法には一定のルールがあり、それを曖昧さが無い形で解釈できると便利です。

このようなニーズに答えるのが、BNFです。

先ほどの文法をBNFで表現すると以下のようになります。

```bnf
local_variable_declaration = type_name identifier ('=' expression)? ';'

このような、`=`で分かれた内の左側を規則名と呼び、右側を本体と呼びます。また、本体と非終端記号を合わせて規則と呼びます。本書では、BNFを多用していくので、慣れていくようにしてください。

### 2.2.2 JSONのBNF

BNFについて説明し終わったところで、早速、JSONのBNFを見ていくことにしましょう。JSONのBNFによる定義は以下で全てです。

```bnf
json = object;
object = LBRACE RBRACE | LBRACE {pair {COMMA pair} RBRACE;
pair = STRING COLON value;
array = LBRACKET RBRACKET | LBRACKET {value {COMMA value}} RBRACKET ;
value = STRING | NUMBER | object | array | TRUE | FALSE | NULL ;

STRING = ("\"\"" / "\"" CHAR+ "\"") S;
NUMBER = (INT FRAC EXP | INT EXP | INT FRAC | INT) S;
TRUE = "true" S ;
FALSE = "false" S;
NULL = "null" S;
COMMA = "," S;
COLON = ":" S;
LBRACE = "{" S;
RBRACE = "}" S;
LBRACKET = "[" S;
RBRACKET = "]" S;

S = ( [ \f\t\r\n]+
  | "/*" (!"*/" _)* "*/"
    / "//" (![\r\n] _)* [\r\n]
    )* ;

CHAR = (!(["\\]) _) | "\\" [\\"/bfnrt] | "u" HEX HEX HEX HEX ;
HEX = `[0-9a-fA-F]` ;
INT = ["-"] (`[1-9]` {`[0-9]`} / "0") ;
FRAC = "." [0-9]+ ;
EXP = e `[0-9]` {`[0-9]`} ;
E = "e+" | "e-" | "E+" | "E-" | "e" | "E" ;
```

　これまで説明したJSONの要素と比較して見慣れない記号が出てきましたが、一つ一つ見て行きましょう。

### json

まず、一番上から読んでいきます。先程も書きましたが、BNFでは、

 ```
json = object;
 ```
 
のような、**規則**の集まりによって、文法を表現します。`=`の左側である`json`が**規則名**で、右側（ここでは `object`）が**本体**とになります。さらに、先程は説明していませんでしたが、本体の中に出てくる、他の規則を参照する部分（ここでは`object`)を非終端記号と呼びます。非終端記号は同じBNFで定義されている規則名と一致する必要があります。
  
この規則を日本語で表現すると、「`json`という名前の規則は、`object`という非終端記号を参照している」と読むことができます。また、`object`は、JSONのオブジェクトを表しているので、jsonという規則は全体で一つのオブジェクトを表しているということになります。

### object

`object` はJSONのオブジェクトを表す規則で、定義は以下のようになっています。

```
object = LBRACE RBRACE | LBRACE pair {COMMA pair} RBRACE;
```

EBNFにおいて`{}`で囲まれたものは、その中の要素が0回以上繰り返して出現することを示しています。また、`pair`の定義はのちほど出てきますので心配しないでください。

この規則によって`object`は

- ブレースで囲まれたもの（`LBRACE RBRACE`)である
  - `LBRACE`はLeft-Brace（開き波カッコ）の略で`{`を示しています
  - `RBACE`はRight-Brace（閉じ波カッコ）の略で`}`を示しています
- `LBRACE`が来た後に、`pair`が1回出現して、さらにその後に、`COMMA`（カンマ）を区切り文字として `pair` が1回以上繰り返して出現した後、`RBRACE`が来る

のどちらかであることを表しています。

具体的なJSONを当てはめてみましょう。以下のJSONは、`LBRACE RBRACE`にマッチします。

```js
{}
```

以下のJSONは`LBRACE {pair {COMMA pair} RBRACE`にマッチします。

```js
{"x":1}
{"x":1,"y":2}
{"x":1,"y":2,"z":3}
```

しかし、以下のテキストは、`object`に当てはまらず、エラーになります。これは、規則の中を見ると、カンマ（`COMMA`）は区切り文字であるためです。

```js
{"x":1,} // ,で終わっている
```

### pair

`pair`（ペア）は、JSONのオブジェクト内での`"x":1`に当たる部分を表現する規則です。`value`の定義については後述します。

```bnf
pair = STRING COLON value;
```

これによってペアは`:`（`COLON`）の前に文字列リテラル（`STRING`)が来て、その後にJSONの値（`value`）が来ることを表しています。`pair`にマッチするテキストとしては、

```
"x":1
"y":true
```

などがあります。一方で、以下のテキストは`pair`にマッチしません。JavaScriptのオブジェクトとJSONが違う点です。

```
x:1 // 文字列リテラルでないといけない
```

### COMMA

`COMMA`は、カンマを表す規則です。カンマそのものを表すには、単に`","`と書けばいいのですが、任意個の空白文字が続くことを表現したいため、規則`S`（後述）を参照しています。

```bnf
COMMA = "," S;
```

### array

`array`は、JSONの値の配列を表す規則です。

```bnf
array = LBRACKET RBRACKET | LBRACKET value {COMMA value} RBRACKET ;
```

`LBRACKET`は開き大カッコ（`[`）を、`RBRACKET`は閉じ大カッコ（`]`)を表しています。

これによって`array`は、

- 大カッコで囲まれたもの（`LBRACKET RBRACET`)である
- 開き大カッコ（`LBRACKET`）が来た後に、`value`が1回あらわれて、さらにその後に、`COMMA`を区切り文字として `value` が1回以上繰り返してあらわれた後、閉じ大カッコが来る（`RBRACKET`)

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

`value`の定義については次の項で説明します。

### value

```bnf
value = STRING | NUMBER | object | array | TRUE | FALSE | NULL ;
```

　`value`はJSONの値を表現する規則です。これは、JSONの値は、

- 文字列（`STRING`)
- 数値（`NUMBER`)
- オブジェクト（`object`）
- 配列（`array`）
- 真（`TRUE`）
- 偽（`FALSE`）
- ヌル（`NULL`）

　のいずれかでなければいけない事を示しています。JSONを普段使っている皆さんにはお馴染みでしょう。

### STRING

　`STRING`は文字列リテラルを表す規則です。

```bnf
STRING = ("\"\"" / "\"" CHAR+ "\"") S;
```

　`"`で始まって、文字が任意個続いて、 `"` で終わります。`COMMA`などと同じように、空白読み飛ばしのために`S`を付けています。`CHAR`の定義については省略します。

### NUMBER

　`NUMBER`は数値リテラルを表す規則です。

```bnf
NUMBER = (INT FRAC EXP | INT EXP | INT FRAC | INT) S;
```

- 整数（`INT`）に続いて、小数部（`FRAC`)と指数部（`EXP`)が来る
- 整数（`INT`）に続いて、指数部（`EXP`)が来る
- 整数（`INT`）

　のいずれかであるのが`NUMBER`であるという事を表現しています。同様に、空白読み飛ばしのために、`S`を付けています。

### TRUE

　`TRUE`は、真を表すリテラルを表す規則です。

```bnf
TRUE = "true" S ;
```

　文字列 `true` が真を表すということでそのままですね。

### FALSE

　`FALSE`は、偽を表すリテラルを表す規則です。構造的には、`TRUE`と同じです。

```bnf
FALSE = "true" S ;
```

　文字列 `false` が偽を表すということでそのままです。

### NULL

　`NULL`は、ヌルリテラルを表す規則です。構造的には、`TRUE`や`FALSE`と同じです。

```bnf
NULL = "null" S;
```

　`NULL`は、ヌル値があるプログラミング言語だと、その値にマッピングされますが、ここではあくまでヌル値は`null`で表されることしか言っておらず、**意味は特に規定していない**ことに注意してください。

### JSONのBNFまとめ

　このように、JSONのBNFは、非常に少数の規則だけで表現することができます。読者の中には、あまりにも簡潔過ぎて驚かれた方もいるのではないでしょうか。しかし、これだけ単純であるにも関わらず、JSONのBNFは**再帰的に定義されている**ため、非常に複雑な構造も表現することができます。たとえば、

- 配列の要素がオブジェクトであり、その中のキー`"a"`に対応する要素の中にさらに配列があって、その配列は空配列である

　といったことも、JSONのBNFでは表現することができます。この、再帰的な規則というのは、構文解析において非常に重要な要素なので、これから本書を読み進める上でも念頭に置いてください。

## 2.3 JSONの構文解析器

ここまでで、JSONの定義と、その文法について見てきました。この節では、BNFを元に、JSONを**構文解析**するプログラムを考えてみます。まだ、構文解析が何かも定義していないわけですが、とりあえずは、以下のようなインタフェース`JsonParser`インタフェースを実装したクラスを「JSONの構文解析器」と考えることにします。

```java
package parser;
interface JsonParser {
        public ParseResult<JsonAst.JsonValue> parse(String input);
}
```

　なお、クラス`ParseResult<T>`は以下のようなジェネリックなクラスになっています。`value`は解析結果の値です。これは任意の型をとり得るので、`T`としています。また、`input`は「構文解析の対象となる文字列」を表します。

```java
public class ParseResult<T> {
        public final T value;
        public final String input;
        public ParseResult(T value, String input) {
                this.value = value;
                this.input = input;
        }
}
```

　このインタフェース`JsonParser`は`parse()`メソッドだけを持ちます。`parse()`メソッドは、文字列`input`を受け取り、`ParseResult<JsonAst.JsonValue>`型を返します。`JsonValue`は以下のように定義されます。GoF(Gang of Four)パターンで言うところの`Composite`パターンですが、Javaのようなオブジェクト指向言語で、再帰的な木構造を表す時には定番のパターンです。

```java
public interface JsonAst {
    // value
    interface JsonValue {}
    
    // NULL
    class JsonNull implements JsonValue {
        private JsonNull(){}
        private static final JsonNull INSTANCE = new JsonNull();
        public static JsonNull getInstance() {
            return INSTANCE;
        }
        
        @Override
        public String toString() {
            return "null";
        }
    }
    
    
    // TRUE
    class JsonTrue implements JsonValue {
        private JsonTrue(){}
        private static final JsonTrue INSTANCE = new JsonTrue();
        public static JsonTrue getInstance() {
            return INSTANCE;
        }
    
        @Override
        public String toString() {
            return "true";
        }
    }
    
    // FALSE
    class JsonFalse implements JsonValue {
        private JsonFalse(){}
        private static final JsonFalse INSTANCE = new JsonFalse();
        public static JsonFalse getInstance() {
            return INSTANCE;
        }
    
        @Override
        public String toString() {
            return "false";
        }
    }
    
    // NUMBER
    class JsonNumber implements JsonValue {
        public final double value;
        public JsonNumber(double value) {
            this.value = value;
        }
        
        @Override
        public boolean equals(Object o) {
            // 実装は省略
        }
        
        @Override
        public int hashCode() {
            // 実装は省略
        }
    
        @Override
        public String toString() {
            return "JsonNumber{" +
                "value=" + value +
                '}';
        }
    }
    
    // STRING
    class JsonString implements JsonValue {
        public final String value;
        public JsonString(String value) {
            this.value = value;
        }
        
        @Override
        public boolean equals(Object o) {
            // 実装は省略
        }
        
        @Override
        public int hashCode() {
            // 実装は省略
        }
    
        @Override
        public String toString() {
            return "JsonString{" +
                "value='" + value + '\'' +
                '}';
        }
    }
    
    // object
    class JsonObject implements JsonValue {
        public final List<Pair<JsonString, JsonValue>> properties;
        public JsonObject(List<Pair<JsonString, JsonValue>> properties) {
            this.properties = properties;
        }
        
        @Override
        public boolean equals(Object o) {
            // 実装は省略
        }
        
        @Override
        public int hashCode() {
            // 実装は省略
        }
    
        @Override
        public String toString() {
            return "JsonObject{" +
                "properties=" + properties +
                '}';
        }
    }
    
    // array
    class JsonArray implements JsonValue {
        public final List<JsonValue> elements;
        public JsonArray(List<JsonValue> elements) {
            this.elements = elements;
        }
        
        @Override
        public boolean equals(Object o) {
            // 実装は省略
        }
        
        @Override
        public int hashCode() {
            // 実装は省略
        }
   
        @Override
        public String toString() {
            return "JsonArray{" +
                "elements=" + elements +
                '}';
        }
    }
}
```

各クラスが、JSONのBNFの規則名に対応しているのがわかるでしょうか。この節では、各規則に対応するメソッドを実装することを通して、実際にJSONの構文解析器を組み上げていきます。

### 構文解析器の全体像

これから、JSONの構文解析器、つまり、JSONを表す文字列を受け取って、それに対応する上記の`JsonAst.JsonValue`型の値を返すメソッドを実装していくわけですが、まず、構文解析器を表現するクラスの全体像を示しておきます。このクラスは次のようになります。

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
        return ('0' <= ch && ch <= '9') || ('a' <= ch && ch <= 'z') || ('A' <= ch && ch <= 'Z');
    }

    private void skipWhitespace() {
        OUTER:
        while(cursor < input.length()) {
            char currentCharacter = input.charAt(cursor);
            switch (currentCharacter) {
                case '\f':
                case '\t':
                case '\r':
                case '\n':
                case '\b':
                case ' ':
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
        return JsonAst.JsonTrue.getInstance();
    }

    private JsonAst.JsonFalse parseFalse() {
        recognize("false");
        skipWhitespace();
        return JsonAst.JsonFalse.getInstance();
    }

    private JsonAst.JsonNull parseNull() {
        recognize("null");
        skipWhitespace();
        return JsonAst.JsonNull.getInstance();
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

このクラス`PegJsonParser`で重要なことは、クラスがフィールドとして

- 入力文字列 `input`
- 現在どこまで読み進めたかを表す整数 `cursor`

をフィールドとして保持していることです。構文解析器を実装する方法としては、主として、同じ入力文字列を与えれば同じ解析結果が返ってくるような関数型の実装方法と、今回のように、現在どこまで読み進めたかによって解析結果が変わる手続き型の方法があるのですが、説明の都合上、手続き型の方がやりやすいので、本書では手続き型の実装方法を採用しています。

なお、`progressive`で始まるフィールドは主にエラーメッセージをわかりやすくするためのものなので、現時点では気にする必要はありません。

### nullの構文解析メソッド

`null`の構文解析は、次のような　`parseNull()` メソッドとして定義します。

```java
private JsonAst.JsonNull parseNull() {
    recognize("null");
    skipWhitespace();
    return JsonAst.JsonNull.getInstance();
}

```

　このメソッドで行っていることを見ていきましょう。このメソッドでは、入力である`input`の現在位置が`"null"`という文字列で始まっているかをチェックします。もしそうなら、**JSONのnull**をあらわす`JsonAst.JsonNull`のインスタンスを返します。もし、先頭が`"null"`でなければ、構文解析は失敗なので例外を発生させますが、これは`recognize()`メソッドの中で行われています。`recognize()`の内部では、入力の現在位置と与えられた文字列を照合して、マッチしない場合例外を投げます。

　次に、`skipWhitespace()`メソッドを呼び出して、「空白の読み飛ばし」を行っています。

　`recognize()`も`skipWhitespace()`も構文解析中に頻出する処理であるため、今回はそれぞれをメソッドにくくりだして、各構文解析メソッドの中で呼び出せるようにしました。

### trueの構文解析メソッド

`true`の構文解析は、次のような　`parseTrue()` メソッドとして定義します。

```java
private JsonAst.JsonTrue parseTrue() {
    recognize("true");
    skipWhitespace();
    return JsonAst.JsonTrue.getInstance();
}
```

　見ればわかりますが、`parseNull()`とほぼ同じです。固定の文字列を解析するという点で両者はほぼ同じ処理であり、引数を除けば同じ処理になるのです。

### falseの構文解析メソッド

`false`の構文解析は、次のシグニチャを持つ　`parseFalse()` メソッドとして定義します。

```java
private JsonAst.JsonFalse parseFalse() {
    recognize("false");
    skipWhitespace();
    return JsonAst.JsonFalse.getInstance();
}
```

　これも、`parseNull()`とほぼ同じですので、特に説明の必要はないでしょう。

### 数値の構文解析メソッド

数値の構文解析は、次のシグニチャを持つ　`parseNumber()` メソッドとして定義します。

```java
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
        return new JsonAst.JsonNumber(Integer.parseInt(input.substring(start, cursor))); }
```

`parseNumber()` では、`while`文において、

- 0から9までの文字が出る間、入力を読む
- 1桁ずつ、数値に変換する

という処理を行っています。本来なら、JSONの仕様では、小数も扱えるのですが、構文解析にとっては本質的ではないので本書では省略します。

### 文字列の構文解析メソッド

文字列の構文解析は、次のシグニチャを持つ　`parseString()` メソッドとして定義します。

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

を`switch`文で判定して分岐しています。JSONで使えるエスケープシーケンスは、

- `b`, `f`, `n`, `t`, `\`, `"`, `/`
- `uxxxx` （ユニコードエスケープ）

のいずれかに分かれているので、意味を読み取るのは簡単でしょう。

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

### 配列の構文解析メソッド

配列の構文解析は、次のシグニチャを持つ　`parseArray()` メソッドとして定義します。

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

　そして、`]`が来るという仮定が成り立たなかった場合、再び最初に`[`が出現して、その次に来るのは任意の`JsonValue`ですから、以下のようなコードになります。

```java
        parseLBracket();
        List<JsonAst.JsonValue> values = new ArrayList<>();
        var value = parseValue();
        values.add(value);
```

　ここで、ローカル変数`values`は、配列の要素を格納するためのものです。

　配列の中で、最初の要素が読み込まれた後、次に来るのは、`,`か`]`のどちらかですが、ひとまず、`,`が来ると仮定して`while`ループで

```java
parseComma();
value = parseValue();
values.add(value);
```

　を繰り返します。この繰り返しは、1回ごとに必ず入力を1以上進めるため、必ず失敗します。失敗した時は、テキストが正しいJSONなら、`]`が来るはずなので、

```java
parseRBracket();
return new JsonAst.JsonArray(values);
```

　とします。もし、テキストが正しいJSONでない場合、`parseRBracket()`から例外が投げられるはずですが、その例外は**より上位の層が適切にリカバーしてくれると期待して**放置します。JSONのような再帰的な構造を解析する時、このような、「自分の呼び出し元が適切にやってくれるはず」（何故なら、自分はその呼び出し元で適切にcatchしているのだから）という考え方が重要になります。

　このように、多少複雑になりましたが、`parseArray()`の定義が、EBNFにおける表記

```bnf
array = LBRACKET RBRACKET | LBRACKET {value {COMMA value}} RBRACKET ;
```

　に対応していることがわかるでしょうか。読み方のポイントは、`|`の後を、例外をキャッチした後の処理ととらえることです。

### オブジェクトの構文解析メソッド


オブジェクトの構文解析は、次のシグニチャを持つ　`parseObject()` メソッドとして定義します。

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

と気づかれた読者の方が居るかも知れません。実際、`parseObject()`がやっていることは非常に`parseArray()`と非常に類似しています。

まず、最初に、

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

　これは、EBNFにおける以下の定義にそのまま対応しているのがわかるでしょう。

```
pair = STRING COLON value;
```

### 構文解析における再帰

　配列やオブジェクトの構文解析メソッドを見るとわかりますが、

- `parseArray() -> parseValue() -> parseArray()`
- `parseArray() -> parseValue() -> parseObject()`
- `parseObject() -> parseValue() -> parseObject()`
- `parseObject() -> parseValue() -> parseArray()`

　のような再帰呼び出しが起こり得ることがわかります。このような再帰呼び出しでは、各ステップで必ず構文解析が1文字以上進むため、JSONがどれだけ深くなっても（スタックが溢れない限り）うまく構文解析ができるのです。

### 構文解析とPEG

ここまででJSONの構文解析器を実装することが出来ましたが、実は、この節で紹介した技法は古典的な構文解析の技法では**ありません**。

この節で解説した技法は、Parsing Expression Grammar(PEG)と呼ばれる手法に基づいています。

PEGは2004にBryan Ford（ブライアン・フォード）によって提案された形式文法であり、従来主流であったCFG(Context-Free Grammar)と少し違う特徴を持ちますが、プログラミング言語など曖昧性の無い言語の解析に使うのには便利であり、最近では色々な言語でPEGをベースにした構文解析器が実装されています。構文解析を理解するのに字句解析は本来的には余計なものとも言えるので、先にPEGを使った技法を学ぶことで、構文解析についてスムーズに理解してもらえたのではないかと思います。ただし、従来の構文解析手法（という言い方は不適切で、依然として従来の手法の方がよく使われています）を学ぶのも重要な事ですので、次の節では、字句解析という手法を用いた構文解析手法について解説します。

## 2.4 字句解析器を使った構文解析器

さて、前節では、再帰的な構文を取り扱う構文解析法の一種であるPEGを取り扱いましたが、通常の構文解析法では、まず、字句解析という前処理を行ってから構文解析を行います。字句解析の字句は英語ではトークン（`token`）と言われるものです。たとえば、以下の英文があったとします。

```
We are parsers.
```

我々は構文解析器であるというジョーク的な文ですが、それはさておき、この文は

```
[We, are, parsers]
```

という三つのトークン（単語）に分解すると考えるのが字句解析の発想法です。

実は、古典的な構文解析の世界では、このような字句解析が必須とされていましたが、それは後の章で説明される構文解析アルゴリズムの都合に加えて、空白のスキップという処理を字句解析で行えるからでもあります。

実際、前節で出てきたJSONの構文解析器では`skipWhitespace()`の呼び出しが頻出していましたが、字句解析器で空白を読み飛ばす処理を先に行うことで、構文解析器で空白の読み飛ばしという作業をしなくてよくなります。

もちろん、この点はトレードオフがあって、たとえば、空白に関する規則がある言語の中でブレがある場合には、字句解析という前処理はかえってしない方が良いということすらあります。ともあれ、字句解析という前処理を通すことには一定のメリットがあるのは確かです。

### 2.4.1 字句解析器を使った構文解析器の全体像

この項では、字句解析器を使った構文解析器の全体像を示します。まず最初に、JSONの字句解析器は次のようになります。

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
                        if((index + 1) + 4 >= input.length()) {
                            throw new TokenizerException("unicode escape ends with EOF: " + input.substring(index));
                        }
                        var unicodeEscape= input.substring(index + 1, index + 1 + 4);
                        if(!unicodeEscape.matches("[0-9a-fA-F]{4}")) {
                            throw new TokenizerException("illegal unicode escape: \\u" + unicodeEscape);
                        }
                        builder.append((char)Integer.parseInt(unicodeEscape, 16));
                        index += 4;
                        break;
                }
            } else {
                builder.append(ch);
            }
            index++;
        }
        return false;
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
                // whitespace
                case ' ':
                case '\t':
                case '\n':
                case '\r':
                case '\b':
                case '\f':
                    char next = 0;
                    do {
                        index++;
                        next = input.charAt(index);
                    } while (index < input.length() && Character.isWhitespace(next));
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

次に、これを利用した構文解析器のコードを示します。

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
        if(!tokenizer.current().equals(true)) {
            return JsonAst.JsonTrue.getInstance();
        }
        throw new parser.ParseException("expected: true, actual: " + tokenizer.current().value);
    }

    private JsonAst.JsonFalse parseFalse() {
        if(!tokenizer.current().equals(false)) {
            return JsonAst.JsonFalse.getInstance();
        }
        throw new parser.ParseException("expected: false, actual: " + tokenizer.current().value);
    }

    private JsonAst.JsonNull parseNull() {
        if(tokenizer.current().value == null) {
            return JsonAst.JsonNull.getInstance();
        }
        throw new parser.ParseException("expected: null, actual: " + tokenizer.current().value);
    }

    private JsonAst.JsonString parseString() {
        return new JsonAst.JsonString((String)tokenizer.current().value);
    }

    private JsonAst.JsonNumber parseNumber() {
        var value = (Integer)tokenizer.current().value;
        return new JsonAst.JsonNumber(value);
    }

    private Pair<JsonAst.JsonString, JsonAst.JsonValue> parsePair() {
        var key = parseString();
        tokenizer.moveNext();
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

構文解析器から呼び出されている`parserXXX()`メソッドを見るとわかりますが、字句解析器を導入したことによって、文字列の代わりにトークンの列を順によみ込んで、期待通りのトークンが現れたかを事前にチェックしています。また、この構文解析器には空白の読み飛ばしに関する処理が入っていないことに着目してください。

、PEG版と異なり、途中で失敗したら後戻り（バックトラック）するという処理も存在しません。後戻りによって、文法の柔軟性を増すというメリットがある一方、構文解析器の速度が落ちるというデメリットもあるため、字句解析器を用いた構文解析器は一般により高速に動作します（ただし、実装者の力量の影響も大きいです）。

### 2.4.2 JSONの字句解析器

さて、2.4.1で触れたJSONの字句解析器について、この項では、主要な部分に着目して説明します。

#### 2.4.2.1 ヘッダ部

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

#### 2.4.2.2 本体部

`SimpleTokenizer`の主要なメソッドは、

- `tokenizeNumber()`
- `tokenizeStringLiteral()`
- `accept()`
- `moveNext()`
- `current()`

#### 2.4.2.2.1 tokenizeNumber

`tokenizeNumber()`メソッドは、文字列の現在位置から開始して、数値トークンを切り出すためのメソッドです。引数`positive`の値が`true`なら、正の整数を、`false`なら、負の整数をトークンとして切り出しています。返り値はトークンの切り出しに成功したか、失敗したかを表します。

#### 2.4.2.2.2 tokenizeStringLiteral

`tokenizeStringLiteral()` メソッドは、文字列の現在位置から開始して、文字列リテラルトークンを切り出すためのメソッドです。返り値はトークンの切り出しに成功したか、失敗したかを表します。

#### 2.4.2.2.3 accept

`accept()` メソッドは、文字列の現在位置から開始して、文字列`literal`にマッチしたら、種類`type`で値が`value`なトークンを生成するメソッドです。これは、`toknizeStringLiteral()`など他のメソッドから呼び出されます。

#### 2.4.2.2.4 moveNext

`moveNext()` メソッドは、字句解析器の中核となるメソッドです。呼び出されると、次のトークンは発見するまで、文字列の位置を進め、トークンが発見されたら、トークンを`fetched`に格納して、`true`を返します。トークン列の終了位置に来たら`false`を返します。これは、`Iterator`パターンの一種とも言えますが、典型的な`Iterator`と異なり、`moveNext()`が副作用を持つ点がポイントでしょうか。この点は、.NETの`IEnumerator`のアプローチを参考にしました。

#### 2.4.2.2.5 current

`current()`メソッドは、`moveNext()`メソッドが`true`を返したあとに呼び出すと、切り出せたトークンを取得することができます。`moveNext()`を次に呼び出すと、`current()`の値が変わってくる点に注意が必要です。

### 2.4.3 JSONの構文解析器

さて、JSONの字句解析器である`SimpleTokenizer`はこのようにして実装しましたが、JSONの構文解析器である`SimpleJSONParser`はどのように実装されているのでしょうか。このクラスは、主に

- `parseTrue()`メソッド：規則`TRUE`に対応する構文解析メソッド
- `parseFalse()`メソッド：規則`FALSE`に対応する構文解析メソッド
- `parseNull()`メソッド：規則`NULL`に対応する構文解析メソッド
- `parseString()`メソッド：規則`STRING`に対応する構文解析メソッド
- `parseNumber()`メソッド：規則`NUMBER`に対応する構文解析メソッド
- `parseObject()`メソッド：規則`object`に対応する構文解析メソッド
- `parseArray()`メソッド：規則`array`に対応する構文解析メソッド
- `parseValue()`メソッド: 規則`value`に対応する構文解析メソッド

というメソッドからなっており、それぞれが内部で`SimpleTokenizer`クラスのオブジェクトのメソッドを呼び出しています。では、これらのメソッドについて順番に見て行きましょう。

#### 2.4.3.1 parseTrue

`parseTrue()`メソッドは、規則`TRUE`に対応するメソッドで、JSONの`true`に対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
    private JsonAst.JsonTrue parseTrue() {
        if(!tokenizer.current().equals(true)) {
            return JsonAst.JsonTrue.getInstance();
        }
        throw new parser.ParseException("expected: true, actual: " + tokenizer.current().value);
    }
```

見るとわかりますが、`tokenizer`が保持している次のトークンの値が`true`だったら、`JsonAst.JsonTrue`のインスタンスを返しているだけですね。ほぼ、字句解析器に処理を丸投げしているだけですから、詳しい説明は不要でしょう。

#### 2.4.3.2 parseFalse

`parseTrue()`メソッドは、規則`FALSE`に対応するメソッドで、JSONの`false`に対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
    private JsonAst.JsonFalse parseFalse() {
        if(!tokenizer.current().equals(false)) {
            return JsonAst.JsonFalse.getInstance();
        }
        throw new parser.ParseException("expected: false, actual: " + tokenizer.current().value);
    }
```

実装については、`parseTrue()`とほぼ同様なので説明は省略します。

#### 2.4.3.3 parseNull

`parseNull()`メソッドは、規則`NULL`に対応するメソッドで、JSONの`null`に対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
  private JsonAst.JsonNull parseNull() {
        if(tokenizer.current().value == null) {
            return JsonAst.JsonNull.getInstance();
        }
        throw new parser.ParseException("expected: null, actual: " + tokenizer.current().value);
    }
```

実装については、`parseTrue()`とほぼ同様なので説明は省略します。

#### 2.4.3.4 parseString

`parseString()`メソッドは、規則`STRING`に対応するメソッドで、JSONの`"..."`に対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
   private JsonAst.JsonString parseString() {
        return new JsonAst.JsonString((String)tokenizer.current().value);
   }
```

実装については、`parseTrue()`とほぼ同様なので説明は省略します。

#### 2.4.3.5 parseNumber

`parseString()`メソッドは、規則`NUMBER`に対応するメソッドで、JSONの`1, 2, 3, 4, ...`に対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
    private JsonAst.JsonNumber parseNumber() {
        var value = (Integer)tokenizer.current().value;
        return new JsonAst.JsonNumber(value);
    }
```

実装については、`parseTrue()`とほぼ同様なので説明は省略します。

#### 2.4.3.6 parseObject

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
- それ以外の場合： `parsePair()` を呼び出し、 `string:pair` のようなペアを解析した後、以下のループに突入：
  - 次のトークンが`}`の場合、集めたペアのリストを引数として、`JsonAst.JsonObject()`オブジェクトを作って返す
  - それ以外で、次のトークンが`,`でない場合、構文エラーを投げて終了
  - それ以外の場合：次のトークンをフェッチして来て、`parsePair()`を呼び出して、ペアを解析した後、リストにペアを追加

のような動作を行います。実際のコードと対応付けてみると、より理解が進むでしょう。

#### 2.4.3.7 parseArray

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

- その次のトークンが`]`であった場合：空オブジェクトを返す
- それ以外の場合： `parseValue()` を呼び出し、 `value`を解析した後、以下のループに突入：
  - 次のトークンが`}`の場合、集めた`values`のリストを引数として、`JsonAst.JsonObject()`オブジェクトを作って返す
  - それ以外で、次のトークンが`,`でない場合、構文エラーを投げて終了
  - それ以外の場合：次のトークンをフェッチして来て、`parsePair()`を呼び出して、`value`を解析した後、リストに`value`を追加

のような動作を行います。実際のコードと対応付けてみると、より理解が進むでしょう。

なお、`parseArray()`のコードを読めばわかるように、ほとんどのコードは、`parseObject()`と共通のものになっています。もしこれが気になるようであれば、共通部分をくくりだすことも出来ます。

### 2.5 まとめ

この章では、JSONの構文解析や字句解析を実際に作ってみることを通して、構文解析の基礎について学んでもらいました。特に、

- 2.1 JSONの定義 
- 2.2 JSONのBNF
- 2.3 JSONの構文解析機（PEG版）
- 2.4 字句解析器を使った構文解析器

といった順番で、JSONの定義から入って、PEGによるJSONパーザ、字句解析器を使った構文解析器の作り方について学んでもらいました。この書籍中で使ったJSONはECMAScriptなどで定義されている正式なJSONに比べてサブセットになっており、たとえば、浮動小数点数が完全に扱えないという制限がありますが、構文解析器全体から見ればささいなことなので、この章を理解出来れば、JSONの構文解析についてはある程度理解出来たと思って構いません。

次の章では、文脈自由文法（Context-Free Grammar, CFG）の考え方について学んでもらいます。というのは、文脈自由文法は、現在使われているほとんどの構文解析アルゴリズム（もちろん、PEG等を除く）の基盤となっている概念であって、CFGの理解なくしては、その後の構文解析の理解もおぼつかないからです。

逆に、CFGの考え方さえわかってしまえば、個別の構文解析アルゴリズム自体は、必ずしもそれほど難しいとは感じられなくなって来るかもしれません。