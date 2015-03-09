var units = {}

function clear() {
    units = {};
}

function set(name, index) {
    units[name] = index;
}

function get(name) {
    return units[name];
}

function reload(add, on_done) {
    clear();
    var un = vault.units();
    for (var n in un) {
        console.log("UI: add unit", n);
        set(n, add(n, un[n]));
    }
    on_done();
}
