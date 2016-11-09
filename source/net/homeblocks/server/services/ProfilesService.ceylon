import ceylon.file {
    parsePath,
    Path,
    Nil,
    File
}
import ceylon.json {
    Object,
    parse
}

import net.homeblocks.data.model {
    PrivateProfile,
    Profile,
    privateProfiles
}
import net.homeblocks.server.security {
    Authentication
}

shared class ProfilesService(String strRoot) {

    Authentication auth = Authentication();
    Path fsRoot = parsePath(strRoot);
    Path profilesPath() => fsRoot.childPath("profiles");
    Path userPath(String username) => profilesPath().childPath(username + ".json");

    if (is Nil res = profilesPath().resource) {
        res.createDirectory();
        print("'profiles' folder has been created.");
    }

    shared Profile? load(String username) {
        return loadPrivate(username)?.public();
    }

    PrivateProfile? loadPrivate(String username) {
        if (is File file = userPath(username).resource) {
            try (reader = file.Reader()) {
                variable String strProfile = "";
                while (exists line = reader.readLine()) {
                    strProfile += "\n" + line;
                }
                if (is Object json = parse(strProfile)) {
                    return privateProfiles.deserialize(json);
                }
                return null;
            }
        }
        return null;
    }

    shared Boolean createEmpty(String username, String password) {
        value resource = userPath(username).resource;
        if (is Nil resource) {
            File file = resource.createFile();
            String hash = auth.getHash(password);
            PrivateProfile p = privateProfiles.empty(username, hash);
            try (writer = file.Overwriter()) {
                writer.write(p.json().string);
                return true;
            }
        } else {
            print("Trying to create '" + resource.string + "', but it already exists.");
        }
        return false;
    }

    shared Boolean update(Profile profile) {
        if (exists hash = loadPrivate(profile.getUsername())?.getPassword()) {
            PrivateProfile pp = privateProfiles.fromPublic(profile, hash);
            if (is File file = userPath(profile.getUsername()).resource) {
                try (writer = file.Overwriter()) {
                    writer.write(pp.json().string);
                    return true;
                }
            }
        }
        return false;
    }

    shared Boolean matchPassword(String username, String password) {
        if (exists storedHash = loadPrivate(username)?.getPassword()) {
            return auth.authenticate(password, storedHash);
        }
        return false;
    }
}
