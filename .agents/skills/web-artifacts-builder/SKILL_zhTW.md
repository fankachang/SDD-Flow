---
name: web-artifacts-builder
description: 用於建立複雜、多元件的 claude.ai HTML 作品的工具組，採用現代前端技術（React、Tailwind CSS、shadcn/ui）。適用於需要狀態管理、路由或 shadcn/ui 元件的複雜作品——不適用於簡單的單一檔案 HTML/JSX 作品。
license: 完整條款詳見 LICENSE.txt
---

# Web Artifacts Builder

建構強大的 claude.ai 前端作品，請依下列步驟執行：
1. 使用 `scripts/init-artifact.sh` 初始化前端專案
2. 編輯生成的程式碼，開發你的作品
3. 使用 `scripts/bundle-artifact.sh` 將所有程式碼打包成單一 HTML 檔案
4. 將作品展示給使用者
5. （選用）測試作品

**技術堆疊**：React 18 + TypeScript + Vite + Parcel（打包）+ Tailwind CSS + shadcn/ui

## 設計與樣式指南

**非常重要**：為避免俗稱「AI 廉價感」的問題，請避免過度使用置中版面、紫色漸層、統一的圓角，以及 Inter 字體。

## 快速開始

### 第一步：初始化專案

執行初始化腳本，建立新的 React 專案：
```bash
bash scripts/init-artifact.sh <project-name>
cd <project-name>
```

此步驟會建立完整設定的專案，包含：
- ✅ React + TypeScript（透過 Vite）
- ✅ Tailwind CSS 3.4.1 與 shadcn/ui 主題系統
- ✅ 路徑別名（`@/`）已設定
- ✅ 預裝 40+ 個 shadcn/ui 元件
- ✅ 包含所有 Radix UI 相依套件
- ✅ Parcel 打包設定（透過 .parcelrc）
- ✅ 相容 Node 18+（自動偵測並固定 Vite 版本）

### 第二步：開發你的作品

編輯生成的檔案來建構作品。詳細指引請參閱下方**常見開發任務**。

### 第三步：打包成單一 HTML 檔案

將 React 應用程式打包成單一 HTML 作品：
```bash
bash scripts/bundle-artifact.sh
```

此步驟會生成 `bundle.html`——一個包含所有 JavaScript、CSS 與相依套件的自包含作品，可直接在 Claude 對話中分享作為作品使用。

**需求**：專案根目錄必須有 `index.html` 檔案。

**腳本執行內容**：
- 安裝打包相依套件（parcel、@parcel/config-default、parcel-resolver-tspaths、html-inline）
- 建立含路徑別名支援的 `.parcelrc` 設定
- 使用 Parcel 建置（不含 source maps）
- 使用 html-inline 將所有資源內嵌至單一 HTML

### 第四步：與使用者分享作品

最後，在對話中分享打包完成的 HTML 檔案，讓使用者以作品形式檢視。

### 第五步：測試/視覺驗證（選用）

**注意**：此步驟完全為選用。僅在必要時或使用者要求時執行。

如需測試或視覺驗證作品，可使用現有工具（包括其他技能或 Playwright、Puppeteer 等內建工具）。一般而言，避免在一開始就測試，以減少請求與呈現完成作品之間的等待時間。如有需要或發現問題，在展示作品後再進行測試。

## 參考資源

- **shadcn/ui 元件**：https://ui.shadcn.com/docs/components
