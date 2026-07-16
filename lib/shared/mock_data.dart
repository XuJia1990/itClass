part of '../main.dart';

const _studentMenu = [
  MenuItem(Icons.forum_rounded, 'AI会話', Color(0xFF38BDF8)),
  MenuItem(Icons.grading_rounded, 'コード採点', Color(0xFF84CC16)),
  MenuItem(Icons.menu_book_rounded, 'AI教室', Color(0xFFF59E0B)),
  MenuItem(Icons.quiz_rounded, 'テスト', Color(0xFFEF4444)),
  MenuItem(Icons.support_agent_rounded, '先生に質問', Color(0xFFF97316)),
  MenuItem(Icons.settings_rounded, '設定', Color(0xFF475569)),
];

const _teacherMenu = [
  MenuItem(Icons.mark_chat_unread_rounded, 'AI回答不能（先生対応）', Color(0xFFF97316)),
  MenuItem(Icons.grading_rounded, 'コード採点', Color(0xFF84CC16)),
  MenuItem(Icons.analytics_rounded, 'テスト解答分析', Color(0xFFEF4444)),
  MenuItem(Icons.chat_rounded, '学生チャット', Color(0xFF38BDF8)),
  MenuItem(Icons.auto_awesome_rounded, 'AI再学習', Color(0xFF8B5CF6)),
  MenuItem(Icons.admin_panel_settings_rounded, 'システム管理', Color(0xFF22C55E)),
  MenuItem(Icons.settings_rounded, '設定', Color(0xFF475569)),
];

const _students = [
  StudentProfile('中村', '生徒 · オンライン', 'GET と POST の主な違いは何ですか？'),
  StudentProfile('佐藤', '生徒 · コード提出済み', 'HashMap の検索が速い理由は何ですか？'),
  StudentProfile('小川', '生徒 · テスト中', 'インターフェースと抽象クラスはどう選びますか？'),
  StudentProfile('takahashi', '生徒 · 回答待ち', 'NullPointerException はどう調査しますか？'),
  StudentProfile('kumagai', '生徒 · 復習中', 'final キーワードはどこで使いますか？'),
  StudentProfile('yamada', '生徒 · オフライン', 'Java Stream と for 文はどちらを使うべきですか？'),
];

const _studentTopics = [
  Topic(
    'GETとPOSTメソッドの...',
    'プログラミング',
    'GETとPOSTメソッドの主な違いは何ですか？',
    'GET は主にリソース取得に使い、パラメータは URL に含まれます。POST は主にデータ送信に使い、パラメータはリクエスト本文に入ります。実務では意味、キャッシュ、ログ、セキュリティも確認します。',
  ),
  Topic(
    'アジャイル開発とはどの...',
    'プログラミング',
    'アジャイル開発はどのようなものですか？',
    'アジャイル開発は短いサイクルで実装と確認を繰り返し、フィードバックを受けながら改善する開発方法です。',
  ),
  Topic(
    '基本設計書に何の内...',
    'プログラミング',
    '基本設計書には何が記載されますか？',
    '基本設計書には、機能一覧、画面設計、データ設計、外部インターフェース、権限、例外処理などを記載します。',
  ),
  Topic(
    'AJAXのデバッグにはど...',
    'プログラミング',
    'AJAXのデバッグにはどのようなツールを使いますか？',
    'ブラウザの DevTools の Network パネルを使うと、URL、Header、Payload、Response、ステータスコードを確認できます。',
  ),
];

