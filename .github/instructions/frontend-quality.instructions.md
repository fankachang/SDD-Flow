---
applyTo: "**/*.{tsx,jsx,vue,css,scss,html,svelte,astro}"
---

# 前端設計品質規則（來源：design-quality hook）

## 禁止通用 AI 風格 UI

以下為「AI 爛 UI」的特徵，**禁止**在設計中出現：

- "Get Started" 或 "Learn More" 這類通用 CTA 按鈕文字（需改為具體行動描述）
- 千篇一律的 `grid-cols-3`、`grid-cols-4` 均等卡片格
- 制式漸層：`bg-gradient-to-r`、`bg-gradient-to-b` 等股票型漸層背景
- 過度泛用的字體：`Inter`、`Roboto`（應選擇符合品牌個性的字體）

## 設計要求

- 每個 UI 元件必須有**明確的設計方向**，而非套用預設模板
- CTA 文字應反映**具體的使用者行動**，例如「開始分析流程」而非「Get Started」
- 視覺層次必須清晰：主要操作 > 次要操作 > 輔助資訊
- 前端設計如有疑問，請使用 `frontend-designer` agent
