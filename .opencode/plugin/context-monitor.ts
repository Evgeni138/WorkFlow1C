import type { Plugin } from "@opencode-ai/plugin"

// Замена Claude Code PostToolUse хука context-monitor.ps1:
// оценивает заполнение контекста по объёму результатов инструментов
// и предупреждает модель на 70% и 85%.
export const ContextMonitorPlugin = async ({ }) => {
  let chars = 0
  let warned70 = false
  let warned85 = false
  const MAX_TOKENS = Number(process.env.CONTEXT_MONITOR_MAX_TOKENS || 200000)
  return {
    "tool.execute.after": async (_input, output) => {
      try {
        const r = (output as any)?.result ?? (output as any)?.output
        if (typeof r === "string") chars += r.length
        else if (r && typeof r === "object") chars += JSON.stringify(r).length
        if (!r) return
        const tokens = Math.floor(chars / 4)
        const pct = Math.floor((tokens / MAX_TOKENS) * 100)
        const suffix = pct >= 85
          ? (!warned85 && ((warned85 = true), true))
            ? `\n\n[context-monitor] Context ~${pct}% (~${tokens} tokens). Save session NOW (/session-save), then /compact or start a new session.`
            : null
          : pct >= 70
            ? (!warned70 && ((warned70 = true), true))
              ? `\n\n[context-monitor] Context ~${pct}% (~${tokens} tokens). Consider saving the session soon.`
              : null
            : null
        if (suffix && typeof r === "string") {
          ;(output as any).result = r + suffix
        } else if (suffix && output && typeof output === "object") {
          ;(output as any).result = JSON.stringify(r) + suffix
        }
      } catch {
        // мониторинг не должен ломать выполнение инструментов
      }
    },
  }
}

export default ContextMonitorPlugin
