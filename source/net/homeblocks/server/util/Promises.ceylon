import ceylon.promise {
    Deferred,
    Promise
}


shared abstract class Promises() of promises {
    shared void reject(Deferred<out Anything> def, String|Throwable error) {
        switch (error)
        case (is String) {
            print(error);
            def.reject(Exception(error));
        }
        case (is Throwable) {
            print(error.message);
            def.reject(error);
        }
    }

    shared Promise<T> immediate<T>(T val) {
        value def = Deferred<T>();
        def.fulfill(val);
        return def.promise;
    }

    shared Promise<T> error<T>(String|Throwable err) {
        value def = Deferred<T>();
        reject(def, err);
        return def.promise;
    }

}
shared object promises extends Promises() {}
