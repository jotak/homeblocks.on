//import ceylon.buffer.base {
//    base64StringUrl
//}
//import ceylon.interop.java {
//    createJavaByteArray,
//    javaCharArray
//}
//import ceylon.regex {
//    Regex,
//    regex,
//    MatchResult
//}
//
//import java.lang {
//    ByteArray,
//    CharArray,
//    System,
//    Character
//}
//import java.security {
//    SecureRandom
//}
//import java.security.spec {
//    KeySpec
//}
//import java.util {
//    Arrays
//}
//
//import javax.crypto {
//    SecretKeyFactory
//}
//import javax.crypto.spec {
//    PBEKeySpec
//}
//import ceylon.promise {
//    Promise,
//    Deferred
//}
//
//shared class Authentication() {
//    Integer keySize = 128;
//    Regex tokenRegex = regex("\\$27\\$(.{43})");
//    SecureRandom random = SecureRandom();
//
//    shared String getHash(String password) {
//        ByteArray salt = ByteArray(keySize / 8);
//        random.nextBytes(salt);
//        ByteArray dk = pbkdf2(convertString(password), salt);
//        ByteArray hash = ByteArray(salt.size + dk.size);
//        System.arraycopy(salt, 0, hash, 0, salt.size);
//        System.arraycopy(dk, 0, hash, salt.size, dk.size);
//        return "$27$" + base64StringUrl.encode(hash.iterable);
//    }
//
//    shared Promise<Boolean> authenticate(String password, String token) {
//        value deferred = Deferred<Boolean>();
//        MatchResult? m = tokenRegex.find(token);
//        if (exists m) {
//            List<Byte> listHash = base64StringUrl.decode(token.sublistFrom(4));
//            ByteArray hash = createJavaByteArray(listHash);
//            ByteArray salt = Arrays.copyOfRange(hash, 0, keySize / 8);
//            ByteArray check = pbkdf2(convertString(password), salt);
//            for (idx in 0..check.size-1) {
//                if (hash[salt.size + idx] != check[idx]) {
//                    deferred.fulfill(false);
//                    return deferred.promise;
//                }
//            }
//            deferred.fulfill(true);
//        } else {
//            deferred.reject(Exception("Invalid token"));
//        }
//        return deferred.promise;
//    }
//
//    ByteArray pbkdf2(CharArray password, ByteArray salt) {
//        KeySpec spec = PBEKeySpec(password, salt, 65536, keySize);
//        return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
//            .generateSecret(spec)
//            .encoded;
//    }
//
//    CharArray convertString(String source)
//            => javaCharArray(Array { for (i in source) Character(i) });
//}
