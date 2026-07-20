# ④ 状態/タイムライン遷移

**用途**: 状態機械・ライフサイクル・デプロイ段階・パイプラインの時間変化・イベント年表など
「状態が移り変わる／時間で変わる」もの。あるシナリオ（トレース）に沿って状態を1つずつ点灯し、
発生イベントと現在状態を同期表示する。

`Player` エンジンを共有する（[html-scaffold.md](html-scaffold.md) の3節）。
このファイルは `mountStateBlock(block, stage, panel)` の実装レシピ。2つのサブモードを持つ。

- **状態機械モード**: 状態図を描き、シナリオのパスに沿って現在状態・とった遷移を強調
- **タイムラインモード**: 横軸に時間、スクラバーで任意時点へ移動、各時点のスナップショットを表示

---

## データ形（状態機械モード）

```javascript
{
  id:'order-fsm', title:'注文の状態遷移', pattern:'state', mode:'fsm',
  states:[
    { id:'cart',     label:'カート',   x:10, y:50 },
    { id:'ordered',  label:'注文確定', x:35, y:50 },
    { id:'paid',     label:'支払済',   x:60, y:30 },
    { id:'shipped',  label:'発送済',   x:85, y:30 },
    { id:'canceled', label:'キャンセル',x:60, y:70 },
  ],
  transitions:[
    { id:'t1', from:'cart',    to:'ordered',  trigger:'注文する' },
    { id:'t2', from:'ordered', to:'paid',     trigger:'支払い成功' },
    { id:'t3', from:'ordered', to:'canceled', trigger:'期限切れ'  },
    { id:'t4', from:'paid',    to:'shipped',  trigger:'出荷'      },
    { id:'t5', from:'paid',    to:'canceled', trigger:'返金'      },
  ],
  // シナリオ = 辿るパス。各要素で現在状態と発火した遷移を示す
  scenario:[
    { state:'cart',    via:null, event:'商品をカートへ' },
    { state:'ordered', via:'t1', event:'注文を確定した' },
    { state:'paid',    via:'t2', event:'クレジット決済が成功' },
    { state:'shipped', via:'t4', event:'倉庫から出荷' },
  ],
}
```

## データ形（タイムラインモード）

```javascript
{
  id:'pipeline', title:'ETLパイプラインの一日', pattern:'state', mode:'timeline',
  tracks:['取込','変換','集計','配信'],       // 行（並行するステージ）
  frames:[                                    // 各時点のスナップショット
    { t:'02:00', active:['取込'],             note:'ソースからロード開始' },
    { t:'02:40', active:['取込','変換'],      note:'変換ジョブ起動' },
    { t:'03:10', active:['変換','集計'],      note:'日次集計を計算' },
    { t:'03:30', active:['集計','配信'],      note:'BIへ配信' },
    { t:'03:45', active:['配信'],             note:'完了・通知送信' },
  ],
}
```

---

## 実装（状態機械モード）

状態図は SVG で描く（[step-player.md](step-player.md) のシーン描画と同じ手法）。`Player` の `onFrame` で
シナリオ i 番目の `state`/`via` を強調し、右パネルにトレースログを追記する。

```javascript
function mountStateBlock(block, stage, panel){
  if(block.mode==='timeline') return mountTimeline(block, stage, panel);

  const wrap=document.createElement('div');
  wrap.style.cssText='display:flex;flex-direction:column;gap:10px;flex:1;min-height:0';
  wrap.innerHTML=`<div class="scene"><svg viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet"
      style="width:100%;height:100%"></svg></div><div class="pcontrols"></div>`;
  stage.appendChild(wrap);
  panel.innerHTML=`<h3>現在の状態</h3><div class="narration cur"></div>
     <h3 style="margin-top:16px">トレース</h3><ol class="trace" style="font-size:13px;line-height:1.7;padding-left:18px"></ol>`;
  const svg=wrap.querySelector('svg'), cur=panel.querySelector('.cur'), trace=panel.querySelector('.trace');

  // 状態＝ノード、遷移＝ラベル付きエッジ（step-playerのSVG描画を流用。ここでは要点のみ）
  drawStateDiagram(svg, block); // states を箱、transitions を矢印+trigger文字で描く関数（step-player 参照）

  const player=new Player({
    length: block.scenario.length,
    onFrame:(i)=>{
      const s=block.scenario[i];
      svg.querySelectorAll('.node').forEach(el=> el.classList.toggle('hl', el.dataset.id===s.state));
      svg.querySelectorAll('.edge').forEach(el=> el.classList.toggle('active', el.dataset.id===s.via));
      cur.innerHTML=`<div class="step-title">${labelOf(block,s.state)}</div><div>${s.event}</div>`;
      // トレースを i まで表示
      trace.innerHTML = block.scenario.slice(0,i+1)
        .map(x=>`<li><span class="tag">${labelOf(block,x.state)}</span>${x.event}</li>`).join('');
    },
  });
  mountPlayerControls(wrap.querySelector('.pcontrols'), player);
  player.seek(0);
  return { player, destroy:()=>player.pause() };
}
function labelOf(b,id){ return (b.states.find(s=>s.id===id)||{}).label || id; }
```

