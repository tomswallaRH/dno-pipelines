# Build context: repository root (`path-context: .` for Konflux docker-build-oci-ta).
# Local builds from the component directory can still use applications/coffee/components/coffee-break/Containerfile.
FROM registry.access.redhat.com/ubi9/python-312:latest

WORKDIR /app

COPY applications/coffee/components/coffee-break/src/app.py /app/app.py

EXPOSE 8080

CMD ["/usr/bin/python3", "/app/app.py"]
