# ① ステップ再生プレイヤー

**用途**: ユースケース・シーケンス・処理フロー・手順・アルゴリズムなど「順番に起きること」。
静的なシーケンス図/フローチャートを、1ステップずつ再生・逆再生・自動再生できるようにし、
「今どこの話か」を強調とナレーションで同期表示する。

土台は [html-scaffold.md](html-scaffold.md) の `Player` エンジンと `mountPlayerControls`。
このファイルは `mountStepBlock(block, stage, panel)` の実装レシピ。

---

## データ形（DATA.blocks[] の1要素）

```javascript
{
  id:'usecase-login', title:'ログインのユースケース', pattern:'step',
  // シーン: 登場人物/コンポーネントを箱として配置（座標は 0..100 の相対%）
  scene:{
    nodes:[
      { id:'user', label:'利用者', x:10,  y:50 },
      { id:'app',  label:'アプリ', x:40,  y:50 },
      { id:'auth', label:'認証API', x:70, y:30 },
      { id:'db',   label:'DB',     x:70,  y:70 },
    ],
    edges:[
      { id:'e1', from:'user', to:'app'  },
      { id:'e2', from:'app',  to:'auth' },
      { id:'e3', from:'auth', to:'db'   },
      { id:'e4', from:'auth', to:'app'  },
      { id:'e5', from:'app',  to:'user' },
    ],
  },
  // ステップ列: 各ステップで強調するノード/エッジとナレーション
  steps:[
    { title:'資格情報を入力', desc:'利用者がID/パスワードを入力し送信する。', hlNodes:['user','app'], active:['e1'] },
    { title:'認証要求',       desc:'アプリが認証APIへ検証を依頼する。',       hlNodes:['app','auth'], active:['e2'] },
    { title:'資格情報を照合', desc:'認証APIがDBの資格情報と照合する。',       hlNodes:['auth','db'],  active:['e3'] },
    { title:'トークン発行',   desc:'照合成功。認証APIがトークンを返す。',     hlNodes:['auth','app'], active:['e4'] },
    { title:'ログイン完了',   desc:'アプリが利用者へ結果を返し画面遷移する。', hlNodes:['app','user'], active:['e5'] },
  ],
}
```

> シーン座標は資料から機械的に決められないことが多い。左→右（時系列）や上→下（レイヤー）で
> 素直に並べる。シーケンス的な内容なら、アクターを横一列に並べて縦方向に時間を流す配置も良い。

---

## 描画（SVGシーン + ステップ強調）

シーンは SVG で描く（拡大しても綺麗、強調のクラス制御が容易）。`Player` の `onFrame` で、そのステップの
`hlNodes`/`active` に応じて `.dim`/`.hl`/`.active` を付け替える。

```javascript
function mountStepBlock(block, stage, panel){
  // レイアウト: シーン + 操作バー / 右パネルにナレーション
  const wrap = document.createElement('div');
  wrap.style.cssText='display:flex;flex-direction:column;gap:10px;flex:1;min-height:0';
  wrap.innerHTML = `<div class="scene"><svg viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet"
       style="width:100%;height:100%"></svg></div><div class="pcontrols"></div>`;
  stage.appendChild(wrap);
  panel.innerHTML = `<h3>ナレーション</h3><div class="narration"></div>
      <h3 style="margin-top:16px">凡例</h3>
      <div class="tag">◀ ▶ / Space で操作</div><div class="tag">← → で前後</div>`;
  const svg = wrap.querySelector('svg');
  const narration = panel.querySelector('.narration');

  // 1) ノード/エッジをSVGに描く
  const S = block.scene;
  const pos = Object.fromEntries(S.nodes.map(n=>[n.id,n]));
  const NS='http://www.w3.org/2000/svg';
  // エッジ（先に描いて背面へ）
  S.edges.forEach(e=>{
    const a=pos[e.from], b=pos[e.to];
    const line=document.createElementNS(NS,'line');
    line.setAttribute('x1',a.x);line.setAttribute('y1',a.y);
    line.setAttribute('x2',b.x);line.setAttribute('y2',b.y);
    line.setAttribute('class','edge'); line.dataset.id=e.id;
    line.setAttribute('stroke','var(--muted)'); line.setAttribute('stroke-width','0.6');
    line.setAttribute('marker-end','url(#arrow)');
    svg.appendChild(line);
  });
  // 矢印マーカー
  const defs=document.createElementNS(NS,'defs');
  defs.innerHTML=`<marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="5" markerHeight="5"
     orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="var(--muted)"/></marker>`;
  svg.appendChild(defs);
  // ノード（箱＋ラベル）
  S.nodes.forEach(n=>{
    const g=document.createElementNS(NS,'g'); g.setAttribute('class','node'); g.dataset.id=n.id;
    const w=18,h=9;
    const rect=document.createElementNS(NS,'rect');
    rect.setAttribute('x',n.x-w/2);rect.setAttribute('y',n.y-h/2);
    rect.setAttribute('width',w);rect.setAttribute('height',h);rect.setAttribute('rx',2);
    rect.setAttribute('fill','var(--surface-2)');rect.setAttribute('stroke','var(--border)');rect.setAttribute('stroke-width',.4);
    const t=document.createElementNS(NS,'text');
    t.setAttribute('x',n.x);t.setAttribute('y',n.y+1.6);t.setAttribute('text-anchor','middle');
    t.setAttribute('font-size','3.2');t.setAttribute('fill','var(--text)');t.textContent=n.label;
    g.append(rect,t); svg.appendChild(g);
  });

  // 2) Player を作り、フレーム描画を配線
  const player = new Player({
    length: block.steps.length,
    onFrame: (i)=>{
      const step=block.steps[i];
      const hl=new Set(step.hlNodes||[]), act=new Set(step.active||[]);
      svg.querySelectorAll('.node').forEach(el=>{
        el.classList.toggle('hl', hl.has(el.dataset.id));
        el.classList.toggle('dim', hl.size>0 && !hl.has(el.dataset.id));
      });
      svg.querySelectorAll('.edge').forEach(el=>{
        el.classList.toggle('active', act.has(el.dataset.id));
        el.classList.toggle('dim', act.size>0 && !act.has(el.dataset.id));
      });
      narration.innerHTML = `<div class="step-title">${i+1}. ${step.title}</div><div>${step.desc}</div>`;
    },
  });
  mountPlayerControls(wrap.querySelector('.pcontrols'), player);
  player.seek(0);
  return { player, destroy:()=>player.pause() };
}
```

---

## 操作仕様（このパターンで必ず提供する）

- 再生 / 停止 / 前へ / 次へ / スクラバー / 速度（0.5x・1x・2x）… `mountPlayerControls` が提供
- キーボード: `←` `→` で前後、`Space` で再生停止（scaffold 5節で配線）
- 現在ステップの **強調**（該当ノード `.hl`、無関係を `.dim`）と **エッジ点灯**（`.active`）
- ナレーション同期（右パネルに「N. タイトル / 説明」）
- ステップ番号表示（`3 / 8`）

---

## 設計のコツ

- **1ステップ＝1つの出来事** に割る。1ステップで複数のことを起こさない。
- ナレーションは元資料の記述に忠実に。図に無い遷移を勝手に足さない。
- シーケンス色が強い（アクター間の往復が多い）なら、アクターを横一列に固定し、各ステップで
  「発→着」のエッジだけ点灯すると、シーケンス図の弱点（縦に長い）を再生で解消できる。
- 分岐（if/else）がある場合は、シナリオごとに別ブロック（正常系/異常系）に分けると分かりやすい。
