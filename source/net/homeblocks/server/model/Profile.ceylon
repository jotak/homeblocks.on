shared class Profile(shared String username, String password, shared Page page) {}

shared Profile emptyProfile(String username, String password) {
    return Profile(username, password, Page([MainBlock(0, 0, null)]));
}
