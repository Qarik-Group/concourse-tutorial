description: Learn to use https://concourse-ci.org with this linear sequence of tutorials. Learn each concept that builds on the previous concept.
image_path: /images/concourse-sample-pipeline.gif

# Concourse の ご紹介

この一連のチュートリアルを通じて、https://concourse-ci.org の利用方法を学びましょう。個々のコンセプトに基づいて各コンテンツは構成されています。

[![concourse-sample-pipeline](/images/concourse-sample-pipeline.gif)](https://concourse-ci.org/)

Concourse は 100% オープンソースの CI/CD システムであり
、約100個の外部との [インテグレーション機能](https://concourse-ci.org/resource-types.html) を備えています.
Concourseの原則は、プロジェクトをCIの細かい作業と分離するプラクティスを奨励し、すべての設定をバージョン管理システムにチェックインできる宣言ファイルに保存することで、Concourseクラスタ間での乗換リスクを軽減することにあります。

このConcourseチュートリアルブックは、2015年以来、Concourseを学習するための世界で最も人気のあるコンテンツです。[Concourse公式ドキュメント](https://concourse-ci.org/index.html)の良き友としてご利用ください。

## 謝辞

Concourse CIを開発したAlex Suraciと、2014年に彼と開発者チームをスポンサードしてくれたPivotalに感謝します。

Stark＆Wayneでは2015年初頭にConcourseを学びながらこのチュートリアルを開始しました.2015年中頃からほぼすべてのクライアントプロジェクトでConcourseを使用していました。

このチュートリアルを体験して頂いている皆様にも感謝を申し上げます。皆様がこのチュートリアルを、またConcourseそのものを楽しんで頂ければ幸いです。

「後方互換性のない変更」が出てきたこれまでのConcourseバージョンで、問題を修正するのに貢献されたすべてのPullRequestに感謝します。

このConcourseチュートリアルとその事例を長年にわたって維持してくれたStark＆Wayneのスタッフ全員に感謝します。

カンファレンス等でStark＆Wayneブースを訪れ、「ありがとう、Concourseチュートリアル！」とお伝え頂いた皆様に感謝します。

## さあ、はじめよう！

1. [Docker](https://www.docker.com/community-edition)をインストールしてください。
2. もしDockerの中に含まれていない場合、[Docker Compose](https://docs.docker.com/compose/install/#install-compose)をインストールしてください。
3. Docker Composeを利用して、Concourseを下記のようにデプロイしてください:
    ```plain
    wget https://raw.githubusercontent.com/starkandwayne/concourse-tutorial/master/docker-compose.yml
    docker-compose up -d
    ```

### セットアップのテストを行う

Webブラウザで http://127.0.0.1:8080/ を開いてみましょう:

[![initial](/images/dashboard-no-pipelines.png)](http://127.0.0.1:8080/)

あなたのOSと同じ `fly` CLI をクリックしてダウンロードしてください。
ダウンロードが終わったら、`fly` バイナリをあなたのパス(`$PATH`)が通ったディレクトリ(例: `/usr/local/bin`, `~/bin`など) にコピーしましょう。実行権限を付与するのも忘れないでください。コマンド例を示します。

```plain
sudo mkdir -p /usr/local/bin
sudo mv ~/Downloads/fly /usr/local/bin
sudo chmod 0755 /usr/local/bin/fly
```

Windowsユーザの方は, [この記事](https://stackoverflow.com/questions/23400030/windows-7-add-path)の方法を利用して、`PATH`の中から`fly`を追加するフォルダを確認してください。

## Concourseをターゲットする

`fly` CLIは、毎回完全に同じ結果を得るために、完全に実行することを、完全に宣言するという精神に基づき、`fly`コマンドを打つ度にターゲットとなるAPIを指定する必要があります。

まず、

`fly` CLIは毎回全く同じ結果を得るために絶対に行うことを絶対に宣言する精神の中で、` fly`要求ごとにターゲットAPIを指定する必要があります。

まず、`tutorial`という名前でエイリアスを作ります。（この名前はチュートリアルすべてのタスクスクリプトで利用します）:

```plain
fly --target tutorial login --concourse-url http://127.0.0.1:8080
fly --target tutorial sync
```

このターゲットとして保存された Concourse APIは、ローカルファイル上でも確認することができます。

```plain
cat ~/.flyrc
```

中身はAPI、認証情報などを含むシンプルなYAMLファイルで構成されています：

```yaml
targets:
  tutorial:
    api: http://127.0.0.1:8080
    team: main
    token:
      type: Bearer
      value: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJjc3JmIjoiYjE3ZDgxZmMwMWIxNDE1Mjk2OWIyZDc4NWViZmVjM2EzM2IyY2MxYWZjZjU3Njc1ZWYwYzY0MTM3MWMzNzI3OSIsImV4cCI6MTUyMjcwMjUwMCwiaXNBZG1pbiI6dHJ1ZSwidGVhbU5hbWUiOiJtYWluIn0.JNutBGQJMKyFzow5eQOTXAw3tOeM8wmDGMtZ-GCsAVoB7D1WHv-nHIb3Rf1zWw166FuCrFqyLYnMroTlQHyPQUTJFDTiMEGnc5AY8wjPjgpwjsjyJ465ZX-70v1J4CWcTHjRGrB1XCfSs652s8GJQlDf0x2hi5K0xxvAxsb0svv6MRs8aw1ZPumguFOUmj-rBlum5k8vnV-2SW6LjYJAnRwoj8VmcGLfFJ5PXGHeunSlMdMNBgHEQgmMKf7bFBPKtRuEAglZWBSw9ryBopej7Sr3VHPZEck37CPLDfwqfKErXy_KhBA_ntmZ87H1v3fakyBSzxaTDjbpuOFZ9yDkGA
```

`fly`コマンドを使うときに、` fly --target tutorial`と打つことで、このConcourse APIをターゲットにできます。

> @alexsuraci: 私は暗黙のターゲット状態を持つよりも、この方法が皆様のお気に召すことを約束します:) Shellのヒストリーからコマンドを再利用しても、これならさほど危険にならずに済むからです（誤ったflyの設定を使っていると悪になる可能性はあります）。

## Concourseを破棄する

`docker-compose up`を使ってデプロイしたローカルConcourseでの作業を終えたら、`docker-compose down`を使ってそれを破棄することができます。

```plain
docker-compose down
```
