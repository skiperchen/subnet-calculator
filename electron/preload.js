// Preload - 安全的桥接
const { contextBridge } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  platform: process.platform,
  isMac: process.platform === 'darwin',
});
