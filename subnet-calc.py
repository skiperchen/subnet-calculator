#!/usr/bin/env python3
"""
子网掩码计算器 - macOS Native Launcher
使用系统 WebView 打开，提供原生 macOS 体验
用法: python3 subnet-calc.py
"""
import os, sys, json, http.server, socketserver, threading, webbrowser, tempfile

APP_DIR = os.path.dirname(os.path.abspath(__file__))
INDEX_FILE = os.path.join(APP_DIR, 'index.html')

PORT = 19876  # 固定端口，方便调试

class QuietHTTPHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=APP_DIR, **kwargs)
    def log_message(self, format, *args):
        pass

def start_server():
    with socketserver.TCPServer(("127.0.0.1", PORT), QuietHTTPHandler) as httpd:
        httpd.serve_forever()

def launch_browser():
    import time
    time.sleep(0.3)
    webbrowser.open(f'http://127.0.0.1:{PORT}/index.html')

def try_webview():
    """Try to use pywebview for native window if installed"""
    try:
        import webview
        threading.Thread(target=start_server, daemon=True).start()
        webview.create_window('子网掩码计算器', f'http://127.0.0.1:{PORT}/index.html',
                              width=960, height=720, resizable=True, min_size=(600, 400))
        webview.start()
        return True
    except ImportError:
        return False

def try_tkinter():
    """Try to use tkinter + tkinterweb if available"""
    try:
        import tkinter as tk
        from tkinter import ttk
        # Try to use tkinterweb for embedded browser
        try:
            from tkinterweb import HtmlFrame
            threading.Thread(target=start_server, daemon=True).start()
            root = tk.Tk()
            root.title('子网掩码计算器')
            root.geometry('960x720')
            root.minsize(600, 400)

            # macOS style
            try:
                root.tk.call('tk', 'scaling', 2.0)
            except:
                pass

            frame = HtmlFrame(root, messages_enabled=False)
            frame.load_website(f'http://127.0.0.1:{PORT}/index.html')
            frame.pack(fill='both', expand=True)
            root.mainloop()
            return True
        except ImportError:
            pass
    except ImportError:
        return False
    return False

if __name__ == '__main__':
    # Try native webview first, then fall back to browser
    if try_webview():
        sys.exit(0)

    if try_tkinter():
        sys.exit(0)

    # Ultimate fallback: open in default browser
    print('启动本地服务器...')
    server_thread = threading.Thread(target=start_server, daemon=True)
    server_thread.start()
    launch_browser()
    print(f'子网掩码计算器已在浏览器中打开: http://127.0.0.1:{PORT}/index.html')
    print('按 Ctrl+C 停止服务')
    try:
        while True:
            server_thread.join(1)
    except KeyboardInterrupt:
        print('\n已退出')
