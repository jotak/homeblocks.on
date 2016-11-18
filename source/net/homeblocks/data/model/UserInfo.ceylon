import ceylon.json {
    Object
}

shared class UserInfo(shared String prov, shared String provUId, shared Integer intIdx, shared String name) {
    shared Object json() {
        return Object {
                "prov" -> prov,
                "provUId" -> provUId,
                "intIdx" -> intIdx,
                "name" -> name
        };
    }
}

shared abstract class JsonUserInfo() of jsonUserInfo {
    shared UserInfo deserialize(Object json) {
        return UserInfo(json.getString("prov"), json.getString("provUId"), json.getInteger("intIdx"), json.getString("name"));
    }
}

shared object jsonUserInfo extends JsonUserInfo() {}
