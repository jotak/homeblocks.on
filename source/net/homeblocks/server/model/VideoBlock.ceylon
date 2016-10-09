import ceylon.json {
    Value,
    Array
}
class VideoBlock(Link[] links, Integer posx, Integer posy, String? title)
        extends Block("video", posx, posy, title) {
    shared actual {<String->Value>*} addJson() => {"links" -> Array([for (l in links) l.json()])};
}
