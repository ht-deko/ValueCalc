# ValueCalc プロパティエディタ (ValueCalc for Object Inspector)

Delphi のオブジェクトインスペクタ上で数値計算を可能にするプロパティエディタです。コントロールの位置やサイズを計算で求めたい場合などに便利です。

## 主な機能

* **計算機能の拡張**: Delphi 6 以降の環境において、整数型および実数型のプロパティ入力欄で直接数式（例: `100+(25+6)*0`）を入力・計算できます。
* **FMX 対応の強化**: `TRTTIContext.GetType()` の採用により、FireMonkey (FMX) 環境における `Font.Size` や `Position.X` などのプロパティ計算が正しく機能するようになりました。
* **豊富な数学関数**: 実数式・整数式それぞれに特化した関数をサポートしています。
* **複数選択時・ビット演算オプション**:
  * `USEMULTI` オプションにより、複数選択時の各コンポーネントのプロパティ（例: `Width`）を個別に評価可能です。
  * `USESTRICTEXP` オプションにより、実数式で論理（ビット）演算やシフト演算を使用する際の演算子の挙動を制御できます。

---

## 動作環境

Delphi 6 以降（フル機能は Delphi 2010 以降）。C++Builder 環境でも動作すると思われます。

---

## インストール手順

1. アーカイブを適当なフォルダに解凍します。
2. Delphi を起動します。
3. パッケージファイル `PkgValueCalc.dpk` を開きます。
4. プロジェクトマネージャでパッケージを右クリックし、［**インストール**］を選択します。
   * ※XE2 以降をご利用の場合、fmx をパッケージに追加するかどうかを尋ねられるので、そのまま追加してください。

---

## 使い方

コントロールの配置計算などに役立ちます。例えば、最初のボタンの `Top` を `100` とし、`Height` を `25`、マージンを `6` として縦に整列させる場合、各オブジェクトのプロパティ値として以下のような数式を指定できます。

* `100+(25+6)*0`
* `100+(25+6)*1`
* `100+(25+6)*2`
  …

> **Tip:** 計算のワーク領域が必要な場合は、コンポーネントの `Tag` プロパティの活用がおすすめです。

### 使える演算子一覧
* **整数型プロパティで使える演算子**: `+`, `-`, `*`, `div (/)`, `mod (%)`, `not (~)` , `and (&)`, `or (|)`, `xor (^)`, `shl (<<)`, `shr (>>)`
* **実数型プロパティで使える演算子**: `+`, `-`, `*`, `/`, `^` （べき乗）
* そのほか、比較演算子（`=`, `<>`, `<`, `>`, `<=`, `>=`）や論理演算子（`!`, `&&`, `||`）も使用可能です。

---

## 関数のサポート一覧

### 整数式で使える関数
`Abs`, `Ceil`, `Floor`, `Round`, `SelectOrder`, `Trunc`

### 実数式で使える関数
`Abs`, `ArcCos`, `ArcCosh`, `ArcCot`, `ArcCotH`, `ArcCsc`, `ArcCscH`, `ArcSec`, `ArcSecH`, `ArcSin`, `ArcSinh`, `ArcTan`, `ArcTanh`, `Cos`, `Cosh`, `Cot`, `Cotan`, `CotH`, `Csc`, `CscH`, `CycleToDeg`, `CycleToGrad`, `CycleToRad`, `DegToCycle`, `DegToGrad`, `DegToRad`, `Float`, `Exp`, `GradToCycle`, `GradToDeg`, `GradToRad`, `Int`, `Ln`, `LnXP1`, `Log10`, `Log2`, `Pi`, `Sec`, `Secant`, `SecH`, `SelectOrder`, `Sin`, `Sinh`, `Sqr`, `Sqrt`, `Tan`, `Tanh`

---

## スイッチ設定

`ValueCalc.inc` には以下のスイッチが用意されており、挙動を変更できます。

* **USEFLOAT**（デフォルト: ON）
  ON にすると整数型プロパティで「実数式での計算」を行うようになります。
* **USESTRICTEXP**（デフォルト: OFF）
  ON にすると実数式の中で論理（ビット）演算およびシフト演算を使うとエラーになります。OFF の場合、オペランドを整数に切り捨てた上で計算されます。
* **USEMULTI**（デフォルト: ON）
  コンポーネントが複数選択されている場合、ON だと式の評価をコンポーネントごとに実行します（Delphi 2009 以降で有効）。

> **Tip:** USEMULTI オプションがオンの場合、`SelectOrder()` はフォームデザイナでコンポーネントを選択した順序を 0 ベースの数値で返します。USEMULTI オプションがオフの場合、`SelectOrder()` は常に 0 を返します。

---

## YouTube 動画

* [YouTube 解説動画 1](http://www.youtube.com/watch?v=YSoVQT1vaEM)
* [YouTube 解説動画 2](http://www.youtube.com/watch?v=5qu7MQ3PwZE)
* [YouTube 解説動画 3](http://www.youtube.com/watch?v=Pv-J3gJ4IXQ)
* [YouTube 解説動画 4](http://www.youtube.com/watch?v=1YgdT03elYs)


## ライセンス

このプロパティエディタは無償で自由に利用できます (便宜上 MIT ライセンスを選択しています)。
