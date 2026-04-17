# Octopus Deploy on OpenShift

This repository contains:

- A `Dockerfile` that rebases the Octopus Deploy Server image onto Red Hat UBI (for OpenShift-style environments).
- A sample `values.yaml` to deploy Octopus Deploy with the official Helm chart.

## Prerequisites

Before starting, ensure you have:

- Access to an OpenShift cluster.
- `oc` CLI installed and logged in to the target cluster/project.
- Docker or Podman to build and push container images.
- Access to a container registry that your OpenShift cluster can pull from.
- Helm 3 installed.
- A SQL Server database reachable from the OpenShift cluster.

## 1) Build the rebased Octopus image

From this repository directory, build the image:

```bash
docker build -t octopus-ubi:latest -f Dockerfile .
```

If needed, you can override the upstream Octopus image version:

```bash
docker build \
  --build-arg UPSTREAM_IMAGE=octopusdeploy/octopusdeploy:<version> \
  --build-arg OCTOPUS_VERSION=<version> \
  -t octopus-ubi:<version> \
  -f Dockerfile .
```

## 2) Tag and push the image to your registry

Tag and push the image so OpenShift can pull it:

```bash
docker tag octopus-ubi:latest <registry>/<namespace>/octopus-ubi:latest
docker push <registry>/<namespace>/octopus-ubi:latest
```

## 3) Update `values.yaml`

Edit `values.yaml` and set at least the following:

- `octopus.image.repository`: your pushed image (for example, `<registry>/<namespace>/octopus-ubi`).
- `octopus.image.tag`: image tag to deploy (for example, `latest` or a versioned tag).
- `octopus.databaseConnectionString`: SQL Server connection string for your Octopus database.

Also review and update:

- `octopus.username` and `octopus.password` for initial admin credentials.
- Any environment-specific values such as storage, resource limits, and security settings.

## 4) Install the Octopus Helm chart

Use the official Octopus Deploy Helm chart and pass this repository's `values.yaml`:
[Octopus Deploy Helm chart](https://github.com/OctopusDeploy/helm-charts/tree/c69e0f2d16d2d119e88adbd7bb8617cdc1e78226/charts/octopus-deploy)

```bash
helm repo add octopusdeploy https://octopus-helm-charts.s3.amazonaws.com
helm repo update
helm install octopus octopusdeploy/octopus-deploy -f values.yaml
```

If you are installing into a specific namespace:

```bash
helm install octopus octopusdeploy/octopus-deploy -n <namespace> --create-namespace -f values.yaml
```

## 5) Validate the deployment

After install, check pods and services:

```bash
oc get pods
oc get svc
```

Check Helm release status:

```bash
helm status octopus
```

## Notes

- The provided `values.yaml` disables the bundled SQL Server chart (`mssql.enabled: false`), so an external SQL Server must be available.
- OpenShift security constraints are strict by default; this sample values file includes settings and writable mount points that help the container run as non-root.
- If your registry requires authentication, ensure the target namespace has the correct pull secret configured.
