import ceylon.json {
    Object
}
import ceylon.promise {
    Promise,
    Deferred
}

import io.vertx.ceylon.auth.oauth2 {
    OAuth2ClientOptions,
    oAuth2Auth,
    AccessToken
}
import io.vertx.ceylon.core {
    Vertx
}

import net.homeblocks.server.util {
    promises
}

class YahooOAuth(Vertx vertx, Object secret) extends OAuthProvider(
    "yah",
    "Yahoo!",
    oAuth2Auth.create(vertx, "AUTH_CODE", OAuth2ClientOptions {
        clientID = secret.getString("clientID");
        clientSecret = secret.getString("secret");
        site = "https://api.login.yahoo.com/oauth2";
        tokenPath = "/get_token";
        authorizationPath = "/request_auth";
        headers = Object {
                "User-Agent" -> "jotak-homeblocks"
        };
    })) {

    String redirectUri = secret.getString("redirectUri");

    shared actual String authorizeUrl(String state) {
        return oAuth2.authorizeURL(Object {
                "state" -> state,
                "redirect_uri" -> redirectUri
        });
    }

    shared actual Promise<AccessToken> getToken(String authCode) {
        value def = Deferred<AccessToken>();
        oAuth2.getToken(Object {
                "code" -> authCode,
                "redirect_uri" -> "oob"
            }, (AccessToken|Throwable res) {
                if (is Throwable res) {
                    promises.reject(def, res);
                } else {
                    def.fulfill(res);
                }
            });
        return def.promise;
    }

    shared actual Promise<String> getUID(AccessToken token) {
        value def = Deferred<String>();
        if (exists guid = token.principal().getStringOrNull("xoauth_yahoo_guid")) {
            def.fulfill(guid);
        } else {
            promises.reject(def, "Missing xoauth_yahoo_guid");
        }
        return def.promise;
    }
}
