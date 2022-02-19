description: Task の `inputs` は、前までに実行された Task の `outputs` から利用することもできます。Task が出力を発行すると宣言しておけば、後続のステップで同じ名前を指定することで、`inputs` として使用することができるのです。
image_path: /images/pass-files.png

# 成功した Task の `outputs` を別の Task の `inputs` にする

[前のレッスン](job-inputs.md) の Task:`web-app-tests` は、Resource を`inputs`に使って、いくつかのユニットテストを実行しました。この Task では、成果物を何も生成しませんでしたが、Task によっては(このレッスンで扱う Task のことです)、あとで処理するために何か別の Task に渡すものを作成したいと考えるでしょう。そして時には Concourse の外へ渡すことも考えられます([次のレッスン](publishing-outputs.md)で扱います)。

これまで私たちが見てきたパイプラインの Task の `inputs` は、`get: resource-tutorial` の ビルド計画ステップを利用する Resource からきているものだけでした。

Task の `inputs` は、その前までに実行された Task の `outputs` を使うこともできます。前の Task が `outputs` と宣言すれば、後続のステップで同じ名前を指定することで、`inputs` として使用することができるのです。

Task ファイルは `outputs` セクションで、出力を利用可能にすることを宣言します:

```
outputs:
- name: some-files
```

Task が上のような `outputs` セクションを含んでいた場合、`run：` コマンドは何かしらのファイルを `some-files/` ディレクトリに入れる必要があります。

後の Task (このセクションで触れます)や Resource (次のセクションで触れます)は、`some-files/` ディレクトリの中に生成されたどんなファイルも参照できます。

```
cd ../task-outputs-to-inputs
fly -t tutorial set-pipeline -p pass-files -c pipeline.yml
fly -t tutorial unpause-pipeline -p pass-files
fly -t tutorial trigger-job -j pass-files/job-pass-files -w
```

このパイプラインの `job-pass-files` には、`create-some-files`、`show-some-files` の2つの Task のステップがあります:

![pass-files](/images/pass-files.png)

前者は4つのファイルを `some-files/` ディレクトリに作成します。 後者は、これらのファイルのコピーを `some-files/`のパスにある独自の Task コンテナのファイルシステムに入れます。

パイプラインのビルド計画では、2つの Task を特定の順序で実行することのみが示されています。 `some-files/` は、Task: `create-some-files` の `outputs` であり、次の Task の `inputs` として使われることを直接的には示していません。

```yaml
jobs:
- name: job-pass-files
  public: true
  plan:
  - get: resource-tutorial
  - task: create-some-files
    config:
      ...
      inputs:
      - name: resource-tutorial
      outputs:
      - name: some-files

      run:
        path: resource-tutorial/tutorials/basic/task-outputs-to-inputs/create_some_files.sh

  - task: show-some-files
    config:
      ...
      inputs:
      - name: resource-tutorial
      - name: some-files

      run:
        path: resource-tutorial/tutorials/basic/task-outputs-to-inputs/show_files.sh

```

注: `create-some-files` の 出力結果には、下記のエラーが含まれています:

```
mkdir: can't create directory 'some-files': File exists
```

これは、Task に `outputs` が含まれている場合、それらの出力ディレクトリが事前に作成され、作成する必要がないというデモンストレーションです。
