import ceylon.json {
    Value,
    Array,
    Object
}

class ListBlock(ListItem[] items, Integer posx, Integer posy, String? title)
        extends Block("list", posx, posy, title) {
    shared actual {<String->Value>*} addJson() => {"list" -> Array([for (i in items) i.json()])};
}

abstract class JsonListBlock() of jsonListBlock {
    shared ListBlock deserialize(Object json) {
        ListItem[] items = [ for (itemJson in json.getArray("list").objects) jsonListItem.deserialize(itemJson) ];
        return ListBlock(
            items,
            json.getInteger(jsonKeyPosx),
            json.getInteger(jsonKeyPosy),
            json.getStringOrNull(jsonKeyTitle));
    }
}
object jsonListBlock extends JsonListBlock() {}
