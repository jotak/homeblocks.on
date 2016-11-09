import ceylon.json {
    Value,
    Array,
    Object,
    InvalidTypeException
}

class VideoBlock(Link[] links, Integer posx, Integer posy, String? title)
        extends Block("video", posx, posy, title) {
    shared actual {<String->Value>*} addJson() => {"links" -> Array([for (l in links) l.json()])};
}

abstract class JsonVideoBlock() of jsonVideoBlock {
    shared VideoBlock deserialize(Object json) {
        Link[] links = [ for (linkJson in json.getArray("links").objects) jsonLink.deserialize(linkJson) ];
        return VideoBlock(
            links,
            json.getInteger(jsonKeyPosx),
            json.getInteger(jsonKeyPosy),
            json.getStringOrNull(jsonKeyTitle));
    }
}
object jsonVideoBlock extends JsonVideoBlock() {}
