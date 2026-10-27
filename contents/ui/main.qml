import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    
    property string apiKey: Plasmoid.configuration.apiKey || ""
    property string todayText: i18n("—")
    property bool loading: false
    property int refreshInterval: (Plasmoid.configuration.refreshInterval || 5) * 60000

    property real totalSeconds: 0
    property real dailyGoalHours: 6
    
    fullRepresentation: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing
        Layout.preferredWidth: Kirigami.Units.gridUnit * 20
        Layout.preferredHeight: Kirigami.Units.gridUnit * 16
        
        Kirigami.Heading {
            text: i18n("Hackatime")
            level: 2
            Layout.alignment: Qt.AlignHCenter
        }
        
        QQC2.Label {
            visible: apiKey.length === 0
            text: i18n("Set your API key in applet settings")
            color: Kirigami.Theme.negativeTextColor
            Layout.alignment: Qt.AlignHCenter
        }

        Item {
            Layout.preferredWidth: 180
            Layout.preferredHeight: 180
            Layout.alignment: Qt.AlignHCenter

            Canvas {
                id: graph
                anchors.fill: parent

                property color dayRingColor: Kirigami.Theme.textColor
                property color ringColor: Kirigami.Theme.highlightColor
                property color trackColor: Kirigami.Theme.disabledTextColor

                onPaint: {
                    var ctx = getContext("2d")
                    var cx = width / 2
                    var cy = height / 2
                    var outerRadius = Math.min(width, height) * 0.40
                    var innerRadius = Math.min(width, height) * 0.38

                    var dayProgress = Math.max(0, Math.min(1,
                        root.totalSeconds / 86400))
                    var goalProgress = root.dailyGoalHours > 0
                        ? Math.max(0, Math.min(1,
                            root.totalSeconds /
                            (root.dailyGoalHours * 3600)))
                        : 0

                    ctx.clearRect(0, 0, width, height)

                    function drawRing(radius, progress, color, thickness) {
                        ctx.beginPath()
                        ctx.arc(cx, cy, radius, 0, 2 * Math.PI)
                        ctx.lineWidth = thickness
                        ctx.strokeStyle = trackColor
                        ctx.globalAlpha = 0.22
                        ctx.stroke()
                        ctx.globalAlpha = 1.0

                        if (progress > 0) {
                            ctx.beginPath()
                            ctx.arc(
                                cx, cy, radius,
                                -Math.PI / 2,
                                -Math.PI / 2 + progress * 2 * Math.PI
                            )
                            ctx.lineWidth = thickness
                            ctx.lineCap = "round"
                            ctx.strokeStyle = color
                            ctx.stroke()
                        }
                    }
                    drawRing(outerRadius, dayProgress, dayRingColor, 10)
                    drawRing(innerRadius, goalProgress, ringColor, 10)
                }
                Connections {
                target: root
                function onTotalSecondsChanged() {
                    graph.requestPaint()
                }
                function onDailyGoalHoursChanged() {
                    graph.requestPaint()
                }
            }
            onRingColorChanged: requestPaint()
            onTrackColorChanged: requestPaint()
            }
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2

                QQC2.Label {
                    text: root.formatSeconds(root.totalSeconds)
                    font.pixelSize: 22
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                QQC2.Label {
                    text: {
                        var goal = Number(root.dailyGoalHours)
                        var seconds = Number(root.totalSeconds)

                        if (!isFinite(goal) || goal <= 0 ||
                            !isFinite(seconds)) {
                            return "0% of goal"
                        }
                        return Math.floor(
                            seconds / (goal * 3600) * 100
                        ) + "% of goal"
                    }
                    font.pixelSize: 11
                    opacity: 0.75
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
        QQC2.Label {
            text: i18n("%1h daily goal").arg(root.dailyGoalHours)
            Layout.alignment: Qt.AlignHCenter
        }

        QQC2.BusyIndicator {
            running: root.loading
            visible: root.loading
            Layout.alignment: Qt.AlignHCenter
        }
    }
    
    Timer {
        interval: root.refreshInterval
        running: true
        repeat: true
        onTriggered: fetchData()
    }
    
    Component.onCompleted: fetchData()
    
    function fetchData() {
        if (!apiKey) {
            todayText = i18n("No Hackatime API key?")
            return
        }
        loading = true
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                loading = false
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response.data && response.data.grand_total) {
                            totalSeconds = response.data.grand_total.total_seconds || 0
                            todayText = response.data.grand_total.text || formatSeconds(totalSeconds)
                        } else {
                            totalSeconds = 0
                            todayText = i18n("Error...")
                        }
                    } catch (e) {
                        console.log("Parse error:", e)
                        todayText = i18n("Error...")
                    }
                } else if (xhr.status === 401) {
                    todayText = i18n("Unauthorized...")
                } else {
                    console.log("HTTP error:", xhr.status)
                    todayText = i18n("Error...")
                }
            }
        }
        xhr.open("GET", "https://hackatime.hackclub.com/api/hackatime/v1/users/current/statusbar/today")
        xhr.setRequestHeader("Authorization", "Bearer " + apiKey)
        xhr.send()
    }
    
    function formatSeconds(seconds) {
        var s = Math.floor(seconds || 0)
        var h = Math.floor(s / 3600)
        var m = Math.floor((s % 3600) / 60)
        if (h > 0) return h + "h " + m + "m"
        if (m > 0) return m + "m"
        return s + "s"
    }
}import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    
    property string apiKey: Plasmoid.configuration.apiKey || "8a192d9d-0fbe-4233-b08e-d75f8700a638"
    property string todayText: i18n("—")
    property bool loading: false
    property int refreshInterval: (Plasmoid.configuration.refreshInterval || 5) * 60000

    property real totalSeconds: 0
    property real dailyGoalHours: 6
    
    fullRepresentation: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing
        Layout.preferredWidth: Kirigami.Units.gridUnit * 20
        Layout.preferredHeight: Kirigami.Units.gridUnit * 16
        
        Kirigami.Heading {
            text: i18n("Hackatime")
            level: 2
            Layout.alignment: Qt.AlignHCenter
        }
        
        QQC2.Label {
            visible: apiKey.length === 0
            text: i18n("Set your API key in applet settings")
            color: Kirigami.Theme.negativeTextColor
            Layout.alignment: Qt.AlignHCenter
        }

        Item {
            Layout.preferredWidth: 180
            Layout.preferredHeight: 180
            Layout.alignment: Qt.AlignHCenter

            Canvas {
                id: graph
                anchors.fill: parent

                property color dayRingColor: Kirigami.Theme.textColor
                property color ringColor: Kirigami.Theme.highlightColor
                property color trackColor: Kirigami.Theme.disabledTextColor

                onPaint: {
                    var ctx = getContext("2d")
                    var cx = width / 2
                    var cy = height / 2
                    var outerRadius = Math.min(width, height) * 0.40
                    var innerRadius = Math.min(width, height) * 0.38

                    var dayProgress = Math.max(0, Math.min(1,
                        root.totalSeconds / 86400))
                    var goalProgress = root.dailyGoalHours > 0
                        ? Math.max(0, Math.min(1,
                            root.totalSeconds /
                            (root.dailyGoalHours * 3600)))
                        : 0

                    ctx.clearRect(0, 0, width, height)

                    function drawRing(radius, progress, color, thickness) {
                        ctx.beginPath()
                        ctx.arc(cx, cy, radius, 0, 2 * Math.PI)
                        ctx.lineWidth = thickness
                        ctx.strokeStyle = trackColor
                        ctx.globalAlpha = 0.22
                        ctx.stroke()
                        ctx.globalAlpha = 1.0

                        if (progress > 0) {
                            ctx.beginPath()
                            ctx.arc(
                                cx, cy, radius,
                                -Math.PI / 2,
                                -Math.PI / 2 + progress * 2 * Math.PI
                            )
                            ctx.lineWidth = thickness
                            ctx.lineCap = "round"
                            ctx.strokeStyle = color
                            ctx.stroke()
                        }
                    }
                    drawRing(outerRadius, dayProgress, dayRingColor, 10)
                    drawRing(innerRadius, goalProgress, ringColor, 10)
                }
                Connections {
                target: root
                function onTotalSecondsChanged() {
                    graph.requestPaint()
                }
                function onDailyGoalHoursChanged() {
                    graph.requestPaint()
                }
            }
            onRingColorChanged: requestPaint()
            onTrackColorChanged: requestPaint()
            }
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2

                QQC2.Label {
                    text: root.formatSeconds(root.totalSeconds)
                    font.pixelSize: 22
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                QQC2.Label {
                    text: {
                        var goal = Number(root.dailyGoalHours)
                        var seconds = Number(root.totalSeconds)

                        if (!isFinite(goal) || goal <= 0 ||
                            !isFinite(seconds)) {
                            return "0% of goal"
                        }
                        return Math.floor(
                            seconds / (goal * 3600) * 100
                        ) + "% of goal"
                    }
                    font.pixelSize: 11
                    opacity: 0.75
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
        QQC2.Label {
            text: i18n("%1h daily goal").arg(root.dailyGoalHours)
            Layout.alignment: Qt.AlignHCenter
        }

        QQC2.BusyIndicator {
            running: root.loading
            visible: root.loading
            Layout.alignment: Qt.AlignHCenter
        }
    }
    
    Timer {
        interval: root.refreshInterval
        running: true
        repeat: true
        onTriggered: fetchData()
    }
    
    Component.onCompleted: fetchData()
    
    function fetchData() {
        if (!apiKey) {
            todayText = i18n("No Hackatime API key?")
            return
        }
        loading = true
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                loading = false
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response.data && response.data.grand_total) {
                            totalSeconds = response.data.grand_total.total_seconds || 0
                            todayText = response.data.grand_total.text || formatSeconds(totalSeconds)
                        } else {
                            totalSeconds = 0
                            todayText = i18n("Error...")
                        }
                    } catch (e) {
                        console.log("Parse error:", e)
                        todayText = i18n("Error...")
                    }
                } else if (xhr.status === 401) {
                    todayText = i18n("Unauthorized...")
                } else {
                    console.log("HTTP error:", xhr.status)
                    todayText = i18n("Error...")
                }
            }
        }
        xhr.open("GET", "https://hackatime.hackclub.com/api/hackatime/v1/users/current/statusbar/today")
        xhr.setRequestHeader("Authorization", "Bearer " + apiKey)
        xhr.send()
    }
    
    function formatSeconds(seconds) {
        var s = Math.floor(seconds || 0)
        var h = Math.floor(s / 3600)
        var m = Math.floor((s % 3600) / 60)
        if (h > 0) return h + "h " + m + "m"
        if (m > 0) return m + "m"
        return s + "s"
    }
}