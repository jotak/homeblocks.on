import ceylon.json {
    Object
}

shared class ListItem(String val) {
    shared Object json() {
        return Object { "value" -> val };
    }
}

abstract class JsonListItem() of jsonListItem {
    shared ListItem deserialize(Object json) {
        return ListItem(json.getString("value"));
    }
}
object jsonListItem extends JsonListItem() {}
