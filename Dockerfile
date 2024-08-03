FROM alpine as builder

RUN apk add binutils nasm

WORKDIR /app/

COPY . .

RUN nasm -f elf64 -o main.o src/main.asm
RUN ld -o main main.o

FROM alpine

COPY --from=builder /app/main /app/main

ENTRYPOINT ["/app/main"]
