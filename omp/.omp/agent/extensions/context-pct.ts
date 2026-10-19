import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

/** Status-line context usage as a bare percentage, rendered by the `status` segment. */
export default function contextPct(pi: ExtensionAPI) {
	const update = (_event: unknown, ctx: ExtensionContext) => {
		const percent = ctx.getContextUsage()?.percent;
		ctx.ui.setStatus("context_pct", percent == null ? "?%" : `${percent.toFixed(1)}%`);
	};

	for (const event of [
		"session_start",
		"session_switch",
		"session_branch",
		"session_tree",
		"session_compact",
		"turn_end",
		"message_end",
	] as const) {
		pi.on(event, update);
	}
}
