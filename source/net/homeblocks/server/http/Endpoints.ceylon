import io.vertx.ceylon.core {
    Vertx
}
import io.vertx.ceylon.web {
    Router,
    RoutingContext
}
import io.vertx.ceylon.web.handler {
    staticHandler,
    StaticHandler,
    cookieHandler,
    sessionHandler
}
import io.vertx.ceylon.web.sstore {
    localSessionStore
}

import net.homeblocks.data.model {
    userProfiles,
    jsonPage,
    UserInfo,
    pageProfile,
    notFound404Profile
}
import net.homeblocks.server.security {
    OAuthProviders
}
import net.homeblocks.server.services {
    ProfilesService,
    UsersService
}

void error(RoutingContext ctx, Integer errorCode, String? msg) {
    ctx.response().setStatusCode(403);
    if (exists msg) {
        ctx.response().end(msg);
    } else {
        ctx.response().end();
    }
}

class Endpoints(String fsRoot, Vertx vertx) {
    value usersService = UsersService(fsRoot);
    value profilesService = ProfilesService(usersService);
    StaticHandler stcHandler = staticHandler.create("public");
    value store = localSessionStore.create(vertx);

    Boolean isValidLoggedUser(RoutingContext ctx, UserInfo user) {
        if (exists logged = getLoggedUser(ctx)) {
            if (user.intIdx == logged.userInfo.intIdx) {
                return !logged.token.expired();
            }
        }
        return false;
    }

    shared void createEndpoints(Router router) {

        router.route().handler((ctx) => cookieHandler.create().handle(ctx));
        router.route().handler((ctx) => sessionHandler.create(store).handle(ctx));

        registerAuthEndpoints(usersService, OAuthProviders(fsRoot, vertx), router);

        // API
        router.get("/api/user/:user").handler((RoutingContext ctx) {
            value res = ctx.response();
            if (exists user = ctx.request().getParam("user"),
                    exists userInfo = usersService.findByAlias(user)) {
                value logged = getLoggedUser(ctx)?.userInfo?.name;
                profilesService.list(userInfo.intIdx).completed {
                        (profiles) => res.end(userProfiles(user, profiles, logged).string);
                        (error) => res.end(notFound404Profile().string);
                };
            } else {
                res.end(notFound404Profile().string);
            }
        });
        router.get("/api/user/:user/profile/:name").handler((RoutingContext ctx) {
            value res = ctx.response();
            if (exists user = ctx.request().getParam("user"),
                    exists profile = ctx.request().getParam("name"),
                    exists userInfo = usersService.findByAlias(user)) {
                value logged = getLoggedUser(ctx)?.userInfo?.name;
                profilesService.load(userInfo.intIdx, profile).completed {
                            (page) => res.end(pageProfile(user, profile, page, logged).string);
                            (error) => res.end(notFound404Profile().string);
                };
            } else {
                res.end(notFound404Profile().string);
            }
        });
        // CREATE
        router.put("/api/user/:user/profile/:name").handler((RoutingContext ctx) {
            value res = ctx.response();
            if (exists user = ctx.request().getParam("user"),
                    exists profile = ctx.request().getParam("name"),
                    exists userInfo = usersService.findByAlias(user)) {
                // Is still logged?
                if (isValidLoggedUser(ctx, userInfo)) {
                    value logged = getLoggedUser(ctx)?.userInfo?.name;
                    profilesService.createEmpty(userInfo.intIdx, profile).completed {
                                (page) => res.end(pageProfile(user, profile, page, logged).string);
                                (err) => error(ctx, 500, err.message);
                    };
                } else {
                    error(ctx, 403, "You must log in");
                }
            } else {
                res.end(notFound404Profile().string);
            }
        });
        // UPDATE
        router.post("/api/user/:user/profile/:name").handler((RoutingContext ctx) {
            value res = ctx.response();
            if (exists user = ctx.request().getParam("user"),
                    exists name = ctx.request().getParam("name"),
                    exists userInfo = usersService.findByAlias(user)) {
                // Is still logged?
                if (isValidLoggedUser(ctx, userInfo)) {
                    parseBodyObject(ctx.request()).map((json) {
                        value page = jsonPage.deserialize(json);
                        return profilesService.update(userInfo.intIdx, name, page);
                    }).completed {
                                (nil) => res.end();
                                (err) => error(ctx, 500, err.message);
                    };
                } else {
                    error(ctx, 403, "You must log in");
                }
            } else {
                error(ctx, 404, "User not found");
            }
        });
        // SET ALIAS
        router.put("/api/alias/:alias").handler((RoutingContext ctx) {
            value res = ctx.response();
            if (exists aliasName = ctx.request().getParam("alias"),
                    exists userInfo = getLoggedUser(ctx)?.userInfo) {
                // Is still logged?
                if (isValidLoggedUser(ctx, userInfo)) {
                    usersService.saveAlias(userInfo.intIdx, aliasName).completed {
                                (newUser) {
                                    // Update logged user
                                    updateLoggedUser(ctx, newUser);
                                    res.end((newUser.name == aliasName).string);
                                };
                                (err) => error(ctx, 500, err.message);
                    };
                } else {
                    error(ctx, 403, "You must log in");
                }
            } else {
                res.end(notFound404Profile().string);
            }
        });

        // Serve static
        router.route("/*").handler((ctx) {
            stcHandler.handle(ctx);
        });
    }
}

