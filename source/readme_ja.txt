===============================
 Value Calc プロパティエディタ 
 (四則演算プロパティエディタ)
===============================

[何をするものなの？]
整数/実数のプリミティブ型プロパティにおいて計算を可能にします。
意味が解らないヒトは、以下の Youtube 動画をご覧ください。

http://www.youtube.com/watch?v=YSoVQT1vaEM
http://www.youtube.com/watch?v=5qu7MQ3PwZE
http://www.youtube.com/watch?v=Pv-J3gJ4IXQ
http://www.youtube.com/watch?v=1YgdT03elYs


[動作環境]
Delphi 6～ です (フル機能は 2010 以降)。
C++Builder 環境でも動作するとは思いますが検証していません。


[インストール手順]
1.アーカイブを適当な場所に解凍
2.Delphi を起動
3.パッケージ PkgValueCalc.dpk を開く。
4.プロジェクトマネージャで右クリックしてインストール 

※XE2 以降では fmx をパッケージに追加するかどうかを尋ねられると
　思うので、素直に追加してください。


[使い方]
コンポーネントの Height プロパティ等で "元々の値 + 10" とかしてみて
ください。

整数型プロパティで使える演算子は

+: 加算 (または符号恒等)
-: 減算 (または符号反転)
*: 乗算
div (/): 除算
mod (%): 剰余
not (~): ビット否定
and (&): ビット論理積
or  (|): ビット論理和
xor (^): ビット排他的論理和
shl(<<): 左シフト
shr(>>): 右シフト

実数型プロパティで使える演算子は基本的に四則演算のみです。
(USESTRICTEXP スイッチに依存します)

+: 加算 (または符号恒等)
-: 減算 (または符号反転)
*: 乗算
/: 除算
^: べき乗

一応比較演算子も使えます。

= (==) : 等しい
<> (!=): 等しくない
<      : より小さい
>      : より大きい
<=     : 以下
>=     : 以上

加えて論理演算子も使えます (論理ビット演算子ではありません)。

! : 論理否定
&&: 論理積
||: 論理和

実数の場合には、1.5 のような値と、1E-5 のような指数表記値が
使えます。

整数型 / 実数型いずれにおいても 16 進数値を入力できます。
0x10 (C++) や $20 (Pascal) は整数値として認識されますが、
実数の式の中で使う事ができます。

以下の関数を使う事もできます。

・整数式で使える関数
Abs(I):I
Ceil(F):I
Floor(F):I
Round(F):I
SelectOrder():I
Trunc(F):I

・実数式で使える関数
Abs(F):F
ArcCos(F):F
ArcCosh(F):F
ArcCot(F):F
ArcCotH(F):F
ArcCsc(F):F
ArcCscH(F):F
ArcSec(F):F
ArcSecH(F):F
ArcSin(F):F
ArcSinh(F):F
ArcTan(F):F
ArcTanh(F):F
Cos(F):F
Cosh(F):F
Cot(F):F
Cotan(F):F
CotH(F):F
Csc(F):F
CscH(F):F
CycleToDeg(F):F
CycleToGrad(F):F
CycleToRad(F):F
DegToCycle(F):F
DegToGrad(F):F
DegToRad(F):F
Float(I):F
Exp(F):F
GradToCycle(F):F
GradToDeg(F):F
GradToRad(F):F
Int(F):F
Ln(F):F
LnXP1(F):F
Log10(F):F
Log2(F):F
Pi():F
Sec(F):F
Secant(F):F
SecH(F):F
SelectOrder():F
Sin(F):F
Sinh(F):F
Sqr(F):F
Sqrt(F):F
Tan(F):F
Tanh(F):F

※()内は引数の型、:に続く文字は戻り値の型を表しています。
　(F=実数、I=整数)

例えば、実数型プロパティでシフト演算を行うには Float(2 shl 4) のように
Float() 関数を使います。逆に整数型プロパティで実数を扱いたい場合には
Trunc(10 * 1.5) のように Trunc() 関数等で整数値にします。

関数は Delphi-RTL の関数と同じです。Power() がありませんが、
べき乗は ^ 演算子として実装されています。整数式の時は xor ですが、
実数式の場合にはべき乗となります。


[スイッチ]
ValueCalc.inc にはスイッチが用意されており、いくつかの挙動を変更する事が
できます。

・USEFLOAT (デフォルト: ON)
ON だと整数型プロパティで "実数式での計算を行う" ようになります。
OFF だと、整数型プロパティでは整数式での計算が行われます。

・USESTRICTEXP (デフォルト: OFF)
ON だと実数式の中で論理(ビット)演算及びシフト演算を使うと、エラーに
なります。OFF だと実数式中で論理(ビット)演算及びシフト演算を使うと、
オペランドが整数に切り捨てられた上で計算が行われます。

・USEMULTI (デフォルト: ON)
コンポーネントが複数選択されている場合、ON だと式の評価をコンポーネント
毎に実行します。OFF だとコンポーネントが複数選択されていても式を一度しか
実行しません。Delphi 2009 以降でのみ ON にできます。


[Tag プロパティは電卓！]
Value Calc プロパティエディタをインストールしておくと、Tag プロパティで
ちょっとした計算ができるようになります。


[計算できて何が嬉しいの？]
例えば 10 個のボタンがあって、最初のボタンが座標 (100, 100) にあって、
Height が25、これをマージン 6 で縦に整列させるには、

100+(25+6)*0
100+(25+6)*1
100+(25+6)*2
　…
100+(25+6)*9

を指定してやればいい事になります。
(式はコードエディタとかにコメントで貼り付けとけば便利です)

USEMULTI スイッチが有効であれば、コンポーネントを複数選択し、
100+(25+6)*SelectOrder
後述するプロパティ参照が使える 2010 以降なら
100+(25+6)*TabOrder
のようにする事もできます。


[数字のプロパティなのに計算できないよ…(´・ω・`)]
ちゃんとインストールされていないか、プロパティの型がプリミティブ型では
ないと思われます。uValueCalcPropEditorReg.pas を編集し、一致するであろう
型を RegisterPropertyEditor() で登録してください。

TIntCalcPropEditor: 
整数型 (Integer) 用のプロパティエディタ。

TInt64CalcPropEditor: 
整数型 (Int64) 用のプロパティエディタ。

TFloatCalcPropEditor: 
実数型 (Extended) 用のプロパティエディタ。

※大抵は TIntCalcPropEditor / TFloatCalcPropEditor でいいハズです。


[Delphi 2009 以降なら…]
USEMULTI オプションが使えます。オンの場合、SelectOrder() 関数は
コンポーネントを選択した順序を 0 ベースの数値で返します。
USEMULTI オプションがオフの場合、SelectOrder() 関数は常に 0 を返します。


[Delphi 2010 以降なら…]
RTTI を活かして、プロパティを参照できます。
例えば、Button (VCL) の Height を Font.Sizeの 2 倍にしたい時は
Height プロパティで "Font.Size * 2" という指定ができます。


[コピーライトとかその辺りの面倒臭いもの]
特に制限なく無償で使えます。


by DEKO
