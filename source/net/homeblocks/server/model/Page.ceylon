import ceylon.json {
    Object,
    Array
}

shared class Page(shared Block[] blocks) {
    shared Object json() {
        return Object {
            "blocks" -> Array([for(b in blocks) b.json()])
        };
    }
}
