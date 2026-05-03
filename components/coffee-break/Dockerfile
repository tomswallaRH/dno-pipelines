# Container image for coffee-break (Konflux build context: components/coffee-break).
FROM quay.io/fedora/fedora:latest

USER 0
WORKDIR /app
COPY breaks.py recipients_mails.py ./
RUN dnf -y install python3 && dnf clean all \
    && chown -R 1001:0 /app && chmod -R g+rwX /app

USER 1001
WORKDIR /app
CMD ["python", "breaks.py"]
