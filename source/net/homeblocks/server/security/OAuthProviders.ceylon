import ceylon.collection {
    ArrayList
}
import ceylon.file {
    File,
    Path,
    parsePath
}
import ceylon.json {
    Object
}

import io.vertx.ceylon.core {
    Vertx
}

import net.homeblocks.server.util {
    files
}

shared class OAuthProviders(String strRoot, Vertx vertx) {

    Path fsRoot = parsePath(strRoot);
    Object? readSecret(String name) {
        if (is File file = fsRoot.childPath("secrets").childPath(name).resource) {
            if (is Object json = files.readJson(file)) {
                return json;
            }
            print("Invalid secret file for " + name);
            return null;
        }
        print("Secret not found for " + name);
        return null;
    }

    value tmpProviders = ArrayList<OAuthProvider>();
    if (exists secret = readSecret("github")) {
        tmpProviders.add(GithubOAuth(vertx, secret));
    }

    shared [OAuthProvider*] providers = tmpProviders.sequence();
}
