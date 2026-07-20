# ③ レイヤードリルダウン

**用途**: C4モデル（Context→Container→Component）や「システム→サブシステム→モジュール」のような
入れ子の階層。全体像と詳細を1枚に描くと情報過多になる内容を、**俯瞰から始めてクリックで内部へズームイン、
パンくずで戻る** ことで段階的に把握する。

`GraphView` エンジンを共有する（[html-scaffold.md](html-scaffold.md) の4節。`load()` でレベルを差し替える）。
このファイルは `mountDrilldownBlock(block, stage, panel)` の実装レシピ。

---

## データ形（DATA.blocks[] の1要素）

各レベルは「② 依存グラフ」と同じ `nodes/edges`。ノードに `drill:true` と `child` を持たせると、
そのノードから子レベルへ降りられる。

```javascript
{
  id:'c4', title:'システム構成（ドリルダウン）', pattern:'drilldown',
  root:'context',
  levels:{
    context:{
      title:'コンテキスト',
      nodes:[
        { id:'user',  label:'利用者',   type:'actor' },
        { id:'sys',   label:'ECシステム', type:'service', drill:true, child:'sys.containers' },
        { id:'stripe',label:'Stripe',   type:'external' },
      ],
      edges:[ {id:'a',source:'user',target:'sys',label:'利用'}, {id:'b',source:'sys',target:'stripe',label:'決済'} ],
    },
    'sys.containers':{
      title:'ECシステム / コンテナ',
      nodes:[
        { id:'web', label:'Web',  type:'frontend' },
        { id:'api', label:'API',  type:'api', drill:true, child:'api.components' },
        { id:'db',  label:'DB',   type:'db' },
      ],
      edges:[ {id:'c',source:'web',target:'api',label:'REST'}, {id:'d',source:'api',target:'db',label:'SQL'} ],
    },
    'api.components':{
      title:'API / コンポーネント',
      nodes:[
        { id:'ctrl', label:'Controller', type:'api' },
        { id:'svc',  label:'Service',    type:'service' },
        { id:'repo', label:'Repository', type:'service' },
      ],
      edges:[ {id:'e',source:'ctrl',target:'svc'}, {id:'f',source:'svc',target:'repo'} ],
    },
  },
}
```

> `drill:true` のノードは `GRAPH_STYLE` の `node[?drill]` で二重枠になり「降りられる」ことが見て分かる。

---

## 実装

`GraphView` を1つ作り、レベルを `load()` で差し替える。パンくずで来歴を保持し、戻れるようにする。

```javascript
function mountDrilldownBlock(block, stage, panel){
  const wrap=document.createElement('div');
  wrap.style.cssText='display:flex;flex-direction:column;gap:10px;flex:1;min-height:0';
  wrap.innerHTML=`
    <div class="breadcrumb"></div>
    <div class="graph"></div>
    <div style="font-size:12px;color:var(--muted)">ダブルクリック（二重枠のノード）で内部へ / パンくずで戻る</div>`;
  stage.appendChild(wrap);
  panel.innerHTML=`<h3>現在のレベル</h3><div class="narration lvl"></div>
    <h3 style="margin-top:16px">選択中</h3><div class="narration detail">（未選択）</div>`;
  const crumb=wrap.querySelector('.breadcrumb'), lvl=panel.querySelector('.lvl'), detail=panel.querySelector('.detail');

  const path=[block.root];                    // 来歴（レベルキーのスタック）
  const gv=new GraphView(wrap.querySelector('.graph'), block.levels[block.root], {
    layout:'dagre', rankDir:'LR',
    onSelect:(d)=>{ detail.innerHTML=`<div class="step-title">${d.label}</div>
      <div><span class="tag">${d.type||''}</span>${d.drill?'（ダブルクリックで内部へ）':''}</div>`; },
    onDrill:(d)=>{ if(d.child && block.levels[d.child]) enter(d.child); },
  });

  function render(){
    const key=path[path.length-1], level=block.levels[key];
    gv.load(level,'dagre');
    lvl.innerHTML=`<div class="step-title">${level.title}</div>`;
    crumb.innerHTML = path.map((k,i)=>{
      const t=block.levels[k].title;
      return i<path.length-1 ? `<a data-i="${i}">${t}</a><span>›</span>` : `<span>${t}</span>`;
    }).join(' ');
    crumb.querySelectorAll('a').forEach(a=>a.onclick=()=>{ path.splice(+a.dataset.i+1); render(); });
  }
  function enter(childKey){ path.push(childKey); render(); }

  render();
  return { graph:gv, destroy:()=>{} };
}
```

---

## 操作仕様（このパターンで必ず提供する）

- **パンくずナビ**（Context › Container › Component）… クリックで任意の上位レベルへ戻る
- **ドリルイン**: 二重枠ノードのダブルクリックで内部レベルへ（レイアウトアニメーション付き）
- 各レベル内では ② 依存グラフの機能（近傍フォーカス・検索）も有効（同じ `GraphView`）
- 現在レベル名の表示・選択ノードの補足表示

---

## 設計のコツ

- **1レベルの要素数を絞る**（目安7±2）。多すぎるならレベルを1段増やす。これがドリルダウンの価値。
- レベル境界は元資料の抽象度に合わせる（C4なら Context/Container/Component）。無理に3段にしない。
- 上位ノードと下位レベルの対応を崩さない（`sys` を開くと必ず `sys` の中身が出る）。
- ② 依存グラフと併用が効く: 「サービス間の全依存」は②で俯瞰し、「各サービスの内部」は③で深掘り、と
  役割分担すると、大規模構成でも潰れずに全体↔詳細を行き来できる。
- `c4-diagram` スキルで生成した Container図/Component図がある場合、その構造をそのまま levels に写すと
  忠実なドリルダウンになる。
