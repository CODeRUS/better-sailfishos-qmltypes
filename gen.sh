#!/bin/bash

CURRENT_DIR=$(readlink -f $(dirname $0))
QML_IMPORTS="/usr/lib/qt5/qml"
TYPEINFO="plugins.qmltypes"
EMPTY_DEPS="$CURRENT_DIR/empty.json"
# DEPENDENCIES="dependencies.json"

# DEFAULT_EXCLUDES="QtQuick QtWebKit QtWebKit.experimental org.nemomobile.lipstick Sailfish.Lipstick Sailfish.Silica Sailfish.Silica.private"

# for qmldir in $(find /usr/lib/qt5/qml -name qmldir)
# do
#   # echo $qmldir
#   DIRNAME=$(dirname $qmldir)
#   PLUGIN=${DIRNAME:17}
#   PLUGIN=${PLUGIN//\//.}
#   if [[ $PLUGIN == org.nemomobile* ]] \
#   || [[ $PLUGIN == Mer* ]] \
#   || [[ $PLUGIN == Nemo* ]] \
#   || [[ $PLUGIN == io* ]] \
#   || [[ $PLUGIN == com.jolla* ]] \
#   || [[ $PLUGIN == Sailfish* ]]
#   then
#     echo $PLUGIN
#   fi
# done

# exit 0

QML=$(find /usr/share -name "*.qml" 2>/dev/null)

import() {
  local PLUGIN="$1"
  local VERSION="$2"

  local DIR="${PLUGIN//\.//}"
  local QMLDIR="$QML_IMPORTS/$DIR/qmldir"

  if [ ! -f "$QMLDIR" ]
  then
    return
  fi

  # if [ "$VERSION" = "" ]
  # then
  #   local FOUND=0
  #   for f in $QML
  #   do
  #     grep -h "^import $PLUGIN " $f \
  #       && FOUND=1 \
  #       && break
  #   done

  #   if [ "$FOUND" = "0" ]
  #   then
  #     echo "import $PLUGIN"
  #   fi
  # else
    echo "import $1 $2"
  # fi

  local NEW_DIR="$CURRENT_DIR/$DIR"
  local NEW_QMLDIR="$NEW_DIR/qmldir"
  mkdir -p "$NEW_DIR"
  if [ ! -f "$NEW_QMLDIR" ]
  then
    cp -vf "$QMLDIR" "$NEW_QMLDIR"
  fi

  for f in $(grep -- "\.qml$\|\.js$" "$QMLDIR" | rev | cut -d" " -f1 | rev)
  do
    local DEST_FILE="$NEW_DIR/$f"
    local DEST_DIR="$(dirname $DEST_FILE)"
    mkdir -p "$DEST_DIR"
    if [ ! -f "$DEST_FILE" ]
    then
      cp -vf "$QML_IMPORTS/$DIR/$f" "$DEST_FILE"
    fi
  done

  if $(grep "^plugin " "$NEW_QMLDIR" > /dev/null)
  then
    if ! $(grep "^typeinfo " "$NEW_QMLDIR" > /dev/null)
    then
      echo "typeinfo $TYPEINFO >> $NEW_QMLDIR"
      echo "typeinfo $TYPEINFO" >> "$NEW_QMLDIR"
    fi

    local QMLTYPES="$NEW_DIR/$TYPEINFO"
    # local DEPS="$NEW_DIR/$DEPENDENCIES"

    # echo "qmlimportscanner -> $DEPS"
    # echo -e "import $PLUGIN $VERSION\nQtObject{}\n" \
    # | /usr/lib/qt5/bin/qmlimportscanner -qmlFiles - -importPath "$QML_IMPORTS" \
    # > "$DEPS"

    # local EXCLUDES="$DEFAULT_EXCLUDES"
    # if [ "$#" -gt 3 ]
    # then
    #   EXCLUDES="$EXCLUDES ${@:3}"
    #   echo "EXCLUDES: $EXCLUDES"
    # fi

    # for d in $EXCLUDES
    # do
    #   echo "sed -i -e \"/\\\"$d\\\"/,/{/d\" $DEPS"
    #   sed -i -e "/\"$d\"/,/{/d" "$DEPS"
    # done

    qmlplugindump \
      -nonrelocatable \
      -noinstantiate \
      -dependencies "$EMPTY_DEPS" \
      "$PLUGIN" "$VERSION" \
      1> "$QMLTYPES" \
      2>"$QMLTYPES.error"
    if [ -s "$QMLTYPES.error" ]
    then
      cat "$QMLTYPES.error"
    else
      rm -f "$QMLTYPES.error" ||:
    fi
  fi
}

