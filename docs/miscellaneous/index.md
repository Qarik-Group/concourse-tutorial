# Introduction

このセクションでは、ここまでの Basic レッスンに続く、様々なレッスンをご用意しました。

Concourse では 資格情報マネージャを使用するのがベストプラクティスです。これ以降は、[Secrets with Credentials Manager](/basics/secret-parameters.md) の `bucc` を実行し続けることを前提としています。

したがって、この後のレッスンには `fly -t tutorial` コマンドではなく、` fly -t bucc` コマンドを利用します。

また、レッスンでは `credhub set` コマンドを使用して、Pipeline のパラメータを設定します。

もちろん、資格証明マネージャーの有無にかかわらず、Concourse を使用することができます。あなたがターゲットした Concourse の `fly -t bucc` のターゲットを変更し、` -v` または `-l` フラグで `fly set-pipeline` を使ってコマンドラインからパラメータを渡すことができます。 詳細は、[Parameters](/basics/parameters.md) のレッスンを参照してください。

## Abbreviated pipelines

Basic セクションでは、すべての Concourse の Pipeline の中の Resource に `resource-` という接頭辞があり、Jobにも `job-` が付いていました。これは、それらが異なっていることを簡単に理解し、それぞれが Pipeline の中で、どのように使用されているかを理解を助けるためでした:

In the Basics section, all Concourse pipeline resources had names prefixed with `resource-` and jobs prefixed with `job-`. This was to help you easily learn that they are different, and start to see how each is used within a pipeline:

* Resource は、`get: myresource` と `put: myresource` を介して Job 内に表現される
* Job は、Job の中で `passed: [myjob]` として Pipeline を形成する

通常の Pipeline には、これらの接頭辞は含まれません。今後のレッスンでは、これらの接頭辞は含まれませんので注意してください。

## Requests for Lessons

Concourse Tutorial ブックに追加したいレッスンがある場合は、[create an Issue](https://github.com/starkandwayne/concourse-tutorial/issues) をご利用ください。あなたやあなたのチームがどのように Concourse を活用しているか、または以前の CI/CD ツールから Concourse への切り替えを検討することを我々が理解するのは、とても大切なことだと考えています。
