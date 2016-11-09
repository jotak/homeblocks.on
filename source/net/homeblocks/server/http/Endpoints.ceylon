import ceylon.json {
    parse,
    Object
}
import ceylon.net.http {
    get,
    post,
    put
}
import ceylon.net.http.server {
    Request,
    AsynchronousEndpoint,
    startsWith,
    equals,
    template,
    Endpoint,
    HttpEndpoint
}
import ceylon.net.http.server.endpoints {
    serveStaticFile
}
import ceylon.regex {
    Regex,
    regex
}

import net.homeblocks.data.model {
    sandboxProfile,
    jsonProfile,
    Profile,
    privateProfiles,
    PrivateProfile
}
import net.homeblocks.server.services {
    ProfilesService
}

HttpEndpoint[] allEndpoints(ProfilesService profilesService) {

    function mapper(Request req)
            => req.path == "/" then "/index.html" else req.path;

    return [
        AsynchronousEndpoint(
            equals("/api/auth"),
            ((req, res, void complete()) {
                print("/api/auth");
                // TODO
                complete();
            }),
            { post }),
        Endpoint(
            template("/api/profile/{username}"),
            (req, res) {
                if (exists username = req.pathParameter("username"),
                        exists profile = profilesService.load(username)) {
                    res.writeString(profile.json().string);
                } else {
                    res.writeString(sandboxProfile().json().string);
                }
            },
            { get }),
        Endpoint(
            template("/api/profile"),
            (req, res) {
                switch (json = parse(req.read()))
                case (is Object) {
                    if (req.method == post) {
                        // Update
                        Profile profile = jsonProfile.deserialize(json);
                        if (checkUsername(profile.getUsername())) {
                            print("Update: " +req.read());
                        } else {
                            // Set status 400
                        }
                    } else {
                        // Create
                        PrivateProfile profile = privateProfiles.deserialize(json);
                        if (checkUsername(profile.getUsername())) {
                            // TODO: manage & generate token
                            //profilesService.createEmpty(profile.getUsername(), profile.getPassword());
                            print(req.read());
                        } else {
                            // Set status 400
                        }
                    }
                } else {

                }
            },
            { post, put }),
        AsynchronousEndpoint(
            startsWith("/"),
            serveStaticFile("public", mapper),
            { get })
    ];
}

Regex usernamePattern = regex("^[\\w]+$");
Boolean checkUsername(String? username) {
    if (exists username) {
        return usernamePattern.test(username);
    }
    return false;
}
