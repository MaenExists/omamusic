# OmaMusic 󱑽

A minimalist, lightweight YouTube & online music player plugin for **Omarchy OS**.

OmaMusic docks seamlessly into your Omarchy status bar with a unique animated icon, compact running track title positioned before the glyph, instant search, queue inspection, favorite tracks, sound effects, and session restart controls.

---

## ✨ Features

- **Unique Bar Widget with Leading Track Title**:
  - Compact running title shown directly **before** the music glyph on the bar.
  - Custom stylized glyph (`󱑽` / `󱑼`) with active glowing indicator dot and spinner when loading/busy.
  - Hover tooltip displaying full now-playing title and artist.
- **Interactive Control Tabs**:
  - **󰍉 Search**: Direct YouTube search with instant stream loading.
  - **󰒮 Queue**: Look up your current playlist queue, active track indicator, and one-click queue clearing.
  - **󰋑 Favorites**: Save favorite tracks with one click and play them back anytime.
- **Session & Daemon Management**:
  - **Restart Session Button (`󰑐`)**: Cleanly restarts the background audio daemon and resets YouTube bot/rate limits without losing your bar icon or widget placement.
  - Clears default placeholder tracks automatically on launch.
- **Audio Feedback**: Subtle desktop sound effects for play, pause, queueing, favoriting, and session restarts.
- **Minimal Keyboard Shortcuts Hint Bar**: Clean, non-intrusive shortcut hints pinned to the bottom of the widget (`↵ Play`, `↑/↓ Navigate`, `Esc Close`).
- **Ultra Low Resource Footprint**: Built on `cliamp --daemon --low-power` with `yt-dlp` stream extraction (<20MB RAM, ~0% idle CPU).

---

## 🛠️ Requirements

- **Omarchy OS** (Hyprland + Quickshell)
- `cliamp` (pre-installed on Omarchy)
- `yt-dlp` (for YouTube search & audio stream resolution)
- `jq`
- `canberra-gtk-play` (for feedback sound effects)

---

## 🚀 Installation

### Option 1: Symlink from source (Active development)

```bash
git clone https://github.com/MaenExists/omamusic.git ~/Builds/OmaMusic
mkdir -p ~/.config/omarchy/plugins
ln -sfn ~/Builds/OmaMusic ~/.config/omarchy/plugins/maen.omamusic
```

### Option 2: Add to Omarchy Bar

Ensure `maen.omamusic` is in your `~/.config/omarchy/shell.json`:

```json
{
  "bar": {
    "layout": {
      "right": [
        { "id": "maen.omamusic" },
        { "id": "omarchy.tray" }
      ]
    }
  }
}
```

Omarchy shell hot-reloads on save automatically!

---

## 🎮 Usage & Controls

- **Left-Click Bar Icon**: Toggle the OmaMusic interactive popup.
- **Right-Click Bar Icon**: Instantly toggle Play / Pause without opening the widget.
- **Search Tab**: Type any song or artist, press `Enter` to search, and click or press `Enter` on a result to play.
- **Queue Tab**: View currently loaded playlist tracks and clear the queue with `󰅖`.
- **Favorites Tab**: Click `󰋔` on any song to bookmark it into Favorites.
- **Restart Session**: Click `󰑐` in the top right of the popup to refresh the background daemon.

---

## 📄 License

MIT © [MaenExists](https://github.com/MaenExists)
