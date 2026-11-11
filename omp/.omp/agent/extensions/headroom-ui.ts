import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";
import { stripTerminalSequences, truncateToWidth, visibleWidth } from "@oh-my-pi/pi-tui";

/** Adapt the linked Headroom fork's framed string widget, without owning its counters or timers. */
export default function headroomUI(pi: ExtensionAPI) {
	type UI = ExtensionContext["ui"];
	const installed = new Map<UI, { original: UI["setWidget"]; wrapped: UI["setWidget"] }>();

	const attach = (_event: unknown, ctx: ExtensionContext) => {
		if (!ctx.hasUI) return;
		const ui = ctx.ui;
		if (installed.has(ui)) return;
		const original = ui.setWidget;
		const wrapped: UI["setWidget"] = (key, content, options) => {
			if (key !== "headroom" || !Array.isArray(content)) {
				original.call(ui, key, content, options);
				return;
			}
			// This is the frame emitted by ~/projects/omp-headroom/src/widget.ts.
			// Leave unfamiliar formats alone rather than silently damaging another version's UI.
			const lines = content.map(stripTerminalSequences);
			if (!lines[0]?.startsWith("╭") || !lines.at(-1)?.endsWith("╯")) {
				original.call(ui, key, content, options);
				return;
			}
			const summary = lines.flatMap(line =>
				line.slice(1, -1).split(/─{2,}/)
					.map(part => part.replace(/^─\s*|\s*─$/g, "").trim())
					.map(part => part.replace(/^Headroom(?:\s*·\s*)?/, "").trim())
					.filter(Boolean),
			).join(" | ");
			original.call(ui, key, (_tui, theme) => ({
				invalidate() {},
				render(width) {
					if (width < 2) return [""];
					const inner = width - 2;
					const horizontal = theme.symbol("boxRound.horizontal");
					const border = theme.getThinkingBorderColor(pi.getThinkingLevel());
					const text = truncateToWidth(` ${summary} `, inner, "…");
					return [
						border(theme.symbol("boxRound.topLeft"))
						+ theme.fg("muted", text)
						+ border(horizontal.repeat(Math.max(0, inner - visibleWidth(text))))
						+ border(theme.symbol("boxRound.topRight")),
					];
				},
			}), { placement: "aboveEditor" });
		};
		ui.setWidget = wrapped;
		installed.set(ui, { original, wrapped });
	};

	for (const event of ["session_start", "session_switch", "session_branch", "session_tree", "turn_start", "message_end"] as const) {
		pi.on(event, attach);
	}
	pi.on("session_shutdown", (_event, ctx) => {
		if (!ctx.hasUI) return;
		for (const [ui, { original, wrapped }] of installed) {
			if (ui.setWidget === wrapped) ui.setWidget = original;
		}
		installed.clear();
	});
}