const _lessons = [
  Lesson(
    title: 'Java基礎 01：変数とデータ型',
    level: 'Java基礎',
    summary: '値を入れる箱と、値の種類を学びます。',
    content:
        'Java の最初の一歩は「データをどこに保存するか」を理解することです。変数は値を入れる箱のようなものです。Java では箱を作るときに、何を入れる箱なのかを型で決めます。数値なら int や double、真偽値なら boolean、文字列なら String を使います。',
    code:
        'int age = 18;\ndouble price = 29.9;\nboolean passed = true;\nString name = "Eden";',
    sections: [
      LessonSection(
        heading: '1. 変数は値を保存する名前',
        body: 'プログラムでは、入力された年齢、計算結果、ユーザー名などを一時的に保存します。その保存場所に名前を付けたものが変数です。',
        keyPoints: ['変数名は意味が分かる名前にする', '値はあとから参照できる', '同じスコープで同じ名前は使えない'],
      ),
      LessonSection(
        heading: '2. 型は入れられる値の種類',
        body:
            'int には整数、double には小数、boolean には true/false、String には文字列を入れます。型が違う値を入れようとするとコンパイルエラーになります。',
        keyPoints: [
          'int は整数',
          'double は小数',
          'String は文字列',
          'boolean は条件判定でよく使う',
        ],
      ),
    ],
    exercise: LessonExercise(
      question: '年齢 20 を保存する変数として正しいものはどれですか？',
      options: [
        'String age = 20;',
        'int age = 20;',
        'boolean age = 20;',
        'double age = "20";',
      ],
      answerIndex: 1,
      correctReason: 'age は整数なので int を使うのが自然です。',
      wrongReason: 'String は文字列、boolean は true/false、double に文字列は入れられません。',
      standardAnswer: 'int age = 20;',
    ),
    aiSummary:
        '変数は値を保存する名前、型は保存できる値の種類です。Java は型を厳しく見るため、最初に「どんな値を扱うか」を考える習慣が大切です。',
  ),
  Lesson(
    title: 'Java基礎 02：if と条件分岐',
    level: 'Java基礎',
    summary: '条件によって処理を変える方法を学びます。',
    content:
        'if 文は「もし条件が正しければ、この処理をする」という書き方です。ログインできるか、点数が合格か、入力が空かどうかなど、実務でも毎日使います。',
    code:
        'int score = 82;\nif (score >= 60) {\n  System.out.println("passed");\n} else {\n  System.out.println("failed");\n}',
    sections: [
      LessonSection(
        heading: '1. 条件式は true / false になる',
        body:
            'score >= 60 のような式は、結果が true か false になります。true のときだけ if の中が実行されます。',
        keyPoints: [
          '比較演算子を使う',
          '条件式は boolean として評価される',
          'else は条件が false のときに実行',
        ],
      ),
      LessonSection(
        heading: '2. 文字列比較は equals を使う',
        body:
            'Java で文字列の中身を比較するときは == ではなく equals を使います。== は参照の比較になり、初心者がよく間違えます。',
        keyPoints: ['"A".equals(level) が安全', '== は文字列内容比較に向かない', 'null 対策にもなる'],
      ),
    ],
    exercise: LessonExercise(
      question: 'score が 60 以上なら合格にする条件式はどれですか？',
      options: ['score = 60', 'score >= 60', 'score < 60', 'score.equals(60)'],
      answerIndex: 1,
      correctReason: '60 以上を表すには >= を使います。',
      wrongReason: '= は代入です。< は 60 未満です。int に equals は通常使いません。',
      standardAnswer: 'if (score >= 60) { System.out.println("passed"); }',
    ),
    aiSummary:
        'if 文はプログラムの分かれ道です。条件式が true なら実行、false なら別の処理へ進みます。比較演算子と equals の使い分けを覚えましょう。',
  ),
  Lesson(
    title: 'Java基礎 03：for と while',
    level: 'Java基礎',
    summary: '同じ処理を繰り返す書き方を学びます。',
    content:
        '繰り返し処理は、一覧データを1件ずつ見るときに使います。for は回数が分かるとき、while は条件が続く間だけ繰り返したいときに向いています。',
    code: 'for (int i = 0; i < 5; i++) {\n  System.out.println(i);\n}',
    sections: [
      LessonSection(
        heading: '1. for はカウンタを使う',
        body: 'i を 0 から始めて、条件を満たす間だけ処理を繰り返し、最後に i++ で増やします。',
        keyPoints: ['初期化', '条件', '更新処理', '配列は i < length が基本'],
      ),
      LessonSection(
        heading: '2. 無限ループに注意',
        body:
            '条件がずっと true のままだと処理が終わりません。while を使うときは、条件がいつ false になるかを必ず考えます。',
        keyPoints: ['終了条件を決める', '変数を更新する', 'break の使いすぎに注意'],
      ),
    ],
    exercise: LessonExercise(
      question: '配列 arr の全要素を安全に見る条件はどれですか？',
      options: [
        'i <= arr.length',
        'i < arr.length',
        'i == arr.length',
        'i > arr.length',
      ],
      answerIndex: 1,
      correctReason: '配列の添字は 0 から length - 1 までなので、i < arr.length が安全です。',
      wrongReason: '<= にすると最後に arr[length] にアクセスして範囲外エラーになります。',
      standardAnswer: 'for (int i = 0; i < arr.length; i++) { ... }',
    ),
    aiSummary: '繰り返しは「同じ作業を何度も行う」ための道具です。配列やリストを扱うときは、境界条件を間違えないことが一番大切です。',
  ),
  Lesson(
    title: 'Java基礎 04：配列と ArrayList',
    level: 'Java基礎',
    summary: '複数の値をまとめて扱います。',
    content:
        '配列と ArrayList は、複数のデータをまとめるために使います。配列は長さが固定、ArrayList はあとから追加・削除しやすいのが特徴です。',
    code:
        'List<String> names = new ArrayList<>();\nnames.add("Sato");\nSystem.out.println(names.size());',
    sections: [
      LessonSection(
        heading: '1. 配列は長さ固定',
        body:
            'int[] scores = new int[3]; のように作ると、要素数は 3 で固定されます。高速ですが柔軟性は低いです。',
        keyPoints: ['length で長さを取得', '添字は 0 から始まる', '長さはあとから変えられない'],
      ),
      LessonSection(
        heading: '2. ArrayList は追加しやすい',
        body: 'ArrayList は add で要素を追加できます。ユーザー一覧、商品一覧、回答一覧など、件数が変わるデータによく使います。',
        keyPoints: ['size() で件数を取得', 'add で追加', 'get(index) で取得'],
      ),
    ],
    exercise: LessonExercise(
      question: 'ArrayList の件数を取得する正しいメソッドはどれですか？',
      options: ['length', 'size()', 'count()', 'total()'],
      answerIndex: 1,
      correctReason: 'ArrayList などの Collection は size() を使います。',
      wrongReason:
          'length は配列で使います。count() や total() は ArrayList の標準メソッドではありません。',
      standardAnswer: 'names.size();',
    ),
    aiSummary:
        '件数が固定なら配列、あとから増減するなら ArrayList と考えると分かりやすいです。初心者は length と size() の違いを必ず覚えましょう。',
  ),
  Lesson(
    title: 'Java基礎 05：HashMap',
    level: 'Java基礎',
    summary: 'key から value をすばやく取得します。',
    content:
        'HashMap は「名前から点数を取り出す」「ID からユーザーを探す」ように、key を使って value を高速に取得したいときに使います。',
    code:
        'Map<String, Integer> scores = new HashMap<>();\nscores.put("Java", 90);\nSystem.out.println(scores.get("Java"));',
    sections: [
      LessonSection(
        heading: '1. key と value の組み合わせ',
        body:
            'HashMap では key が目印、value が保存したい値です。key は重複できず、同じ key に put すると上書きされます。',
        keyPoints: ['put で保存', 'get で取得', 'containsKey で存在確認'],
      ),
      LessonSection(
        heading: '2. 検索が速い理由',
        body: 'HashMap は内部でハッシュ値を使って保存場所を決めます。そのため、平均的には O(1) で値を探せます。',
        keyPoints: ['平均 O(1)', 'Two Sum でよく使う', 'key の設計が重要'],
      ),
    ],
    exercise: LessonExercise(
      question: '指定した key が HashMap にあるか確認するメソッドはどれですか？',
      options: ['findKey', 'hasKey', 'containsKey', 'search'],
      answerIndex: 2,
      correctReason: 'containsKey は指定した key が存在するか確認できます。',
      wrongReason: 'findKey、hasKey、search は HashMap の標準メソッドではありません。',
      standardAnswer: 'if (map.containsKey(key)) { ... }',
    ),
    aiSummary:
        'HashMap は key で素早く探すための道具です。二重ループを避けたい問題では、HashMap が解決のヒントになることが多いです。',
  ),
  Lesson(
    title: 'Java基礎 06：クラスとオブジェクト',
    level: 'Java基礎',
    summary: 'データと処理をひとつにまとめます。',
    content:
        'クラスは設計図、オブジェクトは設計図から作られる実体です。学生クラスなら name や score をフィールドに持ち、study() のようなメソッドを持てます。',
    code:
        'class Student {\n  String name;\n  void study() {\n    System.out.println(name + " studying");\n  }\n}',
    sections: [
      LessonSection(
        heading: '1. フィールドは状態',
        body: '名前、年齢、点数など、オブジェクトが持つデータをフィールドと呼びます。',
        keyPoints: ['状態を保存する', '意味のある名前にする', '外部公開範囲に注意'],
      ),
      LessonSection(
        heading: '2. メソッドは振る舞い',
        body: '計算する、表示する、登録するなど、オブジェクトが行う処理をメソッドにします。',
        keyPoints: ['処理をまとめる', '再利用しやすくなる', '名前から目的が分かるようにする'],
      ),
    ],
    exercise: LessonExercise(
      question: 'クラスから作られた具体的な実体を何と呼びますか？',
      options: ['パッケージ', 'オブジェクト', 'コメント', 'コンパイラ'],
      answerIndex: 1,
      correctReason: 'クラスから生成される実体はオブジェクトです。',
      wrongReason: 'パッケージは分類、コメントは説明、コンパイラは変換ツールです。',
      standardAnswer: 'Student s = new Student(); の s がオブジェクトです。',
    ),
    aiSummary: 'クラスは「何を持つか」と「何ができるか」をまとめた設計図です。大きなプログラムほど、クラス設計が読みやすさを左右します。',
  ),
  Lesson(
    title: 'Java基礎 07：メソッド',
    level: 'Java基礎',
    summary: '処理を名前付きで再利用します。',
    content: 'メソッドは、よく使う処理をまとめて名前を付けたものです。引数で材料を受け取り、return で結果を返せます。',
    code: 'int add(int a, int b) {\n  return a + b;\n}',
    sections: [
      LessonSection(
        heading: '1. 引数は入力',
        body: 'メソッドに渡す値を引数と呼びます。計算や判定に必要な材料を外から渡します。',
        keyPoints: ['型と名前を書く', '複数指定できる', '必要なものだけ渡す'],
      ),
      LessonSection(
        heading: '2. return は出力',
        body: '処理結果を呼び出し元へ返すときに return を使います。戻り値がない場合は void を使います。',
        keyPoints: ['戻り値の型を合わせる', 'return 後は基本的に処理が終わる', 'void は戻り値なし'],
      ),
    ],
    exercise: LessonExercise(
      question: 'int を返すメソッドで結果を返すキーワードはどれですか？',
      options: ['send', 'return', 'break', 'print'],
      answerIndex: 1,
      correctReason: 'return はメソッドの結果を呼び出し元へ返します。',
      wrongReason: 'print は表示、break はループ終了、send は Java の戻り値キーワードではありません。',
      standardAnswer: 'return a + b;',
    ),
    aiSummary: 'メソッドは処理を小さく分けるための道具です。入力は引数、出力は戻り値と考えると理解しやすくなります。',
  ),
  Lesson(
    title: 'Java基礎 08：例外処理',
    level: 'Java基礎',
    summary: '実行中のエラーに対応します。',
    content:
        '例外は、プログラム実行中に起きる問題です。文字列を数値に変換できない、null を参照した、ファイルが見つからないなどがあります。',
    code:
        'try {\n  int value = Integer.parseInt("12");\n} catch (NumberFormatException e) {\n  System.out.println("invalid format");\n}',
    sections: [
      LessonSection(
        heading: '1. try に危ない処理を書く',
        body: '失敗する可能性がある処理を try に書きます。例外が発生すると catch に処理が移ります。',
        keyPoints: ['変換処理', 'ファイル処理', '外部 API 呼び出し'],
      ),
      LessonSection(
        heading: '2. catch で原因を扱う',
        body: 'catch ではエラー内容をログに出したり、ユーザーに分かりやすいメッセージを返したりします。',
        keyPoints: ['握りつぶさない', '原因を記録する', '復旧できる処理を考える'],
      ),
    ],
    exercise: LessonExercise(
      question: '例外を捕捉する組み合わせはどれですか？',
      options: ['if-final', 'try-catch', 'for-switch', 'class-return'],
      answerIndex: 1,
      correctReason: 'try-catch は例外を捕捉して処理する構文です。',
      wrongReason: '他の選択肢は例外処理の構文ではありません。',
      standardAnswer: 'try { ... } catch (Exception e) { ... }',
    ),
    aiSummary: '例外処理は「失敗してもアプリを止めない」ために重要です。原因を隠さず、次に何をすればよいか分かる処理にしましょう。',
  ),
  Lesson(
    title: 'Java基礎 09：インターフェース',
    level: 'Java基礎',
    summary: 'クラスに共通の能力を約束させます。',
    content:
        'インターフェースは「このメソッドを必ず持つ」という約束を定義します。実装クラスは implements を使って、その約束を守ります。',
    code:
        'interface RunnableTask {\n  void run();\n}\nclass Job implements RunnableTask {\n  public void run() {}\n}',
    sections: [
      LessonSection(
        heading: '1. 能力を表す',
        body: 'Runnable、Comparable のように、「できること」を表す名前にすることが多いです。',
        keyPoints: ['implements で実装', '複数実装できる', '規約を統一できる'],
      ),
      LessonSection(
        heading: '2. 抽象クラスとの違い',
        body: '抽象クラスは共通の状態や一部実装を共有したいとき、インターフェースは能力やルールを定義したいときに使います。',
        keyPoints: ['クラスは単一継承', 'インターフェースは複数実装可能', '設計意図で選ぶ'],
      ),
    ],
    exercise: LessonExercise(
      question: 'インターフェースを実装するときに使うキーワードはどれですか？',
      options: ['extends', 'implements', 'package', 'new'],
      answerIndex: 1,
      correctReason: 'implements はインターフェースを実装するときに使います。',
      wrongReason: 'extends は継承、package はパッケージ宣言、new はオブジェクト生成です。',
      standardAnswer: 'class Job implements RunnableTask { ... }',
    ),
    aiSummary: 'インターフェースはチーム開発で特に役立ちます。「このクラスはこの操作ができる」と共通ルールを作れるからです。',
  ),
  Lesson(
    title: 'Java基礎 10：REST API 入門',
    level: 'Java基礎',
    summary: 'Web アプリがサーバーと通信する考え方を学びます。',
    content:
        'REST API は、画面とサーバーがデータをやり取りする入口です。HTTP メソッド、URL、JSON、ステータスコードを理解すると、実務の Web 開発が分かりやすくなります。',
    code: 'GET /api/questions\nPOST /api/exams\nContent-Type: application/json',
    sections: [
      LessonSection(
        heading: '1. HTTP メソッドの意味',
        body: 'GET は取得、POST は作成、PUT/PATCH は更新、DELETE は削除という意味で使うことが多いです。',
        keyPoints: ['GET は取得', 'POST は送信・作成', '意味を合わせると保守しやすい'],
      ),
      LessonSection(
        heading: '2. ステータスコードを見る',
        body: '200 は成功、400 は入力ミス、401 は認証が必要、404 は見つからない、500 はサーバーエラーを表します。',
        keyPoints: ['エラー調査の入口', 'Network パネルで確認', 'API 設計で重要'],
      ),
    ],
    exercise: LessonExercise(
      question: 'リソース取得に使うことが多い HTTP メソッドはどれですか？',
      options: ['GET', 'POST', 'DELETE', 'PATCH'],
      answerIndex: 0,
      correctReason: 'GET はリソース取得の意味で使います。',
      wrongReason: 'POST は送信や作成、DELETE は削除、PATCH は一部更新で使うことが多いです。',
      standardAnswer: 'GET /api/questions',
    ),
    aiSummary: 'REST API は画面とサーバーの会話ルールです。メソッド、URL、JSON、ステータスコードをセットで理解しましょう。',
  ),
];

