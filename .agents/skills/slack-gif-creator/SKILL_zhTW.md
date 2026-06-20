---
name: slack-gif-creator
description: 建立適用於 Slack 的最佳化動態 GIF 的知識與工具庫。提供限制條件、驗證工具與動畫概念。當使用者要求為 Slack 建立動態 GIF，例如「幫我做一個 X 做 Y 動作的 Slack GIF」時使用。
license: 完整授權條款請見 LICENSE.txt
---

# Slack GIF 製作工具

提供工具與知識，用於建立適用於 Slack 的最佳化動態 GIF。

## Slack 規格需求

**尺寸：**
- 表情符號 GIF：128x128（建議）
- 訊息 GIF：480x480

**參數：**
- FPS：10-30（愈低檔案愈小）
- 色彩：48-128（愈少檔案愈小）
- 時長：表情符號 GIF 請控制在 3 秒以內

## 核心工作流程

```python
from core.gif_builder import GIFBuilder
from PIL import Image, ImageDraw

# 1. 建立 builder
builder = GIFBuilder(width=128, height=128, fps=10)

# 2. 產生影格
for i in range(12):
    frame = Image.new('RGB', (128, 128), (240, 248, 255))
    draw = ImageDraw.Draw(frame)

    # 使用 PIL 基本圖形繪製動畫
    # （圓形、多邊形、線條等）

    builder.add_frame(frame)

# 3. 儲存並最佳化
builder.save('output.gif', num_colors=48, optimize_for_emoji=True)
```

## 圖形繪製

### 使用使用者上傳的圖片
若使用者上傳了圖片，請考量他們的意圖：
- **直接使用**（例如「幫我做動畫」、「把這個切成影格」）
- **作為靈感參考**（例如「做一個類似這個風格的」）

使用 PIL 載入並處理圖片：
```python
from PIL import Image

uploaded = Image.open('file.png')
# 直接使用，或僅作為顏色/風格參考
```

### 從頭開始繪製圖形
從頭繪製圖形時，使用 PIL ImageDraw 基本圖形：

```python
from PIL import ImageDraw

draw = ImageDraw.Draw(frame)

# 圓形/橢圓形
draw.ellipse([x1, y1, x2, y2], fill=(r, g, b), outline=(r, g, b), width=3)

# 星形、三角形、任意多邊形
points = [(x1, y1), (x2, y2), (x3, y3), ...]
draw.polygon(points, fill=(r, g, b), outline=(r, g, b), width=3)

# 線條
draw.line([(x1, y1), (x2, y2)], fill=(r, g, b), width=5)

# 矩形
draw.rectangle([x1, y1, x2, y2], fill=(r, g, b), outline=(r, g, b), width=3)
```

**不要使用：** 表情符號字型（跨平台可靠性差）或假設此技能內建有現成圖形資源。

### 讓圖形看起來精緻的技巧

圖形應看起來精緻有創意，而非粗糙基本。方法如下：

**使用較粗的線條** — 外框和線條請一律設定 `width=2` 或更高。細線（width=1）看起來不連貫、顯得業餘。

**增加視覺深度**：
- 背景使用漸層（`create_gradient_background`）
- 疊加多個形狀增加複雜度（例如星形內再加小星形）

**讓形狀更有趣**：
- 不要只畫普通的圓——加上高光、光環或圖案
- 星形可以有光暈效果（在後面繪製較大、半透明的版本）
- 組合多個形狀（星形＋閃光、圓形＋光環）

**注意色彩運用**：
- 使用鮮豔、互補的顏色
- 增加對比度（淺色形狀用深色外框，深色形狀用淺色外框）
- 考量整體構圖

**複雜形狀**（愛心、雪花等）：
- 組合多邊形和橢圓形
- 精確計算頂點以確保對稱
- 加上細節（愛心可有高光曲線，雪花有精緻的分支）

要有創意且注重細節！好的 Slack GIF 應看起來精緻，不像占位圖形。

## 可用工具

### GIFBuilder（`core.gif_builder`）
組合影格並針對 Slack 最佳化：
```python
builder = GIFBuilder(width=128, height=128, fps=10)
builder.add_frame(frame)  # 新增 PIL Image
builder.add_frames(frames)  # 新增影格列表
builder.save('out.gif', num_colors=48, optimize_for_emoji=True, remove_duplicates=True)
```

