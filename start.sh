#!/bin/bash
set -e

echo "🚀 Railway NapCat 启动中..."
echo "📡 PORT = $PORT"

# ========== 1️⃣ Python 代理服务器（健康检查 + 转发）==========
python3 -c "
import http.server, os, sys, socket

PORT = int(os.environ.get('PORT', 8080))
NAPCAT_PORT = 3000

class ProxyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        # ✅ 健康检查：GET / 直接返回 200
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'OK')
            return
        
        # 🔄 其他请求转发到 NapCat
        self._proxy_request('GET')
    
    def do_POST(self):
        self._proxy_request('POST')
    
    def do_HEAD(self):
        self._proxy_request('HEAD')
    
    def _proxy_request(self, method):
        try:
            # 连接到 NapCat
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect(('127.0.0.1', NAPCAT_PORT))
            
            # 转发请求行和请求头
            body = b''
            content_length = int(self.headers.get('Content-Length', 0))
            if content_length > 0:
                body = self.rfile.read(content_length)
            
            request = f'{method} {self.path} HTTP/1.1\r\n'
            for k, v in self.headers.items():
                request += f'{k}: {v}\r\n'
            request += '\r\n'
            s.sendall(request.encode())
            if body:
                s.sendall(body)
            
            # 读取响应并转发
            response = b''
            while True:
                chunk = s.recv(4096)
                if not chunk:
                    break
                response += chunk
            
            s.close()
            
            # 解析并转发响应
            if response:
                # 提取状态行
                header_end = response.find(b'\r\n\r\n')
                if header_end > 0:
                    status_line = response.split(b'\r\n')[0]
                    status_code = int(status_line.split(b' ')[1])
                    self.send_response(status_code)
                    
                    # 转发响应头
                    headers = response[:header_end].decode(errors='replace')
                    for line in headers.split('\r\n')[1:]:
                        if ':' in line:
                            k, v = line.split(':', 1)
                            self.send_header(k.strip(), v.strip())
                    self.end_headers()
                    
                    # 转发响应体
                    self.wfile.write(response[header_end+4:])
                    
        except Exception as e:
            self.send_response(502)
            self.end_headers()
            self.wfile.write(f'Proxy Error: {e}'.encode())
    
    def log_message(self, *args):
        pass  # 静默日志，不干扰 NapCat 的日志

try:
    server = http.server.HTTPServer(('0.0.0.0', PORT), ProxyHandler)
    print(f'✅ 代理/健康检查: 监听 :{PORT} → NapCat :{NAPCAT_PORT}')
    server.serve_forever()
except Exception as e:
    print(f'❌ 启动失败: {e}')
    sys.exit(1)
" &
sleep 1

# ========== 2️⃣ Xvfb（虚拟显示器）==========
rm -f /tmp/.X99-lock
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x16 &
sleep 1
echo "✅ Xvfb 虚拟显示器已启动"

# ========== 3️⃣ 启动 QQ + NapCat ==========
cd /app
echo "⏳ 启动 QQ + NapCat（可能需要 1-3 分钟）..."
xvfb-run -a qq --no-sandbox &
echo "✅ QQ + NapCat 已后台启动"

# ========== 4️⃣ 保持运行 ==========
wait
