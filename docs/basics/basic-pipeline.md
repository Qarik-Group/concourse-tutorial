description: 'hello world' パイプラインを見てみましょう.
image_path: /images/job-hello-world.gif

# ベーシックなパイプライン

`fly execute`を利用してTaskを実行することはごくわずかです。殆どは "パイプライン" として実行される Task になります。

```
cd ../basic-pipeline
fly -t tutorial set-pipeline -c pipeline.yml -p hello-world
```

上記のコマンドを実行すると、Concourse はパイプライン(または任意の変更点)を表示し、確認を求めてきます:

```yaml
jobs:
  - name: job-hello-world
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
            args: [hello world]
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

パイプラインの URL [http://127.0.0.1:8080/teams/main/pipelines/hello-world](http://127.0.0.1:8080/teams/main/pipelines/hello-world) を開いてみましょう。

これは非公開(private) のパイプラインであり、まだあなたは Concourse Web UI にログインしていない状態です。そのためログインページにリダイレクトにされます。

![dashboard-login](/images/dashboard-login.png)

`docker-compose.yml`で設定した admin ユーザの認証情報を入力し、"login" を押すと、パイプラインのページにリダイレクトされます。

## パイプラインをポーズ解除(unpause) する

WebUIを見ると、あなたのパイプラインの上部に青色のバーが見えるはずです。これはpause(ポーズ)していることを意味します。すぐにトリガーが起動すると、Job の実行を開始する準備がまだ整っていない可能性があるため、新しいパイプラインはデフォルトでポーズ(pause) するようになっています。

![dashboard-pipeline-paused](/images/dashboard-pipeline-paused.png)

パイプラインを ポーズ解除(unpause) するには（または再度 pause するには)、2通りの方法があります。

1. 左上のプロペラアイコンを押してダッシュボード画面に戻り、パイプラインの再生(play) ボタンをクリックします。

    ![dashboard-hamburger-menu](/images/dashboard-hamburger-menu.png)

2. `fly unpause-pipeline` コマンドでも可能です (またはそのエイリアス`fly up`):

    ```
    fly -t tutorial unpause-pipeline -p hello-world
    fly -t tutorial unpause-job --job hello-world/job-hello-world
    ```

## はじめてのパイプライン

この1つめのパイプラインは、左からの入力、右への出力、いずれも持たない単一の Job:`job-hello-world` によって構成された、やや面白みに欠けるものです。

これはもっともベーシックなパイプラインです。まだ1度も実行されていないため、Job は灰色になっています。

`job-hello-world`をクリックして、 右上にある大きな`+`ボタンをクリックしましょう。Job が走り始めます。

![job](/images/job-hello-world.gif)

左上の "Home" アイコンをクリックすると、パイプラインのステータスを見ることができます。 Job:`hello-world` を見ると緑色になっているはずです。これは、Job が最後に実行された際、正常に完了したことを表しています。
