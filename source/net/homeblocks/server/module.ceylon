"HTTP server module for homeblocks.net / `net.homeblocks.server`."
native ("jvm")
module net.homeblocks.server "1.0.0" {
    import ceylon.net "1.2.2";
    //shared import maven:"org.apache.httpcomponents:httpcore" "4.4.1";
    import ceylon.file "1.2.2";
    import ceylon.regex "1.2.2";
    import ceylon.interop.java "1.2.2";
    shared import net.homeblocks.data "1.0.0";
    //import maven:"io.dropwizard.metrics:metrics-core" "3.1.2";
    //import maven:"org.hawkular.client:hawkular-dropwizard-reporter" "0.1.0-SNAPSHOT";
}
