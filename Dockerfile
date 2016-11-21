FROM jotak/homeblocks-cache

ADD source /app/source
ADD public /app/public

RUN ceylon compile

EXPOSE 8081

# Uncomment for openshift
# CMD mkdir /tmp/homeblocks && \
#    cp -rf /app/public /tmp/homeblocks/ && \
#    cp -rf /app/modules /tmp/homeblocks/ && \
#    cp -rf /app/.ceylon/cache /tmp && \
#    cd /tmp/homeblocks && \
#    ceylon run --cacherep=/tmp/cache net.homeblocks.server

CMD ceylon run net.homeblocks.server