### 驗證器（`core.validators`）
檢查 GIF 是否符合 Slack 規格：
```python
from core.validators import validate_gif, is_slack_ready

# 詳細驗證
passes, info = validate_gif('my.gif', is_emoji=True, verbose=True)

# 快速檢查
if is_slack_ready('my.gif'):
    print("準備好了！")
```

### 緩動函式（`core.easing`）
使用流暢的緩動效果取代線性動作：
```python
from core.easing import interpolate

# 進度從 0.0 到 1.0
t = i / (num_frames - 1)

# 套用緩動
y = interpolate(start=0, end=400, t=t, easing='ease_out')

# 可用選項：linear、ease_in、ease_out、ease_in_out、
#           bounce_out、elastic_out、back_out
```

### 影格輔助函式（`core.frame_composer`）
常見需求的便利函式：
```python
from core.frame_composer import (
    create_blank_frame,         # 純色背景
    create_gradient_background,  # 垂直漸層
    draw_circle,                # 圓形輔助函式
    draw_text,                  # 簡單文字渲染
    draw_star                   # 五角星
)
```

## 動畫概念

### 搖晃/振動
以振盪偏移物件位置：
- 使用 `math.sin()` 或 `math.cos()` 搭配影格索引
- 加入小幅隨機變化以產生自然感
- 套用於 x 和/或 y 軸位置

### 脈動/心跳
有節奏地縮放物件大小：
- 使用 `math.sin(t * frequency * 2 * math.pi)` 產生平滑脈動
- 心跳效果：兩次快速脈動後暫停（調整正弦波）
- 在基本尺寸的 0.8 到 1.2 倍之間縮放

### 彈跳
物件落下並彈跳：
- 落地使用 `interpolate()` 搭配 `easing='bounce_out'`
- 下落使用 `easing='ease_in'`（加速效果）
- 每個影格增加 y 軸速度模擬重力

### 旋轉/自轉
物件繞中心旋轉：
- PIL：`image.rotate(angle, resample=Image.BICUBIC)`
- 搖擺效果：使用正弦波作為角度而非線性值

### 淡入/淡出
逐漸出現或消失：
- 建立 RGBA 圖片，調整 alpha 通道
- 或使用 `Image.blend(image1, image2, alpha)`
- 淡入：alpha 從 0 到 1
- 淡出：alpha 從 1 到 0

### 滑入
物件從畫面外移動到指定位置：
- 起始位置：畫面邊界以外
- 結束位置：目標位置
- 使用 `interpolate()` 搭配 `easing='ease_out'` 平滑停止
- 超衝效果使用 `easing='back_out'`

### 縮放
縮放並定位以產生縮放效果：
- 放大：從 0.1 縮放到 2.0，裁切中心
- 縮小：從 2.0 縮放到 1.0
- 可加入動態模糊增加戲劇感（PIL filter）

### 爆炸/粒子爆發
建立向外輻射的粒子：
- 產生帶有隨機角度和速度的粒子
- 更新每個粒子：`x += vx`，`y += vy`
- 加入重力：`vy += gravity_constant`
- 隨時間淡出粒子（減少 alpha）

## 最佳化策略

只有在要求縮小檔案大小時，才實作以下部分方法：

1. **減少影格** — 降低 FPS（10 而非 20）或縮短時長
2. **減少色彩** — `num_colors=48` 而非 128
3. **縮小尺寸** — 128x128 而非 480x480
4. **移除重複影格** — 在 save() 中設定 `remove_duplicates=True`
5. **表情符號模式** — `optimize_for_emoji=True` 自動最佳化

```python
# 表情符號的最大最佳化設定
builder.save(
    'emoji.gif',
    num_colors=48,
    optimize_for_emoji=True,
    remove_duplicates=True
)
```

## 設計理念

此技能提供：
- **知識**：Slack 的規格需求與動畫概念
- **工具**：GIFBuilder、驗證器、緩動函式
- **彈性**：使用 PIL 基本圖形建立動畫邏輯

此技能**不**提供：
- 固定的動畫範本或預製函式
- 表情符號字型渲染（跨平台可靠性差）
- 技能內建的現成圖形資源庫

**關於使用者上傳的圖片**：此技能不包含預製圖形，但若使用者上傳了圖片，可使用 PIL 載入並處理——根據使用者的要求判斷是直接使用還是僅作為靈感。

發揮創意！組合各種概念（彈跳＋旋轉、脈動＋滑入等），充分運用 PIL 的所有功能。

## 相依套件

```bash
pip install pillow imageio numpy
```
