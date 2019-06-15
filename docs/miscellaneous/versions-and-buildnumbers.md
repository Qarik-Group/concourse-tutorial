# バージョニングとビルド番号

このセクションのタイトルには、他の CI/CD システムの共通概念であるため、"ビルド番号" が記載されています。一般には、プロダクトや更新された Resource を区別するために用いられる単純増を繰り返す番号のことを指しますが、Concourse では、パイプライン, Job, およびそのステップで使用できる"ビルド番号"の概念はありません。

代わりに、[`semver` Resource Type](https://github.com/concourse/semver-resource#readme) の柔軟なコンセプトと、Concourse 本来の柔軟性を以って、いつ`semver` の値を増やすか、どれだけ増やすかを決定していきます。

## SemVer - セマンティックバージョニング

`semver` とは、"semantic versioning" の略で、https://semver.org/lang/ja/ で文書化されています。要約すれば、

1.3.5 などのバージョン番号 `MAJOR.MINOR.PATCH` が与えられた場合、

* 互換性のないAPIの変更を行う場合は MAJOR(メジャー) バージョン
* 下位互換性のある機能を追加する場合は MINOR(マイナー) バージョン
* 下位互換性のあるバグ修正を行う場合は PATCH(パッチ) バージョン

のように、増加するバージョンを決定していきます。

プレリリース用の追加ラベルとビルドメタデータは、 `MAJOR.MINOR.PATCH` フォーマットの拡張として利用できます。

単調に増加する内部ビルド番号の代わりに、`semver` Resource Type を使用すると、バージョン番号の意味付けをコントロールできるのです。

`semver` Resource Type のセマンティックな意味を気にしない場合は、` 0.0.1`で起動し、PATCH バージョンのみをバンプします。そのうち、`0.0.5000` の値から MINOR バージョンの値を` 0.1.0` にバンプするなどといったことも可能です。

## SemVer の値を保存する

Concourse における SemVer のシンプルさは、リモートで保存されたシンプルなファイルにあり、Concourse ステップの `version` ファイル内で利用可能になっています。

複雑なポイントとしては、その `version` ファイルをどこに格納するか決める必要がある点です。

https://github.com/concourse/semver-resource ソースプロジェクトでは、SemVer ファイルを格納するための以下の "how" ドライバを提供しています:

* [`git`](https://github.com/concourse/semver-resource#git-driver)
* [`s3`](https://github.com/concourse/semver-resource#s3-driver)
* [`swift`](https://github.com/concourse/semver-resource#swift-driver)
* [`gcs`](https://github.com/concourse/semver-resource#gcs-driver)

ほぼすべての Concourse パイプラインは、既に Task スクリプト用のリモート `git` リポジトリを使用しているので、そのgit プロジェクトを再利用して SemVer バージョンファイルを保存すると便利です。 しかし、このケースはあまりメジャーではありません。

代わりに、大部分の Concourse パイプラインは、既に他の大きなアセットを扱うために `s3`, `swift`, `gcs` バケットなどを使用していることが多いので、そのバケットを再利用して、1つの SemVer バージョンファイルを保存するのが便利で簡単です。

私たちは、`semver` Resource Type のトピックをカバーするためにドライバの1つについて話し合うだけです。各ドキュメント、それらの設定方法について上記リンクにありますのでご参照ください。AWS S3 は比較的一般的で、多くの Concourse チュートリアルの読者がアクセスできるので、ここでは例として `s3` ドライバを使用します。

## AWS S3 バケットを作成する

AWS S3 にアクセスできる AWS API の資格情報を作成または再利用します。 あなたが `aws` CLIのユーザであれば、`~/.aws/credentials` から見つけられるでしょう:

```
[youraccount]
aws_access_key_id = ACCESS_KEY
aws_secret_access_key = ACCESS_SECRET
```

これらをあなたの Credhub に追加してください。異なるパイプラインに同じ資格情報を再利用すると仮定すると、`main` Team のすべてのパイプラインで共通のものにすることができます。

`bucc` プロジェクト内で `bucc credhub` を実行し、Credhub で再認証することを忘れないでください。

```
credhub set -n /concourse/main/aws-access-key-id     -t value -v ACCESS_KEY
credhub set -n /concourse/main/aws-secret-access-key -t value -v ACCESS_SECRET
```

[AWS S3 web UI](https://console.aws.amazon.com/s3/home?region=us-east-1) または `aws` CLI を利用して、新しいバケットを作成します(もしくは、あなたのパイプラインに関連のあるバケットを再利用しても良いでしょう)。

あなたのバケット名はグローバルでユニークである必要があるので、以下の `concourse-tutorial-versions-lesson` の部分をお好きな文字列に変更してください。私はこれを取りました。

```
aws --profile youraccount s3 mb s3://concourse-tutorial-versions-lesson
```

バケット名を Credhub に保存します。 通常は、バケット名を `pipeline.yml` にハードコードすることもできます。これらのレッスンのパラメータ変数は、すべての読者で異なるためです。

```
credhub set -n /concourse/main/versions-and-buildnumbers/version-aws-bucket -t value -v concourse-tutorial-versions-lesson
```

これで、パイプラインに `version` Resource を追加することができます:

```yaml
resources:
- name: version
  type: semver
  source:
    driver: s3
    initial_version: 0.0.1
    access_key_id:     ((aws_access_key_id))
    secret_access_key: ((aws_secret_access_key))
    bucket:      ((version_aws_bucket))
    region_name: us-east-1
    key:         concourse-tutorial/version
```

## バージョンを確認できるようにする

あなたのパイプラインのステップが、現在の `semver` のバージョン番号を取得する必要がある場合、シンプルに `get:version` します:

```yaml
jobs:
- name: display-version
  plan:
  - get: version
  - task: display-version
    config:
      inputs:
      - name: version
      run:
        path: cat
        args: [version/number]
```

`version` Resource は、現在の SemVer の値を `number` ファイルに保存します。よって後続のステップは、ファイルパス `version/number` 内の値を参照することができるようになります。

```
cd tutorials/mischellaneous/versions-and-buildnumbers
fly -t bucc sp -p versions-and-buildnumbers -c pipeline-display-version.yml
fly -t bucc up -p versions-and-buildnumbers
fly -t bucc trigger-job -j versions-and-buildnumbers/display-version -w
```

Concourse の WebUI を見ると、その Job の動作が楽しくなることうけあいです:

![semver-display-version](/images/semver-display-version.png)

## バージョンを上げる（ bump する）

Concourse 外で `version` ファイルを手作業で作成し変更することもできますが、一般的には Concourse Job の中でバージョンを上げます(Job の開始時には自動でプレリリース版やリリース候補版などのバージョンに上げ、`MAJOR.MINOR.PATCH` のリリース準備時だけは手作業で...といった具合です)。

`semver` Resource Type は、最初に fetch されるときにバージョンを上げることができます。 [examples](https://github.com/concourse/semver-resource#example) を参照してください。

その新しいバージョン値は、Job の build plan の中にのみ存在し、コンテナ間で Task に `inputs` を介して渡されます。

![bump-version](/images/bump-version.png)

fetch する際に、`semver` の値をバンプするための [2つのオプション](https://github.com/concourse/semver-resource#version-bumping-semantics) があります:

* `bump`: 任意。 指定した部分でバージョン番号をバンプします。次のいずれか1つで指定してください:
    * `major`: メジャーバージョンをバンプします。 例) `1.0.0` -> `2.0.0`
    * `minor`: マイナーバージョンをバンプします。 例) `0.1.0` -> `0.2.0`.
    * `patch`: パッチバージョンをバンプします。 例) `0.0.1` -> `0.0.2`.
    * `final`: バージョンを最終バージョンとして昇格します。 例) `1.0.0-rc.1` -> `1.0.0`.
* `pre`: 任意。バンプの際に、プレリリース(例: `rc`, `alpha`)や、 すでに存在するプレリリースにバンプします。

上のパイプラインの例では、`rc` ナンバーを `pre` でバンプしています:

```yaml
plan:
- get: version
  params: {pre: rc}
```

その次のステップでは、この新しい値をリモートの `s3` バージョンファイルに保存することができます:

```yaml
plan:
- get: version
  params: {pre: rc}
- put: version
  params: {file: version/number}
```

この変更をパイプラインに適用してから、Job: `bump-version` を数回起動し、`0.0.1-rc.3`まで値が増加することを確認してみましょう:

```
fly -t bucc sp -p versions-and-buildnumbers -c pipeline-bump-then-save.yml
fly -t bucc trigger-job -j versions-and-buildnumbers/bump-version -w
fly -t bucc trigger-job -j versions-and-buildnumbers/bump-version -w
fly -t bucc trigger-job -j versions-and-buildnumbers/bump-version -w
```

Job を実行して、上記の画像のように出力結果を確認してみましょう。

## パイプラインを削除して復元する

Concourse の Resource はすべて Concourse の外に保存されるため、パイプラインの移行や、ディザスタリカバリが非常に簡単です。

パイプラインを削除して再作成してみます:

```
fly -t bucc destroy-pipeline -p versions-and-buildnumbers

fly -t bucc sp -p versions-and-buildnumbers -c pipeline-bump-then-save.yml
fly -t bucc up -p versions-and-buildnumbers
fly -t bucc trigger-job -j versions-and-buildnumbers/bump-version -w
```

新しいパイプラインは、`#1` として内部ビルドナンバーを再開していますが、以前の `version` の値は変わらず復元されていることが分かります。

![bump-version-restoration](/images/bump-version-restoration.png)
