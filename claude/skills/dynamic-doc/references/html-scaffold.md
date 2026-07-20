# 単一HTML雛形と共有エンジン

すべての動的表現パターンが乗る土台。**生成前に必ず読む。** 生成時はこの雛形を出発点にし、抽出データと
使用パターンに合わせて調整する。

設計の骨子:

- **1枚のHTMLで自己完結**（CSS/JSインライン、グラフ描画ライブラリのみCDN）
- **データとコードを分離**（冒頭 `const DATA` に抽出モデル、以降のコードがそれを描画）
- **2つの共有エンジン**（`Player` = ①④用 / `GraphView` = ②③用）
- **複数ビューブロック**を左ナビで切替（1資料に複数の可視化を同居できる）

---

## 1. 全体スケルトン

```html
<!doctype html>
<html lang="ja" data-theme="light">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{名前} — 動的資料</title>

<!-- グラフ描画（②③を使うときだけ読み込む。①④のみなら不要） -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/cytoscape/3.30.2/cytoscape.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/dagre@0.8.5/dist/dagre.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/cytoscape-dagre@2.5.0/cytoscape-dagre.min.js"></script>

<style>/* → 「2. デザインシステム(CSS)」を丸ごとここへ */</style>
</head>
<body>
  <header class="topbar">
    <div class="title">
      <strong>{名前}</strong>
      <span class="sub">動的資料 · 元資料: {出典} · {日付}</span>
    </div>
    <div class="actions">
      <input id="search" class="search" placeholder="ノード検索…" hidden>
      <button id="themeBtn" class="btn" title="テーマ切替">◐</button>
    </div>
  </header>

  <div class="layout">
    <!-- 左: ビューブロック一覧（TOC） -->
    <nav class="nav" id="nav"></nav>

    <!-- 中央: 可視化ステージ -->
    <main class="stage" id="stage"></main>

    <!-- 右: 詳細/ナレーション/フィルタ -->
    <aside class="panel" id="panel"></aside>
  </div>

<script>
/* ============ データ（抽出モデル。ここだけ差し替えれば内容が変わる） ============ */
const DATA = {
  blocks: [
    // 先頭は必ず全体像。role/of で「全体像 → その詳細」の親子を表す（フォーマット規約）:
    //   { id, title, role:'overview', pattern:'graph'|'drilldown', ... }        ← 1番目
    //   { id, title, role:'detail', of:'<overviewのid>', pattern:'step'|..., ... } ← 以降
    // 全体像側のノードに linkTo:'<詳細blockのid>' を持たせると、そのノードから詳細へジャンプできる。
  ]
};

/* ============ 共有エンジン（3. Player / 4. GraphView をここへ） ============ */

/* ============ ブロック配線（5. ブロックのマウント規約） ============ */
</script>
</body>
</html>
```

---

## 2. デザインシステム（CSS）

ライト/ダーク両対応。色は CSS 変数で一元管理し、コントラストを確保する。

