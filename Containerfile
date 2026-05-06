# Build context: repository root (`path-context: .` for Konflux docker-build-oci-ta).
FROM registry.access.redhat.com/ubi9/python-312:latest

WORKDIR /app

# Keep a tiny default app so container builds stay valid.
RUN printf 'print("OK")\n' > /app/app.py

EXPOSE 8080

CMD ["/usr/bin/python3", "/app/app.py"]
