import ceylon.json { Object }

shared Object notFound404Profile() {
    value page = Page([
        MainBlock(0, 0, null),
        LinksBlock([
            Link("Homeblocks", "http://www.homeblocks.net/#v/sandbox", "Build your homepage, block after block! Feel free to edit the sandbox (no password), or create a new profile."),
            Link("Homeblocks/jotak", "http://www.homeblocks.net/#/v/jotak", "Example: @jotak's homepage"),
            Link("Homeblocks@GitHub", "https://github.com/jotak/homeblocks", "Fork me on github!")],
            1, 0, "Awesome sites")]);

    return Object {
            "title" -> "404 not found!",
            "page" -> page.json()
    };
}

shared Object loginProfile([String, String][] authProviders) {
    value page = Page([
        LinksBlock(
            authProviders.map(([String, String] p) => Link(p[0], p[1], p[0])).sequence(), 0, 0, "Login")
    ]);

    return Object {
            "title" -> "login",
            "page" -> page.json()
    };
}

shared Object userProfiles(String refUser, String[] profiles, String? logged) {
    value page = Page([
        MainBlock(0, 0, null),
        LinksBlock(
            profiles.map((String p) => Link(p, "#/u/" + refUser + "/" + p, "")).sequence(), 1, 0, "Profiles")
    ]);

    return Object {
            "refUser" -> refUser,
            "title" -> refUser + "'s place",
            "page" -> page.json(),
            if (exists logged) "logged" -> logged
    };
}

shared Object pageProfile(String refUser, String profile, Page page, String? logged) {
    return Object {
            "refUser" -> refUser,
            "profile" -> profile,
            "title" -> refUser + "'s " + profile,
            "page" -> page.json(),
            if (exists logged) "logged" -> logged
    };
}

shared Page emptyPage() {
    return Page([MainBlock(0, 0, null)]);
}
