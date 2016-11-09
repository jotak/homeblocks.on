import ceylon.json {
    Object
}

shared class PrivateProfile(shared String username, String password, shared Page page) extends Profile(username, page) {
    actual shared Object json() {
        return Object {
                "username" -> username,
                "password" -> password,
                "page" -> page.json()
        };
    }

    shared String getPassword() => password;

    shared Profile public() {
        return Profile(username, page);
    }
}

shared abstract class PrivateProfiles() of privateProfiles {
    shared PrivateProfile deserialize(Object json) {
        return PrivateProfile(
            json.getString("username"),
            json.getString("password"),
            jsonPage.deserialize(json.getObject("page")));
    }

    shared PrivateProfile empty(String username, String password) {
        return PrivateProfile(username, password, Page([MainBlock(0, 0, null)]));
    }

    shared PrivateProfile fromPublic(Profile publicProfile, String hash) {
        return PrivateProfile(publicProfile.getUsername(), hash, publicProfile.getPage());
    }
}
shared object privateProfiles extends PrivateProfiles() {}
