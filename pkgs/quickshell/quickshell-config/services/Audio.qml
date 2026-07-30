pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire

// Thin, reactive wrapper around Quickshell's Pipewire service.
//
// Covers both directions: the default sink and source, their volume and
// mute state, and the lists of real devices you could switch either to.
// The Sound panel needs all of it to offer macOS's Output/Input pickers.
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    // ── Output ──────────────────────────────────────────────────────
    readonly property bool ready: sink !== null && sink.ready && sink.audio !== null
    readonly property real volume: ready ? sink.audio.volume : 0
    readonly property bool muted: ready ? sink.audio.muted : false

    // 0-100 integer, easier to bind to in QML than the raw 0.0-1.0 float.
    readonly property int volumePercent: Math.round(volume * 100)

    // ── Input ───────────────────────────────────────────────────────
    readonly property bool inputReady: source !== null && source.ready && source.audio !== null
    readonly property real inputVolume: inputReady ? source.audio.volume : 0
    readonly property bool inputMuted: inputReady ? source.audio.muted : false
    readonly property int inputVolumePercent: Math.round(inputVolume * 100)

    // ── Device lists ────────────────────────────────────────────────
    // Streams are individual apps playing or recording audio, not devices,
    // so they're filtered out — you don't want Firefox listed as somewhere
    // to send your system audio.
    readonly property var outputDevices: {
        const out = [];
        for (const node of Pipewire.nodes.values) {
            if (node.audio !== null && node.isSink && !node.isStream)
                out.push(node);
        }
        return out;
    }

    // Monitor nodes mirror a sink's output back as a capture source. They
    // are legitimate PipeWire sources, but offering one as "your
    // microphone" is never what anyone means, so they're dropped here.
    readonly property var inputDevices: {
        const out = [];
        for (const node of Pipewire.nodes.values) {
            if (node.audio === null || node.isSink || node.isStream)
                continue;
            if (node.name && node.name.toLowerCase().indexOf(".monitor") !== -1)
                continue;
            out.push(node);
        }
        return out;
    }

    // What to call a device in the picker. PipeWire's `description` is the
    // human-facing string ("Built-in Audio Analog Stereo"); `name` is the
    // machine one, and only worth falling back to.
    function deviceLabel(node: PwNode): string {
        if (node === null)
            return "";
        if (node.description && node.description.length > 0)
            return node.description;
        if (node.nickname && node.nickname.length > 0)
            return node.nickname;
        return node.name ?? "";
    }

    // ── Output actions ──────────────────────────────────────────────
    function setVolume(v: real): void {
        if (!ready)
            return;
        const clamped = Math.max(0, Math.min(1, v));
        sink.audio.muted = false;
        sink.audio.volume = clamped;
    }

    function setVolumePercent(p: int): void {
        setVolume(p / 100);
    }

    function toggleMute(): void {
        if (ready)
            sink.audio.muted = !sink.audio.muted;
    }

    function nudge(deltaPercent: int): void {
        setVolumePercent(volumePercent + deltaPercent);
    }

    function setDefaultOutput(node: PwNode): void {
        Pipewire.preferredDefaultAudioSink = node;
    }

    // ── Input actions ───────────────────────────────────────────────
    function setInputVolume(v: real): void {
        if (!inputReady)
            return;
        const clamped = Math.max(0, Math.min(1, v));
        source.audio.muted = false;
        source.audio.volume = clamped;
    }

    function setInputVolumePercent(p: int): void {
        setInputVolume(p / 100);
    }

    function toggleInputMute(): void {
        if (inputReady)
            source.audio.muted = !source.audio.muted;
    }

    function setDefaultInput(node: PwNode): void {
        Pipewire.preferredDefaultAudioSource = node;
    }

    // Binding every node keeps their properties (volume, muted, ready...)
    // live-updating instead of frozen at first read. Both device lists have
    // to be in here, not just the defaults, or the pickers would show stale
    // names and never notice a headset appearing.
    PwObjectTracker {
        objects: [root.sink, root.source, ...root.outputDevices, ...root.inputDevices]
    }
}
