import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: pickerDialog

    property string title
    property string acceptText
    property ListModel selectedContent: SelectedContentModel {}
    property SelectedContentModel _selectedModel
    property int _animationDuration: 150

    property Component _background

    function updateSelectedContent(model) {
        if (!_selectedModel) {
            _selectedModel = selectedModelComponent.createObject(pickerDialog)
        }

        _selectedModel = model
    }

    canAccept: _selectedModel && _selectedModel.count > 0 ? true : false
    onDone: {
        if (result == DialogResult.Accepted) {
            selectedContent = _selectedModel
            selectedContentChanged()
        } else {
            _selectedModel.clear()
        }
    }

    Item {
        id: background
        anchors.fill: parent
    }

    Component {
        id: selectedModelComponent

        SelectedContentModel {}
    }

    Component.onCompleted: {
        if (_background) {
            _background.createObject(background)
        }

        if (!_selectedModel) {
            _selectedModel = selectedModelComponent.createObject(pickerDialog)
        }

        if (selectedContent) {
            var count = selectedContent.count
            for (var i = 0; i < count; ++i) {
                var contentItem = selectedContent.get(i)
                _selectedModel.append(contentItem)
            }
        }
    }
}
