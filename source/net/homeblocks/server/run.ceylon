import ceylon.net.http.server {
    Server,
    newServer,
    Endpoint,
    equals
}
import ceylon.net.http {
    get
}
import com.codahale.metrics {
    MetricRegistry,
    Counter,
    Meter
}
import org.hawkular.client.dropwizard {
    HawkularReporter
}
import java.util.concurrent {
    TimeUnit
}
import ceylon.io {
    SocketAddress
}
import net.homeblocks.server.endpoints { allEndpoints }

shared void run() {
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

    Server server = newServer {
        endpoints = allEndpoints();
//            Endpoint {
//                path = equals("/");
//                acceptMethod = { get };
//                service = ((req, res) {
//                    yaha.inc();
//                    all.inc();
//                    yahaMtr.mark();
//                    allMtr.mark();
//                    res.writeString("<a href='youhou'>Youhou!!</a>");
//                });
//            },
//            Endpoint {
//                path = equals("/youhou");
//                acceptMethod = { get };
//                service = ((req, res) {
//                    youhou.inc();
//                    all.inc();
//                    youhouMtr.mark();
//                    allMtr.mark();
//                    res.writeString("<a href='..'>Yaha!!</a>");
//                });
//            }
    };
    server.start(SocketAddress("127.0.0.1", 8081));
}
