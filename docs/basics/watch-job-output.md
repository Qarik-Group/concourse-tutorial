description: fly CLI を利用して、実行中(または完了済)の Job のストリーミング出力を見ることができます。
image_path: /images/git-resource-in.png

# Watch Job Output in Terminal

`job-hello-world`の [job build](http://127.0.0.1:8080/teams/main/pipelines/helloworld/jobs/job-hello-world/builds/1)を見ると、`git`コマンドを実行して Gitリポジトリを clone した後に、Task:`hello-world` を実行した結果が出力されており、とても分かりやすいです。

![git-resource-in](/images/git-resource-in.png)

この出力内容は、ターミナルで`fly watch`コマンドを使っても見ることができます:

```
fly -t tutorial watch -j hello-world/job-hello-world
```

出力は次のようになります:

```
using version of resource found in cache
initializing
running echo hello world
hello world
succeeded
```

`--build NUM`オプションは、最新の build 出力ではなく、特定の build 番号の出力を見ることができます。

最近の build 結果は、すべての Pipeline を対象にした `fly builds` コマンドを使って確認します:

```
fly -t tutorial builds
```

出力は次のようになります:

```
3   hello-world/job-hello-world    1      succeeded  2016-26@17:22:13+1000  2016-26@17:22:23+1000  10s
2   one-off                       n/a    succeeded  2016-26@17:15:02+1000  2016-26@17:16:36+1000  1m34s
1   one-off                       n/a    succeeded  2016-26@17:13:34+1000  2016-26@17:14:11+1000  37s
```

`fly watch` コマンドは、ラップトップPCのバッテリーの節約になります。実は、Concourse Web UI で実行されているJobを見ていると、ターミナルで`fly watch`を実行するよりもバッテリー消費量が多いことが分かりました。あなたのPCでは、状態が異なる場合があるかもしれませんが。
