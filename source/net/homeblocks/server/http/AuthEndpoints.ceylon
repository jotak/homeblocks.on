import ceylon.collection {
    HashMap
}
import ceylon.json {
    Object
}

import io.vertx.ceylon.auth.oauth2 {
    AccessToken
}
import io.vertx.ceylon.web {
    Router,
    RoutingContext
}

import java.util {
    UUID
}

import net.homeblocks.data.model {
    loginProfile,
    UserInfo
}
import net.homeblocks.server.security {
    OAuthProviders
}
import net.homeblocks.server.services {
    UsersService
}

HttpUser? getLoggedUser(RoutingContext ctx) {
    return ctx.session()?.get("user");
}

void updateLoggedUser(RoutingContext ctx, UserInfo newUser) {
    if (exists logged = getLoggedUser(ctx)) {
        if (newUser.intIdx == logged.userInfo.intIdx) {
            ctx.session()?.put("user", HttpUser(logged.token, newUser, logged.stateToken));
        }
    }
}

void registerAuthEndpoints(UsersService usersService, OAuthProviders oauthProviders, Router router) {

    value tmpStates = HashMap<String, Object>();
    Object? popState(String state) {
        if (exists obj = tmpStates.get(state)) {
            tmpStates.remove(state);
            return obj;
        }
        return null;
    }

    router.post("/api/login").handler((RoutingContext ctx) {
        parseBodyObject(ctx.request()).completed {
                    (json) {
                        String token = UUID.randomUUID().string;
                        tmpStates.put(token, json);
                        [String, String][] loginPageInfo = oauthProviders.providers.map((prov) {
                            value authorizationUrl = prov.oAuth2.authorizeURL(Object { "state" -> token });
                            return [prov.displayName, authorizationUrl];
                        }).sequence();
                        ctx.response().end(loginProfile(loginPageInfo).string);
                    };
                    (err) => error(ctx, 500, err.message);
        };
    });

    router.get("/api/logout").handler((RoutingContext ctx) {
        if (exists user = getLoggedUser(ctx)) {
            // user.token.logout((Throwable? a) => print(a));
            ctx.session()?.remove("user");
        }
        ctx.response().end();
    });

    router.get("/api/logged").handler((RoutingContext ctx) {
        if (exists logged = getLoggedUser(ctx)) {
            if (exists state = popState(logged.stateToken)) {
                value json = Object {
                    "logged" -> logged.userInfo.name,
                    *state
                };
                ctx.response().end(json.string);
            } else {
                ctx.response().end(Object {
                    "logged" -> logged.userInfo.name
                }.string);
            }
        } else {
            ctx.response().end();
        }
    });

    oauthProviders.providers.each((prov) {
        router.get("/oauthclbk-" + prov.providerName).handler((RoutingContext ctx) {
            if (exists state = ctx.request().getParam("state"),
                    exists code = ctx.request().getParam("code")) {
                if (!tmpStates.keys.contains(state)) {
                    error(ctx, 403, "Invalid state");
                } else {
                    prov.oAuth2.getToken(Object { "code" -> code },
                        (AccessToken|Throwable res) {
                            if (is Throwable res) {
                                res.printStackTrace();
                                error(ctx, 403, res.string);
                            } else {
//                                User user = res;
//                                ctx.setUser(user);
                                prov.getUID(res)
                                    .flatMap((username) => usersService.findOrCreate(prov.providerName, username))
                                    .completed {
                                            (userInfo) {
                                                ctx.session()?.put("user", HttpUser(res, userInfo, state));
                                                ctx.reroute("/reroute.html");
                                            };
                                            (err) => error(ctx, 403, err.string);
                                };
                            }
                        });
                }
            } else {
                error(ctx, 403, "Authentication failure");
            }
        });
    });
}