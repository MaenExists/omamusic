# OmaMusic 󰎆

A minimalist, lightweight YouTube & online music player plugin for **Omarchy OS**.

OmaMusic docks into the Omarchy top bar, providing an instant-access dropdown widget for searching, playing, and queueing YouTube audio with minimal CPU/RAM footprint.

---

## ✨ Features

- **Top Bar Integration**: Displays current playback status, animated icons (`󰎆`/`󰝚`), and rich now-playing tooltips.
- **Instant Search Dropdown**: Click the bar icon (or trigger via hotkey/IPC) to open a keyboard-navigable search interface for YouTube Music and online audio streams.
- **Rich Controls**: Play/pause, track navigation, interactive volume slider, and one-click queueing.
- **Ultra Low Resource Footprint**: Uses `cliamp` running in headless low-power daemon mode (`--daemon --low-power`) paired with `yt-dlp` stream extraction.
- **Native Look & Feel**: Built directly with Omarchy's Quickshell theme tokens and design system (`qs.Commons`, `qs.Ui`, `KeyboardPanel`).

---

## 🛠️ Requirements

- **Omarchy OS** (Hyprland + Quickshell)
- `cliamp` (shipped with Omarchy)
- `yt-dlp` (for YouTube search & audio stream resolution)
- `jq`

---

## 🚀 Installation

### Option 1: Automatic Install / Symlink

```bash
git clone https://github.com/MaenExists/omamusic.git ~/Builds/OmaMusic
mkdir -p ~/.config/omarchy/plugins
ln -s ~/Builds/OmaMusic ~/.config/omarchy/plugins/maen.omamusic
```

### Option 2: Add to Omarchy Bar

Edit `~/.config/omarchy/shell.json` to include `maen.omamusic` in your status bar:

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

Omarchy will hot-reload automatically without requiring a shell restart!

---

## 🎮 Usage

- **Click Icon**: Toggle the OmaMusic dropdown panel.
- **Right-Click Icon**: Quickly toggle Play / Pause.
- **Search**: Enter song name or artist in the search box, press `Enter`.
- **Keyboard Navigation**: Use `Up`/`Down` arrows to navigate search results, `Enter` to play, or click `󰐍` to queue next.

---

## 📄 License

MIT © [MaenExists](https://github.com/MaenExists)
