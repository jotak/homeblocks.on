import ceylon.json {
    Object,
    Value,
    InvalidTypeException
}

String jsonKeyType = "type";
shared String jsonKeyPosx = "posx";
shared String jsonKeyPosy = "posy";
shared String jsonKeyTitle = "title";

shared abstract class Block(String type, Integer posx, Integer posy, String? title) {
    default shared {<String->Value>*} addJson() => {};
    shared Object json() {
        return Object {
            jsonKeyType -> type,
            jsonKeyPosx -> posx,
            jsonKeyPosy -> posy,
            jsonKeyTitle -> title,
            *addJson()
        };
    }
}

abstract class JsonBlock() of jsonBlock {
    throws (`class InvalidTypeException`, "If block type is not recognized.")
    shared Block deserialize(Object json) {
        Block? block = switch (json.getString(jsonKeyType))
        case ("links") jsonLinksBlock.deserialize(json)
        case ("audio") jsonAudioBlock.deserialize(json)
        case ("video") jsonVideoBlock.deserialize(json)
        case ("image") jsonImageBlock.deserialize(json)
        case ("list") jsonListBlock.deserialize(json)
        case ("note") jsonNoteBlock.deserialize(json)
        case ("main") jsonMainBlock.deserialize(json)
        else null;
        if (exists block) {
            return block;
        }
        throw InvalidTypeException("Unknown block type: " + json.getString(jsonKeyType));
    }
}
object jsonBlock extends JsonBlock() {}
