FROM quay.io/fedora/fedora:latest

USER 0

ADD upgrade.sh /tmp/

RUN dnf upgrade -y \
    && dnf install -y --disableplugin=subscription-manager \
    git

USER 1000

WORKDIR /workspace
