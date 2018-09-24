description: 最後に、実際の Pipeline を作ってみましょう。1つの Job が成功すると、別のジョブに結果を渡します。
image_path: /images/pipeline.png

# Actual Pipeline - Passing Resources Between Jobs

最後に、実際の Pipeline を作ってみましょう。1つの Job が成功すると、別のジョブに結果を渡します。

これまでのすべてのセクションで、私たちの Pipeline は1つの Job しか持っていませんでした。これまで説明した Pipeline の素晴らしさは、実際の"パイプライン"のようにはまだ感じられていません。Job 間で結果を渡しあえる Job こそ、Concourse がもっとも強く輝く場面です。

1番目の Job が正常終了するたびに実行される `job-show-date` という2番目のJobを追加し、Pipeline:`publishing-outputs` を更新します:

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

Pipeline を更新します:

```
cd ../pipeline-jobs
fly -t tutorial sp -p publishing-outputs -c pipeline.yml -l ../publishing-outputs/credentials.yml
fly -t tutorial trigger-job -w -j publishing-outputs/job-bump-date
```

`../publishing-outputs/credentials.yml` が見当たらない時は、前のレッスンの [Revisiting Publishing Outputs](/basics/parameters/#revisting-publishing-outputs) を参照してください。

ダッシュボード UI では、追加された Job とその Trigger / Triggerでない Resource が表示されています。重要なのは、このレッスンではじめて複数の Job を扱う Pipeline を触るということです:

![pipeline](/images/pipeline.png)

`job-show-date`で fetch された最新の `resource-gist` の commit は、最後に成功した Job:`job-bump-date` で使用された信用できる commit になります。 もし手作業で git commit を作成し、Job:`job-show-date` を手動で実行したとしても、以前に使用した commit を引き続き使用し、新しい commit は無視されます。 *これがパイプラインの力です。*

![trigger](/images/trigger.png)
