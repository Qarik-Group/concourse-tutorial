description: Concourse には、データの保存/取得サービスはありません。git リポジトリはありません。Blobstore もありません。ビルド番号もありません。すべての入力と出力を、Concourse の外から提供する必要があるのです。Concourse ではそれを Resource と呼んでいます。Resource の例としては、それぞれ 'git'、 's3'、 'semver' などが挙げられます。
image_path: /images/resource-job.gif

# Resource について


YAMLファイル`pipeline.yml`の設定で、Job 中の Task を繰り返すことはとても高速に行えます。`pipeline.yml`を変更し、`fly set-pipeline`を実行することで、パイプライン全体が自動的に更新されます。

最初のレッスンでは、Task を1つの YAML ファイルとして(`fly execute`で実行可能なものとして)紹介しました。`pipeline.yml`では、これらの Task ファイルを利用するようにリファクタリングすることができます。

また、[Task スクリプトを別ファイルとして指定する](task-scripts.md) のレッスンでは、複雑な`run:` のコマンドの内容を、単独動作可能なシェルスクリプトファイルとして呼び出すやり方を学んできました。

しかしパイプラインでは、Task ファイルと Task スクリプトを、Concourse の外に保存しておく必要があります。

Concourse には、データの保存/取得をするサービスはありません。git リポジトリはありません。Blobstore もありません。ビルド番号もありません。すべての入力と出力を、Concourse の外から提供する必要があるのです。Concourse ではそれを "Resource" と呼んでいます。Resource の例としては、それぞれ 'git'、 's3'、 'semver' などが挙げられます。

