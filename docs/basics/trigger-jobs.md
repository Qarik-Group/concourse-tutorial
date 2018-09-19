description: Job を起動させる4つの方法をご紹介します。

# Trigger Jobs

Job を起動する(trigger する)には4つの方法があります:

* Job の WebUI 上の `+` ボタンをクリックする(前のセクションで触れた通りです)
* Job を trigger する Resource を入力します(これは次のレッスン [Triggering Jobs with Resources](/basics/triggers/) でご紹介します)
* `fly trigger-job -j pipeline/jobname` コマンド
* `POST` の HTTP リクエストを Concourse API に送る

この方法で、Pipeline `hello-world` の `job-hello-world` を再起動することができます:

```
fly -t tutorial trigger-job -j hello-world/job-hello-world
```

Job が実行されている間（そして完了した後）、ターミナルで `fly watch`コマンドを使って出力結果を見ることができます:

```
fly -t tutorial watch -j hello-world/job-hello-world
```

あるいは、2つのコマンドを組み合わせることもできます - Jobを trigger し、`trigger-job -w` フラグで出力を監視します:

```
fly -t tutorial trigger-job -j hello-world/job-hello-world -w
```

次のレッスンでは、入力された Resource が変更された後に、Job を 起動する方法を学習します。
