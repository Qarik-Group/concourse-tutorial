description: Concourse は、資格情報マネージャで拡張することで、パイプライン本体を変更することなく、変数値や秘密情報を設定・ローテーションさせることができます。 あなたのファイルシステムに秘密情報を含む変数ファイルはもう必要ありません。共通の変数値を変更する場合、複数の パイプラインを更新する必要はありません。

# 秘密パラメータを資格情報マネージャで管理する

Concourse は、資格情報マネージャで拡張することで、パイプライン本体を変更することなく、変数値や秘密情報を設定・ローテーションさせることができます。あなたのファイルシステムに秘密情報を含むパラメータファイルはもう必要ありません。共通の変数値を変更する場合、複数のパイプラインを更新する必要はありません。

Concourse は、Cloud Foundry Credhub, Hashicorp Vault, Amazon SSM, Amazon Secrets Manager をサポートしています。これらは Concourse にとって同じように振る舞います。このチュートリアルを簡単に実行するために、資格情報マネージャとして、Credhub を含む Concourse を構築できるシンプルなツール [bucc](https://github.com/starkandwayne/bucc) で、Concourse を再デプロイします。Credhub は、独自の CLI を介して対話するため非常にシンプルで、100％オープンソースで構成されています。

## Concourse を CredHub つきで再度デプロイする

Concourse の `docker-compose up` デプロイメントから、[bucc](https://github.com/starkandwayne/bucc) に切り替えることで、Credhub を持つ Concourse のローカル単一VMバージョンをデプロイします。これに加え、`bucc` はパブリッククラウド、またはプライベートクラウドに Concourse のプロダクションバージョンを配備することも可能にしてします。 このチュートリアルでは、ローカルマシンに `bucc` をデプロイします。

まず、[VirtualBox](https://www.virtualbox.org/wiki/Downloads) をインストールしてください(`bucc`のローカルデプロイに必要になります).
Ubuntu, macOS, CentOS をお使いの場合は、`bucc` のインストールの前に[依存するソフトウェア](https://bosh.io/docs/cli-v2-install/#additional-dependencies )の事前インストールが必要です。

次に下記のように bucc の git リポジトリをワークスペースに clone します:

```plain
git clone https://github.com/starkandwayne/bucc ~/workspace/bucc
cd ~/workspace/bucc
```

そして以下のコマンドを実行し、VirtualBox を利用してローカルマシンに `bucc` をデプロイします:

```plain
bucc up --lite
```

`command not found: bucc` で失敗した場合、[`direnv`](https://direnv.net/) がインストールされていない可能性があります。落ち着いて。`$PATH`を更新して、`bin/bucc` コマンドを実行してください。

```plain
source .envrc
```

以下を再度実行します:

```plain
bucc up --lite
```

`bucc up --lite` コマンドは `bosh create-env` と似ていますが、同じ VM に Credhub を追加します。`bucc` コマンドには、Concourse と Credhub にログインするためのサブコマンドも含まれています。

ディスクがVMにマウントされるのを待っているときに、`bucc up` がタイムアウトエラーで失敗した場合、VirtualBox の代わりに docker を使用することを検討してください。 詳細については、[この記事](https://starkandwayne.com/blog/bucc-docker) を参照してください。

## Concourse と Credhub

新しい Concourse にターゲットを設定してログインするには下記のコマンドを利用します:

```plain
bucc fly
```

`fly -t tutorial`の代わりに` fly -t bucc`を使います。

Concourse ダッシュボードの UI は、https://192.168.50.6/ になりました。

Credhub をターゲットにしてログインするには、`bucc` に含まれる資格情報マネージャを使用します:

```plain
bucc credhub
```

## 再認証

Credhub は、あなたのログインセッションを積極的かつ頻繁に落とします:

```plain
You are not currently authenticated. Please log in to continue.
```

あなたの `credhub` の認証が切れたら、`〜/workspace/bucc` に戻り、`bucc credhub` を再度実行してログインし直してください。

同様に、`fly -t bucc` セッションもタイムアウトします。再度認証するには、`~/workspace/bucc` に戻り、もう一度 `bucc fly` を実行してください。

## パイプラインを設定する

メインの `concourse-tutorial` ターミナルのウィンドウで、`tutorials/basic/parameters` フォルダに戻り、前のセクションから新しい `bucc` の Concourse 環境に、パイプラインをインストールします。ここではパラメータに明示的な値を指定しないでください。これらの値は資格情報マネージャによって提供されます:

```plain
cd ../parameters
fly -t bucc set-pipeline -p parameters -c pipeline.yml
fly -t bucc unpause-pipeline -p parameters
```

## 資格情報マネージャーにパラメータを設定する

```plain
credhub set -n /concourse/main/parameters/cat-name --type value --value garfield
credhub set -n /concourse/main/parameters/dog-name --type value --value odie
```

パイプラインの Job を実行し、Credhub から秘密情報を動的に取得できたことを確認しましょう:

```plain
fly -t bucc trigger-job -j parameters/show-animal-names -w
```

## 資格情報の探索ルール

`((cat-name))` のようなパラメータを解決する時には、Concourse は次のパスを順番に調べます:

* `/concourse/TEAM_NAME/PIPELINE_NAME/cat-name`
* `/concourse/TEAM_NAME/cat-name`

つまり、`((cat-name))` を Team:`main` の全 パイプラインで共有したい場合、`credhub set` コマンドは以下のようになります:

```plain
credhub delete -n /concourse/main/parameters/cat-name
credhub delete -n /concourse/main/parameters/dog-name
credhub set -n /concourse/main/cat-name --type value --value garfield
credhub set -n /concourse/main/dog-name --type value --value odie
```

再度 パイプラインの Job を実行し、Team で共有した秘密情報を、Credhub から動的に取得できることを確認しましょう:

```plain
fly -t bucc trigger-job -j parameters/show-animal-names -w
```

## 秘密情報をローテーションする

Concourse の資格情報マネージャ連携の大きな特徴は、(Cloud Foundry Credhub や Hashicorp Vault などのいずれを利用していても) パラメータ/秘密情報を更新した場合、次回の Job の実行時に、新しい値を自動的に利用するようになっている点です。

```plain
credhub set -n /concourse/main/cat-name --type value --value milo
credhub set -n /concourse/main/dog-name --type value --value otis

fly -t bucc trigger-job -j parameters/show-animal-names -w
```

出力には、次の2つの新しいパラメータ値が含まれています:

```plain
CAT_NAME=milo
DOG_NAME=otis
```
