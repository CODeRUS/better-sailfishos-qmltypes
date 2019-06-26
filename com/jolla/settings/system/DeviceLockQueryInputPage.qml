import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.devicelock 1.0

Page {
    id: page

    property AuthenticationInput authentication

    backNavigation: false
    opacity: status === PageStatus.Active ? 1.0 : 0.0

    DeviceLockInput {
        id: devicelockinput

        authenticationInput: authentication

        enabled: !evaluatingIndicator.running
        opacity: evaluatingIndicator.running ? 0 : 1
        Behavior on opacity { FadeAnimation{} }

        showEmergencyButton: false
    }

    BusyIndicator {
        id: evaluatingIndicator
        running: authentication.status === AuthenticationInput.Evaluating
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }
}
