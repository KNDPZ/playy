const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('captureDeck', {
  // Monitors and app windows: [{ id, name, kind: 'screen' | 'window' }]
  getSources: () => ipcRenderer.invoke('capturra:get-sources'),

  // Record-location settings
  getRecordDir: () => ipcRenderer.invoke('capturra:get-record-dir'),
  chooseRecordDir: () => ipcRenderer.invoke('capturra:choose-record-dir'),

  // Crash-safe streaming recording: chunks are written to disk immediately
  recStart: (fileName) => ipcRenderer.invoke('capturra:rec-start', fileName),
  recChunk: (arrayBuffer) => ipcRenderer.invoke('capturra:rec-chunk', arrayBuffer),
  recStop: () => ipcRenderer.invoke('capturra:rec-stop'),

  release: '071526a',
});
