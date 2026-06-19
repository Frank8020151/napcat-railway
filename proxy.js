const http = require('http');
const net = require('net');

const PORT = parseInt(process.env.PORT || '3000');
const NAPCAT_PORT = 3000;

const server = http.createServer((req, res) => {
  // ✅ 健康检查：GET / 返回 200
  if (req.method === 'GET' && req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('OK');
    return;
  }
  
  // HTTP API 请求代理到 NapCat
  const options = {
    hostname: '127.0.0.1',
    port: NAPCAT_PORT,
    path: req.url,
    method: req.method,
    headers: req.headers
  };
  
  const proxyReq = http.request(options, (proxyRes) => {
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(res);
  });
  
  proxyReq.on('error', () => {
    res.writeHead(502);
    res.end('Bad Gateway');
  });
  
  req.pipe(proxyReq);
});

// 🔌 WebSocket 升级请求代理到 NapCat
server.on('upgrade', (req, socket, head) => {
  const proxySocket = net.connect(NAPCAT_PORT, '127.0.0.1', () => {
    // 把原始 HTTP Upgrade 请求转发给 NapCat
    proxySocket.write(
      `${req.method} ${req.url} HTTP/1.1\r\n` +
      Object.entries(req.headers).map(([k, v]) => `${k}: ${v}`).join('\r\n') +
      `\r\n\r\n`
    );
    // 双向数据管道
    proxySocket.pipe(socket);
    socket.pipe(proxySocket);
  });
  
  proxySocket.on('error', () => socket.destroy());
  socket.on('error', () => proxySocket.destroy());
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ 健康检查代理运行在端口 ${PORT} → NapCat :${NAPCAT_PORT}`);
});
