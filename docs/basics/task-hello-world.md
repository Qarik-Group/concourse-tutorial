description: Concourseの基本的なコンセプトは、Taskを実行することです。 以下のようにコマンドラインから、またWebUIのパイプラインのJob画面から（チュートリアルの他のセクションでも同様に）直接実行することができます。
image_path: /images/build-output-hello-world.png


# Hello World

Concourse の基本的なコンセプトは、Task を実行することです。 以下のようにコマンドラインから、また WebUI のパイプラインの Job 画面から（チュートリアルの他のセクションでも同様に）直接実行することができます。

From the same directory in which you previously deployed the Docker Concourse image (verify by running `ls -l` and looking for the `docker-compose.yml` file), start the local Concourse server.

```
docker-compose up
```

Now clone the Concourse Tutorial repo, switch to the task-hello-world directory, and run the command to execute the `task_hello_world.yml` task.

```
git clone https://github.com/starkandwayne/concourse-tutorial.git
cd concourse-tutorial/tutorials/basic/task-hello-world
fly -t tutorial execute -c task_hello_world.yml
```

Task の実行結果は、以下のような出力から始まります。

```
executing build 1 at http://127.0.0.1:8080/builds/1
initializing
```

Concourse のすべての Task は"コンテナ"の中で実行されます（正確には、"ターゲットとした platform" 上で動作します）。 `task_hello_world.yml` の設定内容を見ると、`busybox` コンテナイメージを使って `linux` platform 上で走っていることを示しています。 ログを見ると、Docker イメージの `busybox` がダウンロードされていることが分かります。 これは一度だけ行う必要があります（最新の `busybox` イメージがあるたびに再チェックします）。

このコンテナ内では `echo hello world` コマンドを実行します。

Task:`task_hello_world.yml` は以下のようになっています:

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

Task が進むと、その後 `echo hello world` が正常に呼び出されていることがわかります:

```
running echo hello world
hello world
succeeded
```

表示されたURL http://127.0.0.1:8080/builds/1 を使うと WebUI でも実行結果を確認できます。CLI を使わずとも Task の実行結果を得られて便利です。

---
**NOTE**

You'll need to login to Concourse to view this page. The default credentials are `admin / admin`

---


![build-output-hello-world](/images/build-output-hello-world.png)

## Task の Docker イメージ

次に、`image_resource:` と `run:` を変更して、別の Task を実行してみましょう:

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

この Task は下記のファイル名で用意されています:

```
fly -t tutorial execute -c task_ubuntu_uname.yml
```

Task の実行結果は、以下のようになります:

```
executing build 2 at http://127.0.0.1:8080/builds/2
initializing
...
running uname -a
Linux fdfa0821-fbc9-42bc-5f2f-219ff09d8ede 4.4.0-101-generic #124~14.04.1-Ubuntu SMP Fri Nov 10 19:05:36 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
succeeded
```

実行時のベースになる`image`([Task 実行時](http://concourse-ci.org/tasks.html#running-tasks) における`image_resource`) を選択できるのは、Task の実行に必要な依存関係の整理を行う為です。Task の実行中に毎回依存する基本ライブラリなどをインストールするのではなく、`image` にあらかじめそれらを用意したものを用いることで、Task を遥かに高速に実行することができます。

## ちなみに

Concourse を使って新しい Docker イメージを作成したい場合、[Docker イメージの作成・利用](../miscellaneous/docker-images.md) をご覧ください。
