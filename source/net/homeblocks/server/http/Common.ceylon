import io.vertx.ceylon.core.http {
    HttpServerRequest
}
import ceylon.json {
    Object,
    parse
}
import ceylon.promise {
    Promise,
    Deferred
}


Promise<Object> parseBodyObject(HttpServerRequest req) {
    value deferred = Deferred<Object>();
    req.bodyHandler((buffer) {
        String content = buffer.getString(0, buffer.length());
        if (content.empty) {
            deferred.fulfill(Object());
            return;
        }
        switch (val = parse(content))
        case (is Object) {
            deferred.fulfill(val);
        }
        else {
            deferred.reject(Exception("Parsing json: Object expected"));
        }
    });
    return deferred.promise;
}
