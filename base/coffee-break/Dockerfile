# Runnable coffee-break image for Konflux (context: base/coffee-break, dockerfile: Dockerfile).
# Aligns with execute-coffee-break task behavior (Python 3.11 + breaks.py / recipients_mails.py).
# Full application source is maintained in ccit/coffee-break (GitLab); scripts here are minimal placeholders.
FROM quay.io/fedora/fedora:latest

USER 0
WORKDIR /app
COPY breaks.py recipients_mails.py ./
RUN dnf -y install python3 && dnf clean all \
    && chown -R 1001:0 /app && chmod -R g+rwX /app

USER 1001
WORKDIR /app
CMD ["python", "breaks.py"]
