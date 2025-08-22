# ArgoCD Kustomize エラー修正ガイド

## 🔧 修正内容

### 1. 非推奨設定の更新

#### Before (非推奨)
```yaml
commonLabels:
  app: mathsync
  version: v1.0.0
  environment: production

patchesStrategicMerge:
- patches/production-patch.yaml

patchesJson6902:
- target:
    group: apps
    version: v1
    kind: Deployment
    name: mathsync-app
  path: patches/replicas-patch.yaml
```

#### After (推奨)
```yaml
labels:
- pairs:
    app: mathsync
    version: v1.0.0
    environment: production

patches:
- path: patches/production-patch.yaml
  target:
    kind: Deployment
    name: mathsync-app
```

### 2. パッチファイルの統合

- ❌ 削除: `replicas-patch.yaml` (重複するパッチが競合の原因)
- ✅ 保持: `production-patch.yaml` (統合された設定)

### 3. ConfigMap重複の解決

- 不要な `configMapGenerator` を削除
- 既存の `configmap.yaml` のみ使用

## 🚀 デプロイ方法

### ArgoCD Application作成

```bash
kubectl apply -f argocd-application.yaml
```

### 手動デプロイ（テスト用）

```bash
# Kustomizeビルドテスト
cd k8s
kubectl kustomize .

# 実際のデプロイ
kubectl apply -k .
```

### CI/CDパイプライン用

GitHubにプッシュすると自動的に：
1. Docker イメージがビルド・プッシュされる
2. Kustomization.yaml の image tag が更新される
3. ArgoCD が変更を検知してデプロイする

## 🔍 トラブルシューティング

### Kustomize ビルドエラー

```bash
# ローカルでビルドテスト
cd k8s
kubectl kustomize . --enable-helm

# エラー詳細確認
kubectl kustomize . --load-restrictor=none
```

### ArgoCD 同期エラー

```bash
# ArgoCD Application 状態確認
kubectl get application mathsync -n argocd -o yaml

# ArgoCD リフレッシュ
argocd app sync mathsync --force
```

### パッチ適用エラー

```bash
# パッチターゲット確認
kubectl kustomize . | grep -A 10 -B 5 "kind: Deployment"

# リソース名確認
kubectl kustomize . | grep "name:" | head -10
```

## 📋 設定検証

### 必須チェックリスト

- ✅ `kubectl kustomize .` がエラーなしで実行される
- ✅ 生成されたマニフェストに重複リソースがない
- ✅ パッチが正しいリソースをターゲットしている
- ✅ すべてのイメージ参照が正しい
- ✅ 名前空間が一致している

### 警告の解決状況

- ✅ `commonLabels` → `labels` に更新
- ✅ `patchesStrategicMerge` → `patches` に更新  
- ✅ `patchesJson6902` → `patches` に更新
- ✅ 重複パッチファイルを削除

## 🔄 継続的改善

### 推奨事項

1. **定期的なKustomize更新**: 新機能と非推奨警告への対応
2. **パッチファイルの最小化**: 必要最小限のパッチのみ使用
3. **リソース命名の一貫性**: 明確で一意な名前の使用
4. **設定の分離**: 環境固有の設定は別ファイルで管理

### モニタリング

- ArgoCD ダッシュボードでアプリケーション状態を確認
- Kustomize ビルドログでエラー/警告をチェック
- デプロイ後の Pod 状態を確認

---

この修正により、ArgoCDでのKustomizeエラーが解決され、安定したデプロイメントが可能になります。
