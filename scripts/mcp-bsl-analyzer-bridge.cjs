const { spawn } = require('child_process');

const args = process.argv.slice(2);
if (args.length < 1) {
  console.error('usage: node mcp-bsl-analyzer-bridge.cjs <bsl-analyzer.exe> [args...]');
  process.exit(2);
}
const exe = args[0];
const rest = args.slice(1);

/*
 * MCP stdio transport (both opencode and the child) is newline-delimited
 * JSON-RPC: each message is a single line of JSON terminated by "\n".
 * bsl-analyzer "mcp serve" already speaks exactly this protocol, so this
 * bridge is now a transparent byte relay in both directions.
 *
 * NOTE: an earlier version wrongly translated LSP "Content-Length: N\r\n\r\n"
 * frames into newline JSON (and back). opencode never sends LSP frames for
 * stdio MCP servers, so the handshake never completed and the server was
 * reported as "unavailable". The raw relay below cannot break framing.
 */

const child = spawn(exe, rest, { stdio: ['pipe', 'pipe', 'inherit'] });

child.stdout.pipe(process.stdout);
process.stdin.pipe(child.stdin);

child.on('error', (err) => {
  console.error('mcp-bsl-analyzer-bridge: failed to start child: ' + err.message);
  process.exit(1);
});

process.stdin.on('end', () => {
  try { child.stdin.end(); } catch (e) {}
});

child.on('exit', (code, signal) => {
  if (signal) process.exit(1);
  process.exit(code === null ? 1 : code);
});