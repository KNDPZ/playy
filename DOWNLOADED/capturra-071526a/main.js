const { app, BrowserWindow, session, ipcMain, desktopCapturer, dialog } = require('electron');
const path = require('path');
const fs = require('fs');

// Let the compositor start with sound without requiring a click
app.commandLine.appendSwitch('autoplay-policy', 'no-user-gesture-required');

/* ---------------- config (persists the record folder) ---------------- */
const configPath = () => path.join(app.getPath('userData'), 'capturra-config.json');
function loadConfig() {
  try { return JSON.parse(fs.readFileSync(configPath(), 'utf8')); }
  catch (_) { return {}; }
}
function saveConfig(cfg) {
  try { fs.writeFileSync(configPath(), JSON.stringify(cfg, null, 2)); }
  catch (_) { /* non-fatal */ }
}
function recordDir() {
  const cfg = loadConfig();
  return cfg.recordDir && fs.existsSync(cfg.recordDir)
    ? cfg.recordDir
    : app.getPath('videos');
}

/* ---------------- crash-safe recording stream ---------------- */
// The renderer sends 1-second chunks; each one is written (and flushed by the
// OS) immediately. If the renderer, the app, or the whole PC dies, the file
// already contains everything up to the last received chunk.
let recStream = null;
let recPath = null;

function closeRecStream() {
  return new Promise((resolve) => {
    if (!recStream) return resolve();
    const s = recStream;
    recStream = null;
    s.end(() => resolve());
  });
}

function createWindow() {
  const win = new BrowserWindow({
    width: 1380,
    height: 860,
    minWidth: 760,
    minHeight: 500,
    autoHideMenuBar: true,
    backgroundColor: '#0d1013',
    title: 'Capturra',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });
  win.loadFile(path.join(__dirname, 'capturra.html'));
}

app.whenReady().then(() => {
  const grant = (perm) =>
    ['media', 'audioCapture', 'videoCapture', 'display-capture', 'fullscreen'].includes(perm);

  // Auto-grant camera/mic/screen: the app never shows a permission prompt.
  session.defaultSession.setPermissionRequestHandler((wc, permission, callback) => {
    callback(grant(permission));
  });
  session.defaultSession.setPermissionCheckHandler((wc, permission) => grant(permission));

  // Monitors + app windows for the "+ Add video source" menu
  ipcMain.handle('capturra:get-sources', async () => {
    const sources = await desktopCapturer.getSources({
      types: ['screen', 'window'],
      thumbnailSize: { width: 0, height: 0 },
      fetchWindowIcons: false,
    });
    return sources.map((s) => ({
      id: s.id,
      name: s.name,
      kind: s.id.startsWith('screen') ? 'screen' : 'window',
    }));
  });

  // Record-location settings
  ipcMain.handle('capturra:get-record-dir', () => recordDir());
  ipcMain.handle('capturra:choose-record-dir', async () => {
    const res = await dialog.showOpenDialog({
      title: 'Choose where Capturra saves recordings',
      defaultPath: recordDir(),
      properties: ['openDirectory', 'createDirectory'],
    });
    if (res.canceled || !res.filePaths[0]) return null;
    const cfg = loadConfig();
    cfg.recordDir = res.filePaths[0];
    saveConfig(cfg);
    return cfg.recordDir;
  });

  // Streaming recording
  ipcMain.handle('capturra:rec-start', async (ev, fileName) => {
    try {
      await closeRecStream(); // safety: never two files at once
      const dir = recordDir();
      fs.mkdirSync(dir, { recursive: true });
      const safe = String(fileName).replace(/[\\/:*?"<>|]/g, '-');
      recPath = path.join(dir, safe);
      recStream = fs.createWriteStream(recPath, { flags: 'w' });
      return { path: recPath };
    } catch (e) {
      recStream = null; recPath = null;
      return { error: e.message };
    }
  });

  ipcMain.handle('capturra:rec-chunk', (ev, buf) => {
    return new Promise((resolve, reject) => {
      if (!recStream) return resolve(false);
      recStream.write(Buffer.from(buf), (err) => (err ? reject(err) : resolve(true)));
    });
  });

  ipcMain.handle('capturra:rec-stop', async () => {
    const p = recPath;
    await closeRecStream();
    recPath = null;
    return { path: p };
  });

  createWindow();
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

// If the window dies mid-recording, flush and close the file so what was
// captured stays playable.
app.on('before-quit', () => { if (recStream) recStream.end(); });
app.on('window-all-closed', () => {
  if (recStream) recStream.end();
  app.quit();
});
