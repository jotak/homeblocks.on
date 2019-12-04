import ceylon.json { Object }

shared Object notFound404Profile() {
    value page = Page([
        MainBlock(0, 0, null),
        NoteBlock("<h3>404,<br/> Blocks not found!</h3><br/>Oops, looks like you entered a wrong URL", -1, -1, ""),
        LinksBlock([ Link("homeblocks.net", "https://www.homeblocks.net/#/u", "Start page") ], 1, 1, "Try here")]);

    return Object {
            "title" -> "404",
            "page" -> page.json()
    };
}

shared Object loginProfile([String, String][] authProviders) {
    value page = Page([
        LinksBlock(
            authProviders.map(([String, String] p) => Link(p[0], p[1], p[0])).sequence(), 0, 0, "Login"),
        NoteBlock("<h3>Welcome to Homeblocks.net</h3><br/>Build your homepage, block after block!", -1, -1, "")
    ]);

    return Object {
            "title" -> "login",
            "page" -> page.json()
    };
}

shared Object singleBlockLoginProfile([String, String][] authProviders) {
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
