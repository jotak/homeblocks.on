import ceylon.net.http {
    get,
    post
}
import ceylon.net.http.server {
    Request,
    AsynchronousEndpoint,
    startsWith,
    equals,
    Response,
    template,
    Endpoint,
    HttpEndpoint
}
import ceylon.net.http.server.endpoints {
    serveStaticFile
}

import net.homeblocks.server.model {
    PublicProfile,
    sandboxProfile
}

shared HttpEndpoint[] allEndpoints() {

    function mapper(Request req)
            => req.path == "/" then "/index.html" else req.path;

    return [
        AsynchronousEndpoint(
            equals("/api/auth"),
            ((req, res, void complete()) {
                print("/api/auth");
                complete();
            }),
            { post }),
        Endpoint(
            template("/api/profile/{username}"),
            (req, res) {
                getProfile(req.pathParameter("username"), res);
            },
            { get }),
        AsynchronousEndpoint(
            startsWith("/"),
            serveStaticFile("public", mapper),
            { get })
    ];
}

void getProfile(String? username, Response res) {
    PublicProfile profile = sandboxProfile();
    print(profile.json().string);
    res.writeString(profile.json().string);
}
