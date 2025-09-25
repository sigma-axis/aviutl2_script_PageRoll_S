# PageRoll_S AviUtl/AviUtl ExEdit2 スクリプト

ページを丸めるように画像を変形するアニメーション効果と，シーンチェンジです．AviUtl (無印) のシーンチェンジ「ロール(横)」「ロール(縦)」の拡張版・AviUtl2 移植版で，めくる方向を斜めにしたり，丸める部分の太さの調整などの追加機能があります．

無印の AviUtl と AviUtl ExEdit2 の両方に対応しています．

[ダウンロードはこちら．](https://github.com/sigma-axis/aviutl2_script_PageRoll_S/releases) [紹介動画．](https://www.nicovideo.jp/watch/sm45441228)

https://github.com/user-attachments/assets/ee82a50a-59bc-4256-9163-d843ca322a18

https://github.com/user-attachments/assets/b83fc0ba-7e1a-4ee5-b033-b4d8879243a4

- <details>
  <summary>元画像出典 (クリックで表示):</summary>

  1.  https://www.pexels.com/photo/assorted-color-kittens-45170
  1.  https://www.pexels.com/photo/four-ace-game-cards-534181
  1.  https://www.pexels.com/photo/green-leafed-tree-beside-body-of-water-during-daytime-158063
  1.  https://www.pexels.com/photo/vegetables-and-tomatoes-on-cutting-board-255501
  1.  https://www.pexels.com/photo/assorted-color-house-facade-in-park-534124
  1.  https://www.pexels.com/photo/brown-wooden-signage-hanging-beside-wall-434446
  1.  https://www.pexels.com/photo/assorted-car-license-plates-533669
  </details>

##  動作要件

### AviUtl (無印)

- AviUtl 1.10

  http://spring-fragrance.mints.ne.jp/aviutl

- 拡張編集 0.92

- GLShaderKit

  https://github.com/karoterra/aviutl-GLShaderKit

  - `v0.4.0` / `v0.5.0` で動作確認．

### AviUtl ExEdit2

- AviUtl ExEdit2

  http://spring-fragrance.mints.ne.jp/aviutl

  - `beta12` で動作確認済み．

## 導入方法

- AviUtl (無印) の場合

  以下のフォルダのいずれかに `PageRoll_S.anm`, `PageRoll_S.scn`, `PageRoll_S.lua`, `PageRoll_S.frag` の 4 つのファイルをコピーしてください．

  1. `exedit.auf` のあるフォルダにある `script` フォルダ
  1. (1) のフォルダにある任意の名前のフォルダ

- AviUtl ExEdit2 の場合

  以下のフォルダのいずれかに `PageRoll_S.anm2` と `PageRoll_S(シーンチェンジ).scn2` の 2 つのファイルをコピーしてください．

  1.  スクリプトフォルダ
      - AviUtl2 のメニューの「その他」 :arrow_right: 「アプリケーションデータ」 :arrow_right: 「スクリプトフォルダ」で表示されます．
  1.  (1) のフォルダにある任意の名前のフォルダ

##  スクリプトの種類

フィルタ効果 (アニメーション効果) とシーンチェンジが 1 つずつ追加されます．

- AviUtl2 の場合，追加メニュー内の分類は「オブジェクト追加メニューの設定」の「ラベル」項目で変更できます．

### フィルタ効果 (アニメーション効果)

`PageRoll_S` という名前のフィルタ効果 (アニメーション効果)です．画像単体にページを丸めたような変形を適用します．

https://github.com/user-attachments/assets/b83fc0ba-7e1a-4ee5-b033-b4d8879243a4

- AviUtl2 の場合，初期状態だと「オブジェクトを追加」メニューの「変形」に「PageRoll_S」が追加されています．

### シーンチェンジ

AviUtl (無印) だと `PageRoll_S` という名前，AviUtl2 だと `PageRoll_S(シーンチェンジ)` の名前のシーンチェンジ効果です．シーン全体をページを丸めるように動かして次のシーンに移行します．

https://github.com/user-attachments/assets/ee82a50a-59bc-4256-9163-d843ca322a18

- AviUtl2 の場合，初期状態だと「オブジェクトを追加」メニューの「シーンチェンジ」に「PageRoll_S(シーンチェンジ)」が追加されています．
- AviUtl (無印) と AviUtl2 で名前が違うのは，AviUtl2 だとスクリプトの分類がフィルタ効果とシーンチェンジで違っていても，名前が重複できない仕様のためです．

##  パラメタの説明

AviUtl (無印) 版では AviUtl ExEdit2 版と比べてパラメタの並びが異なっていたり，一部がパラメタ設定ダイアログ経由での設定になりますが，特記事項がない限り基本的には同じ機能です．

また，いくつかのパラメタは[フィルタ効果](#フィルタ効果-アニメーション効果)と[シーンチェンジ](#シーンチェンジ)で共通しています．

### 共通の設定項目

<img width="720" height="222" alt="AviUtl1のアニメーション効果版のGUIその1" src="https://github.com/user-attachments/assets/df7e0552-840d-4264-a5a7-b05224404369" />

<img width="298" height="262" alt="AviUtl1のアニメーション効果版のGUIその2" src="https://github.com/user-attachments/assets/5dccccd2-6cd4-4d8f-90ff-3e3b60827278" />

<img width="500" height="350" alt="AviUtl2のフィルタ効果版のGUI" src="https://github.com/user-attachments/assets/39ad6324-e4ae-4d9f-ac0c-44e928bbc987" />

####  `角度`

ページをめくる方向を指定します．`0` で真下から，時計回りに正です．

度数法で指定，最小値は `-720.00`, 最大値は `720.00`, 初期値は `-90.00`.

####  `太さ`

丸めたページの，円柱としての直径が変化します．

1.  [フィルタ効果](#フィルタ効果-アニメーション効果)の場合:

    丸めた円柱の画面上の幅 (直径に [`視野角`](#視野角) の影響を加味した大きさ) をピクセル単位で指定します．

    最小値は `8.00`, 最大値は `4000.00`, 初期値は `80.00`

1.  [シーンチェンジ](#シーンチェンジ)の場合:

    シーンの対角線の長さに対する比で指定．ただし最小でも画面上で `8` ピクセル以上になります．

    %単位で指定，最小値は `2.00`, 最大値は `150.00`, 初期値は `20.00`

####  `視点` / `視点X` / `視点Y`

丸めたページの立体感の基準となる視点の位置を指定します．シーンの中央からの相対位置で，ピクセル単位で指定します．マウスによるアンカー操作でも指定できます．

- AviUtl (無印) の場合

  `視点` がパラメタ設定ダイアログで指定できます．

  `{ X座標, Y座標 }` の形式で指定，初期値は `{0,0}`.

  - [シーンチェンジ](#シーンチェンジ)の場合はアンカーが無効です．(そもそも非対応?)

- AviUtl ExEdit2 の場合

  `視点X` と `視点Y` がトラックバーで指定できます．

  X, Y 座標ともに，最小値は `-4000.00`, 最大値は `4000.00`, 初期値は `0.00`.

####  `視野角`

丸めたページの立体感の基準となる視野角を指定します．ここでの視野角は，オブジェクトやシーンの対角線の視程角度です．

大きくすると遠近感が強くなり，`0` を指定すると [orthographic projection (正射影)](https://en.wikipedia.org/wiki/Orthographic_projection) になります．

度数法で指定，最小値は `0.00`, 最大値は `120.00`, 初期値は `70`.

####  `陰影`

丸めたページの縁部分を影がかかったように暗く描画します．

強さを %単位で指定，最小値は `0.00`, 最大値は `100.00`, 初期値は `50.00`

### フィルタ効果 (アニメーション効果) の設定項目

<img width="720" height="222" alt="AviUtl1のアニメーション効果版のGUIその1" src="https://github.com/user-attachments/assets/df7e0552-840d-4264-a5a7-b05224404369" />

<img width="298" height="262" alt="AviUtl1のアニメーション効果版のGUIその2" src="https://github.com/user-attachments/assets/5dccccd2-6cd4-4d8f-90ff-3e3b60827278" />

<img width="500" height="350" alt="AviUtl2のフィルタ効果版のGUI" src="https://github.com/user-attachments/assets/39ad6324-e4ae-4d9f-ac0c-44e928bbc987" />

####  `距離`

「丸めて転がした」距離を指定します．

ピクセル単位で指定，最小値は `0.00`, 最大値は `4000.00`, 初期値は `0.00`.

####  `領域外も描画`

オブジェクトの画像サイズを拡げて，丸まった部分がサイズ内に収まるようにします．

初期値は ON.

### シーンチェンジの設定項目

<img width="720" height="180" alt="AviUtl1のシーンチェンジのGUIその1" src="https://github.com/user-attachments/assets/87d164cd-9a0b-49c8-bb3d-915cb05d4b98" />

<img width="298" height="294" alt="AviUtl1のシーンチェンジのGUIその2" src="https://github.com/user-attachments/assets/8c408231-deaa-410c-9819-206c5d3ba39c" />

<img width="500" height="316" alt="AviUtl2のシーンチェンジのGUI" src="https://github.com/user-attachments/assets/5e7aae49-5588-4f32-a9ed-1a700d148fe9" />

####  `反転`

AviUtl ExEdit2 版にのみあります．AviUtl (無印) のシーンチェンジ効果にある「反転」と同じ機能のチェックボックスです．

初期値は OFF.

### `PI`

パラメタインジェクション (parameter injection) です．各種パラメタを Lua の数式で直接指定できます．また，任意のスクリプトコードを実行する記述領域にもなります．`PI` 経由でのみ指定できる設定もあります．

[フィルタ効果](#フィルタ効果-アニメーション効果)と[シーンチェンジ](#シーンチェンジ)，AviUtl (無印) 版と AviUtl ExEdit2 版で指定方法が異なります．

####  アニメーション効果の `PI` (AviUtl (無印) 版)

初期値は `nil`. テーブル型を指定すると `obj.track0` などの代替値として使用されます．

```lua
{
  [0] = track0, -- boolean 型で "領域外も描画" の項目を上書き，または nil. 0 を false, 0 以外を true 扱いとして number 型も可能．
  [1] = track1, -- number 型で "距離" の項目を上書き，または nil.
  [2] = track2, -- number 型で "角度" の項目を上書き，または nil.
  [3] = track3, -- number 型で "太さ" の項目を上書き，または nil.
  [4] = check0, -- number 型で "陰影" の項目を上書き，または nil.
}
```

####  フィルタ効果の `PI` (AviUtl ExEdit2 版)

初期値は空欄．テーブル型の中身として解釈され，各種パラメタの代替値として使用されます．

```lua
{
  distance = distance, -- number 型で "距離" の項目を上書き，または nil.
  angle = angle,       -- number 型で "角度" の項目を上書き，または nil.
  width = width,       -- number 型で "太さ" の項目を上書き，または nil.
  X = X,               -- number 型で "視点X" の項目を上書き，または nil.
  Y = Y,               -- number 型で "視点Y" の項目を上書き，または nil.
  fov = fov,           -- number 型で "視野角" の項目を上書き，または nil.
  shadow = shadow,     -- number 型で "陰影" の項目を上書き，または nil.
  unbound = unbound,   -- boolean 型で "領域外も描画" の項目を上書き，または nil. 0 を false, 0 以外を true 扱いとして number 型も可能．
}
```
- テキストボックスには冒頭末尾の波括弧 (`{}`) を省略して記述してください．

####  シーンチェンジの `PI` (AviUtl (無印) 版)

初期値は `nil`. テーブル型を指定すると `obj.track0` などの代替値として使用されます．

```lua
{
  [1] = track0,  -- number 型で "角度" の項目を上書き，または nil.
  [2] = track1,  -- number 型で "太さ" の項目を上書き，または nil.
  phase = phase, -- number 型でシーンチェンジの進捗を直接指定 (0.0 -- 1.0)，または nil.
}
```

####  シーンチェンジの `PI` (AviUtl ExEdit2 版)

初期値は空欄．テーブル型の中身として解釈され，各種パラメタの代替値として使用されます．

```lua
{
  angle = angle,     -- number 型で "角度" の項目を上書き，または nil.
  width = width,     -- number 型で "太さ" の項目を上書き，または nil.
  X = X,             -- number 型で "視点X" の項目を上書き，または nil.
  Y = Y,             -- number 型で "視点Y" の項目を上書き，または nil.
  fov = fov,         -- number 型で "視野角" の項目を上書き，または nil.
  shadow = shadow,   -- number 型で "陰影" の項目を上書き，または nil.
  reverse = reverse, -- boolean 型で "反転" の項目を上書き，または nil. 0 を false, 0 以外を true 扱いとして number 型も可能．
  phase = phase,     -- number 型でシーンチェンジの進捗を直接指定 (0.0 -- 1.0)，または nil.
}
```
- テキストボックスには冒頭末尾の波括弧 (`{}`) を省略して記述してください．

##  TIPS

1.  AviUtl 無印版の場合，テキストエディタで `PageRoll_S.anm`, `PageRoll_S.scn`, `PageRoll_S.lua`, `PageRoll_S.frag` を開くと冒頭付近にファイルバージョンが付記されています．

    ```lua
    --
    -- VERSION: v1.00
    --
    ```

    ファイル間でバージョンが異なる場合，更新漏れの可能性があるためご確認ください．

1.  AviUtl (無印) のシーンチェンジ「ロール(横)」「ロール(縦)」の，[`太さ`](#太さ) に対応する値の計算方法は不明ですが， $1920 \times 1080$ のシーンで確認したところ，概ね画面の横幅 / 縦幅の 25% 程度でした．シーンの対角線との比だと以下の通りです．

    - ロール(横) :arrow_right: 約 21.79% (480 ピクセル).
    - ロール(縦) :arrow_right: 約 12.26% (270 ピクセル).


## 改版履歴

- **v1.00 (for beta12)** (2025-09-25)

  - 初版．


## ライセンス

このプログラムの利用・改変・再頒布等に関しては MIT ライセンスに従うものとします．

---

The MIT License (MIT)

Copyright (C) 2025 sigma-axis

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

https://mit-license.org/


#  連絡・バグ報告

- GitHub: https://github.com/sigma-axis
- Twitter: https://x.com/sigma_axis
- nicovideo: https://www.nicovideo.jp/user/51492481
- Misskey.io: https://misskey.io/@sigma_axis
- Bluesky: https://bsky.app/profile/sigma-axis.bsky.social
