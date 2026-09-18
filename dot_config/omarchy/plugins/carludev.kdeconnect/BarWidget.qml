import QtQuick
import Quickshell
import qs.Ui

BarWidget {
  id: root
  moduleName: "carludev.kdeconnect"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰄡"
    tooltipText: "KDE Connect (Super+Shift+K)"
    onPressed: function(b) {
      root.bar.run("bash /home/carludev/.local/bin/toggle-kdeconnect")
    }
  }
}
