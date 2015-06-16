.pragma library

var iconMap = {
    "computer":"icon-m-computer",
    "phone":"icon-m-phone",
    "modem":"icon-m-bluetooth-device",
    "network-wireless":"icon-m-bluetooth-device",
    "audio-card":"icon-m-headset",
    "camera-video":"icon-m-imaging",
    "input-gaming":"icon-m-game-controller",
    "input-keyboard":"icon-m-keyboard",
    "input-mouse":"icon-m-mouse",
    "camera-photo":"icon-m-imaging",
    "multimedia-player":"icon-m-media"
}

var knownServiceUuids = {
    // Listed at https://www.bluetooth.org/Technical/AssignedNumbers/service_discovery.htm
    "00001000-0000-1000-8000-00805F9B34FB": "SDP",	// Service Discovery
    "00001101-0000-1000-8000-00805F9B34FB": "SPP",	// Serial Port Profile
    "00001103-0000-1000-8000-00805F9B34FB": "DUN",	// Dial-up Networking Profile
    "00001104-0000-1000-8000-00805F9B34FB": "SYNC",	// Synchronization Profile
    "00001105-0000-1000-8000-00805F9B34FB": "OPP",	// Object Push Profile
    "00001106-0000-1000-8000-00805F9B34FB": "FTP",	// File Transfer Profile
    "00001107-0000-1000-8000-00805F9B34FB": "SYNC",	// Synchronization Profile
    "00001108-0000-1000-8000-00805F9B34FB": "HSP",	// Headset Profile
    "00001109-0000-1000-8000-00805F9B34FB": "CTP",	// Cordless Telephony Profile
    "0000110A-0000-1000-8000-00805F9B34FB": "A2DP",	// Advanced Audio Distribution Profile
    "0000110B-0000-1000-8000-00805F9B34FB": "A2DP",	// Advanced Audio Distribution Profile
    "0000110C-0000-1000-8000-00805F9B34FB": "AVRCP",	// Audio/Video Remote Control Profile
    "0000110D-0000-1000-8000-00805F9B34FB": "A2DP",	// Advanced Audio Distribution Profile
    "0000110E-0000-1000-8000-00805F9B34FB": "AVRCP",	// Audio/Video Remote Control Profile
    "0000110F-0000-1000-8000-00805F9B34FB": "AVRCP",	// Audio/Video Remote Control Profile
    "00001110-0000-1000-8000-00805F9B34FB": "ICP",	// Intercom Profile
    "00001111-0000-1000-8000-00805F9B34FB": "FAX",	// Fax Profile
    "00001112-0000-1000-8000-00805F9B34FB": "HSP",	// Headset Profile
    "00001115-0000-1000-8000-00805F9B34FB": "PAN",	// Personal Area Networking Profile
    "00001116-0000-1000-8000-00805F9B34FB": "PAN",	// Personal Area Networking Profile
    "00001117-0000-1000-8000-00805F9B34FB": "PAN",	// Personal Area Networking Profile
    "00001118-0000-1000-8000-00805F9B34FB": "BPP",	// Basic Printing Profile
    "00001119-0000-1000-8000-00805F9B34FB": "BPP",	// See Basic Printing Profile
    "0000111A-0000-1000-8000-00805F9B34FB": "BIP",	// Basic Imaging Profile
    "0000111B-0000-1000-8000-00805F9B34FB": "BIP",	// Basic Imaging Profile
    "0000111C-0000-1000-8000-00805F9B34FB": "BIP",	// Basic Imaging Profile
    "0000111D-0000-1000-8000-00805F9B34FB": "BIP",	// Basic Imaging Profile
    "0000111E-0000-1000-8000-00805F9B34FB": "HFP",	// Hands-Free Profile
    "0000111F-0000-1000-8000-00805F9B34FB": "HFP",	// Hands-free Profile
    "00001120-0000-1000-8000-00805F9B34FB": "BPP",	// Basic Printing Profile
    "00001121-0000-1000-8000-00805F9B34FB": "BPP",	// Basic Printing Profile
    "00001122-0000-1000-8000-00805F9B34FB": "BPP",	// Basic Printing Profile
    "00001123-0000-1000-8000-00805F9B34FB": "BPP",	// Basic Printing Profile
    "00001124-0000-1000-8000-00805F9B34FB": "HID",	// Human Interface Device
    "00001125-0000-1000-8000-00805F9B34FB": "HCRP",	// Hardcopy Cable Replacement Profile
    "00001126-0000-1000-8000-00805F9B34FB": "HCRP",	// Hardcopy Cable Replacement Profile
    "00001127-0000-1000-8000-00805F9B34FB": "HCRP",	// Hardcopy Cable Replacement Profile
    "00001128-0000-1000-8000-00805F9B34FB": "CIP",	// Common ISDN Access Profile
    "0000112D-0000-1000-8000-00805F9B34FB": "SAP",	// SIM Access Profile
    "0000112E-0000-1000-8000-00805F9B34FB": "PBAP",	// Phonebook Access Profile
    "0000112F-0000-1000-8000-00805F9B34FB": "PBAP",	// Phonebook Access Profile
    "00001130-0000-1000-8000-00805F9B34FB": "PBAP",	// Phonebook Access Profile
    "00001131-0000-1000-8000-00805F9B34FB": "HSP",	// Headset Profile
    "00001132-0000-1000-8000-00805F9B34FB": "MAP",	// Message Access Profile
    "00001133-0000-1000-8000-00805F9B34FB": "MAP",	// Message Access Profile
    "00001134-0000-1000-8000-00805F9B34FB": "MAP",	// Message Access Profile
    "00001135-0000-1000-8000-00805F9B34FB": "GNSS",	// Global Navigation Satellite System Profile
    "00001136-0000-1000-8000-00805F9B34FB": "GNSS",	// Global Navigation Satellite System Profile
    "00001137-0000-1000-8000-00805F9B34FB": "3DSP",	// 3D Display
    "00001138-0000-1000-8000-00805F9B34FB": "3DSP",	// 3D Glasses
    "00001139-0000-1000-8000-00805F9B34FB": "3DSP",	// 3D Synchronization
    "0000113A-0000-1000-8000-00805F9B34FB": "MPS",	// Multi-Profile Specification
    "0000113B-0000-1000-8000-00805F9B34FB": "MPS",	// Multi-Profile Specification
    "0000113C-0000-1000-8000-00805F9B34FB": "CTN",	// Calendar Tasks and Notes
    "0000113D-0000-1000-8000-00805F9B34FB": "CTN",	// Calendar Tasks and Notes
    "0000113E-0000-1000-8000-00805F9B34FB": "CTN",	// Calendar Tasks and Notes
    "00001200-0000-1000-8000-00805F9B34FB": "DID",	// Device Identification
    "00001205-0000-1000-8000-00805F9B34FB": "ESDP",	// Enhanced Service Discovery Profile
    "00001206-0000-1000-8000-00805F9B34FB": "ESDP",	// Enhanced Service Discovery Profile
    "00001300-0000-1000-8000-00805F9B34FB": "ESDP",	// Enhanced Service Discovery Profile
    "00001301-0000-1000-8000-00805F9B34FB": "ESDP",	// Enhanced Service Discovery Profile
    "00001302-0000-1000-8000-00805F9B34FB": "ESDP",	// Enhanced Service Discovery Profile
    "00001303-0000-1000-8000-00805F9B34FB": "VDP",	// Video Distribution Profile
    "00001304-0000-1000-8000-00805F9B34FB": "VDP",	// Video Distribution Profile
    "00001305-0000-1000-8000-00805F9B34FB": "VDP",	// Video Distribution Profile
    "00001400-0000-1000-8000-00805F9B34FB": "HDP",	// Health Device Profile
    "00001401-0000-1000-8000-00805F9B34FB": "HDP",	// Health Device Profile
    "00001402-0000-1000-8000-00805F9B34FB": "HDP",	// Health Device Profile

    // non-standard profiles
    "00000001-0000-1000-8000-0002EE000001": "SyncML",           // SyncML server
    "00005601-0000-1000-8000-0002EE000001": "Nokia SyncML",     // Nokia SyncML server
    "00000002-0000-1000-8000-0002EE000002": "SyncML",           // SyncML
    "00005005-0000-1000-8000-0002EE000001": "Nokia OBEX PC Suite",
}

function mapToThemeIcon(icon) {
    if (iconMap[icon] !== undefined) {
        return iconMap[icon]
    }

    return "icon-m-bluetooth-device"
}
