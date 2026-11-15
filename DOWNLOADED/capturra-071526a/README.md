# Capturra — release 071526a

**Capturra** is a multi-source **capture monitor, audio mixer, scene system,
and crash-safe recorder** for webcams, capture cards (Elgato Cam Link,
AVerMedia, generic "USB Video" HDMI grabbers), **monitors, and app windows**.
Mix any number of video and audio sources, build overlay scenes with their own
layouts and hotkeys, monitor everything live, and record it all to a video
file that survives crashes.

It runs two ways from the **same single file**:

| Mode | What you get |
|---|---|
| **Windows desktop app** (recommended) | Zero permission prompts, monitors & windows listed **by name**, true PC system-audio capture, **crash-safe recording streamed to a folder you choose**, auto-starts on launch. |
| **Browser** (`capturra.html`) | Works in Chrome / Edge / Brave / Firefox. Monitors & system audio via the browser's share picker; recordings save to Downloads when you stop. |

---

## Release history

Releases are tagged by **date of change** (`MMDDYY` + letter — the letter is
the iteration within that day, so `071526a` is the first change made on
July 15 2026, `071526b` would be the second, and so on):

| Release | Changes |
|---|---|
| `070906a` | Initial capture monitor |
| `070906b` | Prompt-free Apply, VU meters, identify mode, desktop app |
| `070906c` | Multi-video, monitors/windows as sources, audio mixer, grid & overlay, recording, setup.bat, tag-chip UI, FPS throttle, hideable bottom panel |
| `070906d` | Renamed to **Capturra**; scene system (unlimited overlays, each with its own main source, members, positions, hotkey, duplication); Settings tab; record location; **crash-safe streaming recording**; layout hotkeys; animated setup with "do not close" indicator; `Capturra-Standalone-*.exe` naming |
| `071526a` | **This release** — **resizable options panel** (drag the `⋮` divider); **Master audio** (shared across every scene, always recorded); **per-scene audio** (each scene can add its own sources or copy the master set); unified **Layout → ＋ Add scene** (Single / Grid / Overlay are now scene types — the built-in layout buttons are gone); DECK / SETTINGS tabs stay visible at all times (sticky); **Save / Load config** (whole setup — scenes, positions, audio, hotkeys, output — to a file, re-attached by device name in a new session); hotkeys now start at `1` |

---

## Features

### Scenes — reworked in this release
- **Everything is a scene now.** The old built-in Single/Grid layout buttons
  are gone. Under **Layout**, press **＋ Add scene** and choose its type:
  - **SGL — Single**: one chosen source fills the stage.
  - **GRD — Grid**: a chosen *subset* of sources tiled CCTV-style.
  - **OVL — Overlay**: a chosen **main (background) source** plus any floating
    sources on top — drag to move, drag the corner to resize. **Positions are
    saved per scene**, so two scenes can arrange the same sources differently.
- **Per-scene main source.** In one scene the camera can be the main video;
  in another, the game; a third can be a grid of everything.
- **Per-scene audio — new.** Open a scene to give it its own audio: **＋ ADD
  AUDIO** attaches a source that is recorded *only while that scene is
  active*, and **COPY MASTER AUDIO** duplicates the whole master set into the
  scene with independent volume / MUTE / MON. A scene therefore hears master
  audio (always) plus whatever it carries itself.
- **Duplicate (DUP)** any scene and edit the copy; **rename (✎)** and
  **delete (✕)** per scene. Click a scene's name to activate it; click again
  to fall back to the MAIN source filling the stage.

### Master audio — new in this release
- The mixer is now called **Master audio**: whatever is in it and not muted
  is recorded **no matter which scene is on the stage** — change scenes
  mid-recording and the master mix carries straight through.
- Scene audio sits on top of it, gated by the active scene.

### Resizable panel — new in this release
- Grab the **⋮ divider** between the stage and the options panel and drag it
  left / right to resize the panel (260-720 px). The width is remembered.
- The **DECK / SETTINGS tabs are sticky** — they stay visible while you
  scroll the panel or open menus.

### Save / Load config — new in this release
- **Settings → Config → SAVE CONFIG** writes the whole setup to a JSON file:
  scenes (type, name, hotkey, main, members, floating positions), master and
  per-scene audio (volume / MUTE / MON), output settings, and the active
  scene.
