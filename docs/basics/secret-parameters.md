description: Concourse は、資格情報マネージャで拡張することで、Pipeline 本体を変更することなく、変数値や秘密情報を設定・ローテーションさせることができます。 あなたのファイルシステムに秘密情報を含む変数ファイルはもう必要ありません。共通の変数値を変更する場合、複数の Pipeline を更新する必要はありません。

# Secret Parameters with Credentials Manager

Concourse は、資格情報マネージャで拡張することで、Pipeline 本体を変更することなく、変数値や秘密情報を設定・ローテーションさせることができます。 あなたのファイルシステムに秘密情報を含む変数ファイルはもう必要ありません。共通の変数値を変更する場合、複数の Pipeline を更新する必要はありません。

Concourse は、Cloud Foundry Credhub と Hashicorp Vault をサポートしています。これらは Concourse にとって同じように振る舞います。このチュートリアルを簡単に実行するために、資格情報マネージャとして、Credhub を含む Concourse を構築できるシンプルなツール [bucc](https://github.com/starkandwayne/bucc) で、Concourse を再デプロイします。Credhub は、独自の CLI を介して対話するため非常にシンプルで、100％オープンソースで構成されています。

## Redeploy Concourse with Credhub

Concourse の `docker-compose up` デプロイメントから、[bucc](https://github.com/starkandwayne/bucc) に切り替えることで、Credhub を持つ Concourse のローカル単一VMバージョンをデプロイします。これに加え、`bucc` はパブリッククラウド、またはプライベートクラウドに Concourse のプロダクションバージョンを配備することも可能にしてします。 このチュートリアルでは、ローカルマシンに `bucc` をデプロイします。

まず、[VirtualBox](https://www.virtualbox.org/wiki/Downloads) をインストールしてください(`bucc`のローカルデプロイに必要になります).

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

The `bucc up --lite` command is similar to `bosh create-env` but adds Credhub to the same VM. The `bucc` command also includes subcommands for logging in to Concourse and Credhub.

`bucc up --lite` コマンドは `bosh create-env` と似ていますが、同じ VM に Credhub を追加します。`bucc` コマンドには、Concourse と Credhub にログインするためのサブコマンドも含まれています。

## Concourse & Credhub

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

## Reauthentication

Credhub は、あなたのログインセッションを積極的かつ頻繁に落とします:

```plain
You are not currently authenticated. Please log in to continue.
```

あなたの `credhub` の認証が切れたら、`〜/workspace/bucc` に戻り、`bucc credhub` を再度実行してログインし直してください。

同様に、`fly -t bucc` セッションもタイムアウトします。再度認証するには、`~/workspace/bucc` に戻り、もう一度 `bucc fly` を実行してください。

## Setup pipeline with parameters

メインの `concourse-tutorial` ターミナルのウィンドウで、`tutorials/basic/parameters` フォルダに戻り、前のセクションから新しい `bucc` の Concourse 環境に、Pipeline をインストールします。ここではパラメータに明示的な値を指定しないでください。これらの値は、Credhub、資格情報マネージャによって提供されます:

```plain
cd ../parameters
fly -t bucc sp -p parameters -c pipeline.yml
fly -t bucc up -p parameters
```

## Insert values into Credentials Manager

```plain
credhub set -n /concourse/main/parameters/cat-name --type value --value garfield
credhub set -n /concourse/main/parameters/dog-name --type value --value odie
```

Pipeline の Job を実行し、Credhub から秘密情報を動的に取得できたことを確認しましょう:

```plain
fly -t bucc trigger-job -j parameters/show-animal-names -w
```

## Credential Lookup Rules

`((cat-name))` のようなパラメータを解決する時には、Concourse は次のパスを順番に調べます:

* `/concourse/TEAM_NAME/PIPELINE_NAME/cat-name`
* `/concourse/TEAM_NAME/cat-name`

つまり、`((cat-name))` を Team:`main` の全 Pipeline で共有したい場合、`credhub set` コマンドは以下のようになります:

```plain
credhub delete -n /concourse/main/parameters/cat-name
credhub delete -n /concourse/main/parameters/dog-name
credhub set -n /concourse/main/cat-name --type value --value garfield
credhub set -n /concourse/main/dog-name --type value --value odie
```

再度 Pipeline の Job を実行し、Team で共有した秘密情報を、Credhub から動的に取得できることを確認しましょう:

```plain
fly -t bucc trigger-job -j parameters/show-animal-names -w
```

## Rotating Secrets

Concourse の資格情報マネージャ連携の大きな特徴は、(Cloud Foundry Credhub や Hashicorp Vault のいずれを利用していても) パラメータ/秘密情報を更新した場合、次回の Job の実行時に、新しい値を自動的に利用するようになっている点にあります。

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
