description: Concourseの基本的なコンセプトは、Taskを実行することです。 以下のようにコマンドラインから、またWebUIのパイプラインのJob画面から（チュートリアルの他のセクションでも同様に）直接実行することができます。
image_path: /images/build-output-hello-world.png


# Hello World

Concourseの基本的なコンセプトは、Taskを実行することです。 以下のようにコマンドラインから、またWebUIのパイプラインのJob画面から（チュートリアルの他のセクションでも同様に）直接実行することができます。

```
git clone https://github.com/starkandwayne/concourse-tutorial
cd concourse-tutorial/tutorials/basic/task-hello-world
fly -t tutorial execute -c task_hello_world.yml
```

Taskの実行結果は、以下のような出力から始まります。

```
executing build 1 at http://127.0.0.1:8080/builds/1
initializing
```

ConcourseのすべてのTaskは"コンテナ"の中で実行されます（正確には、"ターゲットとしたplatform"上で動作します）。 `task_hello_world.yml`の設定内容を見ると、` busybox`コンテナイメージを使って `linux`platform上で走っていることを示しています。 ログを見ると、Dockerイメージの `busybox`がダウンロードされていることが分かります。 これは一度だけ行う必要があります（最新の `busybox`イメージがあるたびに再チェックします）。

このコンテナ内では `echo hello world`コマンドを実行します。

Task:`task_hello_world.yml`は以下のようになっています:

```yaml
---
platform: linux

image_resource:
  type: docker-image
  source: {repository: busybox}

run:
  path: echo
  args: [hello world]
```

Taskが進むと、その後`echo hello world`が正常に呼び出されていることがわかります:

```
running echo hello world
hello world
succeeded
```

URL http://127.0.0.1:8080/builds/1 is viewable in the browser. It is another view of the same task.

表示されたURL http://127.0.0.1:8080/builds/1 を使うとWebUIでも実行結果を確認できます。CLIを使わずともTaskの実行結果を得られて便利です。

![build-output-hello-world](/images/build-output-hello-world.png)

## Task Docker Images

次に、`image_resource:` と `run:` を変更して、別のTaskを実行してみましょう:

```yaml
---
platform: linux

image_resource:
  type: docker-image
  source: {repository: ubuntu}

run:
  path: uname
  args: [-a]
```

このTaskは下記のファイル名で用意されています:

```
fly -t tutorial execute -c task_ubuntu_uname.yml
```

Taskの実行結果は、以下のようになります:

```
executing build 2 at http://127.0.0.1:8080/builds/2
initializing
...
running uname -a
Linux fdfa0821-fbc9-42bc-5f2f-219ff09d8ede 4.4.0-101-generic #124~14.04.1-Ubuntu SMP Fri Nov 10 19:05:36 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
succeeded
```

実行時のベースになる`image`([Task実行時](http://concourse-ci.org/running-tasks.html)における`image_resource`)を選択できるのは、Taskの実行に必要な依存関係の整理を行う為です。Taskの実行中に毎回依存する基本ライブラリなどをインストールするのではなく、`image`にあらかじめそれらを用意したものを用いることで、Taskを遥かに高速に実行することができます。

## Miscellaneous

Concourseを利用して新しいDockerImageを作成したい場合、[DockerImageの作成・利用](/miscellaneous/docker-images)をご覧ください。