- **LOAD CONFIG** restores it in a new session. Sources are saved by **device
  name** and re-attached automatically — no re-arranging, re-adding, or
  remapping. Anything that can't come back by itself (unplugged device,
  browser share-picker sources) is listed so you can re-add just those.

### Hotkeys
- **Every new scene automatically gets the next free key** (1, 2, 3 ...), so
  you can jump between views mid-recording without touching the mouse.
- Remap everything in **Settings → Hotkeys**: click a key box, press the key
  you want; `Esc` clears it. Assigning a key that's in use steals it from the
  previous owner. Reserved: `Space` (start/stop), `R` (record), `M` (mute),
  `F` (fullscreen), `H` (bottom panel).

### Crash-safe recording — new in this release
- **Desktop app:** the recording is **streamed to disk every second** while it
  runs. If Capturra, the PC, or anything else crashes mid-recording, the file
  in your chosen folder already contains everything up to the last second —
  nothing to recover, it's simply there.
- **Record location** is configurable in **Settings → Recording** (defaults to
  your Videos folder) and is remembered between launches.
- **Browser mode:** browsers only make files durable when recording stops, so
  browser recordings still save to Downloads on stop — the Settings tab says
  so honestly. For crash protection, use the desktop app.
- Files are named `Capturra-071526a-YYYYMMDD-HHMMSS.webm`. WebM plays in VLC
  and browsers; convert with HandBrake or `ffmpeg -i in.webm out.mp4`.

### Video
- Up to **8 simultaneous video sources**: cameras/capture cards (by name),
  monitors ("Screen 1", "Screen 2" — desktop app), app windows (desktop app),
  or the browser's share picker in browser mode.
- Add and remove sources **while live**; every scene adapts instantly.
- Output resolution (480p–4K), FPS (24/30/50/60), aspect ratio — the
  compositor renders exactly what gets recorded.

### Audio mixer
- Any number of sources: microphones / line-ins (where a capture card's sound
  lives), **System audio** (true Windows loopback in the desktop app), and
  **app / browser-tab audio**.
- Per-source **volume**, **MUTE** (affects the recording — mute your mic
  mid-recording and it's muted in the file), **MON** toggle (whether *you*
  hear it; always recorded), and a live VU meter.
- Feedback-safe defaults: your own mic starts MON-off; capture-card line-ins
  start MON-on.
- Master volume/mute affects only what you hear, never the recording.

### General
- Broadcast-style OSD: tally, output resolution, measured FPS, **active view
  name**, source counts, audio state.
- Collapsible options panel (`>>>` / `<<< OPTIONS`) and hideable bottom panel
  (`▼` / `▲ PANEL`, hotkey `H`).
- **DECK / SETTINGS tabs** in the options panel.
- Plain-text tag chips (`CAM SCR WIN MIC SYS APP`, `SGL GRD OVL`) that render
  correctly on every system.

---

## Installation

### Easiest: run `setup.bat` (Windows)

1. Unzip this folder anywhere.
2. **Double-click `setup.bat`.** It will:
   - check for Node.js — if missing, it opens the download page and tells you
     exactly what to install;
   - install dependencies and build the exe **with a live progress animation
     and elapsed timer** so you can see it's working — **don't close the
     window while the `[ = ]` bar is moving**;
   - offer to **create a desktop shortcut**;
   - offer to launch Capturra immediately.
3. If a step fails, the window prints the last log lines plus the fix
   (internet/proxy, antivirus, disk space) — follow it and re-run.

The result is **`dist\Capturra-Standalone-071526a.exe`** — "Standalone" in the
name tells downloaders this is the single-file portable version (the other
version being this source folder run via `npm start`). Copy the exe to any PC
and double-click; no install, no Node.js, no prompts.

### Manual (any OS)

```
npm install     # once
npm start       # run the app
npm run dist    # build the standalone exe into dist\
```

### Browser only (no build)

Open `capturra.html` in Chrome/Edge/Brave and click **Allow** on the
permission prompt. In **Brave**, set "Remember my decision" to a permanent
option or it re-asks each session — file:// policy, not the app.

---

## Using Capturra

1. **Add video sources** (＋) — cameras, capture cards, monitors, windows.
2. **Add master audio** (＋) — mics, the capture card's line-in, System
   audio, app/tab audio. Master audio is recorded in every scene. Adjust each
   one's volume/MUTE/MON any time, including mid-recording.
