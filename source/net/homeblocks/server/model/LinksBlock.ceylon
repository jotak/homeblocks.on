import ceylon.json {
    Array,
    Value
}

class LinksBlock(Link[] links, Integer posx, Integer posy, String? title)
        extends Block("links", posx, posy, title) {
    shared actual {<String->Value>*} addJson() => {"links" -> Array([for (l in links) l.json()])};
}
