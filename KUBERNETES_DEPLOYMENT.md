# MathSync Kubernetes Deployment

このディレクトリには、MathSyncアプリケーションをKubernetesクラスターにデプロイするために必要なすべてのマニフェストファイルが含まれています。

## 📁 ディレクトリ構造

```
k8s/
├── namespace.yaml              # 名前空間定義
├── configmap.yaml             # 設定マップ
├── deployment.yaml            # アプリケーションデプロイメント
├── service.yaml               # サービス定義
├── ingress.yaml               # Ingressリソース
├── hpa.yaml                   # Horizontal Pod Autoscaler
├── network-policy.yaml        # ネットワークポリシー
├── pod-disruption-budget.yaml # Pod中断予算
├── service-monitor.yaml       # Prometheus監視設定
├── kustomization.yaml         # Kustomize設定
├── .env.prod                  # 本番環境変数
└── patches/
    ├── production-patch.yaml  # 本番環境用パッチ
    └── replicas-patch.yaml    # レプリカ数調整パッチ
```

## 🚀 クイックデプロイ

### 前提条件

- Docker
- kubectl
- Kubernetes クラスター
- Ingress Controller (nginx-ingress推奨)
- cert-manager (SSL証明書用、オプション)

### 1. 環境設定

```bash
# Docker レジストリ設定
export REGISTRY="your-registry.com"

# 環境変数ファイルを編集
vi k8s/.env.prod
```

### 2. 自動デプロイ

```bash
# 最新タグでデプロイ
./deploy.sh

# 特定バージョンでデプロイ
./deploy.sh v1.2.3

# イメージビルドをスキップしてデプロイ
NO_BUILD=true ./deploy.sh
```

### 3. 手動デプロイ

```bash
# Docker イメージをビルド
docker build -t your-registry.com/mathsync:latest .

# イメージをプッシュ
docker push your-registry.com/mathsync:latest

# Kubernetes にデプロイ
kubectl apply -k k8s/
```

## 🔧 設定のカスタマイズ

### ドメイン設定

`k8s/ingress.yaml` でドメインを変更：

```yaml
spec:
  tls:
  - hosts:
    - your-domain.com
    secretName: mathsync-tls
  rules:
  - host: your-domain.com
```

### リソース制限

`k8s/deployment.yaml` でCPU・メモリ制限を調整：

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### オートスケーリング

`k8s/hpa.yaml` でスケーリング設定を調整：

```yaml
spec:
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## 📊 監視とログ

### デプロイメント状態確認

```bash
# Pod状態確認
kubectl get pods -n mathsync

# サービス確認
kubectl get svc -n mathsync

# Ingress確認
kubectl get ingress -n mathsync

# HPA状態確認
kubectl get hpa -n mathsync
```

### ログ確認

```bash
# アプリケーションログ
kubectl logs -f deployment/mathsync-app -n mathsync

# 過去のログ
kubectl logs deployment/mathsync-app -n mathsync --previous
```

### メトリクス

Prometheusが設定されている場合、以下のメトリクスが利用可能：

- CPU使用率
- メモリ使用率
- リクエスト数
- レスポンス時間

## 🔒 セキュリティ

### ネットワークポリシー

アプリケーションへのアクセスは制限されています：

- Ingress Controllerからのトラフィックのみ許可
- 監視システムからのアクセス許可
- 外部への必要最小限の通信のみ許可

### Pod セキュリティ

- 非特権ユーザーでの実行
- 読み取り専用ルートファイルシステム
- Seccompプロファイル適用

## 🚨 トラブルシューティング

### よくある問題

1. **ImagePullBackOff**
   ```bash
   # イメージが存在するか確認
   docker pull your-registry.com/mathsync:latest
   
   # レジストリ認証確認
   kubectl get secrets -n mathsync
   ```

2. **Pod起動失敗**
   ```bash
   # イベント確認
   kubectl describe pod <pod-name> -n mathsync
   
   # ログ確認
   kubectl logs <pod-name> -n mathsync
   ```

3. **Ingress接続失敗**
   ```bash
   # Ingress Controller確認
   kubectl get pods -n ingress-nginx
   
   # SSL証明書確認
   kubectl get certificate -n mathsync
   ```

### デバッグコマンド

```bash
# 全リソース確認
kubectl get all -n mathsync

# イベント確認
kubectl get events -n mathsync --sort-by='.lastTimestamp'

# リソース使用量確認
kubectl top pods -n mathsync
```

## 🔄 アップデート

### ローリングアップデート

```bash
# 新しいイメージタグでアップデート
kubectl set image deployment/mathsync-app mathsync=your-registry.com/mathsync:v1.2.3 -n mathsync

# ロールアウト状況確認
kubectl rollout status deployment/mathsync-app -n mathsync

# ロールバック（必要な場合）
kubectl rollout undo deployment/mathsync-app -n mathsync
```

### 設定更新

```bash
# ConfigMap更新
kubectl apply -f k8s/configmap.yaml

# Pod再起動（設定を反映）
kubectl rollout restart deployment/mathsync-app -n mathsync
```

## 📞 サポート

問題が発生した場合は、以下の情報を含めてサポートに連絡してください：

- Kubernetesバージョン
- エラーメッセージ
- Pod/Deployment の状態
- 関連するログ

---

**注意**: 本番環境での使用前に、すべての設定値を適切に調整してください。
