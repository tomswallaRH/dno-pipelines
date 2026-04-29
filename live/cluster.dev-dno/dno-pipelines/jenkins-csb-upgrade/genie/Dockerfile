FROM quay.io/fedora/fedora:

USER 0

RUN dnf install -y --disableplugin=subscription-manager \
    git \
    kustomize

USER 1000
