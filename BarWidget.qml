import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "maen.omamusic"
  ipcTarget: "maen.omamusic"
  manageIpc: false

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color dim: Qt.darker(foreground, 1.5)
  readonly property color muted: Qt.darker(foreground, 1.8)
  readonly property color accent: Color.accent
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property string backendPath: Qt.resolvedUrl("oma-player").toString().replace(/^file:\/\//, "")
  readonly property string statusPath: Quickshell.env("XDG_STATE_HOME", Quickshell.env("HOME") + "/.local/state") + "/omamusic/status.json"

  // Player State
  property bool isPlaying: false
  property bool isPaused: false
  property string currentTitle: ""
  property string currentArtist: ""
  property string currentDuration: ""
  property int currentPositionSec: 0
  property int totalDurationSec: 0
  property int volume: 100

  // Search State
  property var searchResults: []
  property bool isSearching: false
  property string lastQuery: ""
  property int selectedIndex: 0

  function refreshStatus() {
    if (statusProc.running) return
    statusProc.running = true
  }

  function togglePlayPause() {
    execAction("toggle")
  }

  function nextTrack() {
    execAction("next")
  }

  function prevTrack() {
    execAction("prev")
  }

  function playTrack(item) {
    if (!item || !item.url) return
    currentTitle = item.title || "Loading..."
    currentArtist = item.artist || ""
    isPlaying = true
    isPaused = false
    execActionWithArg("play-url", item.url)
  }

  function queueTrack(item) {
    if (!item || !item.url) return
    execActionWithArg("queue-url", item.url)
  }

  function setVolume(pct) {
    volume = Math.max(0, Math.min(100, Math.round(pct)))
    execActionWithArg("volume", String(volume))
  }

  function startSearch(query) {
    var trimmed = (query || "").trim()
    if (!trimmed || trimmed === lastQuery) return
    lastQuery = trimmed
    isSearching = true
    selectedIndex = 0
    searchProc.query = trimmed
    searchProc.running = true
  }

  function execAction(action) {
    actionProc.command = [root.backendPath, action]
    actionProc.running = true
  }

  function execActionWithArg(action, arg) {
    actionProc.command = [root.backendPath, action, arg]
    actionProc.running = true
  }

  function parseStatus(raw) {
    try {
      if (!raw || typeof raw !== "string") return
      var data = JSON.parse(raw)
      root.isPlaying = data.state === "playing"
      root.isPaused = data.state === "paused"

      if (data.track) {
        root.currentTitle = data.track.title || ""
        root.currentArtist = data.track.artist || ""
        root.totalDurationSec = data.track.duration_secs || data.duration || 0
      } else {
        root.currentTitle = ""
        root.currentArtist = ""
        root.totalDurationSec = 0
      }

      if (data.position !== undefined) {
        root.currentPositionSec = Math.round(data.position)
      }
    } catch (e) {
      // Ignored
    }
  }

  function formatTime(secs) {
    if (!secs || secs < 0) return "0:00"
    var m = Math.floor(secs / 60)
    var s = Math.floor(secs % 60)
    return m + ":" + (s < 10 ? "0" : "") + s
  }

  visible: true
  implicitWidth: barButton.implicitWidth
  implicitHeight: barButton.implicitHeight

  // Periodic polling for playback position & state while open or playing
  Timer {
    interval: root.opened ? 1500 : (root.isPlaying ? 3000 : 8000)
    running: true
    repeat: true
    onTriggered: root.refreshStatus()
  }

  // File watcher for status file written by oma-player
  FileView {
    path: root.statusPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.parseStatus(text())
    onFileChanged: reload()
  }

  Process {
    id: statusProc
    command: [root.backendPath, "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onTextChanged: if (text) root.parseStatus(text)
    }
  }

  Process {
    id: actionProc
    command: []
    onExited: root.refreshStatus()
  }

  Process {
    id: searchProc
    property string query: ""
    command: [root.backendPath, "search", query, "8"]
    stdout: StdioCollector {
      id: searchOut
      waitForEnd: true
    }
    onExited: function(exitCode) {
      root.isSearching = false
      if (exitCode === 0 && searchOut.text) {
        try {
          var parsed = JSON.parse(searchOut.text)
          root.searchResults = parsed.results || []
        } catch (e) {
          root.searchResults = []
        }
      }
    }
  }

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function toggle(): void { root.toggle() }
    function play(): void { root.togglePlayPause() }
    function next(): void { root.nextTrack() }
    function prev(): void { root.prevTrack() }
  }

  // Status Bar Icon
  BarIconButton {
    id: barButton
    anchors.fill: parent
    bar: root.bar
    text: root.isPlaying ? "󰎆" : "󰝚"
    tooltipText: root.isPlaying
      ? (root.currentTitle ? "Playing: " + root.currentTitle + (root.currentArtist ? " - " + root.currentArtist : "") : "Playing music")
      : (root.isPaused ? "Paused: " + root.currentTitle : "OmaMusic - YouTube Player")

    onPressed: function(mouse) {
      if (mouse === Qt.RightButton) {
        root.togglePlayPause()
      } else {
        root.toggle()
      }
    }
  }

  // Interactive Dropdown Panel
  KeyboardPanel {
    id: panel
    anchorItem: barButton
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: searchField
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(mainColumn.implicitHeight, Style.space(520))

    Column {
      id: mainColumn
      width: parent.width
      spacing: Style.space(10)
      topPadding: Style.space(12)
      bottomPadding: Style.space(14)
      leftPadding: Style.space(14)
      rightPadding: Style.space(14)

      // Header row with Title and close action
      Row {
        width: parent.width - Style.space(28)
        spacing: Style.space(8)

        Text {
          text: "󰎆 OmaMusic"
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.title
          font.bold: true
          anchors.verticalCenter: parent.verticalCenter
        }

        Item {
          width: parent.width - x - closeBtn.width
          height: 1
        }

        PanelActionButton {
          id: closeBtn
          iconText: "󰅖"
          tooltipText: "Close"
          anchors.verticalCenter: parent.verticalCenter
          onClicked: root.close()
        }
      }

      // Search Bar
      Row {
        width: parent.width - Style.space(28)
        spacing: Style.space(8)

        TextField {
          id: searchField
          width: parent.width - searchActionBtn.width - Style.space(8)
          placeholderText: "Search YouTube Music..."
          font.family: root.fontFamily
          font.pixelSize: Style.font.body

          onAccepted: {
            root.startSearch(text)
          }

          Keys.onDownPressed: {
            if (resultsList.count > 0) {
              resultsList.forceActiveFocus()
              resultsList.currentIndex = 0
            }
          }
          Keys.onEscapePressed: root.close()
        }

        PanelActionButton {
          id: searchActionBtn
          iconText: root.isSearching ? "󰑮" : "󰍉"
          tooltipText: "Search"
          anchors.verticalCenter: parent.verticalCenter
          onClicked: root.startSearch(searchField.text)
        }
      }

      // Now Playing Hero Card
      Rectangle {
        width: parent.width - Style.space(28)
        height: root.currentTitle ? Style.space(104) : Style.space(56)
        radius: Style.cornerRadius
        color: Style.selectedFillFor(root.foreground, root.accent)
        clip: true

        Column {
          anchors.fill: parent
          anchors.margins: Style.space(10)
          spacing: Style.space(4)

          // Track title & artist
          Text {
            width: parent.width
            text: root.currentTitle ? root.currentTitle : "No song playing"
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            font.bold: true
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: root.currentArtist ? root.currentArtist : "Search songs or artists above"
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            elide: Text.ElideRight
          }

          // Progress text (if duration known)
          Text {
            visible: root.totalDurationSec > 0
            text: root.formatTime(root.currentPositionSec) + " / " + root.formatTime(root.totalDurationSec)
            color: root.muted
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }

          // Playback Controls Row
          Row {
            visible: root.currentTitle !== ""
            spacing: Style.space(12)
            anchors.horizontalCenter: parent.horizontalCenter

            PanelActionButton {
              iconText: "󰒮"
              tooltipText: "Previous"
              onClicked: root.prevTrack()
            }

            PanelActionButton {
              iconText: root.isPlaying ? "󰏤" : "󰐊"
              tooltipText: root.isPlaying ? "Pause" : "Play"
              onClicked: root.togglePlayPause()
            }

            PanelActionButton {
              iconText: "󰒭"
              tooltipText: "Next"
              onClicked: root.nextTrack()
            }
          }
        }
      }

      // Volume Row
      Row {
        width: parent.width - Style.space(28)
        spacing: Style.space(8)

        Text {
          text: root.volume === 0 ? "󰝟" : (root.volume < 50 ? "󰕿" : "󰕾")
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          anchors.verticalCenter: parent.verticalCenter
        }

        PanelSlider {
          id: volSlider
          bar: root.bar
          minimum: 0
          maximum: 100
          value: root.volume
          width: parent.width - Style.space(70)
          anchors.verticalCenter: parent.verticalCenter
          onMoved: function(val) { root.setVolume(val) }
        }

        Text {
          text: root.volume + "%"
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      PanelSeparator {
        width: parent.width - Style.space(28)
      }

      // Search Results Section
      PanelSectionHeader {
        width: parent.width - Style.space(28)
        text: root.isSearching ? "SEARCHING YOUTUBE..." : (root.searchResults.length > 0 ? "SEARCH RESULTS" : "FEATURED & SEARCH")
      }

      ListView {
        id: resultsList
        width: parent.width - Style.space(28)
        height: Math.min(Style.space(220), count * Style.space(48))
        clip: true
        model: root.searchResults

        Keys.onUpPressed: {
          if (currentIndex === 0) searchField.forceActiveFocus()
          else currentIndex--
        }
        Keys.onDownPressed: {
          if (currentIndex < count - 1) currentIndex++
        }
        Keys.onReturnPressed: {
          var item = model[currentIndex]
          if (item) root.playTrack(item)
        }
        Keys.onEscapePressed: root.close()

        delegate: Rectangle {
          width: resultsList.width
          height: Style.space(44)
          radius: Style.cornerRadius
          color: resultsList.currentIndex === index
            ? Style.selectedFillFor(root.foreground, root.accent)
            : (mouseArea.containsMouse ? Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.08) : "transparent")

          MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              resultsList.currentIndex = index
              root.playTrack(modelData)
            }
          }

          Row {
            anchors.fill: parent
            anchors.leftMargin: Style.space(8)
            anchors.rightMargin: Style.space(8)
            spacing: Style.space(8)

            Text {
              text: "󰐊"
              color: resultsList.currentIndex === index ? root.foreground : root.muted
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              anchors.verticalCenter: parent.verticalCenter
            }

            Column {
              width: parent.width - playQueueBtn.width - timeText.width - Style.space(36)
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(2)

              Text {
                width: parent.width
                text: modelData.title || ""
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                elide: Text.ElideRight
              }

              Text {
                width: parent.width
                text: modelData.artist || ""
                color: root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                elide: Text.ElideRight
              }
            }

            Text {
              id: timeText
              text: modelData.duration || ""
              color: root.muted
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              anchors.verticalCenter: parent.verticalCenter
            }

            PanelActionButton {
              id: playQueueBtn
              iconText: "󰐍"
              tooltipText: "Add to Queue"
              size: Style.space(26)
              anchors.verticalCenter: parent.verticalCenter
              onClicked: root.queueTrack(modelData)
            }
          }
        }
      }

      // Empty State Prompt
      Text {
        visible: !root.isSearching && root.searchResults.length === 0
        text: "Type a track, artist, or album name above\nand press Enter to search & stream directly."
        color: root.muted
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        horizontalAlignment: Text.AlignHCenter
        width: parent.width - Style.space(28)
      }
    }
  }

  Component.onCompleted: {
    root.refreshStatus()
  }
}
