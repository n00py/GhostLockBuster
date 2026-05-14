# GhostLock DESTROYER

[find_and_kick_smb_holder.ps1](/Users/spartan/codex/ghostlock_guard/find_and_kick_smb_holder.ps1) lists SMB sessions holding matching files and can close those sessions.

```powershell
# list holders
powershell -ExecutionPolicy Bypass -File .\find_and_kick_smb_holder.ps1 `
  -PathLike "\\fileserver\share\dept\*"

# close matching sessions
powershell -ExecutionPolicy Bypass -File .\find_and_kick_smb_holder.ps1 `
  -PathLike "\\fileserver\share\dept\*" `
  -Mode CloseSession

# close one specific session
powershell -ExecutionPolicy Bypass -File .\find_and_kick_smb_holder.ps1 `
  -SessionId 44123 `
  -Mode CloseSession
```
