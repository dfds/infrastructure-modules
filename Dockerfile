# Running Alpine 3.8
FROM dfdsdk/terratest-runner:0.11

COPY ./network /go/src/project/network
COPY ./test /go/src/project/test
RUN dep ensure
WORKDIR /go/src/project/test

CMD ["version"]
ENTRYPOINT ["go"]