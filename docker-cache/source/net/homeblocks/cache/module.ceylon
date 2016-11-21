"Fake module for building cache"
native ("jvm")
module net.homeblocks.cache "1.0.0" {
    import io.vertx.ceylon.core "3.3.3";
    import io.vertx.ceylon.web "3.3.3";
    import io.vertx.ceylon.auth.common "3.3.3";
    shared import io.vertx.ceylon.auth.oauth2 "3.3.3";
    import ceylon.buffer "1.2.2";
    shared import ceylon.file "1.2.2";
    import ceylon.regex "1.2.2";
    shared import ceylon.promise "1.2.2";
    import ceylon.interop.java "1.2.2";
    shared import ceylon.json "1.2.2";
}
