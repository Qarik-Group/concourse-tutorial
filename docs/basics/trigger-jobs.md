description: Job を起動させる4つの方法をご紹介します。

# Job を起動する

Job を起動する( "trigger" する)には4つの方法があります:

* Job の WebUI 上の `+` ボタンをクリックする(前のセクションで触れた通りです)
* Resource の検出から Job を起動する(これは次のレッスン [Resource から Job を起動する](/basics/triggers/) でご紹介します)
* `fly trigger-job -j pipeline/jobname` コマンド
* `POST` の HTTP リクエストを Concourse API に送る

以下のコマンドで、Pipeline `hello-world` の `job-hello-world` をもう1度起動することができます:

```
fly -t tutorial trigger-job -j hello-world/job-hello-world
```

Job が実行されている間（そして完了した後）、ターミナルで `fly watch` コマンドを使ってログの出力結果を見ることができます:

```
fly -t tutorial watch -j hello-world/job-hello-world
```

あるいは、2つのコマンドを組み合わせることもできます - Jobを起動し、`trigger-job -w` フラグで出力を監視します:

```
fly -t tutorial trigger-job -j hello-world/job-hello-world -w
```

次のレッスンでは、指定された Resource の変更が検出をトリガーにして、Job を起動する方法を学習します。