const _examQuestions = [
  ExamQuestion(
    topic: 'Java基礎',
    question: 'Java で文字列を表す型はどれですか？',
    options: ['char', 'String', 'boolean', 'double'],
    answerIndex: 1,
    explanation: 'String は Java で文字列を表すクラスです。',
  ),
  ExamQuestion(
    topic: 'コレクション',
    question: 'ArrayList の要素数を取得するメソッドはどれですか？',
    options: ['length', 'size()', 'count()', 'total()'],
    answerIndex: 1,
    explanation: 'コレクションは size()、配列は length を使います。',
  ),
  ExamQuestion(
    topic: 'Map',
    question: 'HashMap に指定した key が存在するか確認するメソッドはどれですか？',
    options: ['hasKey', 'containsKey', 'includeKey', 'findKey'],
    answerIndex: 1,
    explanation: 'containsKey で指定した key の存在を確認できます。',
  ),
  ExamQuestion(
    topic: '制御構文',
    question: 'for 文で i < arr.length と書く主な目的は何ですか？',
    options: ['範囲外アクセスを避ける', '配列を作成する', '並び替える', '型変換する'],
    answerIndex: 0,
    explanation: '配列の添字は 0 から始まるため、i < length にすると範囲外アクセスを避けられます。',
  ),
  ExamQuestion(
    topic: 'オブジェクト指向',
    question: 'Java のクラスから作られる実体を通常何と呼びますか？',
    options: ['メソッド', 'パッケージ', 'オブジェクト', 'インターフェース'],
    answerIndex: 2,
    explanation: 'オブジェクトはクラスから作られる具体的な実体です。',
  ),
  ExamQuestion(
    topic: 'インターフェース',
    question: 'クラスがインターフェースを実装するときに使うキーワードはどれですか？',
    options: ['extends', 'implements', 'interface', 'package'],
    answerIndex: 1,
    explanation: 'implements はインターフェースを実装するときに使います。',
  ),
  ExamQuestion(
    topic: '例外',
    question: '例外を捕捉するときによく使う構文はどれですか？',
    options: ['if-else', 'try-catch', 'switch', 'for'],
    answerIndex: 1,
    explanation: 'try-catch は例外を捕捉して処理するために使います。',
  ),
  ExamQuestion(
    topic: 'HTTP',
    question: '通常、リソース取得に使う HTTP メソッドはどれですか？',
    options: ['GET', 'POST', 'DELETE', 'PATCH'],
    answerIndex: 0,
    explanation: 'GET は意味としてリソース取得に使います。',
  ),
  ExamQuestion(
    topic: 'HTTP',
    question: '404 ステータスコードは通常何を表しますか？',
    options: ['成功', '未認証', 'リソースが存在しない', 'サーバー内部エラー'],
    answerIndex: 2,
    explanation: '404 は要求したリソースが存在しないことを表します。',
  ),
  ExamQuestion(
    topic: 'アルゴリズム',
    question: 'HashMap の平均的な検索計算量はどれですか？',
    options: ['O(1)', 'O(n)', 'O(log n)', 'O(n²)'],
    answerIndex: 0,
    explanation: 'HashMap は平均的に定数時間で検索できます。',
  ),
  ExamQuestion(
    topic: 'Java基礎',
    question: '文字列の内容比較で推奨される方法はどれですか？',
    options: ['==', 'equals', '!=', 'compareAddress'],
    answerIndex: 1,
    explanation: 'equals は文字列の内容を比較します。== は参照を比較します。',
  ),
  ExamQuestion(
    topic: 'キーワード',
    question: 'final で変数を修飾すると通常どうなりますか？',
    options: ['自由に変更できる', '一度だけ代入できる', '自動で並び替える', '文字列に変換する'],
    answerIndex: 1,
    explanation: 'final 変数は一度代入すると再代入できません。',
  ),
];