```css
:root{
  --bg:#f7f8fa; --surface:#ffffff; --surface-2:#eef1f6; --border:#dfe3ea;
  --text:#0b1020; --muted:#5b6472; --accent:#2563eb; --accent-weak:#dbeafe;
  --ok:#16a34a; --warn:#d97706; --danger:#dc2626;
  --radius:12px; --gap:12px; --shadow:0 1px 2px rgba(16,24,40,.06),0 8px 24px rgba(16,24,40,.06);
  --font:-apple-system,BlinkMacSystemFont,"Segoe UI","Hiragino Sans","Noto Sans JP",sans-serif;
}
[data-theme="dark"]{
  --bg:#0b1020; --surface:#141a2b; --surface-2:#1b2338; --border:#273149;
  --text:#e6eaf2; --muted:#9aa4b6; --accent:#60a5fa; --accent-weak:#1e293b;
  --shadow:0 1px 2px rgba(0,0,0,.4),0 8px 24px rgba(0,0,0,.35);
}
*{box-sizing:border-box}
html,body{height:100%}
body{margin:0;font-family:var(--font);color:var(--text);background:var(--bg);
  display:flex;flex-direction:column;-webkit-font-smoothing:antialiased}

.topbar{display:flex;align-items:center;justify-content:space-between;gap:var(--gap);
  padding:10px 16px;background:var(--surface);border-bottom:1px solid var(--border)}
.title strong{font-size:15px}
.title .sub{margin-left:10px;color:var(--muted);font-size:12px}
.actions{display:flex;gap:8px;align-items:center}
.btn{border:1px solid var(--border);background:var(--surface);color:var(--text);
  border-radius:8px;padding:6px 10px;font-size:13px;cursor:pointer}
.btn:hover{background:var(--surface-2)}
.btn.active{background:var(--accent-weak);border-color:var(--accent);color:var(--accent)}
.search{border:1px solid var(--border);background:var(--surface);color:var(--text);
  border-radius:8px;padding:6px 10px;font-size:13px;min-width:180px}

.layout{flex:1;display:grid;grid-template-columns:220px 1fr 300px;min-height:0}
.nav{border-right:1px solid var(--border);background:var(--surface);padding:10px;overflow:auto}
.nav .item{display:block;width:100%;text-align:left;border:0;background:transparent;color:var(--text);
  padding:9px 10px;border-radius:8px;cursor:pointer;font-size:13px}
.nav .item:hover{background:var(--surface-2)}
.nav .item.active{background:var(--accent-weak);color:var(--accent);font-weight:600}
.nav .item.sub{padding-left:24px;font-size:12.5px;color:var(--muted)}
.nav .item.sub::before{content:"└ ";opacity:.6}
.nav .group{color:var(--muted);font-size:11px;text-transform:uppercase;letter-spacing:.04em;
  padding:12px 10px 4px}

.stage{position:relative;min-width:0;min-height:0;display:flex;flex-direction:column;padding:14px;gap:10px}
.panel{border-left:1px solid var(--border);background:var(--surface);padding:14px;overflow:auto}
.panel h3{margin:.2em 0 .4em;font-size:13px;color:var(--muted);text-transform:uppercase;letter-spacing:.04em}

/* カード/シーン */
.card{background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);
  box-shadow:var(--shadow);padding:14px}
.scene{position:relative;flex:1;min-height:320px;background:var(--surface);border:1px solid var(--border);
  border-radius:var(--radius);overflow:hidden}
.graph{flex:1;min-height:360px;background:var(--surface);border:1px solid var(--border);border-radius:var(--radius)}

/* プレイヤー操作 */
.controls{display:flex;align-items:center;gap:10px;background:var(--surface);border:1px solid var(--border);
  border-radius:var(--radius);padding:8px 12px}
.controls .scrubber{flex:1;accent-color:var(--accent)}
.controls .counter{font-variant-numeric:tabular-nums;color:var(--muted);font-size:12px;min-width:56px;text-align:right}
.iconbtn{border:1px solid var(--border);background:var(--surface);color:var(--text);border-radius:8px;
  width:34px;height:34px;font-size:14px;cursor:pointer}
.iconbtn:hover{background:var(--surface-2)}

/* フィルタ/凡例 */
.chips{display:flex;flex-wrap:wrap;gap:6px}
.chip{display:inline-flex;align-items:center;gap:6px;border:1px solid var(--border);border-radius:999px;
  padding:4px 10px;font-size:12px;cursor:pointer;background:var(--surface)}
.chip .dot{width:10px;height:10px;border-radius:50%}
.chip.off{opacity:.4}
.breadcrumb{display:flex;gap:6px;align-items:center;font-size:13px;color:var(--muted)}
.breadcrumb a{color:var(--accent);cursor:pointer;text-decoration:none}

/* ステップ強調（SVG/DOMシーン共通） */
.node{transition:opacity .25s, filter .25s, transform .25s}
.node.dim{opacity:.18}
.node.hl{filter:drop-shadow(0 0 0 var(--accent));outline:2px solid var(--accent)}
.edge{transition:opacity .25s,stroke .25s,stroke-dashoffset .6s}
.edge.dim{opacity:.1}
.edge.active{stroke:var(--accent);stroke-width:2.5}

.narration{font-size:14px;line-height:1.6}
.narration .step-title{font-weight:700;margin-bottom:4px}
.tag{display:inline-block;font-size:11px;color:var(--muted);border:1px solid var(--border);
  border-radius:6px;padding:1px 6px;margin-right:4px}

@media (max-width:900px){ .layout{grid-template-columns:1fr} .nav,.panel{display:none} }
```

---

## 3. Player エンジン（①ステップ再生 / ④状態タイムライン で共有）

