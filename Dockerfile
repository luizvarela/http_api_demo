# Build stage 0
FROM erlang:24-alpine

# Set working directory
RUN mkdir /buildroot
WORKDIR /buildroot

# Install some libs
RUN apk add --no-cache openssl && \
    apk add --no-cache ncurses-libs && \
    apk add --no-cache libstdc++ && \
    apk add --update git

# Copy our Erlang test application
COPY . http_api_demo

# And build the release
WORKDIR http_api_demo
RUN DEBUG=1 rebar3 as prod release

# Build stage 1
FROM alpine

RUN apk add --no-cache libstdc++ openssl ncurses-libs git

# Install the released application
COPY --from=0 /buildroot/http_api_demo/_build/prod/rel/http_api_demo /http_api_demo

# Expose relevant ports
EXPOSE 8080
EXPOSE 8443

CMD ["/http_api_demo/bin/http_api_demo", "foreground"]