const _teacherRequests = [
  TeacherRequest(
    student: '中村',
    category: 'AI会話',
    question: 'GET と POST はパラメータ位置以外にどのような設計上の違いがありますか？',
    aiAnswer: 'GET は URL、POST は body を使います。',
  ),
  TeacherRequest(
    student: '佐藤',
    category: 'コード採点',
    question: 'Two Sum は二重ループでも解けますか？なぜ先生は HashMap をすすめますか？',
    aiAnswer: 'HashMap の方が速いです。',
  ),
  TeacherRequest(
    student: 'takahashi',
    category: '例外処理',
    question: 'NullPointerException はどの手順で調査すればよいですか？',
    aiAnswer: 'null の可能性があるオブジェクトを確認します。',
  ),
  TeacherRequest(
    student: '小川',
    category: 'テスト',
    question: 'インターフェースと抽象クラスはどちらもメソッドを定義できますが、違いは何ですか？',
    aiAnswer: 'インターフェースの方がより抽象的です。',
    answered: true,
    teacherAnswer: 'インターフェースは能力や規約、抽象クラスは共通の親クラスと状態の共有に向いています。',
  ),
];

const _examReports = [
  ExamReport('中村', 82, 'HTTP メソッドとステータスコードの理解を強化しましょう', 'REST API を復習'),
  ExamReport('佐藤', 76, 'コレクションと Map の計算量がまだ不安定です', 'HashMap 問題を練習'),
  ExamReport('小川', 91, 'オブジェクト指向はよく理解できています', 'インターフェース設計へ進む'),
  ExamReport('takahashi', 68, '例外処理の問題でミスが多いです', 'try-catch を復習'),
  ExamReport('kumagai', 88, '基礎文法は安定しています', 'Stream に進む'),
];

