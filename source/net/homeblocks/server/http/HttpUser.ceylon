import io.vertx.ceylon.auth.oauth2 {
    AccessToken
}
import net.homeblocks.data.model {
    UserInfo
}

class HttpUser(shared AccessToken token, shared UserInfo userInfo, shared String stateToken) {}
