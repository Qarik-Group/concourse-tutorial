description: Taskスクリプトは通常、入力の1つから渡されます。

# Task Scripts

Taskの`inputs`は、2種類の入力を渡すことができます:

* 処理/テスト/コンパイル される 要件/依存関係
* 複雑な処理を実行するために予め実行されるTaskスクリプト

Concourse Taskの一般的なパターンは、前セクションで行なった(`uname`コマンドを引数` -a`で実行するような)"直接コマンドを呼び出す"ものではなく、"複雑なシェルスクリプトを`run: `する" ものです。

では、複製済のTaskスクリプト `task-scripts/task_show_uname.sh`を使って、` task-hello-world/task_ubuntu_uname.yml`を、新しいTask `task-scripts/task_show_uname.yml`にリファクタリングしましょう。

```
cd ../task-scripts
fly -t tutorial e -c task_show_uname.yml
```

`task-scripts/task_show_uname.yml`は、Taskスクリプトとして`task-scripts/task_show_uname.sh`を指定します:

```yaml
run:
  path: ./task-scripts/task_show_uname.sh
```

_`./task-scripts/task_show_uname.sh`ファイルはどこから持ってきたのですか?_

セクション"Task Inputs"で、私たちは入力をTaskに渡すことができることを学びました。Task設定`task-scripts/task_show_uname.yml`は1つの入力を指定します:

```
inputs:
- name: task-scripts
```

入力 `task-scripts`はカレントディレクトリ`task-scripts`と同じなので、`fly execute -i task-scripts=.`を指定する必要はありませんでした。

カレントディレクトリはConcourseのTaskコンテナにアップロードされ、 `task-scripts`ディレクトリの中に置かれました。

したがって、そのファイル`task_show_uname.sh`は`task-scripts/task_show_uname.sh`のConcourseタスクコンテナ内で利用可能になるのです。

ここでの唯一の要件は、`task_show_uname.sh`が実行可能なスクリプトであることです。
