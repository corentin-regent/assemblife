FROM alpine as builder

RUN apk add --no-cache binutils make nasm

WORKDIR /app/

COPY . .

RUN make main

FROM alpine

COPY --from=builder /app/main /app/main

ENTRYPOINT ["/app/main"]
