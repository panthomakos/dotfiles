import { CustomEditor, type ExtensionAPI, type KeybindingsManager } from "@earendil-works/pi-coding-agent";
import type { EditorTheme, TUI } from "@earendil-works/pi-tui";

const BLINKING_BLOCK_CURSOR = "\x1b[1 q";
const DEFAULT_CURSOR = "\x1b[0 q";

class BlinkingCursorEditor extends CustomEditor {
  constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
    super(tui, theme, keybindings);
    process.stdout.write(BLINKING_BLOCK_CURSOR);
    tui.setShowHardwareCursor(true);
  }

  override render(width: number): string[] {
    process.stdout.write(BLINKING_BLOCK_CURSOR);

    // The stock editor draws its own solid block cursor with reverse video.
    // Leave the zero-width hardware cursor marker in place, but remove the
    // reverse-video styling so the terminal's real blinking cursor is visible.
    return super.render(width).map((line) =>
      line.replace(/\x1b\[7m([\s\S]*?)\x1b\[0m/g, "$1"),
    );
  }

  dispose(): void {
    process.stdout.write(DEFAULT_CURSOR);
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;
    process.stdout.write(BLINKING_BLOCK_CURSOR);
    ctx.ui.setEditorComponent((tui, theme, keybindings) =>
      new BlinkingCursorEditor(tui, theme, keybindings),
    );
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    if (!ctx.hasUI) return;
    ctx.ui.setEditorComponent(undefined);
    process.stdout.write(DEFAULT_CURSOR);
  });
}
