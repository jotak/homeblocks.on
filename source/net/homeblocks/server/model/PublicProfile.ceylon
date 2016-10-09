import ceylon.json {
    Object
}

shared class PublicProfile(String username, Page page)
        extends Profile(username, "", page) {

    shared Object json() {
        return Object {
            "username" -> username,
            "page" -> page.json()
        };
    }
}

shared PublicProfile fromProfile(Profile p) {
    return PublicProfile(p.username, p.page);
}

shared PublicProfile sandboxProfile() {
    return PublicProfile("sandbox", Page([
        MainBlock(0, 0, null),
        LinksBlock([
            Link("Homeblocks", "http://www.homeblocks.net/#v/sandbox", "Build your homepage, block after block! Feel free to edit the sandbox (no password), or create a new profile."),
            Link("Homeblocks/jotak", "http://www.homeblocks.net/#/v/jotak", "Example: @jotak's homepage"),
            Link("Homeblocks@GitHub", "https://github.com/jotak/homeblocks", "Fork me on github!")], 1, 0, "Awesome sites")
    ]));
}
