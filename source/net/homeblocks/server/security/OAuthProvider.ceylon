import io.vertx.ceylon.auth.oauth2 {
    OAuth2Auth,
    AccessToken
}
import ceylon.promise {
    Promise
}


shared abstract class OAuthProvider(shared String providerName, shared String displayName, shared OAuth2Auth oAuth2) {
    shared formal Promise<String> getUID(AccessToken token);
}
