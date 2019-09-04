import io.vertx.ceylon.core {
    vertx_=vertx
}
import io.vertx.ceylon.core.http {
    HttpServerOptions
}
import io.vertx.ceylon.core.net {
    PemKeyCertOptions
}
import io.vertx.ceylon.web {
    router_=router
}

shared Integer appPort = 443;

shared void startServer() {

    print("Starting server...");
    value vertx = vertx_.vertx();

    value options = HttpServerOptions {
        ssl = true;
        pemKeyCertOptions = PemKeyCertOptions {
            keyPath = "/etc/letsencrypt/live/www.homeblocks.net/privkey.pem";
            certPath = "/etc/letsencrypt/live/www.homeblocks.net/fullchain.pem";
        };
    };

    value server = vertx.createHttpServer(options);

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
