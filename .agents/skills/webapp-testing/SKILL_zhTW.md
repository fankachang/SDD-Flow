---
name: webapp-testing
description: 使用 Playwright 與本地端網頁應用程式互動及測試的工具組。支援驗證前端功能、除錯 UI 行為、擷取瀏覽器截圖，以及查看瀏覽器日誌。
license: 完整條款詳見 LICENSE.txt
---

# 網頁應用程式測試

測試本地端網頁應用程式時，請撰寫原生 Python Playwright 腳本。

**可用輔助腳本**：
- `scripts/with_server.py` — 管理伺服器生命週期（支援多個伺服器）

**執行任何腳本前，請先加上 `--help` 查看用法說明。** 在確認必須自訂方案之前，請勿閱讀原始碼。這些腳本可能非常龐大，讀取原始碼會污染你的上下文視窗。這些腳本設計為直接呼叫的黑盒工具，而非需要讀入上下文的程式碼。

## 決策樹：選擇合適的方式

```
使用者任務 → 是靜態 HTML 嗎？
    ├─ 是 → 直接讀取 HTML 檔案以識別選擇器
    │         ├─ 成功 → 使用選擇器撰寫 Playwright 腳本
    │         └─ 失敗/不完整 → 視為動態應用（見下方）
    │
    └─ 否（動態網頁應用）→ 伺服器是否已在執行中？
        ├─ 否 → 執行：python scripts/with_server.py --help
        │        然後使用輔助工具 + 撰寫簡化的 Playwright 腳本
        │
        └─ 是 → 先偵察再行動：
            1. 導覽並等待 networkidle
            2. 截圖或檢查 DOM
            3. 從渲染狀態識別選擇器
            4. 使用已發現的選擇器執行動作
```

## 範例：使用 with_server.py

啟動伺服器前，先執行 `--help`，再使用輔助工具：

**單一伺服器：**
```bash
python scripts/with_server.py --server "npm run dev" --port 5173 -- python your_automation.py
```

**多個伺服器（例如後端 + 前端）：**
```bash
python scripts/with_server.py \
  --server "cd backend && python server.py" --port 3000 \
  --server "cd frontend && npm run dev" --port 5173 \
  -- python your_automation.py
```

撰寫自動化腳本時，只需包含 Playwright 邏輯（伺服器由輔助工具自動管理）：
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True) # 永遠以 headless 模式啟動 chromium
    page = browser.new_page()
    page.goto('http://localhost:5173') # 伺服器已在執行且就緒
    page.wait_for_load_state('networkidle') # 關鍵：等待 JS 執行完畢
    # ... 你的自動化邏輯
    browser.close()
```

## 偵察後行動模式

1. **檢查已渲染的 DOM**：
   ```python
   page.screenshot(path='/tmp/inspect.png', full_page=True)
   content = page.content()
   page.locator('button').all()
   ```

2. **從檢查結果識別選擇器**

3. **使用已發現的選擇器執行動作**

## 常見陷阱

❌ **不要**在動態應用中等待 `networkidle` 之前就檢查 DOM
✅ **要**在檢查之前先執行 `page.wait_for_load_state('networkidle')`

## 最佳實踐

- **將打包腳本當作黑盒使用** — 執行任務時，先確認 `scripts/` 中是否有可用的腳本。這些腳本能可靠地處理複雜的常見工作流程，且不會污染上下文視窗。使用 `--help` 查看用法，然後直接呼叫。
- 使用 `sync_playwright()` 撰寫同步腳本
- 完成後務必關閉瀏覽器
- 使用具描述性的選擇器：`text=`、`role=`、CSS 選擇器或 ID
- 加入適當的等待：`page.wait_for_selector()` 或 `page.wait_for_timeout()`

## 參考檔案

- **examples/** — 示範常見模式的範例：
  - `element_discovery.py` — 探索頁面上的按鈕、連結與輸入欄位
  - `static_html_automation.py` — 使用 file:// URL 操作本地 HTML
  - `console_logging.py` — 在自動化過程中擷取主控台日誌
