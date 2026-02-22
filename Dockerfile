FROM ghcr.io/gleam-lang/gleam:v1.14.0-erlang-alpine AS builder

COPY . /build/

RUN cd /build \
  && gleam export erlang-shipment \
  && mv build/erlang-shipment /out \
  && rm -r /build

FROM erlang:alpine AS runtime
WORKDIR /app

COPY --from=builder /out /app

RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]