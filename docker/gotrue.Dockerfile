FROM golang as base
WORKDIR /go/src/supabase
RUN git clone https://github.com/uxodb/auth.git
WORKDIR /go/src/supabase/auth
COPY docker/auth.patch .
RUN git apply auth.patch
RUN CGO_ENABLED=0 go build -o /auth .

FROM scratch
COPY --from=base /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=base /etc/passwd /etc/passwd
COPY --from=base /etc/group /etc/group

COPY --from=base /auth .
COPY --from=base /go/src/supabase/auth/migrations ./migrations

CMD ["./auth"]