const _codeReviewItems = [
  CodeReviewItem('佐藤', 'Two Sum', 84, '動作します。時間計算量の説明を追加するとさらに良いです。'),
  CodeReviewItem('中村', '文字列反転', 72, '空文字列と境界条件に注意してください。'),
  CodeReviewItem('takahashi', '学生成績集計', 65, 'メソッド分割をもう少し明確にしましょう。'),
];

const _defaultCode = '''
import java.util.*;

class Solution {
  public int[] twoSum(int[] nums, int target) {
    Map<Integer, Integer> seen = new HashMap<>();
    for (int i = 0; i < nums.length; i++) {
      int need = target - nums[i];
      if (seen.containsKey(need)) {
        return new int[] { seen.get(need), i };
      }
      seen.put(nums[i], i);
    }
    return new int[] {};
  }
}
''';

const _standardTwoSumAnswer = '''
import java.util.*;

class Solution {
  public int[] twoSum(int[] nums, int target) {
    if (nums == null || nums.length < 2) {
      return new int[] {};
    }

    Map<Integer, Integer> indexByValue = new HashMap<>();
    for (int i = 0; i < nums.length; i++) {
      int need = target - nums[i];
      if (indexByValue.containsKey(need)) {
        return new int[] { indexByValue.get(need), i };
      }
      indexByValue.put(nums[i], i);
    }
    return new int[] {};
  }
}
''';

