import ceylon.file {
    Path,
    Nil,
    File,
    Directory
}
import ceylon.json {
    Object
}
import ceylon.promise {
    Promise,
    Deferred
}

import net.homeblocks.data.model {
    Page,
    jsonPage,
    emptyPage
}
import net.homeblocks.server.util {
    promises,
    files
}

shared class ProfilesService(UsersService usersService) {

    Path userPath(Integer userID) => usersService.usersPath.childPath(userID.string);
    Path profilePath(Integer userID, String profile) => userPath(userID).childPath(profile + ".json");

    shared Promise<String[]> list(Integer userID) {
        value deferred = Deferred<String[]>();
        if (is Directory dir = userPath(userID).resource) {
            deferred.fulfill(
                [for (path in dir.childPaths()) if (is File f = path.resource) f.name.substring(0, f.name.size-5)]);
        } else {
            deferred.fulfill([]);
        }
        return deferred.promise;
    }

    shared Promise<Page> load(Integer userID, String profile) {
        value deferred = Deferred<Page>();
        if (is File file = profilePath(userID, profile).resource) {
            if (is Object json = files.readJson(file)) {
                deferred.fulfill(jsonPage.deserialize(json));
            } else {
                promises.reject(deferred, "Can't load profile: json root should be an object");
            }
        } else {
            promises.reject(deferred, "Can't load profile: file not found");
        }
        return deferred.promise;
    }

    shared Promise<Page> createEmpty(Integer userID, String profile) {
        value deferred = Deferred<Page>();
        if (is Nil res = userPath(userID).resource) {
            res.createDirectory();
        }
        value resource = profilePath(userID, profile).resource;
        if (is Nil resource) {
            File file = resource.createFile();
            try (writer = file.Overwriter()) {
                Page p = emptyPage();
                writer.write(p.json().string);
                deferred.fulfill(p);
            }
        } else {
            promises.reject(deferred, "Trying to create '" + resource.string + "', but it already exists");
        }
        return deferred.promise;
    }

    shared Promise<Null> update(Integer userID, String name, Page page) {
        value deferred = Deferred<Null>();
        if (is File file = profilePath(userID, name).resource) {
            try (writer = file.Overwriter()) {
                writer.write(page.json().string);
                deferred.fulfill(null);
            }
        } else {
            promises.reject(deferred, "Could not retrieve the profile to update");
        }
        return deferred.promise;
    }
}
