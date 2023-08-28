#!/bin/bash


PROJECT_ID=your_project
REGION=asia-northeast1
CLUSTER_NAME=asm-sample

gcloud config set project $PROJECT_ID

# enable AFR, GKE, ASM
gcloud services enable artifactregistry.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable mesh.googleapis.com

## make Artifact Registry registry and repo
gcloud artifacts repositories create asm-sample-repo --repository-format=docker \
--location=asia-northeast1 --description="Docker ASM sample imager registry"

## GEK autopilot install
gcloud compute networks create asm-cluster-vpc --subnet-mode=auto
gcloud container clusters create-auto $CLUSTER_NAME \
    --region=$REGION \
    --network=asm-cluster-vpc \
    --project=$PROJECT_ID

## check cluster status
gcloud container clusters get-credentials $CLUSTER_NAME \
    --region $REGION \
    --project=$PROJECT_ID

kubectl get nodes

## ASM install with fleet API.
### https://cloud.google.com/service-mesh/docs/managed/provision-managed-anthos-service-mesh?hl=ja
gcloud container fleet mesh enable --project $PROJECT_ID

GKE_URI=$(gcloud container clusters list --uri)
echo "show GKE_URI $GKE_URI"

# register cluster to fleet
gcloud container fleet memberships register asm-sample-cluster \
  --gke-uri=$GKE_URI \
  --enable-workload-identity \
  --project $PROJECT_ID

# check fleet status
gcloud container fleet memberships list --project $PROJECT_ID

PROJECT_NUMBER=$(gcloud projects list --filter="${PROJECT_ID}" --format="value(PROJECT_NUMBER)")

gcloud projects add-iam-policy-binding "$PROJECT_ID"  \
  --member "serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-servicemesh.iam.gserviceaccount.com" \
  --role roles/anthosservicemesh.serviceAgent

# set mesh_id label to GKE cluster for cluster associate to fleet.
gcloud container clusters update $CLUSTER_NAME --project $PROJECT_ID \
  --region $REGION --update-labels mesh_id=proj-${PROJECT_NUMBER}

gcloud container fleet mesh update \
    --management automatic \
    --memberships asm-sample-cluster \
    --project $PROJECT_ID \
    --location global

# check asm control plane status
gcloud container fleet mesh describe --project $PROJECT_ID
kubectl get -n istio-system controlplaneRevision
# OK 
#NAME          RECONCILED   STALLED   AGE
#asm-managed   True         False     56m
kubectl describe -n istio-system controlplaneRevision asm-managed


## Optional: cloud trace configure for application by Workload Identity
gcloud iam service-accounts create trace-gsa \
    --project=$PROJECT_ID
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:trace-gsa@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role "roles/cloudtrace.agent"

gcloud iam service-accounts add-iam-policy-binding trace-gsa@${PROJECT_ID}.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${PROJECT_ID}.svc.id.goog[app/front-sa]"