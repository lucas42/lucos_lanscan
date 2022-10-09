FROM alpine:latest

WORKDIR /lanscan

RUN apk add bash curl cargo
RUN cargo install htmlq
ENV PATH="${PATH}:/root/.cargo/bin"
COPY run.sh .

CMD [ "./run.sh" ]