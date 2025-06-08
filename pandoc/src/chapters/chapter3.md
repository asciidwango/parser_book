
# 第3章 JSONの構文解析

2章で構文解析に必要な基本概念について学ぶことができました。この章ではJSONという実際に使われている言語を題材に、より実践的な構文解析のやり方を学んでいきます。

## JSON（JavaScript Object Notation）の概要

JSONは、WebサービスにアクセスするためのAPIで非常に一般的に使われているデータフォーマットです。また、企業内サービス間で連携するときにも非常によく使われます。皆さんは何らかの形でJSONに触れたことがあるのではないかと思います。

JSONは元々は、JavaScriptのサブセットとして、オブジェクトに関する部分だけを切り出したものでしたが、現在はECMA-404[^1]で標準化されており、色々な言語でJSONを扱うライブラリがあります。また、JSONはデータ交換用フォーマットの中でも非常にシンプルであるという特徴があり、そのシンプルさ故か、同じ言語でもJSONを扱うライブラリが乱立する程です。今のWebアプリケーション開発に携わる開発者にとってJSONは避けて通れないといってよいでしょう。
 
以降では簡単なJSONのサンプルを通してJSONの概要を説明します。

### オブジェクト

以下は、二つの名前/値のペアからなる**オブジェクト**です。

```js
{
  "name": "Kota Mizushima",
  "age":  41
}
```

このJSONは、`name`と`"Kota Mizushima"`という文字列の**ペア**と、`age`と`41`という数値の**ペア**からなる**オブジェクト**であることを示しています。

なお、用語については、ECMA-404の仕様書に記載されているものに準拠しています。名前/値のペアは、属性やプロパティと呼ばれることもあるので、適宜読み替えてください。
日本語で表現すると、このオブジェクトは、名前が`Kota Mizushima`、年齢が`41`という人物一人分のデータを表していると考えることができます。オブジェクトは、`{}`で囲まれた、`"name":value`の対が`,`を区切り文字として続く形になります。後述しますが、`name`の部分は**文字列**である必要があります。

### 配列

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
- `"points"`と`[...]`のペア

からなるオブジェクトです。さらに、`"points"`に対応する値が**配列**になっていて、その中に以下の4つの要素が含まれています。
 
- オブジェクト： `{"x":0,   "y":0}`
- オブジェクト： `{"x":0,   "y":100}`
- オブジェクト： `{"x":100, "y":100}`
- オブジェクト： `{"x":100, "y":0}`

配列は、`[]`で囲まれた要素の並びで、区切り文字は`,`です。

このオブジェクトは、種類が四角形で、それを構成する点が`(0, 0), (0, 100), (100, 100), (100, 0)`からなっているデータを表現しているとみることができます。
 
### 数値

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

### 文字列

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

### 真偽値

JSONには、多くのプログラミング言語にある真偽値もあります。JSONの真偽値は以下のように、`true`または`false`の二通りです。

```js
true
false
```

真偽値も解釈方法は定められていませんが、ほとんどのプログラミング言語で、該当するリテラル表現があるので、おおむねそのような真偽値リテラルにマッピングされます。

### null

多くのプログラミング言語にある要素ですが、JSONには`null`もあります。多くのプログラミング言語のJSONライブラリでは、無効値に相当する値にマッピングされますが、JSONの仕様では`null`の解釈は定められていません。`null`に相当するリテラルがあればそれにマッピングされる事も多いですが、`Option`や`Maybe`といったデータ型によって`null`を表現する言語では、そのようなデータ型にマッピングされる事が多いようです。

### JSONの全体像

ここまでで、JSONで現れる6つの要素について説明しましたが、JSONで使える要素は**これだけ**です。このシンプルさが、多くのプログラミング言語でJSONが使われる要因でもあるのでしょう。JSONで使える要素について改めて並べてみます。

- オブジェクト
- 配列
- 数値
- 文字列
- 真偽値
- `null`

次の節では、このJSONの**文法**が、どのような形で表現できるかについて見ていきます。

