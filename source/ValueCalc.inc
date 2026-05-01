// Options:
// -----------------------------------------------------------------------------
{* [USE FLOAT] オプション: (デフォルト: ON)                                   *}
{* 有効の場合、整数値のプロパティで実数の計算を行えるようになる。             *}
{* 例えば、VCL コンポーネントの Height で 20*1.5 のような計算が可能になるが、 *}
{* 整数演算固有のシフト演算、論理(ビット)演算、div (整数除算) 等は使えなくなる*}
{* (USESTRICTEXP が ON の場合)。計算結果は整数に切り捨てられる。              *}
{$DEFINE USEFLOAT}

{* [USE MULTI] オプション: (デフォルト: ON)                                   *}
{* 有効の場合、複数選択されたコンポーネントに対して複数の式を実行する。       *}
{* 無効の場合、最初に選択されたコンポーネントの値が基準となり、式は一度しか   *}
{* 実行されない。Delphi 2009 以降でのみ有効にできる。                         *}
{$DEFINE USEMULTI}

{* [USE STRICTEXP] オプション: (デフォルト: OFF)                              *}
{* 有効の場合、実数式の中で論理演算及びシフト演算を行うと、「無効な演算子」   *}
{* エラーになる。無効の場合、実数式の中で論理演算及びシフト演算を行うと、     *}
{* オペランドは整数に切り捨てられて計算が行われる。                           *}
//{$DEFINE USESTRICTEXP}

// Compiler Switches:
// -----------------------------------------------------------------------------
// 2009 or later
{$IF CompilerVersion >= 20.0}
  {$IFDEF USEMULTI}
    {$DEFINE USEMULTIEXP}
  {$ENDIF}
  // 2010 or later
  {$IF CompilerVersion >= 21.0}
    {$DEFINE HASRTTI}
    // XE2 or later
    {$IF CompilerVersion >= 23.0}
      {$DEFINE HASFMX}
      // XE4 or later
      {$IF CompilerVersion >= 25.0}
        {$DEFINE IFENDNEEDFIX}
      {$IFEND}
    {$IFEND}
  {$IFEND}
{$IFEND}
