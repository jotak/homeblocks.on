import io.vertx.ceylon.core {
    vertx_=vertx
}
import io.vertx.ceylon.core.http {
    HttpServerResponse
}
import io.vertx.ceylon.web {
    router_=router
}

import net.homeblocks.server.services {
    ProfilesService
}
import io.vertx.ceylon.web.handler {
    staticHandler
}

shared void startServer() {
    //    MetricRegistry metrics = MetricRegistry();
    //    HawkularReporter reporter = HawkularReporter.builder(metrics, "homeblocks").build();
    //    reporter.start(1, TimeUnit.\iSECONDS);
    //
    //    Counter all = metrics.counter("all");
    //    Counter youhou = metrics.counter("youhou");
    //    Counter yaha = metrics.counter("yaha");
    //    Meter allMtr = metrics.meter("all-mtr");
    //    Meter youhouMtr = metrics.meter("youhou-mtr");
    //    Meter yahaMtr = metrics.meter("yaha-mtr");

    value vertx = vertx_.vertx();
    value server = vertx.createHttpServer();
    value router = router_.router(vertx);

    value endpoints = Endpoints("", vertx);

    endpoints.createEndpoints(router);
    //        endpoints = allEndpoints(profilesService);
//        //            Endpoint {
//        //                path = equals("/");
//        //                acceptMethod = { get };
//        //                service = ((req, res) {
//        //                    yaha.inc();
//        //                    all.inc();
//        //                    yahaMtr.mark();
//        //                    allMtr.mark();
//        //                    res.writeString("<a href='youhou'>Youhou!!</a>");
//        //                });
//        //            },
//        //            Endpoint {
//        //                path = equals("/youhou");
//        //                acceptMethod = { get };
//        //                service = ((req, res) {
//        //                    youhou.inc();
//        //                    all.inc();
//        //                    youhouMtr.mark();
//        //                    allMtr.mark();
//        //                    res.writeString("<a href='..'>Yaha!!</a>");
//        //                });
//        //            }
//    };
    server.requestHandler(router.accept).listen(8081, "127.0.0.1");
}
