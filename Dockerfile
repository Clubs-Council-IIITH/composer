FROM debian:bullseye-slim

ENV APOLLO_ELV2_LICENSE accept

WORKDIR /app
COPY . .
RUN chmod +x ./entrypoint.sh

RUN apt update && apt install curl wget -y
RUN curl -sSL https://rover.apollo.dev/nix/v0.15.0 | sh
RUN wget -nv https://github.com/mikefarah/yq/releases/download/v4.2.0/yq_linux_amd64.tar.gz -O - | tar xz && mv yq_linux_amd64 /usr/bin/yq
RUN export PATH=$HOME/.rover/bin:$PATH

ENTRYPOINT [ "./entrypoint.sh" ]
