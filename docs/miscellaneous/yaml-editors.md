# パイプラインと Task 編集用のエディタ

パイプラインのサイズが大きくなると、yml を編集するのが非常に難しくなります。 また、インデントのミスやパラメータ不足は、パイプライン設定/実行のエラーの元になります。こうしたチェックには[`validate-pipeline`](https://concourse-ci.org/setting-pipelines.html#fly-validate-pipeline) を使うことができますが、開発前にあらかじめエラーを即ハイライトしてくれるエディタがあると捗ります。これは、IDE の構文エラーのハイライト機能に近いものです。 このセクションでは、Concourse のパイプラインと Task の yml の編集に使用できるエディタをご紹介します。

## Visual Studio Code
---------------------
![vscode](/images/vscode-concourse.png)

 [`ここ`](https://code.visualstudio.com/download) から Visual Studio Code をダウンロードし、パイプラインと Task の yml を自由に編集することができます。ダウンロードしたら、Concourse CI パイプラインEditor を [`ここ`](https://marketplace.visualstudio.com/items?itemName=Pivotal.vscode-concourse) からインストールしましょう。 Concourse CI の パイプラインおよび Task 設定の yml ファイルのバリデーションとコンテンツアシストを提供します。これはパラメータや構文エラーを自動的にサジェストしてくれる機能です。

### 機能

機能は次のとおりです:

#### バリデーション

タイピングするとテキストがパースされ、基本的な構文上および構造上の正確性がチェックされます。説明を表示したい時は、エラーマーカーにカーソルを合わせます。

#### コンテンツアシスト

属性のすべての名前やそのスペルを覚えられないと思ったことはありませんか？
または、取得する Task のパラメータと、ソース属性のどちらに設定する Resource プロパティだったかを覚えられないといったことはありませんでしたか？ または、特定のプロパティに「特別な」値が受け入れ可能であることを忘れていたことはありませんか？ コンテンツアシストは、これらに対する解決方法です。

#### ホバードキュメント

各属性の意味が何であるかを正確に覚えられないと思ったことはありませんか？ そういった場合、属性にカーソルを置いて詳細なドキュメントを読むことができます。

[`この`](https://marketplace.visualstudio.com/items?itemName=Pivotal.vscode-concourse) プラグインのページで、さらに詳細な情報と制限事項を確認できます。

## Atom
---------------------
![atom](/images/atom-concourse.gif)

[`ここ`](https://atom.io) から Atom をダウンロードし、パイプラインと Task の yml を自由に編集することができます。ダウンロードしたら、concourse-vis プラグインを[`ここ`](https://atom.io/packages/concourse-vis) からインストールしましょう。これは、Atom 上で Concourse パイプラインをプレビューするためのプラグインです。Atom のもう一つの利点は、`set-pipeline` を使う前に、とてもクールに Concourse パイプラインのプレビューを確認できる点です。

[`この`](https://atom.io/packages/concourse-vis) プラグインのページで、さらに詳細な情報と制限事項を確認できます。
