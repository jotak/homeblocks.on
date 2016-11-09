import ceylon.json {
    Array,
    Value,
    Object,
    InvalidTypeException
}

class LinksBlock(Link[] links, Integer posx, Integer posy, String? title)
        extends Block("links", posx, posy, title) {
    shared actual {<String->Value>*} addJson() => {"links" -> Array([for (l in links) l.json()])};
}

abstract class JsonLinksBlock() of jsonLinksBlock {
    shared LinksBlock deserialize(Object json) {
        Link[] links = [ for (linkJson in json.getArray("links").objects) jsonLink.deserialize(linkJson) ];
        return LinksBlock(
            links,
            json.getInteger(jsonKeyPosx),
            json.getInteger(jsonKeyPosy),
            json.getStringOrNull(jsonKeyTitle));
    }
}
object jsonLinksBlock extends JsonLinksBlock() {}
