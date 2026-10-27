import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Item {
    id: page

    implicitWidth: 400
    implicitHeight: layout.implicitHeight

    property alias cfg_apiKey: apiKeyField.text
    property alias cfg_refreshInterval: refreshField.value
    property alias cfg_dailyGoalHours: goalField.text

    Kirigami.FormLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right

        QQC2.TextField {
            id: apiKeyField
            Kirigami.FormData.label: i18n("Hackatime API key:")
            echoMode: QQC2.TextInput.Password
        }

        QQC2.SpinBox {
            id: refreshField
            Kirigami.FormData.label: i18n("Refresh interval:")
            from: 1
            to: 60
        }

        QQC2.TextField {
            id: goalField
            Kirigami.FormData.label: i18n("Daily goal (hours):")
            text: "6"
            validator: DoubleValidator { bottom: 0.5; top: 24 }
        }
    }
}