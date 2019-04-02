# CloudNative Kubernetes setup

## Usage

See `make usage`

## Fetch kubeconfig

```sh
scp root@${IP}:/etc/kubernetes/admin.conf .
export KUBECONFIG="$(pwd)/admin.conf"
``
