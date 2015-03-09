.pragma library

var _serviceComponent
var _serviceInstance

function service() {
    if (_serviceComponent === undefined) {
        _serviceComponent = Qt.createComponent(Qt.resolvedUrl('ContactsDBusService.qml'))
        if (_serviceComponent.status === 1) {
            _serviceInstance = _serviceComponent.createObject(0)
        } else {
            console.log(_serviceComponent.errorString)
        }
    }
    return _serviceInstance
}

function showContact(contactId) { service().call("showContact", contactId) }
function editContact(contactId) { service().call("editContact", contactId) }
function createContact(number) { service().call("createContact", number) }
