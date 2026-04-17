To run Octopus in Openshift, run the below docker build command to rebase the image

docker build -t octopus-ubi-test -f Dockerfile .

In the values.yaml, update repository value with location of the rebased container/location, and update the databaseConnectionString value with your Octopus Deploy db location.

Install Octopus using the Helm chart here and the updates value.yaml: [Octopus Deploy Helm chart](https://github.com/OctopusDeploy/helm-charts/tree/c69e0f2d16d2d119e88adbd7bb8617cdc1e78226/charts/octopus-deploy)
