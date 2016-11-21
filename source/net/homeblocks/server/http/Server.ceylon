import io.vertx.ceylon.core {
    vertx_=vertx
}
import io.vertx.ceylon.web {
    router_=router
}

shared Integer appPort = 8081;

shared void startServer() {

    print("Starting server...");
    value vertx = vertx_.vertx();
    value server = vertx.createHttpServer();
    value router = router_.router(vertx);

    value endpoints = Endpoints("", vertx);

    endpoints.createEndpoints(router);
    server.requestHandler(router.accept)
        .listen(appPort, (Anything|Throwable res) {
            switch (res)
            case (is Throwable) {
                print("Server failed to start!");
                res.printStackTrace();
            } else {
                print("Server started, listening on ``appPort``");
            }
    });
}