時系列の位置を管理し、フレーム描画コールバックを呼ぶだけの汎用コントローラ。**シーンの見た目は持たない**
（描画は各パターンの `onFrame` に委譲）。これにより同じエンジンでステップ再生も状態遷移も駆動できる。

```javascript
class Player {
  constructor({ length, onFrame, onState, interval = 1400 }) {
    this.length = length;            // 総ステップ数
    this.onFrame = onFrame;          // (index) => void  そのステップを描画
    this.onState = onState || null;  // ({index,length,playing}) => void  UI更新
    this.baseInterval = interval;
    this.interval = interval;
    this.index = 0;
    this.playing = false;
    this._timer = null;
  }
  _emit(){ this.onFrame(this.index); this.onState && this.onState({index:this.index,length:this.length,playing:this.playing}); }
  seek(i){ this.index = Math.max(0, Math.min(this.length-1, i)); this._emit(); }
  next(){ if(this.index>=this.length-1){ this.pause(); return; } this.seek(this.index+1); }
  prev(){ this.seek(this.index-1); }
  play(){
    if(this.playing) return;
    if(this.index>=this.length-1) this.index = 0;
    this.playing = true; this._emit();
    this._timer = setInterval(()=>{ if(this.index>=this.length-1){ this.pause(); return; } this.seek(this.index+1); }, this.interval);
  }
  pause(){ this.playing=false; clearInterval(this._timer); this._timer=null;
    this.onState && this.onState({index:this.index,length:this.length,playing:this.playing}); }
  toggle(){ this.playing ? this.pause() : this.play(); }
  setSpeed(mult){ this.interval = this.baseInterval / mult; if(this.playing){ this.pause(); this.play(); } }
}

// 汎用プレイヤーUI（操作バー）を生成して Player に配線する
function mountPlayerControls(container, player){
  container.innerHTML = `
    <div class="controls">
      <button class="iconbtn" data-act="prev" title="前へ (←)">◀</button>
      <button class="iconbtn" data-act="toggle" title="再生/停止 (Space)">▶</button>
      <button class="iconbtn" data-act="next" title="次へ (→)">⏭</button>
      <input class="scrubber" type="range" min="0" max="${player.length-1}" value="0">
      <span class="counter">1 / ${player.length}</span>
      <select class="speed" title="速度">
        <option value="0.5">0.5x</option><option value="1" selected>1x</option><option value="2">2x</option>
      </select>
    </div>`;
  const $ = (s)=>container.querySelector(s);
  const scrubber=$('.scrubber'), counter=$('.counter'), toggle=$('[data-act=toggle]');
  $('[data-act=prev]').onclick=()=>player.prev();
  $('[data-act=next]').onclick=()=>player.next();
  toggle.onclick=()=>player.toggle();
  scrubber.oninput=(e)=>{ player.pause(); player.seek(+e.target.value); };
  $('.speed').onchange=(e)=>player.setSpeed(+e.target.value);
  player.onState = ({index,length,playing})=>{
    scrubber.value=index; counter.textContent=`${index+1} / ${length}`;
    toggle.textContent = playing ? '⏸' : '▶';
  };
}
```

キーボード操作は、アクティブなブロックの player に対して配線する（5節参照）。

---

## 4. GraphView エンジン（②依存グラフ / ③ドリルダウン で共有）

Cytoscape.js をラップし、**クリックで近傍フォーカス（focus+context）／種別フィルタ／検索／上流下流ハイライト／
レイアウト切替／レベル差し替え** を提供する。これが「大きい図が潰れる・矢印が絡む」問題の解消部。

