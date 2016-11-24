import ceylon.collection {
    HashMap
}
import ceylon.file {
    parsePath,
    Path,
    Nil,
    File
}
import ceylon.json {
    Array,
    Object
}
import ceylon.promise {
    Promise,
    Deferred
}

import java.util.concurrent.atomic {
    AtomicInteger
}

import net.homeblocks.data.model {
    UserInfo,
    jsonUserInfo
}
import net.homeblocks.server.util {
    promises,
    files
}

shared class UsersService(String strRoot) {

    Path fsRoot = parsePath(strRoot);
    shared Path usersPath => fsRoot.childPath("users");
    Path indexPath => usersPath.childPath("_index.json");

    if (is Nil res = usersPath.resource) {
        res.createDirectory();
        print("'users' folder has been created.");
    }

    value providerKey2 = (String p, String id) => p + "-" + id;
    value providerKey = (UserInfo userInfo) => providerKey2(userInfo.prov, userInfo.provUId);

    value init = () {
        value usersIndex = HashMap<Integer,UserInfo>();
        value aliasUsersIndex = HashMap<String,UserInfo>();
        value providerUsersIndex = HashMap<String,UserInfo>();

        // Read users index
        value indexFile = indexPath.resource;
        if (is Nil indexFile) {
            File file = indexFile.createFile();
            try (writer = file.Overwriter()) {
                writer.write("[]");
            }
        } else if (is File indexFile) {
            if (is Array users = files.readJson(indexFile)) {
                for (userJson in users) {
                    switch (userJson)
                    case (is Object) {
                        value userInfo = jsonUserInfo.deserialize(userJson);
                        value provKey = providerKey(userInfo);
                        if (!usersIndex.keys.contains(userInfo.intIdx),
                                !aliasUsersIndex.keys.contains(userInfo.name),
                                !providerUsersIndex.keys.contains(provKey)) {
                            usersIndex.put(userInfo.intIdx, userInfo);
                            aliasUsersIndex.put(userInfo.name, userInfo);
                            providerUsersIndex.put(provKey, userInfo);
                        } else {
                            print("Cannot load index for user " + userInfo.intIdx.string + " (" + userInfo.name
                            + "), index or alias already used");
                        }
                    }
                    case (is Null) {
                        print("Users index corrupted, object expected but got null");
                    }
                    else {
                        print("Users index corrupted, object expected but got: " + userJson.string);
                    }
                }
            }
        }
        return [usersIndex, aliasUsersIndex, providerUsersIndex];
    };
    value [usersIndex, aliasUsersIndex, providerUsersIndex] = init();
    AtomicInteger maxIdx = AtomicInteger(usersIndex.keys.fold(0)(largest));

    shared Boolean isAliasAvailable(String userAlias) {
        if (userAlias.startsWith("@user")) {
            // Reserved for internal alias generation
            return false;
        }
        return !aliasUsersIndex.keys.contains(userAlias);
    }

    Promise<Null> writeUsersIndex(File file) {
        value deferred = Deferred<Null>();
        try (writer = file.Overwriter()) {
            Array all = Array(usersIndex.items.map((UserInfo element) => element.json()).sequence());
            writer.write(all.string);
            deferred.fulfill(null);
        }
        return deferred.promise;
    }

    Promise<Null> updateUsersIndex(UserInfo userInfo) {
        if (exists old = usersIndex.get(userInfo.intIdx)) {
            aliasUsersIndex.remove(old.name);
            providerUsersIndex.remove(providerKey(old));
        }
        usersIndex.put(userInfo.intIdx, userInfo);
        aliasUsersIndex.put(userInfo.name, userInfo);
        providerUsersIndex.put(providerKey(userInfo), userInfo);
        value indexFile = indexPath.resource;
        if (is Nil indexFile) {
            return writeUsersIndex(indexFile.createFile());
        } else if (is File indexFile) {
            return writeUsersIndex(indexFile);
        }
        return promises.error("Cannot open index file for writing");
    }

    shared Promise<UserInfo> findOrCreate(String provider, String provUID) {
        if (exists userInfo = providerUsersIndex.get(providerKey2(provider, provUID))) {
            return promises.immediate(userInfo);
        }
        value id = maxIdx.addAndGet(1);
        value userInfo = UserInfo(provider, provUID, id, "@user" + id.string);
        return updateUsersIndex(userInfo).map((nil) => userInfo);
    }

    shared Promise<UserInfo> saveAlias(Integer id, String userAlias) {
        if (exists oldUser = usersIndex.get(id)) {
            if (isAliasAvailable(userAlias)) {
                value newUser = UserInfo(oldUser.prov, oldUser.provUId, id, userAlias);
                return updateUsersIndex (newUser).map((nil) => newUser);
            }
            return promises.immediate(oldUser);
        }
        return promises.error("Could not find existing user");
    }

    shared UserInfo? findById(Integer id) {
        return usersIndex.get(id);
    }

    shared UserInfo? findByAlias(String name) {
        return aliasUsersIndex.get(name);
    }
}
