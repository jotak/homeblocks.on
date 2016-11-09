import ceylon.json {
    Object
}

shared class Profile(String username, Page page) {
    default shared Object json() {
        return Object {
            "username" -> username,
            "page" -> page.json()
        };
    }

    shared String getUsername() => username;
    shared Page getPage() => page;
}

shared abstract class JsonProfile() of jsonProfile {
    shared Profile deserialize(Object json) {
        return Profile(json.getString("username"), jsonPage.deserialize(json.getObject("page")));
    }
}
shared object jsonProfile extends JsonProfile() {}

shared Profile sandboxProfile() {
    return Profile("sandbox", Page([
        MainBlock(0, 0, null),
        LinksBlock([
            Link("Homeblocks", "http://www.homeblocks.net/#v/sandbox", "Build your homepage, block after block! Feel free to edit the sandbox (no password), or create a new profile."),
            Link("Homeblocks/jotak", "http://www.homeblocks.net/#/v/jotak", "Example: @jotak's homepage"),
            Link("Homeblocks@GitHub", "https://github.com/jotak/homeblocks", "Fork me on github!")], 1, 0, "Awesome sites")
    ]));
}
