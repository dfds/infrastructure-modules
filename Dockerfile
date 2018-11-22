# Running Alpine 3.8
FROM dfdsdk/terratest-runner:0.11

COPY ./_sub /go/src/project/_sub
COPY ./network /go/src/project/network
COPY ./test /go/src/project/test
RUN dep ensure
WORKDIR /go/src/project/test

CMD ["version"]
ENTRYPOINT ["go"]