# dno-pipelines

Tekton / OpenShift pipeline content lives under `base/` and `live/`. [Konflux](https://konflux-ci.dev/docs/) runs [Pipelines as Code](https://pipelinesascode.com/) from `.tekton/` and builds the image defined at `base/jenkins-csb-upgrade/image/Dockerfile`.

**Before onboarding in Konflux:** In `.tekton/dno-pipelines-*.yaml`, replace `changeme-tenant` with your workspace namespace (same value in `metadata.namespace` and in the `quay.io/redhat-user-workloads/...` image path). Match `appstudio.openshift.io/application` and `component` labels to your Konflux Application and Component names.