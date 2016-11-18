//import ceylon.json {
//    Object
//}
//
//shared class PrivateProfile(String refUser, String name, shared String password, Page page) extends Profile(refUser,
//        name, page) {
//    actual shared Object json() {
//        return Object {
//                "refUser" -> refUser,
//                "name" -> name,
//                "password" -> password,
//                "page" -> page.json()
//        };
//    }
//
//    shared Profile public() {
//        return Profile(refUser, name, page);
//    }
//}
//shared object privateProfiles extends PrivateProfiles() {}
