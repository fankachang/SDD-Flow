````skill
---
name: container-image-hygiene
description: 在使用 Podman/Docker 建構容器映像檔後自動清理 dangling images，避免產生大量 <none> 映像檔佔用磁碟空間。適用於本專案使用 podman compose build/docker compose build 建構 image、需要保持系統乾淨、排查為何 image prune 後仍殘留 <none> 的情境。
license: Proprietary
---


# 容器映像檔清潔（Build 後自動清理）

**等級**：基礎
**預估時間**：2-10 分鐘
**最後更新**：2026-01-26

## 目標

- 建構映像檔後自動清理 dangling images（常見為 `<none>`）
- 降低磁碟被大量舊 image 佔滿的風險
- 提供安全（保守）與進階（較激進）兩種清理模式

## 快速開始（建議）

若你的專案有建構腳本（例如本機腳本或 CI pipeline），建議在「建構成功後」追加以下清理指令；沒有腳本也可以直接手動執行。

### Podman（Windows/Linux/Mac）

```bash
podman image prune -f
```

### Docker（Windows/Linux/Mac）

```bash
docker image prune -f
```

## 保守清理（只清 dangling images）

此模式最安全：只刪除「沒有 tag 且不再被引用」的 dangling images。

```ps1
podman image prune -f
```

驗證：

```ps1
# 應該回傳空或很少
podman images -f "dangling=true"
```

## 進階清理（處理 prune 後仍殘留的大型 <none>）

如果你看到仍有大型 `<none>`（例如 8GB）存在，常見原因是：

- 有容器（包含停止狀態）仍引用該 image
- 該 image 不是 dangling（例如仍被 build cache/容器引用），因此 `image prune` 不會移除

### Step 1：找出哪些容器還在用該 image

```ps1
podman ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"
```

若發現停止容器引用舊 image，可選擇刪除停止容器（注意：會刪掉容器本體，但不會刪除你的專案檔案與 bind mount 來源資料夾）。

```ps1
podman container prune -f
```

### Step 2：再做一次 image prune

```ps1
podman image prune -f
```

## 較激進模式（不建議預設開啟）

如果你確定要把「所有未被使用的 images」一起清掉（可能包含 base image，之後需要重新下載），可使用：

```ps1
# 刪除所有未被使用的 images（比 dangling 更廣）
podman image prune -a -f
```

或整體清理（可能影響更多資源：停止容器、未使用網路、未使用 image）：

```ps1
podman system prune -f
```

## 常見注意事項

- **不要在重要容器仍在跑時做激進清理**：保守的 `podman image prune -f` 通常沒問題，但 `-a` / `system prune` 可能影響你預期外的資源。
- **大量 `<none>` 的根因**：通常是反覆用同一個 tag（例如 `latest`）重建，舊版本就會變成 untagged；因此「建構後自動清理」是最省心做法。

## 檢查清單

- [ ] 建構流程使用 `scripts/build.ps1` / `scripts/build.sh`
- [ ] 建構後執行過 `podman image prune -f`
- [ ] 若仍殘留大型 `<none>`，已檢查並清掉停止容器後再 prune
````
