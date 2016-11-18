import ceylon.collection {
    LinkedList,
    ArrayList
}
import ceylon.file {
    File,
    Path,
    parsePath
}

import io.vertx.ceylon.core {
    Vertx
}

shared class OAuthProviders(String strRoot, Vertx vertx) {

    Path fsRoot = parsePath(strRoot);
    String? readSecret(String name) {
        if (is File file = fsRoot.childPath("secrets").childPath(name).resource) {
            try (reader = file.Reader()) {
                value content = LinkedList<String>();
                while (exists line = reader.readLine()) {
                    content.add(line);
                }
                return "\n".join(content);
            }
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
