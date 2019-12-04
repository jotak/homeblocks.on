import io.vertx.ceylon.core {
    vertx_=vertx
}
import io.vertx.ceylon.core.http {
    HttpServerOptions,
    HttpServerRequest
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
                print("HTTPS server failed to start!");
                res.printStackTrace();
            } else {
                print("HTTPS server started, listening on ``appPort``");
            }
    });

    // Keep listening on 80, and redirect
    value server80 = vertx.createHttpServer();
    server80.requestHandler((HttpServerRequest req) {
        req.response()
            .setStatusCode(301)
            .putHeader("Location", req.absoluteURI().replace("http", "https"))
            .end();
    }).listen(80, (Anything|Throwable res) {
        switch (res)
        case (is Throwable) {
            print("HTTP server failed to start!");
            res.printStackTrace();
        } else {
            print("HTTP server started, redirecting to HTTPS");
        }
    });
}
