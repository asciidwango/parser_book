# テスト章

これはPandoc環境のテスト用サンプルです。

## コードブロックのテスト

```java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, Parser World!");
    }
}
```

## 数式のテスト

インライン数式: $E = mc^2$

ブロック数式:
$$\sum_{i=1}^{n} i = \frac{n(n+1)}{2}$$

## 画像のテスト

![AST図](img/chapter1/ast1.svg){ width=50% }
