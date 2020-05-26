FROM golang:alpine AS build-env
WORKDIR $GOPATH/src/github.com/ironcore864/go-hello-http
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o hello

FROM alpine
ENV KUBE_LATEST_VERSION="v1.17.3"
RUN apk add --update ca-certificates \
  && apk add --update -t deps unzip curl \
  && curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl \
  && apk del --purge deps \
  && rm /var/cache/apk/*
WORKDIR /app
COPY --from=build-env /go/src/github.com/ironcore864/go-hello-http/hello /app/
COPY debug /usr/local/bin/debug
RUN chmod +x /usr/local/bin/debug
CMD ["./hello"]
USER 1000
