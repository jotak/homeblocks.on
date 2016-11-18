import ceylon.json {
    Value,
    Array,
    Object
}

class ImageBlock(Link[] links, Integer posx, Integer posy, String? title)
        extends Block("image", posx, posy, title) {
    shared actual {<String->Value>*} addJson() => {"links" -> Array([for (l in links) l.json()])};
}

abstract class JsonImageBlock() of jsonImageBlock {
    shared ImageBlock deserialize(Object json) {
        Link[] links = [ for (linkJson in json.getArray("links").objects) jsonLink.deserialize(linkJson) ];
        return ImageBlock(
            links,
            json.getInteger(jsonKeyPosx),
            json.getInteger(jsonKeyPosy),
            json.getStringOrNull(jsonKeyTitle));
    }
}
object jsonImageBlock extends JsonImageBlock() {}
