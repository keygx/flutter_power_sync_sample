# Flutter + PowerSync Cloud Sample

Flutter 3.47.8（mise 管理）と PowerSync Dart SDK 2.5 を使う、Android / iOS 向けのサンプルです。同期元には Supabase の PostgreSQL を使用し、PowerSync Cloud 経由で端末の SQLite に同期します。アプリから Supabase に直接接続する SDK は使用していません。

同期元データベース → PowerSync Cloud → 端末の SQLite → ToDo 一覧、という構成です。サーバー側の変更を受信し、一度受信した内容はオフラインでも表示できます。

このサンプルは受信専用です。PowerSync Cloud は同期サービスであり、同期元データベースやアプリからの書き込み API は別途必要です。ローカル変更をサーバーへ送ったように見せる処理は実装していません。

## 1. 同期元データベースと Cloud の準備

1. [PowerSync Dashboard](https://dashboard.powersync.com/) でプロジェクトと Cloud インスタンスを作成します。
2. Supabase の SQL Editor で `todos` テーブルを作成します。`powersync/source-schema.sql` にテーブルとサンプルデータの SQL があります。すでに作成済みの場合、再実行は不要です。
3. DB プロバイダーの手順に従い、論理レプリケーションを有効にし、レプリケーション用ユーザー・SELECT 権限・`powersync` publication を設定します。SQL は既存環境へそのまま適用せず、publication の重複などを確認してください。
4. Cloud インスタンスの Database Connection に同期元 DB を設定し、接続を確認します。
5. Sync Streams に `powersync/sync-config.yaml` の内容を設定して Validate / Deploy します。`owner_id = auth.user_id()` により、トークンのユーザー ID と一致する行だけを配信します。クライアント側の絞り込みはアクセス制御の代わりになりません。

詳細: [公式セットアップガイド](https://docs.powersync.com/intro/setup-guide)

## 2. 開発用トークンとアプリの設定

1. Cloud の Client Auth で Development tokens を有効にして保存します。
2. 上部の Connect を開き、Instance URL をコピーします。
3. Connect 内の **Connect Sync Diagnostics** タブを開き、**Enter token subject** に `sample-user`（サンプル SQL の `owner_id`）を入力して **Generate token** を押します。生成された開発用トークンをコピーしてください。Supabase Auth に `sample-user` のユーザーを作成する必要はありません。
4. プロジェクト直下の `.env` に `POWERSYNC_URL` と `POWERSYNC_DEV_TOKEN` を入力します。ファイルがない場合は `.env.example` をコピーしてください。
5. 起動します。

```sh
mise exec -- flutter pub get
mise exec -- flutter run --dart-define-from-file=.env
```

Android Studio の Run Configuration では Additional run args に `--dart-define-from-file=.env` を設定してください。設定がない場合はアプリ内に設定案内を表示します。

開発用トークンは通常 12 時間で失効します。失効したら再発行して設定を更新し、アプリを再起動してください。トークンはアプリに組み込まれるため、この方法は開発用です。本番では自前の認証と JWT 発行エンドポイントを用意し、`CloudConnector.fetchCredentials()` を置き換えます。管理用 API キーや DB パスワードはアプリに入れないでください。`.env` と `.env.*` は Git の対象外で、値の入っていない `.env.example` だけを共有します。`.env` は Flutter のビルド引数として読み込み、アセットには登録しません。ただし設定値はアプリに組み込まれるので、`.env` による管理は端末内での秘密保持を保証するものではありません。

詳細: [開発用トークン](https://docs.powersync.com/configuration/auth/development-tokens)

## 3. 同期とオフライン表示の確認

1. 設定を渡して起動し、接続状態と ToDo の表示を確認します。
2. 同期元 DB で変更します。

```sql
UPDATE public.todos SET completed = true WHERE id = 'todo-1';
```

3. アプリの一覧に変更が届くことを確認します。
4. 端末をオフラインにして再起動し、保存済みの一覧が表示されることを確認します。初回同期には通信が必要です。

DB ファイルはアプリのサポートディレクトリに保存し、Cloud URL とトークンのユーザー ID ごとに分離します。対応プラットフォームは Android と iOS のみです。

## 開発時の確認

```sh
mise exec -- flutter analyze
mise exec -- flutter test
mise exec -- flutter build apk --debug --dart-define-from-file=.env
mise exec -- flutter build ios --simulator --debug --dart-define-from-file=.env
```

実際のクラウド同期の確認には、接続済みの同期元 DB・デプロイ済みの Sync Streams・有効な開発用トークンが必要です。
