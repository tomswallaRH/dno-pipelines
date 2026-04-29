# KONFLUX – Local setup

Simple folder for running **Konflux** and **KubeArchive** on your OpenShift/CRC cluster.

---

## Folder structure

```
KONFLUX/
├── README.md              ← You are here
├── docs/                  Documentation
│   ├── CRC-SETUP.md       Set up CRC (local OpenShift) – read first
│   ├── INSTALL.md         Install Konflux on the cluster
│   └── LEARN-KONFLUX.md   Step-by-step learning guide (Hebrew)
├── konflux/               Konflux install
│   ├── install-konflux.sh
│   ├── install.yaml
│   └── konflux_v1alpha1_konflux.yaml
├── kubearchive/           KubeArchive install
│   ├── install-kubearchive.sh
│   ├── INSTALL-KUBEARCHIVE.md
│   └── kubearchive-postgres.yaml
├── Konflux-pro/           Your app (Application + Component examples)
├── optional/              Optional files
│   ├── openshift-pipelines-subscription.yaml
│   └── pull-secret.txt
└── konflux-ci/            (Optional) Upstream repo – delete and clone when needed
```

---

## Quick start

1. **Start CRC and log in**  
   See **docs/CRC-SETUP.md**.

2. **Install Konflux**  
   ```bash
   ./konflux/install-konflux.sh
   ```  
   See **docs/INSTALL.md** for details.

3. **Optional: install KubeArchive**  
   See **kubearchive/INSTALL-KUBEARCHIVE.md** (PostgreSQL + cert-manager required).

---

## Useful commands

| Goal | Command |
|------|--------|
| CRC status | `crc status` |
| Log in to cluster | `eval $(crc oc-env)` then `oc login -u kubeadmin -p '<password>' https://api.crc.testing:6443 --insecure-skip-tls-verify=true` |
| Konflux UI (port-forward) | `oc port-forward -n konflux svc/konflux-ui 9443:9443` → https://localhost:9443 |

More in **docs/LEARN-KONFLUX.md** and **docs/INSTALL.md**.
# dno-pipelines
