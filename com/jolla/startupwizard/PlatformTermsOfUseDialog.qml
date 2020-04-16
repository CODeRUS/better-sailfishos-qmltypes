/*
 * Copyright (c) 2016 - 2019 Jolla Ltd.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0
import org.nemomobile.systemsettings 1.0

TermsOfUseDialog {
    id: root

    headerText: {
        //% "End User License Agreement"
        qsTrId("startupwizard-he-eula") // trigger Qt Linguist translation
        return startupWizardManager.translatedText("startupwizard-he-eula", root.localeName)
    }
    summaryText: {
        //: %1 = an operating system name, %2 = a copy of the translated text of startupwizard-he-agree
        //% "This device runs %1. By selecting '%2' and starting to use %1 you agree to the %1 End User License Agreement."
        qsTrId("startupwizard-la-sailfish_eula_intro") // trigger Qt Linguist translation
        return startupWizardManager.translatedText("startupwizard-la-sailfish_eula_intro", root.localeName)
                .arg(aboutSettings.localizedOperatingSystemName)
                .arg(dialogHeader.acceptText)
    }
    linkText: {
        //: %1 is an operating system name, text surrounded by %2 and %3 is underlined and colored differently
        //% "Please read the %2%1 End User License Agreement%3 carefully before accepting."
        qsTrId("startupwizard-la-sailfish_eula_read_carefully") // trigger Qt Linguist translation
        return startupWizardManager.translatedText("startupwizard-la-sailfish_eula_read_carefully", root.localeName)
                .arg(aboutSettings.localizedOperatingSystemName)
    }
    rejectLinkText: {
        //: %1 is an operating system name, text surrounded by %2 and %3 is underlined and colored differently
        //% "%2Reject the %1 End User License Agreement%3 and turn the device off"
        qsTrId("startupwizard-la-reject_sailfish_eula_and_turn_off") // trigger Qt Linguist translation
        return startupWizardManager.translatedText("startupwizard-la-reject_sailfish_eula_and_turn_off", root.localeName)
                .arg(aboutSettings.localizedOperatingSystemName)
    }
    rejectHeaderText: {
        //: %1 = an operating system name
        //% "Are you sure you want to reject the %1 End User License Agreement?"
        qsTrId("startupwizard-he-reject_eula_heading_text") // trigger Qt Linguist translation
        return startupWizardManager.translatedText("startupwizard-he-reject_eula_heading_text", root.localeName)
                .arg(aboutSettings.localizedOperatingSystemName)
    }
    rejectBodyText: {
        //% "If you cannot accept the terms of this Agreement after having purchased a product incorporating Software, please return the product containing the Software to the seller in accordance with the applicable return policy."
        qsTrId("startupwizard-la-reject_eula_body_text") // trigger Qt Linguist translation
        return startupWizardManager.translatedText("startupwizard-la-reject_eula_body_text", root.localeName)
    }

    AboutSettings {
        id: aboutSettings
    }
}
