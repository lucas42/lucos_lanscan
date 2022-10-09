FROM alpine:latest

RUN apk add nmap curl
COPY run.sh .

CMD [ "./run.sh" ]