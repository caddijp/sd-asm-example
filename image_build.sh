#/bin/sh

project_id=<PROJECT_ID>
repo=asia-northeast1-docker.pkg.dev/${project_id}/asm-sample-repo
version=0.0.1

# gcloud auth login , at first time
gcloud auth configure-docker asia-northeast1-docker.pkg.dev

docker build --platform linux/amd64 -t  ${repo}/front:${version} samples/front
docker build --platform linux/amd64 -t ${repo}/backend:${version} samples/backend


docker push ${repo}/front:${version}
docker push ${repo}/backend:${version}