String _teacherTitle(TeacherSection section) {
  switch (section) {
    case TeacherSection.pendingAi:
      return 'AI回答不能（先生対応）';
    case TeacherSection.codeScoring:
      return 'コード採点';
    case TeacherSection.examAnalysis:
      return 'テスト解答分析';
    case TeacherSection.studentMessages:
      return '学生チャット';
    case TeacherSection.relearning:
      return 'AI再学習';
    case TeacherSection.system:
      return 'システム管理';
    case TeacherSection.settings:
      return '設定';
  }
}

String _mockAiAnswer(String text) {
  final lower = text.toLowerCase();
  if (lower.contains('hashmap') || text.contains('Map')) {
    return 'HashMap は key-value 形式でデータを保存し、平均的な検索計算量は O(1) です。Two Sum では数字と添字を Map に保存すると、二重ループを避けられます。';
  }
  if (text.contains('GET') || text.contains('POST') || lower.contains('post')) {
    return 'GET はデータ取得に向いており、パラメータは主に URL に含まれます。POST は送信や作成に向いており、パラメータはリクエスト本文に入ります。実務では冪等性、キャッシュ、ログ、セキュリティも確認します。';
  }
  if (text.contains('interface') ||
      text.contains('abstract') ||
      text.contains('インターフェース')) {
    return 'インターフェースは能力や規約を定義し、抽象クラスは共通の状態や一部実装を共有するときに使います。Java のクラスは複数のインターフェースを実装できます。';
  }
  return '学習の進め方は、1. 入力と出力を確認する、2. 最小の例を書く、3. 境界条件を確認する、4. 計算量を考える、の順番がおすすめです。必要なら先生に質問できます。';
}
