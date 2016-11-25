import ceylon.json {
    Value,
    Object
}

class NoteBlock(String note, Integer posx, Integer posy, String? title)
        extends Block("note", posx, posy, title) {
    shared actual {<String->Value>*} addJson() => {"note" -> note};
}

abstract class JsonNoteBlock() of jsonNoteBlock {
    shared NoteBlock deserialize(Object json) {
        return NoteBlock(
            json.getString("note"),
            json.getInteger(jsonKeyPosx),
            json.getInteger(jsonKeyPosy),
            json.getStringOrNull(jsonKeyTitle));
    }
}
object jsonNoteBlock extends JsonNoteBlock() {}
