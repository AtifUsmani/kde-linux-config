import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.private.batterymonitor
import org.kde.ksysguard.sensors as Sensors

PlasmoidItem {
  id: root
  property string code

  property string powerManagementControlQml: `
  import org.kde.plasma.private.batterymonitor
  PowerManagementControl {
    id: powerManagementControl
    // Configuración adicional para PowerManagementControl
  }
  `

  property string inhibitionControlQml: `
  import org.kde.plasma.private.batterymonitor
  InhibitionControl {
    id: powerManagementControl
    // Configuración adicional para InhibitionControl
  }
  `
  Sensors.SensorDataModel {
    id: plasmaVersionModel
    sensors: ["os/plasma/plasmaVersion"]
    enabled: true

    onDataChanged: {
      const value = data(index(0, 0), Sensors.SensorDataModel.Value);
      if (value !== undefined && value !== null) {
        if (value.indexOf("6.3") >= 0 || value.indexOf("6.4") >= 0) {
          code = inhibitionControlQml
        } else {
          code = powerManagementControlQml
        }
      }
    }
  }


  property var inhibitionControl: Qt.createQmlObject(code, root, "inhibitionControl");


  property var inhibitions: inhibitionControl.inhibitions
  property bool isManuallyInhibited: inhibitionControl.isManuallyInhibited
  property bool active: inhibitions.length > 0 || isManuallyInhibited

  signal inhibitionChangeRequested(bool inhibit)

  onInhibitionChangeRequested: inhibit => {

    if (inhibit) {
      const reason = i18n("The battery applet has enabled suppressing sleep and screen locking");
      inhibitionControl.inhibit(reason)
    } else {
      inhibitionControl.uninhibit()
    }
  }

  Item {
    width: parent.width
    height: parent.height



    Kirigami.Icon {
      id: logo
      anchors.centerIn: parent
      width: 22
      height: width
      source: active ? "caffeine-cup-full" : "caffeine-cup-empty"
      anchors.horizontalCenter: parent.horizontalCenter

    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: {
        isManuallyInhibited = !isManuallyInhibited
        inhibitionChangeRequested(!isManuallyInhibited)
        logo.source = active ? "caffeine-cup-empty" : "caffeine-cup-full"// forza la actulizacion del icono
      }
    }


  }
  Component.onCompleted: {
    if(!isManuallyInhibited){
      isManuallyInhibited = true
    }
  }
}
