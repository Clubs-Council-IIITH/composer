FROM debian:bullseye-slim

ENV APOLLO_ELV2_LICENSE accept

WORKDIR /app
COPY . .
RUN chmod +x ./entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]
