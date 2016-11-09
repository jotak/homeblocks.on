import ceylon.json {
    Object,
    InvalidTypeException
}

class MainBlock(Integer posx, Integer posy, String? title)
        extends Block("main", posx, posy, title) {}

abstract class JsonMainBlock() of jsonMainBlock {
    shared MainBlock deserialize(Object json) {
        return MainBlock(
            json.getInteger(jsonKeyPosx),
            json.getInteger(jsonKeyPosy),
            json.getStringOrNull(jsonKeyTitle));
    }
}
object jsonMainBlock extends JsonMainBlock() {}
