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

abstract class JsonPage() of jsonPage {
    shared Page deserialize(Object json) {
        return Page([for (block in json.getArray("blocks").objects) jsonBlock.deserialize(block)]);
    }
}
object jsonPage extends JsonPage() {}
