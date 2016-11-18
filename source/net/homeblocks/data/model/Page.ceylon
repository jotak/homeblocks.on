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

shared abstract class JsonPage() of jsonPage {
    shared Page deserialize(Object json) {
        return Page([for (block in json.getArray("blocks").objects) jsonBlock.deserialize(block)]);
    }
}
shared object jsonPage extends JsonPage() {}