3. **Build scenes** — Layout → ＋ Add scene → single / grid / overlay. Pick
   the main source and members in the inline editor; drag floating videos on
   the stage; give the scene its own audio or copy the master set. DUP to
   make variants.
4. **Set hotkeys** — Settings → Hotkeys (new scenes already have one).
5. **Start capture** (`Space`) to monitor; **Record** (`R`) to save. Switch
   views live with `1`, `2`, and your overlay keys — the recording follows
   whatever is on the stage.
6. **Settings → Recording** to choose where files go (desktop app).
7. **Settings → Config → SAVE CONFIG** once you're happy — next session,
   LOAD CONFIG brings the whole setup back.

### Default keys

| Key | Action |
|---|---|
| `Space` | Start / stop capture |
| `R` | Start / stop recording |
| `1` `2` `3` … | Your scenes (auto-assigned, remappable) |
| `M` | Mute / unmute monitor audio |
| `F` | Toggle fullscreen |
| `H` | Hide / show the bottom panel |

---

## Troubleshooting

**Capture card doesn't appear in the ＋ menu.**
Grant access first (browsers hide devices until then — amber button appears);
close OBS / the card's own software (one app at a time); confirm the card is
UVC (shows in Windows' Camera app — non-UVC cards are invisible to Chromium);
try a USB 3.0 port.

**System audio produced nothing.**
Browser: pick **Entire screen** and tick **"Also share system audio"** in the
picker. Desktop: loopback is Windows-only; macOS needs a virtual audio driver
(e.g. BlackHole).

**One app's audio, not the whole PC?**
Browser tabs isolate cleanly (🎵 App/tab audio). Windows doesn't expose other
apps' audio individually to Chromium — use System audio, or route the app
through a virtual audio cable (VB-Audio) and add it as a MIC input.

**Echo of my own voice.** Your microphone's MON toggle is on — turn it off.
It's still recorded.

**Recording has no sound.** A per-source MUTE affects the file; the master
mute doesn't. The per-source meters show what's actually being captured.

**A crash happened mid-recording — where's my video?**
Desktop app: it's already in your record folder, playable up to the moment of
the crash. Browser mode can't offer this — the file only exists once you stop.

**Overlay won't drag.** Activate an overlay-type scene first (click its name);
only its floating sources drag — the main background doesn't.

**setup.bat seems stuck.** If the `[ = ]` bar is moving and the seconds are
counting, it's working — first runs download ~100 MB. If the bar is frozen for
several minutes, close it, check `setup-install.log` / `setup-build.log` in
the folder, and re-run.

**Black screen from a console.** HDCP — disable it in the console's settings
(PlayStation allows this); use the card's HDMI **IN** port; give it a few
seconds to sync.

---

## FAQ

**Where do recordings go?** Desktop app: the folder in Settings → Recording
(default: Videos), written continuously. Browser: Downloads, on stop.

**Do scenes persist after closing?** Use **Settings → Config → SAVE CONFIG**
to write the whole setup (scenes, audio, hotkeys, output) to a file, and
LOAD CONFIG to bring it back next session — sources re-attach by device name.
The record location and panel width are remembered automatically.

**Does anything leave my PC?** No. No server, no network code.

**Why is capture-card audio a "microphone"?** Cards present incoming HDMI
audio as an input device to Windows. Capturra records it raw — no voice
processing.

**macOS / Linux?** The HTML runs in any modern browser; `npm start` runs the
desktop app cross-platform (system-audio loopback is Windows-only). Change
`--win portable` in `package.json` to `--mac` or `--linux` to build there.

---

## Project structure

```
capturra/
├── capturra.html   The entire application (UI, compositor, scenes, mixer, recorder)
├── main.js         Electron main: window, auto permissions, monitor/window
│                   listing, record-folder config, crash-safe file streaming
├── preload.js      Safe bridge between the page and the main process
├── package.json    npm scripts + Capturra-Standalone exe build config
├── setup.bat       One-click Windows builder with live progress animation
└── README.md       This file
```

The compositor draws every scene onto one canvas (the recording is exactly
what you see), the mixer is a Web Audio graph (per-source gain → recorder bus
+ monitor bus), and recording uses `MediaRecorder` with 1-second chunks that
the desktop app writes straight to disk.

---

## License

MIT — use it, modify it, ship it.