```javascript
if (window.cytoscapeDagre) cytoscape.use(window.cytoscapeDagre);

const TYPE_COLORS = { // 種別→色。抽出したtypeに合わせて調整する
  actor:'#64748b', frontend:'#3b82f6', api:'#22c55e', service:'#22c55e',
  db:'#f59e0b', store:'#f59e0b', queue:'#ec4899', external:'#a855f7', default:'#94a3b8'
};

const GRAPH_STYLE = [
  { selector:'node', style:{
     'background-color':(e)=>TYPE_COLORS[e.data('type')]||TYPE_COLORS.default,
     'label':'data(label)','font-size':12,'color':'#0b1020',
     'text-valign':'center','text-halign':'center','text-wrap':'wrap','text-max-width':120,
     'width':'label','height':'label','padding':'12px','shape':'round-rectangle',
     'border-width':1,'border-color':'rgba(0,0,0,.15)'} },
  { selector:'node[?drill], node[?linkTo]', style:{ 'border-width':2,'border-style':'double','border-color':'#111827' } }, // 子を持つ=ドリル可 / 詳細ブロックへジャンプ可
  { selector:'edge', style:{
     'width':1.5,'line-color':'#94a3b8','target-arrow-color':'#94a3b8','target-arrow-shape':'triangle',
     'curve-style':'bezier','label':'data(label)','font-size':10,'color':'#64748b',
     'text-background-color':'#ffffff','text-background-opacity':.75,'text-background-padding':'2px'} },
  { selector:'.dim', style:{ 'opacity':.12,'text-opacity':.05 } },
  { selector:'node.focus', style:{ 'opacity':1 } },
  { selector:'edge.focus', style:{ 'opacity':1,'line-color':'#334155','target-arrow-color':'#334155','width':2.5 } },
  { selector:'node.selected', style:{ 'border-width':3,'border-color':'#111827' } },
];

class GraphView {
  constructor(container, data, opts={}){
    this.opts = opts;
    this.cy = cytoscape({
      container,
      elements: this._toElements(data),
      style: GRAPH_STYLE,
      layout: this._layoutCfg(opts.layout||'dagre'),
      wheelSensitivity:.2, minZoom:.2, maxZoom:2.5,
    });
    this.cy.on('tap','node',(e)=> this.focus(e.target));
    this.cy.on('tap',(e)=>{ if(e.target===this.cy) this.clearFocus(); });
    this.onSelect = opts.onSelect || null; // (nodeData)=>void  右パネル表示など
    this.onDrill  = opts.onDrill  || null; // (nodeData)=>void  ③ドリルダウン
    if(this.onSelect) this.cy.on('tap','node',(e)=> this.onSelect(e.target.data()));
    if(this.onDrill)  this.cy.on('dbltap','node',(e)=>{ const d=e.target.data(); if(d.drill||d.linkTo) this.onDrill(d); });
  }
  _toElements(d){ return [...d.nodes.map(n=>({data:n})), ...d.edges.map(e=>({data:e}))]; }
  _layoutCfg(name){
    if(name==='dagre') return {name:'dagre',rankDir:this.opts.rankDir||'LR',nodeSep:36,rankSep:70,animate:true};
    return {name, animate:true};
  }
  focus(node, depth=1){
    let hood = node.closedNeighborhood();
    for(let d=1; d<depth; d++) hood = hood.closedNeighborhood();
    this.cy.elements().addClass('dim').removeClass('focus');
    hood.removeClass('dim').addClass('focus');
    this.cy.nodes().removeClass('selected'); node.addClass('selected');
    this.cy.animate({fit:{eles:hood,padding:60}},{duration:300});
  }
  focusDirection(node, dir){ // 'up'=依存先(predecessors) / 'down'=被依存(successors)
    const rel = dir==='up' ? node.predecessors() : node.successors();
    const eles = rel.union(node).union(node.connectedEdges());
    this.cy.elements().addClass('dim').removeClass('focus');
    eles.removeClass('dim').addClass('focus'); node.addClass('selected');
  }
  clearFocus(){ this.cy.elements().removeClass('dim focus selected'); this.cy.animate({fit:{padding:40}},{duration:300}); }
  filter(activeTypes){ // Set<string>
    this.cy.batch(()=> this.cy.nodes().forEach(n=>{
      n.style('display', activeTypes.has(n.data('type')) ? 'element':'none');
    }));
  }
  search(q){ q=(q||'').trim().toLowerCase();
    if(!q){ this.clearFocus(); return; }
    const hit = this.cy.nodes().filter(n=>(n.data('label')||'').toLowerCase().includes(q));
    if(hit.length) this.focus(hit[0]);
  }
  setLayout(name){ this.cy.layout(this._layoutCfg(name)).run(); }
  load(data, layout='dagre'){ this.cy.elements().remove(); this.cy.add(this._toElements(data)); this.setLayout(layout); }
  types(){ return [...new Set(this.cy.nodes().map(n=>n.data('type')))]; }
}
```