`drawStateDiagram` は step-player.md のSVG描画（ノード箱＋エッジ＋矢印マーカー）に、エッジ中点へ
`trigger` テキストを添えるだけ。強調は `.hl`（現在状態）/`.active`（とった遷移）で行う。

---

## 実装（タイムラインモード）

横軸＝時間、縦＝トラック（並行ステージ）のグリッド。スクラバーで frame を選び、その時点で `active` な
トラックのセルを点灯する。

```javascript
function mountTimeline(block, stage, panel){
  const wrap=document.createElement('div');
  wrap.style.cssText='display:flex;flex-direction:column;gap:10px;flex:1;min-height:0';
  wrap.innerHTML=`<div class="card tl" style="flex:1;overflow:auto"></div><div class="pcontrols"></div>`;
  stage.appendChild(wrap);
  panel.innerHTML=`<h3>この時点</h3><div class="narration cur"></div>`;
  const tl=wrap.querySelector('.tl'), cur=panel.querySelector('.cur');

  // グリッド描画: 行=tracks, 列=frames
  const head = `<div></div>`+block.frames.map(f=>`<div class="tl-t" style="font-size:11px;color:var(--muted);text-align:center">${f.t}</div>`).join('');
  const rows = block.tracks.map(tr=>{
    const cells = block.frames.map((f,ci)=>`<div class="tl-cell" data-track="${tr}" data-i="${ci}"
        style="height:26px;border-radius:6px;border:1px solid var(--border);margin:3px;background:var(--surface-2)"></div>`).join('');
    return `<div style="font-size:12px;display:flex;align-items:center">${tr}</div>${cells}`;
  }).join('');
  tl.innerHTML=`<div style="display:grid;grid-template-columns:90px repeat(${block.frames.length},1fr);align-items:center">${head}${rows}</div>`;

  const player=new Player({
    length: block.frames.length,
    onFrame:(i)=>{
      const f=block.frames[i], on=new Set(f.active);
      tl.querySelectorAll('.tl-cell').forEach(c=>{
        const isActive = on.has(c.dataset.track) && +c.dataset.i===i;
        const isPast   = on.has(c.dataset.track) && +c.dataset.i<i; // 進行済みの薄い表示は任意
        c.style.background = isActive ? 'var(--accent)' : 'var(--surface-2)';
        c.style.opacity = (+c.dataset.i<=i) ? '1' : '.5';
      });
      cur.innerHTML=`<div class="step-title">${f.t}</div><div>${f.note}</div>`;
    },
  });
  mountPlayerControls(wrap.querySelector('.pcontrols'), player);
  player.seek(0);
  return { player, destroy:()=>player.pause() };
}
```

---

## 操作仕様（このパターンで必ず提供する）

- 再生 / 停止 / 前後 / スクラバー / 速度（`mountPlayerControls`）＋ キーボード（`←→` `Space`）
- 状態機械モード: 現在状態の点灯・とった遷移の強調・**トレースログの追記表示**
- タイムラインモード: 各時点のスナップショット点灯・時刻表示・注記
- 「今どの状態/時点か」が常に一目で分かること

---

## 設計のコツ

- 状態機械は **全遷移を静的に描いた上で、シナリオのパスだけを再生** するのが肝。全体像（どんな遷移が
  あり得るか）と、ある1本の道筋（実際に辿った道）を両立できる。
- 複数シナリオ（正常系/異常系/キャンセル）は、`scenario` を切り替えるセレクトを付けるか、別ブロックにする。
- タイムラインは「並行して何が動いているか」を見せるのに強い。逐次的な手順なら ① ステップ再生の方が適切。
- 実時間の間隔が重要なら、frame の `t` に比例して列幅を変えることも検討する（既定は等間隔）。