## JSONのBNF

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

### json

一番上から読んでいきます。2章の復習になりますが、BNFでは、

 ```
json = ws value ws;
 ```
 
のような**規則**の集まりによって、文法を表現します。`=`の左側である`json`が**規則名**で、右側（ここでは `ws value ws`）が**本体**になります。さらに、本体の中に出てくる、他の規則を参照する部分（ここでは`value`や`ws`)を非終端記号と呼びます。非終端記号は同じBNFで定義されている規則名と一致する必要があります。
  
この規則を日本語で表現すると、「`json`という名前の規則は、`ws`の後に`value`が続き、その後`ws`になる」と読むことができます。`value`は、JSONの値を表しているので、jsonという規則は`ws`（空白文字）で囲まれたJSONの値を表しています。

### object

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

### pair

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

### COMMA

`COMMA`は、カンマを表す規則です。カンマそのものを表すには、単に`","`と書けばいいのですが、任意個の空白文字が続くことを表現したいため、規則`ws`（後述）を参照しています。

```text
COMMA = "," ws;
```

### array

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

### value

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

### true

`true`は、真を表すリテラルを表す規則です。

```text
true = "true" ws;
```

文字列 `true` が真を表すということでそのままですね。

### false

`false`は、偽を表すリテラルを表す規則です。構造的には、`true`と同じです。

```text
false = "false" ws;
```

### null

`null`は、ヌルリテラルを表す規則です。構造的には、`true`や`false`と同じです。

```text
null = "null" ws;
```

`null`は、ヌル値があるプログラミング言語だと、その値にマッピングされますが、ここではあくまでヌル値は`null`で表されることしか言っておらず、**意味は特に規定していない**ことに注意してください。

### number

`number`は、数値リテラルを表す規則です。

```text
number = INT ws;
```

整数（`INT`）に続いて、`ws`が来るのが`number`であるということを表現しています。

### string

`string`は文字列リテラルを表す規則です。

```text
string = ("\"\"" | "\"" CHAR+ "\"") ws;
```

`"`で始まって、`CHAR`で定義される文字が0個以上続いて、 `"` で終わります。`CHAR`の定義はBNF中に含まれており、エスケープシーケンスなどもここで定義されています。

### JSONのBNFまとめ

JSONのBNFは、非常に少数の規則だけで表現することができます。読者の中には、あまりにも簡潔過ぎて驚かれた方もいるのではないでしょうか。しかし、これだけ単純であるにも関わらず、JSONのBNFは**再帰的に定義されている**ため、非常に複雑な構造も表現することができます。たとえば、

- 一要素の配列があり、その要素はオブジェクトであり、キー`"a"`に対応する要素の中に配列があって、その配列は空配列である

といったことも、JSONのBNFでは以下のように表現することができます。

```json
[{"a":[]}]
```

再帰的な規則は、構文解析において非常に重要な要素なので、これから本書を読み進める上でも念頭に置いてください。

## JSONの構文解析器

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

### 構文解析器の全体像

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

### nullの構文解析メソッド

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

### trueの構文解析メソッド

`true`の構文解析は、次のような `parseTrue()` メソッドとして定義します。

```java
private JsonAst.JsonTrue parseTrue() {
    recognize("true");
    skipWhitespace();
    return new JsonAst.JsonTrue();
}
```

　見ればわかりますが、`parseNull()`とほぼ同じです。固定の文字列を解析するという点で両者はほぼ同じ処理であり、引数を除けば同じ処理になるのです。

### falseの構文解析メソッド

`false`の構文解析は、次のシグニチャを持つ `parseFalse()` メソッドとして定義します。

```java
private JsonAst.JsonFalse parseFalse() {
    recognize("false");
    skipWhitespace();
    return new JsonAst.JsonFalse();
}
```

　これも、`parseNull()`とほぼ同じですので、特に説明の必要はないでしょう。

### 数値の構文解析メソッド

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

### 文字列の構文解析メソッド

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

