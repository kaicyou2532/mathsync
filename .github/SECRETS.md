# 🔐 GitHub Secrets Configuration

CI/CDパイプラインを動作させるために、以下のSecretsをGitHubリポジトリに設定する必要があります。

## 必須Secrets

### Docker Hub関連
```
DOCKER_USERNAME=kaicyou2532
DOCKER_PASSWORD=your_docker_hub_token
```

### 通知関連（オプション）
```
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
NOTIFICATION_EMAIL=admin@example.com
SECURITY_EMAIL=security@example.com
EMAIL_USERNAME=your_email@gmail.com
EMAIL_PASSWORD=your_app_password
```

### セキュリティスキャン（オプション）
```
SNYK_TOKEN=your_snyk_api_token
```

## Secrets設定手順

1. **GitHubリポジトリの設定**
   - リポジトリページの `Settings` タブをクリック
   - 左サイドバーの `Secrets and variables` → `Actions` をクリック

2. **New repository secret** をクリックして各Secretを追加

### Docker Hub Token作成手順

1. [Docker Hub](https://hub.docker.com/) にログイン
2. Account Settings → Security → New Access Token
3. トークン名を入力（例：`github-actions`）
4. 権限を選択（Read, Write, Delete推奨）
5. 生成されたトークンを `DOCKER_PASSWORD` に設定

### Slack Webhook URL取得手順

1. [Slack API](https://api.slack.com/apps) でアプリを作成
2. Incoming Webhooks を有効化
3. チャンネルを選択してWebhook URLを生成
4. URLを `SLACK_WEBHOOK_URL` に設定

### Gmail App Password作成手順

1. Googleアカウントの2段階認証を有効化
2. [App passwords](https://myaccount.google.com/apppasswords) にアクセス
3. アプリパスワードを生成
4. パスワードを `EMAIL_PASSWORD` に設定

### Snyk Token取得手順

1. [Snyk](https://snyk.io/) にアカウント作成
2. Account settings → General → Auth Token
3. トークンを `SNYK_TOKEN` に設定

## 環境変数の確認

設定後、以下のワークフローで環境変数が正しく設定されているか確認できます：

```yaml
name: Test Secrets
on: workflow_dispatch
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - name: Check Secrets
      run: |
        echo "Docker Username: ${{ secrets.DOCKER_USERNAME && '✅ Set' || '❌ Not Set' }}"
        echo "Docker Password: ${{ secrets.DOCKER_PASSWORD && '✅ Set' || '❌ Not Set' }}"
        echo "Slack Webhook: ${{ secrets.SLACK_WEBHOOK_URL && '✅ Set' || '❌ Not Set' }}"
        echo "Notification Email: ${{ secrets.NOTIFICATION_EMAIL && '✅ Set' || '❌ Not Set' }}"
```

## セキュリティ注意事項

- ❌ Secretsの値をログに出力しない
- ❌ Pull Requestでは制限されたSecretsのみ使用
- ✅ 定期的にトークンをローテーション
- ✅ 最小権限の原則を適用
- ✅ 不要になったSecretsは削除

## トラブルシューティング

### よくある問題

1. **Docker push失敗**
   ```
   Error: unauthorized: authentication required
   ```
   → `DOCKER_USERNAME` と `DOCKER_PASSWORD` を確認

2. **Slack通知が届かない**
   → `SLACK_WEBHOOK_URL` の形式を確認

3. **Email送信失敗**
   → Gmail の2段階認証とアプリパスワードを確認

### デバッグ方法

```bash
# ローカルでSecrets環境変数をテスト
export DOCKER_USERNAME="your_username"
export DOCKER_PASSWORD="your_token"

# Docker ログインテスト
echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
```
