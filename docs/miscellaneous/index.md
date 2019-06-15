# はじめに

このセクションでは、ここまでの Basic レッスンに続く、様々なレッスンをご用意しました。

Concourse では 資格情報マネージャを使用するのがベストプラクティスです。これ以降は、[秘密パラメータを資格情報マネージャで管理する](/basics/secret-parameters.md) の `bucc` を実行し続けることを前提としています。

したがって、この後のレッスンには `fly -t tutorial` コマンドではなく、` fly -t bucc` コマンドを利用します。

また、レッスンでは `credhub set` コマンドを使用して、パイプラインのパラメータを設定します。

もちろん、資格証明マネージャの有無にかかわらず、Concourse を使用することができます。あなたがターゲットした Concourse の `fly -t bucc` のターゲットを変更し、` -v` または `-l` フラグで `fly set-pipeline` を使ってコマンドラインからパラメータを渡すことができます。 詳細は、[パラメータを利用する](/basics/parameters.md) のレッスンを参照してください。

## パイプライン表記の省略

Basic セクションでは、すべての Concourse パイプライン中の Resource に `resource-`、Jobに `job-` という接頭辞がが付いていました。これは、それらが異なっていることを簡単に理解し、それぞれがパイプラインの中で、どのように使用されているかを理解を助けるためでした:

* Resource は、`get: myresource` と `put: myresource` を介して Job 内に表現される
* Job は、Job の中で `passed: [myjob]` として パイプラインを形成する

通常のパイプラインには、これらの接頭辞は含まれません。今後のレッスンでは、これらの接頭辞は含まれませんので注意してください。

## レッスンのリクエスト

この　Concourse チュートリアルに追加したいレッスンがある場合は、[create an Issue](https://github.com/starkandwayne/concourse-tutorial/issues) をご利用ください。あなたやあなたのチームがどのように Concourse を活用しているか、または以前の CI/CD ツールから Concourse への切り替えを検討することを我々が理解するのは、とても大切なことだと考えています。
