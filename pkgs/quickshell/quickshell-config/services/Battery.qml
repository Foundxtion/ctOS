pragma Singleton
import Quickshell
import Quickshell.Services.UPower

// Thin wrapper around UPower's aggregate display device.
Singleton {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property bool ready: device !== null && device.ready
    readonly property bool isLaptop: ready && device.isLaptopBattery

    // UPower's percentage here comes through as a 0.0-1.0 fraction, not
    // 0-100 — confirmed by it displaying "1%" for what should've been a
    // much higher charge. Scale it up.
    readonly property real percent: ready ? device.percentage * 100 : 0
    readonly property int percentInt: Math.round(percent)

    readonly property bool charging: ready && device.state === UPowerDeviceState.Charging
    readonly property bool fullyCharged: ready && device.state === UPowerDeviceState.FullyCharged
    readonly property bool discharging: ready && device.state === UPowerDeviceState.Discharging
    readonly property bool isLow: ready && !charging && percentInt <= 20

    // Seconds; 0 when not applicable.
    readonly property int timeToEmpty: ready ? device.timeToEmpty : 0
    readonly property int timeToFull: ready ? device.timeToFull : 0

    // Human readable "2h 14m left" / "1h 05m until full", or "" if unknown.
    readonly property string timeRemainingLabel: {
        if (!ready)
            return "";
        if (charging && timeToFull > 0)
            return formatDuration(timeToFull) + " until full";
        if (discharging && timeToEmpty > 0)
            return formatDuration(timeToEmpty) + " remaining";
        if (fullyCharged)
            return "Fully charged";
        return "";
    }

    function formatDuration(seconds: int): string {
        const totalMinutes = Math.round(seconds / 60);
        const h = Math.floor(totalMinutes / 60);
        const m = totalMinutes % 60;
        if (h <= 0)
            return m + "m";
        return h + "h " + String(m).padStart(2, "0") + "m";
    }
}
