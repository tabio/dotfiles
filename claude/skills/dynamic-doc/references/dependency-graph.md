# ② 依存グラフ探索

**用途**: アーキテクチャ図・コンポーネント/モジュール依存・サービスマップなど「たくさんのノードと矢印の網」。
静的なMermaid図が **潰れる・矢印が絡む** 問題を、クリックで近傍だけ強調（focus+context）・種別フィルタ・
検索・上流/下流ハイライトで解消する。

`GraphView` エンジンを共有する（[html-scaffold.md](html-scaffold.md) の4節）。
このファイルは `mountGraphBlock(block, stage, panel)` の実装レシピ。

---

## データ形（DATA.blocks[] の1要素）

```javascript
{
  id:'arch', title:'全体アーキテクチャ', pattern:'graph', role:'overview', // ← 先頭の全体像として使う場合
  layout:'dagre',            // 'dagre'(階層) / 'concentric' / 'grid' / 'cose'
  rankDir:'LR',              // dagre時の方向: 'LR'(左→右) / 'TB'(上→下)
  nodes:[
    { id:'web',   label:'Web',        type:'frontend', meta:'Next.js / SSR' },
    { id:'bff',   label:'BFF',        type:'api',      meta:'GraphQL' },
    { id:'order', label:'注文サービス', type:'service',  meta:'Go' },
    // linkTo を持つノードは二重枠になり、ダブルクリックで対応する詳細ブロックへジャンプできる（全体像→詳細の導線）
    { id:'pay',   label:'決済サービス', type:'service',  meta:'Go', linkTo:'pay-flow' },
    { id:'db',    label:'注文DB',      type:'db',       meta:'PostgreSQL' },
    { id:'mq',    label:'イベントバス', type:'queue',    meta:'Kafka' },
    { id:'stripe',label:'Stripe',     type:'external',  meta:'外部決済' },
  ],
  edges:[
    { id:'e1', source:'web',   target:'bff',   label:'GraphQL' },
    { id:'e2', source:'bff',   target:'order', label:'gRPC' },
    { id:'e3', source:'bff',   target:'pay',   label:'gRPC' },
    { id:'e4', source:'order', target:'db',    label:'SQL' },
    { id:'e5', source:'order', target:'mq',    label:'publish' },
    { id:'e6', source:'pay',   target:'mq',    label:'subscribe' },
    { id:'e7', source:'pay',   target:'stripe',label:'HTTPS' },
  ],
}
```

- `type` は色分け・フィルタの単位（`TYPE_COLORS` に対応。無い種別は色を足す）。
- `meta` はノード選択時に右パネルへ表示する補足。
- **エッジの向き＝依存の向き**。「A→B」は「AがBに依存/呼び出す」で統一する。

---

## 実装

