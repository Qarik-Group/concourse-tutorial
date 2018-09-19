description: Pipeline、それに含まれる Job や Resource を破棄する方法について。

# Destroying Pipelines

今の `hello-world` Pipeline は、2〜3分ごとに永遠に起動し続けます。 あなたがパイプラインを破壊し、すべての Build 履歴を消滅させたい場合、その力があなたには与えられています。

下記のように、`fly destroy-pipeline` コマンドで、`hello-world` Pipelineを削除することが可能です:

```
fly -t tutorial destroy-pipeline -p hello-world
```
