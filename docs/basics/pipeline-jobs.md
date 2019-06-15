description: 最後に、実際のパイプラインを作ってみましょう。1つの Job が成功すると、別のジョブに結果を渡します。
image_path: /images/pipeline.png

# リアルなパイプライン - 複数の Job で Resource を共有する

最後に、現場で使えるようなリアルなパイプラインを作ってみましょう。1つの Job が成功すると、別の Job に結果を渡すものを見てみます。

これまでのすべてのセクションで、私たちの パイプライン は単一の Job しか使っていませんでした。これまで説明したパイプラインの素晴らしさは、文字通り "パイプライン" のようには感じません。Job 間で結果を渡しあう Job こそ、Concourse の真骨頂です。

1番目の Job が正常終了するたびに実行される `job-show-date` という2番目の Job を追加し、パイプライン:`publishing-outputs` を更新します:

```yaml
- name: job-show-date
  plan:
  - get: resource-tutorial
  - get: resource-gist
    passed: [job-bump-date]
    trigger: true
  - task: show-date
    config:
      platform: linux
      image_resource:
        type: docker-image
        source: {repository: busybox}
      inputs:
        - name: resource-gist
      run:
        path: cat
        args: [resource-gist/bumpme]
```

パイプラインを更新します:

```
cd ../pipeline-jobs
fly -t tutorial sp -p publishing-outputs -c pipeline.yml -l ../publishing-outputs/credentials.yml
fly -t tutorial trigger-job -w -j publishing-outputs/job-bump-date
```

`../publishing-outputs/credentials.yml` が見当たらない時は、前のレッスンの [成果物アップロード時のパラメータも設定する](/basics/parameters/#revisting-publishing-outputs) を参照してください。

ダッシュボード UI では、追加された Job とその Trigger / 非Trigger の Resource が表示されています。重要なのは、このレッスンではじめて複数の Job を扱うパイプラインに触れたということです:

![pipeline](/images/pipeline.png)

`job-show-date`で fetch された最新の `resource-gist` の commit は、最後に成功した Job:`job-bump-date` で使用された、信頼できる commit になります。 もし手作業で git commit を作成し、Job:`job-show-date` を手動で実行したとしても、以前に使用した commit を引き続き使用し、新しい commit は無視されます。 *これがパイプラインの力です。*

![trigger](/images/trigger.png)
