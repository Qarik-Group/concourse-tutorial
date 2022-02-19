description: fly CLI を利用して、実行中(または完了済)の Job のストリーミング出力を見ることができます。
image_path: /images/git-resource-in.png

# Job の出力結果をターミナルで確認する

`job-hello-world`の [ビルドページ](http://127.0.0.1:8080/teams/main/pipelines/hello-world/jobs/job-hello-world/builds/1) を見ると、`git` コマンドを実行して Git リポジトリを clone した後に、Task:`hello-world` を実行した結果が分かりやすく表示されます。

![git-resource-in](/images/git-resource-in.png)

この出力内容は、ターミナルで `fly watch` コマンドを使っても見ることができます:

```
fly -t tutorial watch -j hello-world/job-hello-world
```

出力結果は次のようになります:

```
using version of resource found in cache
initializing
running echo hello world
hello world
succeeded
```

`--build NUM` オプションは、最新のビルド出力ではなく、特定のビルド番号の出力結果を見ることができます。

最近のビルド結果は、すべてのパイプラインを対象にした `fly builds` コマンドを使って確認します:

```
fly -t tutorial builds
```

出力結果は次のようになります:

```
3   hello-world/job-hello-world    1      succeeded  2016-26@17:22:13+1000  2016-26@17:22:23+1000  10s
2   one-off                       n/a    succeeded  2016-26@17:15:02+1000  2016-26@17:16:36+1000  1m34s
1   one-off                       n/a    succeeded  2016-26@17:13:34+1000  2016-26@17:14:11+1000  37s
```

`fly watch` コマンドは、ラップトップPCのバッテリーの節約になります。実は、Concourse Web UI で実行されているジョブを見ていると、ターミナルで`fly watch`を実行するよりもバッテリー消費量が多いことが分かりました。あなたのPCでは、状態が異なる場合があるかもしれませんが。
