description: Job が起動される主な方法は、Resource の変更によるものです。 'git'リポジトリに新しいコミットがありますか？ Job を実行してテストしましょう。 GitHub Project が新しい Release を作成していますか？ Job を実行して、添付ファイルをダウンロードするなどしてみましょう。
image_path: /images/resource-trigger.png

# Resource を使って Job を起動する

Job が起動される主な方法は、Resource の変更を検出したことによるものがほとんどです。 'git'リポジトリに新しいコミットがありますか？ Job を実行してテストしましょう。 GitHub Project が新しい Release を作成していますか？ Job を実行して、添付ファイルをダウンロードするなどしてみましょう。

起動に使われる Resource は、先の `concourse-tutorial` のような trigger が定義されていない Resource と同じように定義できます。

その違いは、ビルド計画の中に "トリガー(trigger)" が設定されているか否かというだけです。

デフォルトでは、ビルド計画に `get: my-resource` を含めても Job は起動しません。

Resource の変更をトリガーに Job が起動するように計画するには、 これに加えて `trigger: true` を追加します。

```yaml
jobs:
- name: job-demo
  plan:
  - get: resource-tutorial
    trigger: true
```

上記の例では、`job-demo` は、リモートの `resource-tutorial` が新しい "バージョン" を持っていたときに常に起動します。`git` Resource の場合、これは新しい git のコミットが "バージョン" として扱われます。

`time` Resource は、Job にトリガーを設置するのを主目的とした Resource です。

Job を数分ごとに起動させたい、と言ったケースにこそ、[`time` Resource](https://github.com/concourse/time-resource#readme) が利用できます。

```yaml
resources:
- name: my-timer
  type: time
  source:
    interval: 2m
```

ここでは、パイプライン `hello-world` を、`time` をトリガーにするように変更してみましょう。unpause も忘れずに実行します。

```
cd ../triggers
fly set-pipeline -t tutorial -c pipeline.yml -p hello-world
fly unpause-pipeline -t tutorial -p hello-world
```

`my-timer` という新しい Resource を追加し、約2分おきに `job-hello-world` を起動します。

[パイプラインのダッシュボード](http://127.0.0.1:8080/teams/main/pipelines/hello-world) を見てみましょう。 数分待つと、Job が自動的に実行されているのがわかるはずです。

![resource-trigger](/images/resource-trigger.png)

ダッシュボードの UI は、トリガーではない Resource を点線で区別して表示しており、それらを Job に接続させています。トリガーが設定されている場合、実線で表示されています。

_`interval：2m`で設定された` time` Resource が「約」2分おきに trigger されるのはなぜですか？_

> Resource は 毎分チェックされますが、ビルドをいつ実行するかを決めるために短い(10秒程度の)間隔があります。Resource は、ある大まかな周期で Job が確実に実行されるようにするためのものです。例えば、スノーフレークを取り除くために継続的なインテグレーション/受け入れテストを実行するために使ったりするような用途で利用するのです - alex

結果として、`2m`のタイマーは、2~3分おきにトリガーされることになります。