import Mer.Cutes 1.1
import Mer.State 1.1
import Nemo.Alarms 1.0
import Nemo.Configuration 1.0
import Nemo.Connectivity 1.0
import Nemo.DBus 2.0
import Nemo.Email 0.1
import Nemo.FileManager 1.0
import Nemo.KeepAlive 1.2
import Nemo.Mce 1.0
import Nemo.Ngf 1.0
import Nemo.Notifications 1.0
import Nemo.Policy 1.0
import Nemo.Ssu 1.0
import Nemo.Thumbnailer 1.0
import Nemo.Time 1.0
import Sailfish.AccessControl 1.0
import Sailfish.Accounts 1.0
import Sailfish.Ambience 1.0
import Sailfish.Bluetooth 1.0
import Sailfish.Calculator 1.0
import Sailfish.Calendar 1.0
import Sailfish.Contacts 1.0
import Sailfish.Crypto 1.0
import Sailfish.Email 1.1
import Sailfish.Encryption 1.0
import Sailfish.FileManager 1.0
import Sailfish.Gallery 1.0
import Sailfish.Gallery.private 1.0
import Sailfish.Lipstick 1.0
import Sailfish.Mdm 1.0
import Sailfish.Media 1.0
import Sailfish.Messages 1.0
import Sailfish.Office 1.0
import Sailfish.Office.PDF 1.0
import Sailfish.Pickers 1.0
import Sailfish.Pickers.private 1.0
import Sailfish.Policy 1.0
import Sailfish.Secrets.Ui 1.0
import Sailfish.Settings.Networking 1.0
import Sailfish.Settings.Networking.Vpn 1.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import Sailfish.Silica.theme 1.0
import Sailfish.Store 1.0
import Sailfish.Telephony 1.0
import Sailfish.TextLinking 1.0
import Sailfish.Timezone 1.0
import Sailfish.TransferEngine 1.0
import Sailfish.TransferEngine.Nextcloud 1.0
import Sailfish.Tutorial 1.0
import Sailfish.Utilities 1.0
import Sailfish.Vault 1.0
import Sailfish.Weather 1.0
import Sailfish.WebEngine 1.0
import Sailfish.WebView 1.0
import Sailfish.WebView.Pickers 1.0
import Sailfish.WebView.Popups 1.0
import com.jolla.apkd 1.0
import com.jolla.camera 1.0
import com.jolla.connection 1.0
import com.jolla.contacts.settings 1.0
import com.jolla.email 1.1
import com.jolla.eventsview.nextcloud 1.0
import com.jolla.gallery 1.0
import com.jolla.gallery.ambience 1.0
import com.jolla.gallery.dropbox 1.0
import com.jolla.gallery.extensions 1.0
import com.jolla.gallery.facebook 1.0
import com.jolla.gallery.nextcloud 1.0
import com.jolla.gallery.onedrive 1.0
import com.jolla.gallery.vk 1.0
import com.jolla.hwr 1.0
import com.jolla.keyboard 1.0
import com.jolla.mediaplayer 1.0
import com.jolla.sailfisheas 1.0
import com.jolla.settings 1.0
import com.jolla.settings.accounts 1.0
import com.jolla.settings.multisim 1.0
import com.jolla.settings.sailfishos 1.0
import com.jolla.settings.system 1.0
import com.jolla.signonuiservice 1.0
import com.jolla.startupwizard 1.0
import com.jolla.xt9 1.0
import com.jolla.xt9cp 1.0
import io.thp.pyotherside 1.5
import org.nemomobile.accounts 1.0
import org.nemomobile.alarms 1.0
import org.nemomobile.calendar 1.0
import org.nemomobile.calendar.lightweight 1.0
import org.nemomobile.commhistory 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.contacts 1.0
import org.nemomobile.contentaction 1.0
import org.nemomobile.dbus 2.0
import org.nemomobile.devicelock 1.0
import org.nemomobile.email 0.1
import org.nemomobile.grilo 0.1
import org.nemomobile.lipstick 0.1
import org.nemomobile.messages.internal 1.0
import org.nemomobile.models 1.0
import org.nemomobile.mpris 1.0
import org.nemomobile.ngf 1.0
import org.nemomobile.notifications 1.0
import org.nemomobile.ofono 1.0
import org.nemomobile.policy 1.0
import org.nemomobile.signon 1.0
import org.nemomobile.social 1.0
import org.nemomobile.socialcache 1.0
import org.nemomobile.systemsettings 1.0
import org.nemomobile.thumbnailer 1.0
import org.nemomobile.time 1.0
import org.nemomobile.transferengine 1.0
import org.nemomobile.voicecall 1.0
