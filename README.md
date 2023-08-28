# Anthos Service Mesh サンプルコード

Software Design 連載記事 Google Cloudで実践するSREプラクティス の第8回 Anthos Service Mesh 入門で用いるサンプルコードです。

このサンプルコードはライセンスの範囲内で自由に使っていただいて構いません。
Google Cloud や Cloud SDKのセットアップ, サンプルコードを動作させるための開発環境などの準備についてはサンプルコードの範囲外です。

また、この手順を実施するためには、Google Cloud上で課金対象のリソースを実行します。
課金の対象となりますので、あらかじめご了承ください。

## 手順

### 事前準備

Google Cloud のプロジェクトを作成し、 cloud SDK, Docker をインストール,初期設定をしておきます。

### 環境構築

install.sh にて project_id などを自身のものに設定し、 `./install.sh` で実行します。

VPC, GKE Autopilot cluster, Artifact Registry, Anthos Service Meshなどがインストールされます。

### 実行イメージ準備

image_build.shを開き、 project_id などを自身のものに設定し、 `./image_build.sh` で実行します。
2つのイメージが Artifact Registryにアップロードされます。

### アプリケーションデプロイ

manifests/ フォルダの 5_front.yaml, 6_backend.yaml の  service accont の annotationb,
およびDeploymentリソースの image にある image repository中の <PROJECT_ID> を実際のプロジェクトIDに置き換えます。

その後、 manifests フォルダで、 以下のコマンドで manifestを適用します。

```
PROJECT_ID=<>
gcloud container clusters get-credentials asm-sample --region asia-northeast1 --project=$PROJECT_ID
cd manifests
kubectl apply -f .
```

実行後、ingress_gatewayが type:load_balancerで開くので、`http://<LBのExternal IP>/hello` にアクセスし、稼働確認を行なってください。
External IPは `kubectl get svc -n istio-gateway` で確認できます。

GKE コンソールや Anthos Service mesh, Cloud Trace などでPodや通信の状況が確認できます。


### 終了手順

Google Cloud プロジェクトの削除をお願いします。