Concourse にあらかじめビルドイン(組み込み)されている Resource と、Concourse コミュニティによって作られた Resource の一覧については、公式ドキュメントの[Resource Types](https://resource-types.concourse-ci.org)を参照してください。Slack にメッセージを送る、バージョン番号を0.5.6から1.0.0に bump(上げる) する、Pivotal Tracker にチケットを作る...このようなことはすべて、Concourse の Resource Type によって可能になります。このチュートリアルの [Miscellaneous](../miscellaneous/) セクションでも、一般的に有用とされる Resource Type について紹介しています。

Task ファイルと Task スクリプトを保存する最も一般的な Resource Type は `git` Resource Type です。もしくは、Taskファイル を AWS S3 上から `s3` Resource Type を介して入手することもできます。また、`archive` Resource Type を使用してリモートアーカイブファイルからそれらを抽出することも可能です。あるいは、Task ファイルを `image_resource`ベースのDockerImageに入れておくこともできるでしょう。とは言えほとんどの場合は、`git` Resource を使用して パイプライン の Task ファイルを取得することになるでしょう。

このチュートリアルのソースリポジトリは Git リポジトリで、多くの Task ファイル（と Task スクリプト）が含まれています。例えば、オリジナルは `tutorials/basic/task-hello-world/task_hello_world.yml` です。

Git リポジトリを pull するには、YAML ファイル `pipeline-resources/pipeline.yml` のトップレベルセクションに `resources` として追加します:

```yaml
resources:
- name: resource-tutorial
  type: git
  source:
    uri: https://github.com/starkandwayne/concourse-tutorial.git
    branch: develop
```

次に、`get: resource-tutorial` のステップを追加し、 `task: hello-world` ステップの `config:` セクションを `file: resource-tutorial/tutorials/basic/task-hello-world/task_hello_world.yml` で置き換えます。

```yaml
jobs:
- name: job-hello-world
  public: true
  plan:
  - get: resource-tutorial
  - task: hello-world
    file: resource-tutorial/tutorials/basic/task-hello-world/task_hello_world.yml
```

パイプラインの変更点を反映してみます:

```
cd ../pipeline-resources
fly -t tutorial set-pipeline -c pipeline.yml -p hello-world
fly -t tutorial unpause-pipeline -p hello-world
```

出力には、2つのパイプライン間の差分と変更確認のリクエストが表示されますので、yを押します。成功すると、次のように表示されます:

```
apply configuration? [yN]: y
configuration updated
```

パイプライン:[`hello-world`](http://127.0.0.1:8080/teams/main/pipelines/hello-world) は 取得した Resource `resource-tutorial` を、Job `job-hello-world` に送っていることがわかります。

![pipeline-resources](/images/resource-job.gif)

この Concourse チュートリアルでは、冗長ですが、Resource 名には `resource-`を、Job 名には `job-` を接頭辞としてつけることで、学習中の理解に役立つようにしています。学習が終わったら接頭辞を外しても、双方の位置付けが明確にわかることでしょう。

Web UI を介して Job を手動で実行すると、以下のように出力されます:

![job-task-from-task](/images/job-task-from-task.png)

進行中、または新規に完了となった `job-hello-world` の Job の画面には、3つのセクションがあります:

* Job の 実行準備 - 入力として指定したものと、依存関係の収集
* Resource `resource-tutorial` の読み込み
* Task `hello-world` の実行

後者の2つは、Job の [ビルド計画](http://concourse-ci.org/builds.html)の"ステップ"です。ビルド計画は、実行する一連のステップを指します。これらのステップにおいては、読込む(もしくは更新する)Resource や、実行したい Taskを定義していきます。

最初のビルド計画のステップでは、これらのトレーニング資料とチュートリアルのための `git` リポジトリを取得します（下の矢印に注意してください）。パイプラインはこの Resource に `resource-tutorial` という名前をつけ、同じ名前のディレクトリに Git リポジトリを clone します。 これはビルドプランで、後からこのフォルダ内のファイルを参照することを意味します。

Resource `resource-tutorial` は、Job のビルド計画で使用されます:

```yaml
jobs:
- name: job-hello-world
  public: true
  plan:
  - get: resource-tutorial
  ...
```

読み込まれた Resource は、 Job のビルド計画において、任意の Task で入力として利用できるようになります。 [Task への入力](task-inputs.md) と [Task スクリプト](task-scripts.md) で説明したとおり、Task への入力は Task スクリプトとして使用できます。

2番目のステップでは、ユーザが定義した Task を実行します。パイプライン上では `hello-world` と命名しました。 Task の中身は パイプライン上には記述されていませんが、その代わりに入力した `resource-tutorial` の `tutorials/basic/task-hello-world/task_hello_world.yml` に記述されています。

Job の全体像は以下のようになっています:

```yaml
jobs:
- name: job-hello-world
  public: true
  plan:
  - get: resource-tutorial
  - task: hello-world
    file: resource-tutorial/tutorials/basic/task-hello-world/task_hello_world.yml
```

Task `{task: hello-world, file: resource-tutorial/...}` は、読み込まれたすべての Resource に（そして、他の Task から出力された出力内容にも）アクセスできます。

Resource (Task の出力内容）の名前は、他の Task や 後続の Resource がアクセスするのに用いられます。

つまり、`hello-world` は、Resource `resource-tutorial` を通じて、`resource-tutorial/` パス配下にあるものにアクセスできるようになります。この Git リポジトリ内の `task_hello_world.yml` の相対パスは `tutorials/basic/task-hello-world/task_hello_world.yml` なので、`task: hello-world` は、これと `file: resource-tutorial/tutorials/basic/task-hello-world/task_hello_world.yml` の2つの内容を結合した状態で参照するように動作します。

Task を パイプライン外の YAML ファイルとして切り出して抽象化することには、メリット/デメリット双方あります。

1つ目のメリットは、Task の動作を主要な入力元の Resource と同期させることができる点です（例えば、テストを実行する Task, バイナリをビルドする Task などをもつソフトウェアプロジェクトの場合など）。

1つ目のデメリットは、`pipeline.yml` が呼び出されるコマンドを正確には説明しなくなる点です。潜在的に、パイプラインの動作を理解するポイントが減少することになります。

2つ目のメリットは、`pipeline.yml`が長くなり、YAML ファイルすべてを読み込んで理解することが難しくなるのを避ける意味もあります。代わりに、Task に長い名前をつけることで、YAML の読者が Task の目的と期待する動作が一目でわかるようにすると良いでしょう。

2つ目のデメリットは、`fly set-pipeline` が、パイプラインを更新する唯一の手段ではなくなってしまう、ということです。

よって、これから パイプラインを変更する際は、下記の1つ目、もしくは両方を実行する必要があります:

* `fly set-pipeline`: Job のビルド計画や、入力/出力する Resource の Concourse 上の情報更新
* `git commit` and `git push`: Task ファイルや Task スクリプトが含まれた主要な Git リポジトリ

パイプラインが新しい動作を実行できなかった場合、上記の2つのいずれかを飛ばしてしまった可能性があります。

インラインな Task の構成と、YAML ファイルの Task の構成は、上述の通り、双方メリット/デメリットがあるため、この Concourse チュートリアルや Concourse コミュニティ全体で見ても、両方のアプローチが使用されています。
