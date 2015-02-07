import QtQuick 2.0
import Sailfish.Silica 1.0

PickerDialog {
    id: contentPickerDialog

    // We are single selection, so don't show the forward navigation indicator
    forwardNavigation: false

    SilicaListView {
        id: categoryList

        anchors.fill: parent
        header: PageHeader {
            id: dialogHeader
            title: contentPickerDialog.title
        }

        model: categoryModel

        delegate: ListItem {
            Label {
                id: categoryName

                text: categoryList.model.category(index)
                color: down ? Theme.highlightColor : Theme.primaryColor
                anchors.verticalCenter: parent.verticalCenter
                x: Theme.paddingLarge
            }

            onClicked: {
                var subview = pageStack.push(Qt.resolvedUrl(model.subview), {
                    title: contentPickerDialog.title,
                    acceptDestination: pageStack.previousPage(contentPickerDialog),
                    acceptDestinationAction: PageStackAction.Pop,
                    _selectedModel: contentPickerDialog._selectedModel,
                    _animationDuration: contentPickerDialog._animationDuration
                }, pageStack._transitionDuration === 0 ? PageStackAction.Immediate : PageStackAction.Animated);

                subview.accepted.connect(function() {
                    contentPickerDialog._dialogDone(DialogResult.Accepted)
                })
            }
        }

        VerticalScrollDecorator {}
    }


    CategoryModel {
        id: categoryModel
        multiPicker: true
    }
}
