description: Concourseは、処理の中にファイル/フォルダを渡すための `inputs` を用意しています。

# Task `inputs` について

前のセクションの Task では、実行時に利用できた入力方法は、`image` を使ったものだけでした。Docker イメージなどのベースイメージと呼ばれるものは比較的静的でサイズが大きく、作成には時間がかかってしまいます。そのため、Concourse には処理の中に都度ファイル/フォルダを渡せる `inputs` という項目が用意されています。

特に `inputs` のない Task の作業ディレクトリを見てみましょう:

```
cd ../task-inputs
fly -t tutorial e -c no_inputs.yml
```

この Task は `ls -al` を実行し、コンテナ内の作業フォルダの内容(空)を表示します:

```
running ls -al
total 8
drwxr-xr-x    2 root     root          4096 Feb 27 07:23 .
drwxr-xr-x    3 root     root          4096 Feb 27 07:23 ..
```

注: 上記の例では短縮形の `execute` コマンド `e` を使用しています。このように、多くのコマンドに短縮文字の形式があります。たとえば、**fly s ** は **fly sync** のエイリアスです。

Taskの例 `inputs_required.yml` では、1つの入力を加えています:

```yaml
inputs:
- name: some-important-input
```

Taskを実行しようとすると...:

```
fly -t tutorial e -c inputs_required.yml
```

失敗します:

```
error: missing required input `some-important-input`
```

通常、`fly execute`を実行したい場合、手元のローカルフォルダ（` .`）の内容を渡したいと考えるはずです。そのため、`-i name=path`オプションを使用して、必要な`inputs`にそれぞれパスを設定してみてください：

```
fly -t tutorial e -c inputs_required.yml -i some-important-input=.
```

これで`fly execute`コマンドは`.`ディレクトリをコンテナへの入力内容としてアップロードします。`some-important-input`のパスで利用可能になります:

```
running ls -alR
.:
total 12
drwxr-xr-x    3 root     root          4096 Dec 18 02:35 .
drwxr-xr-x    3 root     root          4096 Dec 18 02:35 ..
drwxr-xr-x    1 root     root          4096 Dec 18 02:35 some-important-input

./some-important-input:
total 24
drwxr-xr-x    1 root     root          4096 Dec 18 02:35 .
drwxr-xr-x    3 root     root          4096 Dec 18 02:35 ..
-rw-r--r--    1 501      20             156 Dec  9 22:26 input_parent_dir.yml
-rw-r--r--    1 501      20             162 Dec  9 22:26 inputs_required.yml
-rw-r--r--    1 501      20             123 Dec  9 22:26 no_inputs.yml
-rwxr-xr-x    1 501      20             522 Dec 17 21:31 test.sh
```

別のディレクトリを入力として渡すには、絶対パスまたは相対パスを指定します:

```
fly -t tutorial e -c inputs_required.yml -i some-important-input=../task-hello-world
```

現在のディレクトリが必要な入力と同じ名前であれば、 `fly execute -i`オプションを削除することができます。

Task: `input_parent_dir.yml` は、現在のディレクトリでもある入力`task-inputs`を含んでいます。よって次のコマンドは動作し、上記と同じ結果を返します。

```
fly -t tutorial e -c input_parent_dir.yml
```
