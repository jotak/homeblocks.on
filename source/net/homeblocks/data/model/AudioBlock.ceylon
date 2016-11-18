import ceylon.json {
    Value,
    Array,
    Object
}

class AudioBlock(Link[] links, Integer posx, Integer posy, String? title)
        extends Block("audio", posx, posy, title) {
    shared actual {<String->Value>*} addJson() => {"links" -> Array([for (l in links) l.json()])};
}

abstract class JsonAudioBlock() of jsonAudioBlock {
    shared AudioBlock deserialize(Object json) {
        Link[] links = [ for (linkJson in json.getArray("links").objects) jsonLink.deserialize(linkJson) ];
        return AudioBlock(
            links,
            json.getInteger(jsonKeyPosx),
            json.getInteger(jsonKeyPosy),
            json.getStringOrNull(jsonKeyTitle));
    }
}
object jsonAudioBlock extends JsonAudioBlock() {}