### 配列の構文解析メソッド

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
            int endIndex = cursor + 
                (literal.length() > substring.length() ? substring.length() : literal.length());
            throwParseException(
                "expected: " + literal + ", actual: " + input.substring(cursor, endIndex)
            );
        }
    }
```

このようにすることで、マッチしない場合に例外を投げ、そうでなければ入力を進めるという挙動を実装できます。`[`の次には任意の`JsonValue`または`"]"`が来る可能性があります。この時、まず最初に、`]`が来ると**仮定**するのがポイントです。

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

### オブジェクトの構文解析メソッド

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

### 構文解析における再帰

配列やオブジェクトの構文解析メソッドを見るとわかりますが、

- `parseArray() -> parseValue() -> parseArray()`
- `parseArray() -> parseValue() -> parseObject()`
- `parseObject() -> parseValue() -> parseObject()`
- `parseObject() -> parseValue() -> parseArray()`

のような再帰呼び出しが起こり得ることがわかります。このような再帰呼び出しでは、各ステップで必ず構文解析が1文字以上進むため、JSONがどれだけ深くなっても（スタックが溢れない限り）うまく構文解析ができるのです。

### 構文解析とPEG

このようにしてJSONの構文解析器を実装することが出来ましたが、実は、この節で紹介した技法は古典的な構文解析の技法では**ありません**。

この節で解説した技法は、Parsing Expression Grammar(PEG)と呼ばれる手法に基づいています。

PEGは2004にBryan Ford（ブライアン・フォード）によって提案された形式文法であり、従来主流であったCFG(Context-Free Grammar)と違う特徴を持ちますが、プログラミング言語など曖昧性の無い言語の解析に使うのには便利であり、最近では色々な言語でPEGをベースにした構文解析器が実装されています。メジャーな言語だとPythonは3.9からPEGベースの構文解析器を使うようになりました。

PEGはとてもシンプルなので、先にPEGを使った技法を学ぶことで、構文解析についてスムーズに理解してもらえたのではないかと思います。ただし、従来の構文解析手法（という言い方は不適切で、依然として従来の手法の方がよく使われています）を学ぶのも重要な事ですので、次の節では、従来型の構文解析手法について解説します。

## 古典的な構文解析器

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
            return new JsonAst.JsonNumber(
                ((Number)currentToken.value).doubleValue()
            );
        }
        throw new parser.ParseException(
            "expected: number, actual: " + currentToken.value
        );
    }

    private Pair<JsonAst.JsonString, JsonAst.JsonValue> parsePair() {
        // オブジェクトのキーは必ず文字列
        Token keyToken = tokenizer.current();
        if (keyToken.type != Token.Type.STRING) {
            throw new parser.ParseException(
                "expected: string for object key, actual: " + keyToken.value
            );
        }
        JsonAst.JsonString key = new JsonAst.JsonString(
            (String)keyToken.value
        );
        tokenizer.moveNext(); // キー文字列トークンを消費

        if(tokenizer.current().type != Token.Type.COLON) {
            throw new parser.ParseException(
                "expected: `:`, actual: " + tokenizer.current().value
            );
        }
        tokenizer.moveNext();
        var value = parseValue();
        return new Pair<>(key, value);
    }

    private JsonAst.JsonObject parseObject() {
        if(tokenizer.current().type != Token.Type.LBRACE) {
            throw new parser.ParseException(
                "expected `{`, actual: " + tokenizer.current().value
            );
        }

        tokenizer.moveNext();
        if(tokenizer.current().type == Token.Type.RBRACE) {
            return new JsonAst.JsonObject(new ArrayList<>());
        }

        List<Pair<JsonAst.JsonString, JsonAst.JsonValue>> members = 
            new ArrayList<>();
        var pair= parsePair();
        members.add(pair);

        while(tokenizer.moveNext()) {
            if(tokenizer.current().type == Token.Type.RBRACE) {
                return new JsonAst.JsonObject(members);
            }
            if(tokenizer.current().type != Token.Type.COMMA) {
                throw new parser.ParseException(
                    "expected: `,`, actual: " + tokenizer.current().value
                );
            }
            tokenizer.moveNext();
            pair = parsePair();
            members.add(pair);
        }

        throw new parser.ParseException("unexpected EOF");
    }

    private JsonAst.JsonArray parseArray() {
        if(tokenizer.current().type != Token.Type.LBRACKET) {
            throw new parser.ParseException(
                "expected: `[`, actual: " + tokenizer.current().value
            );
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
                throw new parser.ParseException(
                    "expected: `,`, actual: " + tokenizer.current().value
                );
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

## JSONの字句解析器

JSONの字句解析器について、この節では、主要な部分に着目して説明します。

### ヘッダ部

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

### 本体部

`SimpleTokenizer`の主要なメソッドは、

- `tokenizeNumber()`
- `tokenizeStringLiteral()`
- `accept()`
- `moveNext()`
- `current()`

となります。以下、これらのメソッドについて説明します。

### tokenizeNumber

`tokenizeNumber()`メソッドは、文字列の現在位置から開始して、数値トークンを切り出すためのメソッドです。引数`positive`の値が`true`なら、正の整数を、`false`なら、負の整数をトークンとして切り出しています。返り値はトークンの切り出しに成功したか、失敗したかを表します。

### tokenizeStringLiteral

`tokenizeStringLiteral()` メソッドは、文字列の現在位置から開始して、文字列リテラルトークンを切り出すためのメソッドです。返り値はトークンの切り出しに成功したか、失敗したかを表します。

### accept

`accept()` メソッドは、文字列の現在位置から開始して、指定された文字列`literal`にマッチした場合に、対応する種類`type`と値`value`を持つトークンを生成し、内部状態（`fetched`フィールドと`index`フィールド）を更新します。このメソッドは主に`moveNext()`メソッド内部で、固定的なリテラル（例: `true`, `false`, `{`, `}` など）をトークン化する際に使用されます。

### moveNext

`moveNext()` メソッドは、字句解析器の中核となるメソッドです。呼び出されると、次のトークンを発見するまで、文字列の位置を進め、トークンが発見されたら、トークンを`fetched`に格納して、`true`を返します。トークン列の終了位置に来たら`false`を返します。これは、`Iterator`パターンの一種とも言えますが、典型的な`Iterator`と異なり、`moveNext()`が副作用を持つ点がポイントでしょうか。この点は、.NETの`IEnumerator`のアプローチを参考にしました。

### current

`current()`メソッドは、`moveNext()`メソッドが`true`を返したあとに呼び出すと、切り出せたトークンを取得することができます。`moveNext()`を次に呼び出すと、`current()`の値が変わってくる点に注意が必要です。

## JSONの構文解析器

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

### parseTrue

`parseTrue()`メソッドは、規則`TRUE`に対応するメソッドで、JSONの`true`に対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
    private JsonAst.JsonTrue parseTrue() {
        Token currentToken = tokenizer.current();
        if(currentToken.type == Token.Type.TRUE) {
            tokenizer.moveNext(); // トークンを消費
            return new JsonAst.JsonTrue();
        }
        throw new parser.ParseException(
            "expected: true, actual: " + currentToken.value
        );
    }
```

見るとわかりますが、`tokenizer`が保持している次のトークンの値が`true`だったら、`JsonAst.JsonTrue`のインスタンスを返しているだけですね。ほぼ、字句解析器に処理を丸投げしているだけですから、詳しい説明は不要でしょう。

### parseFalse

`parseFalse()`メソッドは、規則`FALSE`に対応するメソッドで、JSONの`false`に対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
    private JsonAst.JsonFalse parseFalse() {
        Token currentToken = tokenizer.current();
        if(currentToken.type == Token.Type.FALSE) {
            tokenizer.moveNext(); // トークンを消費
            return new JsonAst.JsonFalse();
        }
        throw new parser.ParseException(
            "expected: false, actual: " + currentToken.value
        );
    }
```

実装については、`parseTrue()`とほぼ同様なので説明は省略します。

### parseNull

`parseNull()`メソッドは、規則`NULL`に対応するメソッドで、JSONの`null`に対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
    private JsonAst.JsonNull parseNull() {
        Token currentToken = tokenizer.current();
        if(currentToken.type == Token.Type.NULL) {
            tokenizer.moveNext(); // トークンを消費
            return new JsonAst.JsonNull();
        }
        throw new parser.ParseException(
            "expected: null, actual: " + currentToken.value
        );
    }
```

実装については、`parseTrue()`とほぼ同様なので説明は省略します。

### parseString

`parseString()`メソッドは、規則`STRING`に対応するメソッドで、JSONの`"..."`に対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
    private JsonAst.JsonString parseString() {
        Token currentToken = tokenizer.current();
        if (currentToken.type == Token.Type.STRING) {
            tokenizer.moveNext(); // トークンを消費
            return new JsonAst.JsonString((String)currentToken.value);
        }
        throw new parser.ParseException(
            "expected: string, actual: " + currentToken.value
        );
    }
```

実装については、`parseTrue()`とほぼ同様なので説明は省略します。

### parseNumber

`parseNumber()`メソッドは、規則`NUMBER`に対応するメソッドで、JSONの`1, 2, 3, 4, ...`に対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
    private JsonAst.JsonNumber parseNumber() {
        Token currentToken = tokenizer.current();
        // SimpleJsonTokenizerの実装では数値はToken.Type.INTEGERとして扱われる
        if (currentToken.type == Token.Type.INTEGER) {
            tokenizer.moveNext(); // トークンを消費
            // JsonNumberはdoubleを期待するが、tokenizerはintを返すのでキャスト
            return new JsonAst.JsonNumber((
                (Number)currentToken.value).doubleValue()
            );
        }
        throw new parser.ParseException(
            "expected: number, actual: " + currentToken.value
        );
    }
```

実装については、`parseTrue()`とほぼ同様なので説明は省略します。

### parseObject

`parseObject()`メソッドは、規則`object`に対応するメソッドで、JSONのオブジェクトリテラルに対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
    private JsonAst.JsonObject parseObject() {
        if(tokenizer.current().type != Token.Type.LBRACE) {
            throw new parser.ParseException(
                "expected `{`, actual: " + tokenizer.current().value
            );
        }

        tokenizer.moveNext();
        if(tokenizer.current().type == Token.Type.RBRACE) {
            return new JsonAst.JsonObject(new ArrayList<>());
        }

        List<Pair<JsonAst.JsonString, JsonAst.JsonValue>> members = 
            new ArrayList<>();
        var pair= parsePair();
        members.add(pair);

        while(tokenizer.moveNext()) {
            if(tokenizer.current().type == Token.Type.RBRACE) {
                return new JsonAst.JsonObject(members);
            }
            if(tokenizer.current().type != Token.Type.COMMA) {
                throw new parser.ParseException(
                    "expected: `,`, actual: " + tokenizer.current().value
                );
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

### parseArray

`parseArray()`メソッドは、規則`array`に対応するメソッドで、JSONの配列リテラルに対応するものを解析するメソッドでもあります。実装は以下のようになります：

```java
    private JsonAst.JsonArray parseArray() {
        if(tokenizer.current().type != Token.Type.LBRACKET) {
            throw new parser.ParseException(
                "expected: `[`, actual: " + tokenizer.current().value
            );
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
                throw new parser.ParseException(
                    "expected: `,`, actual: " + tokenizer.current().value
                );
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

## まとめ

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
    *   テストケースとして、`123`, `-0.5`, `1.2e3`, `0.4E-1` のような多様な数値表現を試してみてください
[^1]: ECMA-404 The JSON data interchange syntax 2nd edition, December 2017.  https://ecma-international.org/publications-and-standards/standards/ecma-404/