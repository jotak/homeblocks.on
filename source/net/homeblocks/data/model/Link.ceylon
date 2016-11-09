import ceylon.json {
    Object
}

shared class Link(String title, String url, String? description) {
    shared Object json() {
        return Object {
            "title" -> title,
            "url" -> url,
            "description" -> description
        };
    }
}

abstract class JsonLink() of jsonLink {
    shared Link deserialize(Object json) {
        return Link(json.getString("title"), json.getString("url"), json.getStringOrNull("description"));
    }
}
object jsonLink extends JsonLink() {}
