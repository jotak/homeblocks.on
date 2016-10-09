import ceylon.json {
    Value,
    Array
}
class AudioBlock(Link[] links, Integer posx, Integer posy, String? title)
        extends Block("audio", posx, posy, title) {
    shared actual {<String->Value>*} addJson() => {"links" -> Array([for (l in links) l.json()])};
}