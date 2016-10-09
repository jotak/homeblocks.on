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
