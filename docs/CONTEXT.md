# Omarchy Music Player Plugin Architecture & Context

## 1. System Environment & Platform
- **OS**: Omarchy Linux (`7.2.5-3-omarchy #1 SMP PREEMPT_DYNAMIC x86_64`)
- **Desktop / Shell**: Hyprland + Omarchy Shell (`quickshell`)
- **Plugin Infrastructure**:
  - User plugins live in `~/.config/omarchy/plugins/<plugin-id>/`
  - Manifest schema: `manifest.json` with `schemaVersion: 1`, `kinds: ["bar-widget"]` or `["bar-widget", "panel"]`
  - Hot reloading: saving any file inside `~/.config/omarchy/plugins/` auto-reloads the plugin
  - Bar widgets: Quickshell QML (`BarWidget.qml`, `BarIconButton`, `KeyboardPanel`, `qs.Ui.TextField`)
  - Integration: MPRIS native bridge (`omarchy.media` built into Omarchy shell)
  - Installed tools: `cliamp 2.0.1` (installed & working), `mpv` (installed), `yt-dlp` (installed)

## 2. Requirements & Goals
1. **Top Bar Icon**: An elegant icon on the Omarchy status bar that displays status / now playing tooltip and controls.
2. **Interactive Dropdown / Widget**: Clicking the bar icon opens a lightweight, keyboard-accessible popup widget (`KeyboardPanel` / `Panel`).
3. **Search & Play Capabilities**:
   - Integrated search bar with instant query execution.
   - Search results list with track selection, playback, and queue actions.
   - Direct support for online streams (Internet Radio, YouTube/YouTube Music, Bandcamp, Podcasts, Lofi).
4. **Daemon & Resource Efficiency**:
   - Ultra-low memory and CPU usage even when running as a daemon.
   - Non-blocking asynchronous IPC architecture.
   - Instant response without locking the shell UI.
