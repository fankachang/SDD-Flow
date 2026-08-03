---
name: RunPowerShell
description: Configure PowerShell UTF-8 encoding to avoid Chinese character encoding issues, used for initial setup when Copilot starts PowerShell.
license: Complete terms in LICENSE.txt
---

# PowerShell UTF-8 Configuration for Copilot

**Level**: Basic  
**Estimated Time**: 2-5 minutes  
**Last Updated**: 2026-01-06

## Learning Objectives

- Understand why PowerShell UTF-8 encoding is needed
- Learn to execute initial setup commands
- Ensure Chinese characters display correctly when Copilot starts PowerShell

## Quick Start

Execute the following commands in PowerShell to configure UTF-8 encoding:

```ps1
chcp 65001 > $null
$OutputEncoding = [Console]::OutputEncoding = [Console]::InputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
```

Description: Switches code page and sets input/output and Cmdlet default encoding to UTF-8.

## Verification

```ps1
Write-Output "Testing Chinese output: 你好，世界！"
[Console]::OutputEncoding.EncodingName
```

## FAQ

**Q: Why do I need to run these commands?**  
A: By default, PowerShell encoding may not be UTF-8, causing Chinese characters to display as garbled text. These commands ensure both input and output use UTF-8 encoding.

**Q: Do I need to run this every time PowerShell starts?**  
A: If you add these commands to your PowerShell Profile, they will execute automatically on startup, eliminating the need for manual input.

## References

- https://learn.microsoft.com/en-us/powershell/
- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding

## 檢查清單

- [ ] 我已執行初始設定指令
- [ ] 我已驗證中文顯示正常
- [ ] （選用）我已將設定加入 PowerShell Profile
