# image variables
FROM alpine as base_alpine

FROM base_alpine as bats
RUN apk add bats --no-cache
WORKDIR scripts
COPY scripts /scripts/
CMD ["bats", "."]


# DYNU_DOMAIN
# runs ddns updating
# https://stackoverflow.com/questions/37015624/how-to-run-a-cron-job-inside-a-docker-container
# https://stackoverflow.com/questions/45395390/see-cron-output-via-docker-logs-without-using-an-extra-file
FROM base_alpine as dynu_domain

ENV TIME_INTERVAL="*/5 * * * *" \
    UPDATE_IP_V4=true \
    UPDATE_IP_V6=true \
    USE_SSL=true \
    VERIFY_DYNU_CONFIG=true

COPY /scripts/entry.sh /scripts/entry.sh
RUN apk add curl --no-cache
RUN chmod 755 /scripts/entry.sh
CMD ["/scripts/entry.sh"]

