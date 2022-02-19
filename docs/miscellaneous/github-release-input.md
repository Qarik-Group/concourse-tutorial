# Github Release を input にする

Concourse の大きな特徴の1つは、他のプロジェクト起因のイベントを監視したり、それに基づいて Jobを起動することができるという点です。例えば、サブモジュールを更新された際に、プロジェクトをテストすることができますし、別の Github Release を、Job の起動用に監視することができます。

このセクションでは、Github Release を Job のトリガーとして利用する方法をご紹介します。

![github-release](/images/github-release.png)

## Resource Type

`github-release` Resource Type は、`user` と `repository` を必要とします。次の例は、https://github.com/starkandwayne/shield/releases の最新 Release を利用するケースです。

```yaml
resources:
- name: github-release-shield
  type: github-release
  source:
    user: starkandwayne
    repository: shield
```

## SHIELD とは?

[SHIELD](https://shieldproject.io/) は、すべてのデータサービスのバックアップ/復元システムです。マルチテナントであり、フライト中(Jobの実行中)、および休憩中の暗号化機能を提供します。オープンソースであり、Stark＆Wayne（この Concourse チュートリアルブックを書いた素敵な人たち）がスポンサードしています。

新しいバージョンが出たら、それを自動的にテストしてロールアウトしたいですよね? Concourse はパーフェクトにそれを実現します。

## パイプラインの設定

最新の Github Release と添付ファイルを取得する Job のビルド計画では、Job の plan の最初のステップ（または `aggregate`の最初のステップの一部）に以下のように記述します:

```yaml
- get: github-release-shield
```

同様に、SHIELD の新しい Release が存在するときに、Job を自動的に起動するには：

```yaml
- get: github-release-shield
  trigger: true
```

このパイプラインを試してみましょう:

```
cd tutorials/miscellaneous/github-release-input
fly -t bucc set-pipeline -p github-release-input -c pipeline.yml
fly -t bucc unpause-pipeline -p github-release-input
fly -t bucc trigger-job -j github-release-input/shield -w
```

Job を実行すると、`github-release` Resource は、Github Release から添付ファイルをダウンロードします:

```
./github-release-shield:
total 70328
-rw-r--r-- 1 root     1920 Dec 10 11:40 body
-rw-r--r-- 1 root  7781104 Dec 10 11:40 shield-darwin-amd64
-rw-r--r-- 1 root  7741099 Dec 10 11:40 shield-linux-amd64
-rw-r--r-- 1 root 56479093 Dec 10 11:41 shield-server-linux-amd64.tar.gz
-rw-r--r-- 1 root        6 Dec 10 11:40 tag
-rw-r--r-- 1 root        5 Dec 10 11:40 version
```

`tag` と `version` ファイルも含まれています。

- `tag`は、Github Release に使用されたオリジナルの git tag です。
- `version` は tag から外挿された SemVer のバージョン番号です（存在する場合は最初の`v`を削除しています）

この Job の例では、このファイルの内容も出力されます:

```
initializing
running cat github-release-shield/version
8.0.1succeeded
```

## 実装例

`github-release` Resource Type の使用例がもっと必要な場合は、https://github.com/starkandwayne/homebrew-cf/blob/master/ci/pipeline.yml を参照してください。

Stark&Wayne では、自社およびサードパーティの CLI を Homebrew と Debian パッケージとして各パッケージ化した Homebrew tap と Debian リポジトリ https://apt.starkandwayne.com を運用しています。

新しいバージョンがリリースされるたびに、私たちのパイプラインは自動的に Homebrew と Debian パッケージを更新しています。

[![github-release-debian-packages](/images/github-release-debian-packages.png)](http://ci.starkandwayne.com/teams/main/pipelines/homebrew-recipes?groups=debian)
