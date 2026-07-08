# mermaid 図の選び方・記法ガイド

「セクションごとに図を1枚」を実践するための、図の選択基準と最小記法集。**内容に合う種類を選ぶ**こと（迷ったら flowchart）。すべてレンダリング可能な構文で書く。

## 何を描きたいか → どの図か

| 描きたいもの | 図の種類 | 典型シーン |
|--------------|----------|------------|
| 全体像・処理の流れ・分岐 | `flowchart` | サマリの全体像、処理フロー、判断分岐 |
| 時系列のやり取り | `sequenceDiagram` | API 呼び出し、コンポーネント間通信、認証フロー |
| 状態と遷移 | `stateDiagram-v2` | ライフサイクル、ステータス管理、注文/ジョブの状態 |
| データ構造・テーブル関係 | `erDiagram` | DB スキーマ、エンティティ関係 |
| クラス・型・責務 | `classDiagram` | ドメインモデル、モジュール構造 |
| 工程・スケジュール | `gantt` | ロードマップ、フェーズ計画 |
| 階層・分類・分解 | `flowchart TB` or `mindmap` | 構成要素の分解、目次的な俯瞰 |

## 最小記法サンプル

### flowchart（全体像・フロー）

```mermaid
flowchart LR
    A[利用者] -->|リクエスト| B(API)
    B --> C{条件?}
    C -->|Yes| D[処理X]
    C -->|No| E[処理Y]
    D --> F[(DB)]
```

- 向き: `TB`（上→下）/ `LR`（左→右）。全体像は情報量が多ければ `TB` が読みやすい。
- ノード形: `[ ]` 四角 / `( )` 角丸 / `{ }` 判断 / `[( )]` DB / `(( ))` 円。
- グルーピングは `subgraph 名前 ... end`。

### sequenceDiagram（時系列のやり取り）

```mermaid
sequenceDiagram
    participant U as 利用者
    participant API as APIサーバ
    participant DB as データベース
    U->>API: 注文リクエスト
    API->>DB: 在庫確認
    DB-->>API: 在庫あり
    API-->>U: 受付完了
```

- 実線 `->>` は呼び出し、破線 `-->>` は応答。
- `alt / else / end`、`loop / end`、`Note over A,B: メモ` が使える。

### stateDiagram-v2（状態遷移）

```mermaid
stateDiagram-v2
    [*] --> 受付
    受付 --> 処理中: 支払い確認
    処理中 --> 完了: 発送
    処理中 --> キャンセル: 在庫切れ
    完了 --> [*]
```

### erDiagram（データ構造）

```mermaid
erDiagram
    USER ||--o{ ORDER : "注文する"
    ORDER ||--|{ ORDER_ITEM : "含む"
    PRODUCT ||--o{ ORDER_ITEM : "対象"
```

- カーディナリティ: `||`(1) / `o{`(0以上) / `|{`(1以上)。

### classDiagram（モデル・責務）

```mermaid
classDiagram
    class Order {
      +id: string
      +status: Status
      +total(): int
    }
    Order "1" --> "*" OrderItem
```

### gantt（工程・計画）

```mermaid
gantt
    title ロードマップ
    dateFormat YYYY-MM-DD
    section フェーズ1
    設計 :a1, 2026-01-01, 14d
    実装 :after a1, 21d
```

## 描くときの注意

- **1枚に詰め込みすぎない。** ノードが多いなら `subgraph` でまとめるか、図を分割する。
- **日本語ラベル**は原則そのまま使えるが、`:` `;` などの特殊記号を含むラベルは `"..."` で囲む。
- 矢印には**動詞ラベル**を付けて意味を明確にする（`-->|確認|` など）。
- 出力前に構文エラー（閉じ忘れ、未定義ノード、向き指定漏れ）がないか見直す。