//HttpEndpoint[] allEndpoints(ProfilesService profilesService) {
//
//    function mapper(Request req)
//            => req.path == "/" then "/index.html" else req.path;
//
//    void writeAsyncStatus(Response res, String content, Integer? status, void complete()) {
//        if (exists status) {
//            res.responseStatus = status;
//        }
//        res.writeString(content);
//        complete();
//    }
//    void writeAsync(Response res, String content, void complete()) => writeAsyncStatus(res, content, null, complete);
//
//    return [
//        AsynchronousEndpoint(
//            equals("/api/auth"),
//            ((req, res, void complete()) {
//                switch (json = parse(req.read()))
//                case (is Object) {
//                    if (exists username = json.getStringOrNull("username"),
//                            exists password = json.getStringOrNull("password")) {
//                        profilesService.matchPassword(username, password).completed {
//                                (Boolean match) {
//                                    if (match) {
//                                        writeAsync(res, generateToken(username), complete);
//                                    } else {
//                                        writeAsyncStatus(res, "Wrong username or password", 401, complete);
//                                    }
//                                };
//                                (Throwable err) {
//                                    writeAsyncStatus(res, "Authentication failure: " + err.message, 401, complete);
//                                };
//                        };
//                    } else {
//                        writeAsyncStatus(res, "Missing username and/or password in json", 400, complete);
//                    }
//                } else {
//                    writeAsyncStatus(res, "Bad json (not an object)", 400, complete);
//                }
//            }),
//            { post }),
//        AsynchronousEndpoint(
//            equals("/api/profile"),
//            (req, res, void complete()) {
//                if (req.method == get) {
//                    if (exists username = req.queryParameter("username")) {
//                        profilesService.load(username).completed {
//                                    (profile) => writeAsync(res, profile.json().string, complete);
//                                    (error) => writeAsync(res, sandboxProfile().json().string, complete);
//                        };
//                    } else {
//                        writeAsync(res, sandboxProfile().json().string, complete);
//                    }
//                } else {
//                    switch (json = parse(req.read()))
//                    case (is Object) {
//                        if (req.method == post) {
//                            // Update
//                            if (exists token = json.getStringOrNull("token")) {
//                                Profile profile = jsonProfile.deserialize(json);
//                                if (checkUsername(profile.username)) {
//                                    if (exists storedToken = tokens.get(profile.username),
//                                        token == storedToken) {
//                                        profilesService.update(profile).completed {
//                                                    (_) {
//                                                        // Successful update
//                                                        writeAsync(res, "", complete);
//                                                    };
//                                                    (Throwable err) {
//                                                        writeAsyncStatus(res, err.message, 500, complete);
//                                                    };
//                                        };
//                                    } else {
//                                        writeAsyncStatus(res, "Token mismatch", 401, complete);
//                                    }
//                                } else {
//                                    writeAsyncStatus(res, "Invalid username", 400, complete);
//                                }
//                            } else {
//                                writeAsyncStatus(res, "You must login first", 403, complete);
//                            }
//                        } else {
//                            // Create
//                            PrivateProfile profile = privateProfiles.deserialize(json);
//                            if (checkUsername(profile.username)) {
//                                profilesService.createEmpty(profile.username, profile.password)
//                                    .completed {
//                                            (Profile p) {
//                                                // Profile created => send the token
//                                                String s = generateToken(profile.username);
//                                                res.writeString(s);
//                                                complete();
////                                                writeAsync(res, generateToken(profile.username), complete);
//                                            };
//                                            (Throwable err) {
//                                                writeAsyncStatus(res, err.message, 500, complete);
//                                            };
//                                };
//                            } else {
//                                writeAsyncStatus(res, "Invalid username", 400, complete);
//                            }
//                        }
//                    } else {
//                        writeAsyncStatus(res, "Bad json (not an object)", 400, complete);
//                    }
//                }
//            },
//            { get, post, put }),
//        AsynchronousEndpoint(
//            startsWith("/"),
//            serveStaticFile("public", mapper),
//            { get })
//    ];
//}

