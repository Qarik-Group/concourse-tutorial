description: パイプライン、それに含まれる Job や Resource を破棄する方法について。

# パイプラインを削除する

今の `hello-world` パイプライン は、2〜3分ごとに永遠に起動し続けます。 あなたがパイプラインを削除し、すべてのビルド履歴を消去したい場合、その力があなたには与えられています。

下記のように、`fly destroy-pipeline` コマンドで、`hello-world` パイプラインを削除することが可能です:

```
fly -t tutorial destroy-pipeline -p hello-world
```