利用可能な近傍API（Cytoscape）:
`node.closedNeighborhood()`（自身+隣接）, `node.successors()`（下流全体）, `node.predecessors()`（上流全体）,
`node.connectedEdges()`。フォーカス/方向ハイライトはこれらを組み合わせる。

---

## 5. ブロックのマウント規約

複数の可視化を1枚に同居させるため、`DATA.blocks[]` を左ナビに並べ、選ばれたブロックだけを stage/panel に描く。

```javascript
const stage = document.getElementById('stage');
const panel = document.getElementById('panel');
const nav   = document.getElementById('nav');
let current = null;               // 現在アクティブなブロックの状態(playerや破棄関数)

const MOUNTERS = {
  step:      mountStepBlock,       // → step-player.md
  state:     mountStateBlock,      // → state-timeline.md
  graph:     mountGraphBlock,      // → dependency-graph.md
  drilldown: mountDrilldownBlock,  // → layer-drilldown.md
};

function selectBlock(block){
  if(current && current.destroy) current.destroy();
  stage.innerHTML=''; panel.innerHTML='';
  [...nav.querySelectorAll('.item')].forEach(el=>el.classList.toggle('active', el.dataset.id===block.id));
  document.getElementById('search').hidden = !(block.pattern==='graph'||block.pattern==='drilldown');
  current = MOUNTERS[block.pattern](block, stage, panel); // {player?, graph?, destroy?} を返す
}

// 全体像→詳細の導線。全体像ノードの linkTo や詳細ブロック内から呼ぶ
function goToBlock(id){ const b=DATA.blocks.find(x=>x.id===id); if(b) selectBlock(b); }

// ナビは「全体像 → その詳細群」の親子で並べ、詳細は字下げ表示にする（フォーマット規約）
function buildNav(){
  const overviews = DATA.blocks.filter(b=>b.role!=='detail');
  const detailsOf = (id)=>DATA.blocks.filter(b=>b.role==='detail' && b.of===id);
  const addItem=(b,sub)=>{
    const btn=document.createElement('button');
    btn.className='item'+(sub?' sub':''); btn.dataset.id=b.id; btn.textContent=b.title;
    btn.onclick=()=>selectBlock(b); nav.appendChild(btn);
  };
  overviews.forEach(ov=>{ addItem(ov,false); detailsOf(ov.id).forEach(d=>addItem(d,true)); });
  // どの全体像にも紐づかない詳細（of未設定）は最後に平置き
  DATA.blocks.filter(b=>b.role==='detail' && !overviews.some(o=>o.id===b.of)).forEach(d=>addItem(d,false));
}

// キーボード（アクティブブロックが player を持つときのみ）
window.addEventListener('keydown',(e)=>{
  if(!current||!current.player) return;
  if(e.key==='ArrowRight'){ current.player.next(); }
  else if(e.key==='ArrowLeft'){ current.player.prev(); }
  else if(e.key===' '){ e.preventDefault(); current.player.toggle(); }
});

// テーマ切替
document.getElementById('themeBtn').onclick=()=>{
  const html=document.documentElement;
  html.dataset.theme = html.dataset.theme==='dark' ? 'light':'dark';
};
// 検索（graph系ブロックへ）
document.getElementById('search').oninput=(e)=>{ if(current&&current.graph) current.graph.search(e.target.value); };

buildNav();
if(DATA.blocks.length) selectBlock(DATA.blocks[0]);
```

各 `mountXxxBlock(block, stage, panel)` は、対応するパターンの reference に実装レシピがある。戻り値の規約:

- `player`: キーボード操作対象（①④）
- `graph`: 検索対象の `GraphView`（②③）
- `destroy()`: ブロック切替時のクリーンアップ（タイマー停止など。任意）

---

## 6. 生成時の注意

- **CDNが使えない配布先** では、Cytoscapeの `.min.js` を取得してHTMLへインライン化する（`<script>…</script>`）。
  ①④のみのHTMLならライブラリ不要で完全オフライン動作する。
- グラフ描画コンテナ（`.graph`）には必ず高さが必要（本CSSは `min-height` を確保済み）。
- Cytoscapeのスタイルは CSS変数を解釈しないため、`TYPE_COLORS` 等は具体値で持つ（本節のとおり）。
- ノード/エッジの `id` は一意にする。エッジの `source`/`target` は存在するノードidを指すこと。
- テキストはすべて日本語。凡例・操作ヒント・キーボード説明を必ず添える。
