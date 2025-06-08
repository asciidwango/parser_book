---
title: "TikZ動作確認テスト"
---

# TikZのテスト

## シンプルな図形

```{=latex}
\begin{center}
\begin{tikzpicture}
  \draw[thick] (0,0) circle (1cm);
  \draw[fill=blue!20] (0,0) -- (0.8,0) arc (0:60:0.8cm) -- cycle;
  \node at (0.4,0.2) {$60°$};
\end{tikzpicture}
\end{center}
```

## 状態遷移図の例

```{=latex}
\begin{center}
\begin{tikzpicture}[node distance=3cm,auto]
  % 状態の定義
  \node[state,initial] (s0) {$S_0$};
  \node[state] (s1) [right of=s0] {$S_1$};
  \node[state,accepting] (s2) [right of=s1] {$S_2$};
  
  % 遷移の定義
  \path[->]
    (s0) edge node {a} (s1)
    (s1) edge node {b} (s2)
    (s1) edge [loop above] node {a} ()
    (s2) edge [loop above] node {b} ();
\end{tikzpicture}
\end{center}
```

## 構文木の例

```{=latex}
\begin{center}
\begin{tikzpicture}[
  level distance=1.5cm,
  sibling distance=2cm,
  every node/.style={circle,draw,minimum size=1cm}
]
  \node {+}
    child { node {*}
      child { node {a} }
      child { node {b} }
    }
    child { node {c} };
\end{tikzpicture}
\end{center}
```

## フローチャートの例

```{=latex}
\begin{center}
\begin{tikzpicture}[node distance=2cm]
  % ノードのスタイル定義
  \tikzstyle{startstop} = [rectangle, rounded corners, minimum width=3cm, minimum height=1cm, text centered, draw=black, fill=red!30]
  \tikzstyle{process} = [rectangle, minimum width=3cm, minimum height=1cm, text centered, draw=black, fill=orange!30]
  \tikzstyle{decision} = [diamond, minimum width=3cm, minimum height=1cm, text centered, draw=black, fill=green!30]
  \tikzstyle{arrow} = [thick,->,>=stealth]
  
  % ノードの配置
  \node (start) [startstop] {開始};
  \node (input) [process, below of=start] {入力を読む};
  \node (decide) [decision, below of=input, yshift=-0.5cm] {構文解析成功?};
  \node (accept) [process, right of=decide, xshift=2cm] {受理};
  \node (reject) [process, left of=decide, xshift=-2cm] {拒否};
  \node (stop) [startstop, below of=decide, yshift=-1cm] {終了};
  
  % 矢印の描画
  \draw [arrow] (start) -- (input);
  \draw [arrow] (input) -- (decide);
  \draw [arrow] (decide) -- node[anchor=south] {はい} (accept);
  \draw [arrow] (decide) -- node[anchor=south] {いいえ} (reject);
  \draw [arrow] (accept) |- (stop);
  \draw [arrow] (reject) |- (stop);
\end{tikzpicture}
\end{center}
```