---
name: run-tests
description: Run the codeblock test suite in-engine, by booting Luanti headless with codeblock_run_tests enabled and reading the results. Handles enabling the setting, launching, parsing the output and — critically — removing the setting afterwards.
when_to_use: After changing anything in mods/codeblock, before committing, when asked to run or verify the tests, or when checking whether the game still loads cleanly on the installed engine.
argument-hint: "[--keep-world]"
allowed-tools: Bash, Read, Glob, Grep
---

# Running the tests

The specs run inside Luanti, not under a standalone interpreter, because several
of them need the mod loaded — `integration_spec` drives the real command budget,
`forms_spec` needs the registered callbacks, `stepper_spec` needs the real
config. A headless server boots the game, the specs print, and the server is
killed.

Five of the eight also run standalone under Lua 5.1 in CI. That is not
redundant: it is the only thing that catches behaviour differing between plain
5.1 and the LuaJIT the game runs. A bug in the `string.rep` separator was found
exactly this way.

## The one thing that must not be skipped

Enabling the suite means writing `codeblock_run_tests = true` into the **real
user config** at `%APPDATA%\Minetest\minetest.conf`. Luanti's `--config` flag
does not work for this — it is silently ignored, verified by setting `port` in a
file passed that way and watching the server bind the default anyway.

So the setting goes into the config the player actually uses, and **must be
removed afterwards**, or every ordinary launch of the game runs the test suite
and prints to their console. Remove it on the failure path too.

## Procedure

Run this from the repository root. It enables the setting, boots, captures,
kills, strips the setting, and prints the results.

```powershell
$exe   = "$env:LOCALAPPDATA\luanti\5.17.0\bin\luanti.exe"
$uconf = "$env:APPDATA\Minetest\minetest.conf"
$world = Join-Path $env:TEMP ("cc_test_" + [guid]::NewGuid().ToString("N").Substring(0,8))
$out   = "$world.out"
$err   = "$world.err"

Add-Content -Path $uconf -Encoding utf8 -Value "codeblock_run_tests = true"
try {
    $p = Start-Process -FilePath $exe -PassThru -NoNewWindow `
        -ArgumentList @("--server","--gameid","codecube","--world",$world) `
        -RedirectStandardOutput $out -RedirectStandardError $err
    Start-Sleep -Seconds 22
    if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force }
    Start-Sleep -Seconds 2
}
finally {
    # Always, including if the launch threw. A setting left behind runs the
    # suite on every normal launch of the game.
    (Get-Content $uconf) |
        Where-Object { $_ -notmatch '^codeblock_run_tests' } |
        Set-Content $uconf -Encoding utf8
}

Get-Content $out | Select-String "passed|failed|FAIL|want|got|skipped"
"--- errors ---"
$e = Get-Content $err | Select-String "ModError|attempt to|traceback|invalid|Blocked"
if ($e) { $e | Select-Object -First 10 } else { "none" }
```

Pass `--keep-world` to leave the world directory for inspection; otherwise it is
a throwaway under `%TEMP%` and can be ignored.

## Reading the result

A healthy run prints one summary per spec:

```
  api_spec              30 passed   0 failed
  preprocess_spec       54 passed   0 failed   1 xfail (known defects)   0 xpass
  env_spec              21 passed   0 failed
  shapes_spec           18 passed   0 failed
  strguard_spec         29 passed   0 failed
  forms_spec            35 passed   0 failed
  stepper_spec          24 passed   0 failed
  integration_spec      48 passed   0 failed
```

What each column means:

- **failed** — a real failure. Nothing else matters until it is zero.
- **xfail** — a known defect, asserted as still broken. The count dropping is
  good news; it means something was fixed. The count *rising* means a defect was
  introduced and someone recorded it rather than fixing it.
- **xpass** — an `xfail` that now passes. **This fails the run deliberately.** It
  usually means a defect was fixed and the test should be promoted — but it can
  also mean the test is passing vacuously because the thing it exercises stopped
  running at all. That second case has happened here: instrumentation was
  silently disabled and the `xfail` cases passed trivially. Always check which.
- **skipped** — a spec that needs the mod and did not find it. Investigate; it
  means the mod failed to load.

If nothing prints at all, the mod did not load. Look in the error output for
`ModError` and read the traceback — a syntax error in any `lib/*.lua` stops the
whole mod.

## Before concluding it passes

- No `ModError` in the error stream.
- Every spec reported, none skipped.
- `0 failed` and `0 xpass` everywhere.
- The setting is gone from `minetest.conf` — check, do not assume.

## Related

`scripts/check_game.sh` in the game repo verifies the game *assembles* — that is
a different question and is not run by this skill.
`mods/codeblock/scripts/gen_docs.lua --check` verifies the API reference is
current. Both run in CI.
