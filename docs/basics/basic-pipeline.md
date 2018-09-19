description: 'hello world' パイプラインを見てみましょう.
image_path: /images/job-hello-world.gif

# ベーシックなパイプライン

`fly execute`を利用してTaskを実行することはごくわずかです。殆どは"Pipeline"として実行されるTaskになります。

```
cd ../basic-pipeline
fly -t tutorial set-pipeline -c pipeline.yml -p hello-world
```

上記のコマンドを実行すると、ConcourseのPipeline(または任意の変更点)を表示し、確認を求めてきます:

```yaml
jobs:
  job job-hello-world has been added:
    name: job-hello-world
    public: true
    plan:
    - task: hello-world
      config:
        platform: linux
        image_resource:
          type: docker-image
          source: {repository: busybox}
        run:
          path: echo
          args:
          - hello world
```

`fly set-pipeline`（またはそのエイリアス`fly sp`）を実行するたびに、設定の変更を適用するよう求められます。

```
apply configuration? [yN]:
```

`y`を押しましょう。

以下のようなメッセージが表示されるはずです:

```
pipeline created!
you can view your pipeline here: http://127.0.0.1:8080/teams/main/pipelines/hello-world

the pipeline is currently paused. to unpause, either:
  - run the unpause-pipeline command
  - click play next to the pipeline in the web ui
```

## Concourse の Web UI にログインする

パイプラインのURL http://127.0.0.1:8080/teams/main/pipelines/hello-world を開いてみましょう。

これは非公開(private)のPipelineであり、まだあなたはConcourse Web UIにログインしていない状態です。そのためログインページにリダイレクトにされます。

![dashboard-login](/images/dashboard-login.png)

"Login" を押すと、Pipelineのページにリダイレクトされます。

_なぜ、ユーザ名とパスワードを入力する必要がなかったのでしょう？_ 実に良い質問です。これは、Concourseの現在の`fly -t tutorial`デプロイメントでは、認証が無効になっているからです。今後のレッスンでは、パスワード認証や機能的な認証方法を備えた、より堅牢なインストール方法によって構成されたConcourseにアップグレードしていきます。

## Pipeline を unpause する

WebUIを見ると、あなたのPipelineの上部に青色のバーが見えるはずです。これはpause(ポーズ)していることを意味します。すぐにTriggerが起動すると、Jobの実行を開始する準備がまだ整っていない可能性があるため、新しいPipelineはデフォルトでpauseするようになっています。

![dashboard-pipeline-paused](/images/dashboard-pipeline-paused.png)

Pipelineをunpause(ポーズ解除)するには（または再度pauseするには)、2通りの方法があります。

1. ハンバーガーメニューを開き、あなたのパイプラインの `>` (一時停止/再生ボタン) をクリックしてください。マークが変わったらハンバーガーメニューアイコンをクリックして、パイプラインのサイドバーを閉じてください。

    ![dashboard-hamburger-menu](/images/dashboard-hamburger-menu.png)

2. `fly unpause-pipeline` コマンドでも可能です (またはそのエイリアス`fly up`):

    ```
    fly -t tutorial unpause-pipeline -p hello-world
    fly -t tutorial unpause-job --job hello-world/job-hello-world
    ```

## はじめての Pipeline

この1つめの Pipeline は、左からの入力、右への出力、いずれも持たない単一の Job:`job-hello-world` によって構成された、やや面白みに欠けるものです。

これはもっともベーシックな Pipeline です。まだ1度も実行されていないため、Job は灰色になっています。

`job-hello-world`をクリックして、 右上にある大きな`+`ボタンをクリックしましょう。Job が走り始めます。

![job](/images/job-hello-world.gif)

左上の家の形をしたアイコンをクリックすると、Pipelineのステータスを見ることができます。 Job:`hello-world`を見ると緑色になっているはずです。これは、Jobが最後に実行されたときに、Jobが正常に完了したことを表しています。

注: このアニメーションGIFは若干古いものです。現在のConcourse Web UI は 少し違う表示になっています。
