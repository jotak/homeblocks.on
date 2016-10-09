import ceylon.json {
    Object,
    Value
}

shared abstract class Block(String type, Integer posx, Integer posy, String? title) {
    default shared {<String->Value>*} addJson() => {};
    shared Object json() {
        return Object {
            "type" -> type,
            "posx" -> posx,
            "posy" -> posy,
            "title" -> title,
            *addJson()
        };
    }
}
