# Dart Frog → single binary for Render (reads PORT from env, default 8080).
FROM dart:stable AS build
WORKDIR /app

RUN dart pub global activate dart_frog_cli
ENV PATH="/root/.pub-cache/bin:${PATH}"

COPY pubspec.yaml ./
COPY analysis_options.yaml ./analysis_options.yaml
COPY routes ./routes
COPY test ./test

RUN dart pub get
RUN dart_frog build
RUN dart compile exe build/bin/server.dart -o /runtime/cbsvault_api

FROM debian:bookworm-slim
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/* \
  && useradd -r -s /usr/sbin/nologin appuser

COPY --from=build /runtime/cbsvault_api /usr/local/bin/cbsvault_api

ENV PORT=8080
EXPOSE 8080
USER appuser
CMD ["/usr/local/bin/cbsvault_api"]
