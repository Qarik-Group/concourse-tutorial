description: この一連のチュートリアルを通じて、https://concourse-ci.org の利用方法を学びましょう。個々のコンセプトに基づいて各コンテンツは構成されています。
image_path: /images/concourse-sample-pipeline.gif

# Concourse の ご紹介

この一連のチュートリアルを通じて、https://concourse-ci.org の利用方法を学びましょう。個々のコンセプトに基づいて各コンテンツは構成されています。

[![concourse-sample-pipeline](/images/concourse-sample-pipeline.gif)](https://concourse-ci.org/)

Concourse は 100% オープンソースの CI/CD システムであり、約 100 個の外部との [インテグレーション機能](https://concourse-ci.org/resource-types.html) を備えています.
Concourse の原則は、プロジェクトを CI の細かい作業と分離するプラクティスを奨励し、すべての設定をバージョン管理システムにチェックインできる宣言ファイルに保存することで、Concourse クラスタ間での乗換リスクを軽減することにあります。

この Concourse チュートリアルブックは、2015年以来、Concourse を学習するための世界で最も人気のあるコンテンツです。[Concourse 公式ドキュメント](https://concourse-ci.org/index.html)の良き友としてご利用ください。

## 謝辞

Concourse CI を開発した Alex Suraci と、2014年に彼と開発者チームをスポンサードしてくれた Pivotal に感謝します。

Stark＆Wayne では 2015年初頭に Concourse を学びながらこのチュートリアルを開始しました.2015年中頃からほぼすべてのクライアントプロジェクトで Concourse を使用していました。

このチュートリアルを体験して頂いている皆様にも感謝を申し上げます。皆様がこのチュートリアルを、また Concourse そのものを楽しんで頂ければ幸いです。

「後方互換性のない変更」が出てきたこれまでの Concourse バージョンで、問題を修正するのに貢献されたすべての PullRequest に感謝します。

この Concourse チュートリアルとその事例を長年にわたって維持してくれた Stark＆Wayne のスタッフ全員に感謝します。

カンファレンス等で Stark＆Wayne ブースを訪れ、「ありがとう、Concourse チュートリアル！」とお伝え頂いた皆様に感謝します。

## さあ、はじめよう！

1. [Docker](https://www.docker.com/community-edition) をインストールしてください。
2. もし Docker 中に含まれていない場合、[Docker Compose](https://docs.docker.com/compose/install/#install-compose) をインストールしてください。
3. Docker Compose を利用して、Concourse を下記のようにデプロイしてください:
    ```plain
    wget https://raw.githubusercontent.com/starkandwayne/concourse-tutorial/master/docker-compose.yml
    docker-compose up -d
    ```

### セットアップのテストを行う

Webブラウザで http://127.0.0.1:8080/ を開いてみましょう:

[![initial](/images/dashboard-no-pipelines.png)](http://127.0.0.1:8080/)

あなたのOSと同じ `fly` CLI をクリックしてダウンロードしてください。
ダウンロードが終わったら、`fly` バイナリをあなたのパス(`$PATH`)が通ったディレクトリ(例: `/usr/local/bin`, `~/bin`など) にコピーしましょう。実行権限を付与するのも忘れないでください。例を示します。

```plain
sudo mkdir -p /usr/local/bin
sudo mv ~/Downloads/fly /usr/local/bin
sudo chmod 0755 /usr/local/bin/fly
```

Windows ユーザの方は, [この記事](https://stackoverflow.com/questions/23400030/windows-7-add-path)の方法を利用して、`PATH` の中から `fly` を追加するフォルダを確認してください。

## Concourse をターゲットする

`fly` CLI は、毎回完全に同じ結果を得るために、完全に実行することを、完全に宣言するという精神に基づき、`fly` コマンドを打つ度にターゲットとなる API を指定する必要があります。

まず、

`fly` CLI は毎回全く同じ結果を得るために絶対に行うことを絶対に宣言する精神の中で、` fly` 要求ごとにターゲット API を指定する必要があります。

まず、`tutorial` という名前でエイリアスを作ります。（この名前はチュートリアルすべての Task スクリプトで利用します）:

```plain
fly --target tutorial login --concourse-url http://127.0.0.1:8080 -u admin -p admin
fly --target tutorial sync
```

このターゲットとして保存された Concourse API は、ローカルファイル上でも確認することができます。

```plain
cat ~/.flyrc
```

中身はAPI、認証情報などを含むシンプルな YAML ファイルで構成されています：

```yaml
targets:
  tutorial:
    api: http://127.0.0.1:8080
    team: main
    token:
      type: Bearer
      value: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJjc3JmIjoiYjE3ZDgxZmMwMWIxNDE1Mjk2OWIyZDc4NWViZmVjM2EzM2IyY2MxYWZjZjU3Njc1ZWYwYzY0MTM3MWMzNzI3OSIsImV4cCI6MTUyMjcwMjUwMCwiaXNBZG1pbiI6dHJ1ZSwidGVhbU5hbWUiOiJtYWluIn0.JNutBGQJMKyFzow5eQOTXAw3tOeM8wmDGMtZ-GCsAVoB7D1WHv-nHIb3Rf1zWw166FuCrFqyLYnMroTlQHyPQUTJFDTiMEGnc5AY8wjPjgpwjsjyJ465ZX-70v1J4CWcTHjRGrB1XCfSs652s8GJQlDf0x2hi5K0xxvAxsb0svv6MRs8aw1ZPumguFOUmj-rBlum5k8vnV-2SW6LjYJAnRwoj8VmcGLfFJ5PXGHeunSlMdMNBgHEQgmMKf7bFBPKtRuEAglZWBSw9ryBopej7Sr3VHPZEck37CPLDfwqfKErXy_KhBA_ntmZ87H1v3fakyBSzxaTDjbpuOFZ9yDkGA
```

`fly` コマンドを使うときに、` fly --target tutorial` と打つことで、このConcourse API をターゲットすることができます。

> @alexsuraci: 私は暗黙のターゲット状態を持つよりも、この方法が皆様のお気に召すことを約束します:) Shellのヒストリーからコマンドを再利用しても、これならさほど危険にならずに済むからです（誤ったflyの設定を使っていると悪になる可能性はあります）。

## Concourse を破棄する

`docker-compose up` を使ってデプロイしたローカル Concourse での作業を終えたら、`docker-compose down` を使ってそれを破棄することができます。

```plain
docker-compose down
```