```javascript
function mountGraphBlock(block, stage, panel){
  const wrap=document.createElement('div');
  wrap.style.cssText='display:flex;flex-direction:column;gap:10px;flex:1;min-height:0';
  wrap.innerHTML=`
    <div class="toolbar" style="display:flex;gap:8px;flex-wrap:wrap;align-items:center">
      <div class="chips filters"></div>
      <span style="flex:1"></span>
      <button class="btn" data-act="up"   title="選択ノードの依存先(上流)だけ">上流</button>
      <button class="btn" data-act="down" title="選択ノードの被依存(下流)だけ">下流</button>
      <button class="btn" data-act="reset">全体表示</button>
      <select class="btn layoutSel">
        <option value="dagre">階層(dagre)</option>
        <option value="concentric">同心円</option>
        <option value="cose">力学</option>
        <option value="grid">グリッド</option>
      </select>
    </div>
    <div class="graph"></div>`;
  stage.appendChild(wrap);
  panel.innerHTML=`<h3>使い方</h3>
    <div style="font-size:13px;line-height:1.7">
      ・ノードをクリック → 近傍だけ強調<br>・上/下流ボタン → 依存の連鎖を辿る<br>
      ・種別チップ → 表示の絞り込み<br>・上部の検索 → ノードへジャンプ<br>
      ・二重枠のノードをダブルクリック → 詳細ブロックへ<br>・背景クリック → 解除</div>
    <h3 style="margin-top:16px">凡例</h3><div class="chips legend"></div>
    <h3 style="margin-top:16px">選択中</h3><div class="narration detail">（ノード未選択）</div>`;

  const gv=new GraphView(wrap.querySelector('.graph'), block, {
    layout:block.layout||'dagre', rankDir:block.rankDir||'LR',
    onSelect:(d)=>{ panel.querySelector('.detail').innerHTML=
      `<div class="step-title">${d.label}</div><div><span class="tag">${d.type||''}</span>${d.meta||''}</div>`
      + (d.linkTo?`<div style="margin-top:6px"><span class="tag">詳細</span>ダブルクリックで移動</div>`:''); },
    // 全体像→詳細の導線: linkTo を持つノードのダブルクリックで対応ブロックへジャンプ
    onDrill:(d)=>{ if(d.linkTo) goToBlock(d.linkTo); },
  });

  // 凡例＋種別フィルタ（チップ）
  const types=gv.types();
  const active=new Set(types);
  const filters=wrap.querySelector('.filters'), legend=panel.querySelector('.legend');
  types.forEach(t=>{
    const color=TYPE_COLORS[t]||TYPE_COLORS.default;
    legend.insertAdjacentHTML('beforeend',`<span class="chip"><span class="dot" style="background:${color}"></span>${t}</span>`);
    const chip=document.createElement('span');
    chip.className='chip'; chip.innerHTML=`<span class="dot" style="background:${color}"></span>${t}`;
    chip.onclick=()=>{ chip.classList.toggle('off'); active.has(t)?active.delete(t):active.add(t); gv.filter(active); };
    filters.appendChild(chip);
  });

  // ツールバー配線
  const sel=()=>gv.cy.nodes('.selected')[0];
  wrap.querySelector('[data-act=up]').onclick  =()=>{ const n=sel(); if(n) gv.focusDirection(n,'up'); };
  wrap.querySelector('[data-act=down]').onclick=()=>{ const n=sel(); if(n) gv.focusDirection(n,'down'); };
  wrap.querySelector('[data-act=reset]').onclick=()=>gv.clearFocus();
  wrap.querySelector('.layoutSel').onchange=(e)=>gv.setLayout(e.target.value);

  return { graph:gv, destroy:()=>{} };
}
```

`document.getElementById('search')` からの入力は scaffold 5節が `current.graph.search()` へ流すので、
このブロックは `graph` を返すだけで検索が有効になる。

---

## 「潰れない」ための機能（このパターンの核心・必ず入れる）

| 機能 | 効果 | API |
| --- | --- | --- |
| 近傍フォーカス | クリックしたノードと隣接だけ残し、他を薄く | `gv.focus(node)` |
| 上流/下流ハイライト | 依存の連鎖（誰に依存/誰から依存）を辿る | `gv.focusDirection(node,'up'|'down')` |
| 種別フィルタ | レイヤー/種別で表示を絞る | `gv.filter(activeSet)` |
| 検索ジャンプ | 名前でノードへ移動・フォーカス | `gv.search(q)` |
| レイアウト切替 | 階層/同心円/力学で見え方を変える | `gv.setLayout(name)` |
| パン/ズーム/フィット | 大きい図を自在に | Cytoscape標準 |

---

## 設計のコツ

- **エッジの向きの意味を1つに固定** し、凡例に明記する（例:「A→B ＝ AがBに依存」）。
- ノードが非常に多い（目安50超）なら、`type` でグルーピングした **サマリグラフ** を親ブロックにし、
  ③ レイヤードリルダウンで各グループの内部へ降りられるようにする。
- 双方向依存（往復矢印）は静的図が最も潰れる箇所。フォーカス時に in/out を色で分けると理解しやすい
  （`focusDirection` を上流=1色/下流=別色に拡張してよい）。
- dagre（階層）は依存の流れ、concentric は中心性、cose はクラスタが見やすい。既定は dagre。
- 元資料に無い依存を足さない。推測で補ったエッジは `meta` に「推定」と記す。
