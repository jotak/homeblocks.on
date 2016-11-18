"HTTP server module for homeblocks.net / `net.homeblocks.server`."
native ("jvm")
module net.homeblocks.server "1.0.0" {
    import io.vertx.ceylon.core "3.3.3";
    import io.vertx.ceylon.web "3.3.3";
    import io.vertx.ceylon.auth.common "3.3.3";
    shared import io.vertx.ceylon.auth.oauth2 "3.3.3";
    import ceylon.buffer "1.2.2";
    shared import ceylon.file "1.2.2";
    import ceylon.regex "1.2.2";
    shared import ceylon.promise "1.2.2";
    import ceylon.interop.java "1.2.2";
    shared import net.homeblocks.data "1.0.0";
    //import maven:"io.dropwizard.metrics:metrics-core" "3.1.2";
    //import maven:"org.hawkular.client:hawkular-dropwizard-reporter" "0.1.0-SNAPSHOT";
}
