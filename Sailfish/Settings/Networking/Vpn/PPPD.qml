import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0
import Sailfish.Settings.Networking.Vpn 1.0
import Sailfish.Settings.Networking 1.0

Column {
    function setProperties(providerProperties) {
        var getProperty = function(name) {
            if (providerProperties) {
                return providerProperties[name] || ''
            }
            return ''
        }

        if (getProperty('PPPD.ReqMPPE128') == 'true') {
            pppdReqMPPE.setValue('mppe128-required')
        } else if (getProperty('PPPD.ReqMPPE40') == 'true') {
            pppdReqMPPE.setValue('mppe40-required')
        } else if (getProperty('PPPD.ReqMPPE') == 'true') {
            pppdReqMPPE.setValue('mppe-required')
        } else {
            pppdReqMPPE.setValue('no-mppe')
        }
        pppdReqMPPEStateful.checked = getProperty('PPPD.ReqMPPEStateful') == 'true'
        pppdAcceptEAP.checked = getProperty('PPPD.RefuseEAP') != 'true'
        pppdAcceptPAP.checked = getProperty('PPPD.RefusePAP') != 'true'
        pppdAcceptCHAP.checked = getProperty('PPPD.RefuseCHAP') != 'true'
        pppdAcceptMSCHAP.checked = getProperty('PPPD.RefuseMSCHAP') != 'true'
        pppdAcceptMSCHAP2.checked = getProperty('PPPD.RefuseMSCHAP2') != 'true'
        pppdAddrCtrlComp.checked = getProperty('PPPD.UseAccomp') == 'true'
        pppdBsdComp.checked = getProperty('PPPD.NoBSDComp') != 'true'
        pppdProtocolComp.checked = getProperty('PPPD.NoPcomp') != 'true'
        pppdDeflateComp.checked = getProperty('PPPD.NoDeflate') != 'true'
        pppdVJComp.checked = getProperty('PPPD.NoVJ') != 'true'
        pppdEchoInterval.text = getProperty('PPPD.EchoInterval')
        pppdEchoFailure.text = getProperty('PPPD.EchoFailure')
    }

    function updateProperties(providerProperties) {
        var updateProvider = function(name, value) {
            // If the value is empty/default, do not include the property in the configuration
            if (value != '' && value != '_default') {
                providerProperties[name] = value
            }
        }

        if (pppdReqMPPE.currentIndex == 1) {
            updateProvider('PPPD.ReqMPPE', 'true')
        } else if (pppdReqMPPE.currentIndex == 2) {
            updateProvider('PPPD.ReqMPPE40', 'true')
        } else if (pppdReqMPPE.currentIndex == 3) {
            updateProvider('PPPD.ReqMPPE128', 'true')
        }
        if (pppdReqMPPEStateful.checked) {
            updateProvider('PPPD.ReqMPPEStateful', 'true')
        }
        if (!pppdAcceptEAP.checked) {
            updateProvider('PPPD.RefuseEAP', 'true')
        }
        if (!pppdAcceptPAP.checked) {
            updateProvider('PPPD.RefusePAP', 'true')
        }
        if (!pppdAcceptCHAP.checked) {
            updateProvider('PPPD.RefuseCHAP', 'true')
        }
        if (!pppdAcceptMSCHAP.checked) {
            updateProvider('PPPD.RefuseMSCHAP', 'true')
        }
        if (!pppdAcceptMSCHAP2.checked) {
            updateProvider('PPPD.RefuseMSCHAP2', 'true')
        }
        if (pppdAddrCtrlComp.checked) {
            updateProvider('PPPD.UseAccomp', 'true')
        }
        if (!pppdBsdComp.checked) {
            updateProvider('PPPD.NoBSDComp', 'true')
        }
        if (!pppdProtocolComp.checked) {
            updateProvider('PPPD.NoPcomp', 'true')
        }
        if (!pppdDeflateComp.checked) {
            updateProvider('PPPD.NoDeflate', 'true')
        }
        if (!pppdVJComp.checked) {
            updateProvider('PPPD.NoVJ', 'true')
        }
        updateProvider('PPPD.EchoInterval', pppdEchoInterval.text)
        updateProvider('PPPD.EchoFailure', pppdEchoFailure.text)
    }

    width: parent.width

    SectionHeader {
        //: Options for the pppd utility program
        //% "PPP"
        text: qsTrId("settings_network-he-vpn_ppp_options")
    }

    ConfigComboBox {
        id: pppdReqMPPE

        values: [ 'no-mppe', 'mppe-required', 'mppe40-required', 'mppe128-required' ]

        //% "Authentication via MPPE"
        label: qsTrId("settings_network-la-vpn_pppd_reqmppe")
    }

    TextSwitch {
        id: pppdReqMPPEStateful

        //% "Allow stateful MPPE"
        text: qsTrId("settings_network-la-vpn_pppd_reqmppe_stateful")
    }

    SectionHeader {
        //% "Accept"
        text: qsTrId("settings_network-he-vpn_ppp_authentication_protocol_options")
    }

    TextSwitch {
        id: pppdAcceptEAP

        //% "EAP"
        text: qsTrId("settings_network-la-vpn_pppd_accept_eap")
    }

    TextSwitch {
        id: pppdAcceptPAP

        //% "PAP"
        text: qsTrId("settings_network-la-vpn_pppd_accept_pap")
    }

    TextSwitch {
        id: pppdAcceptCHAP

        //% "CHAP"
        text: qsTrId("settings_network-la-vpn_pppd_accept_chap")
    }

    TextSwitch {
        id: pppdAcceptMSCHAP

        //% "MSCHAP"
        text: qsTrId("settings_network-la-vpn_pppd_accept_mschap")
    }

    TextSwitch {
        id: pppdAcceptMSCHAP2

        //% "MSCHAP v2"
        text: qsTrId("settings_network-la-vpn_pppd_accept_mschap2")
    }

    SectionHeader {
        //% "Compression"
        text: qsTrId("settings_network-he-vpn_ppp_compression_options")
    }

    TextSwitch {
        id: pppdBsdComp

        //% "BSD compression"
        text: qsTrId("settings_network-la-vpn_pppd_bsd_compression")
    }

    TextSwitch {
        id: pppdProtocolComp

        //% "Protocol compression"
        text: qsTrId("settings_network-la-vpn_pppd_protocol_compression")
    }

    TextSwitch {
        id: pppdDeflateComp

        //% "Deflate compression"
        text: qsTrId("settings_network-la-vpn_pppd_deflate_compression")
    }

    TextSwitch {
        id: pppdVJComp

        //% "Van Jacobson compression"
        text: qsTrId("settings_network-la-vpn_pppd_vj_compression")
    }

    TextSwitch {
        id: pppdAddrCtrlComp

        //% "Address/control compression"
        text: qsTrId("settings_network-la-vpn_pppd_ac_compression")
    }

    SectionHeader {
        //% "Echo"
        text: qsTrId("settings_network-he-vpn_ppp_echo_options")
    }

    ConfigTextField {
        id: pppdEchoInterval

        //% "Seconds between packets"
        label: qsTrId("settings_network-la-vpn_pppd_echo_interval")
        inputMethodHints: Qt.ImhDigitsOnly
        nextFocusItem: pppdEchoFailure
    }

    ConfigTextField {
        id: pppdEchoFailure

        //% "Fail after missed count"
        label: qsTrId("settings_network-la-vpn_pppd_echo_failure")
        inputMethodHints: Qt.ImhDigitsOnly
    }
}

