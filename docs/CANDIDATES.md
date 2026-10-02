# Online CLI Music Player Candidates Evaluation

Comparison of potential CLI/daemon music engines for the Omarchy status bar music plugin:

| Candidate | Tech Stack | Online / Streaming Support | IPC / Daemon Mode | Resource Usage (RAM/CPU) | Pros & Cons | Verdict |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **cliamp** | Go + Bubbletea | Radio (Radio Browser catalog), YouTube/YTMusic, SoundCloud, Spotify, Jellyfin/Plex/Navidrome | **First-class V2 Unix socket IPC** (`cliamp -d --low-power`, `remote call`, `status --json`) | **Very low** (~15–25MB RAM, ~0% idle CPU) | **Pros**: Already installed on Omarchy system; purpose-built headless daemon mode (`-d`); rich JSON-RPC V2 API with search, queue, play, status; MPRIS integration; written in clean Go.<br>**Cons**: Large binary if building from scratch (~37MB), but it's already a native Omarchy package. | **Top Recommendation (Best Fit)** |
| **mpv + yt-dlp + custom daemon** | C + Python / Bash or Go wrapper | YouTube, Soundcloud, Bandcamp, Radio, direct audio URLs | IPC via Unix socket (`--input-ipc-server`) | **Low** (~20-30MB RAM) | **Pros**: Universal format support, already installed.<br>**Cons**: No built-in search or catalog indexing; requires building custom search and playlist state engines from scratch. | **Viable alternative backend** |
| **termusic** | Rust | YouTube, NetEase, Podcasts, Local | Limited remote CLI / socket IPC | **Very low** (~15MB RAM) | **Pros**: Fast Rust TUI.<br>**Cons**: IPC API is not as comprehensive for headless GUI widget control as cliamp. | **Secondary** |
| **ncspot** | Rust | Spotify Premium only | D-Bus / MPRIS | **Low** (~20MB RAM) | **Pros**: Great Spotify client.<br>**Cons**: Strictly Spotify Premium only; no open radio or generic online search without account. | **Too limited** |
| **cmus** | C | Local files, basic streams | `cmus-remote` | **Minimal** (<10MB RAM) | **Pros**: Battle-tested, ultra lightweight.<br>**Cons**: No native search for online streams/YouTube; local-focused. | **Too limited** |

## Recommendation
**Fork / Extend `cliamp` architecture**:
1. It already ships on Omarchy with a native headless daemon mode (`cliamp --daemon --low-power`).
2. Provides a full JSON-RPC V2 API (`provider.search`, `track.play`, `runtime.queue`, `runtime.status`).
3. Supports live online search across internet radio, YouTube, Soundcloud, and streaming providers out of the box.
4. Omarchy's existing QML Shell plugin architecture can communicate directly via a dedicated helper daemon script or Quickshell Process/Socket calls.
