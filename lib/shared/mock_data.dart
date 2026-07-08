part of '../main.dart';

const _studentMenu = [
  MenuItem(Icons.forum_rounded, 'AI会話', Color(0xFF38BDF8)),
  MenuItem(Icons.grading_rounded, 'コード採点', Color(0xFF84CC16)),
  MenuItem(Icons.menu_book_rounded, 'AI学習', Color(0xFFF59E0B)),
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
    title: 'Javaの変数とデータ型',
    level: '入門',
    summary: 'int、double、boolean、String の使い方を理解します。',
    content:
        '変数はプログラム内で値を保存する名前です。Java は静的型付け言語なので、変数を宣言するときに型を指定します。代表的な型には int、long、double、boolean があり、文字列は String を使います。',
    code:
        'int age = 18;\ndouble price = 29.9;\nboolean passed = true;\nString name = "Eden";',
  ),
  Lesson(
    title: 'if と switch の条件分岐',
    level: '入門',
    summary: '条件に応じて処理を切り替えます。',
    content:
        'if は範囲判定や複雑な条件に向いています。switch は決まった値ごとに処理を分けるときに便利です。文字列比較では == ではなく equals を使う点に注意します。',
    code:
        'String level = "A";\nif ("A".equals(level)) {\n  System.out.println("excellent");\n}',
  ),
  Lesson(
    title: 'for と while のループ',
    level: '入門',
    summary: '同じ処理を繰り返します。',
    content:
        'for は回数が分かっている処理に向いています。while は条件が満たされる間だけ処理を続けたい場合に使います。境界条件と終了条件を必ず確認します。',
    code: 'for (int i = 0; i < 5; i++) {\n  System.out.println(i);\n}',
  ),
  Lesson(
    title: '配列と ArrayList',
    level: '基礎',
    summary: '同じ型のデータをまとめて扱います。',
    content:
        '配列は長さが固定で高速にアクセスできます。ArrayList は長さを変えられるため、業務アプリのリスト処理でよく使います。配列は length、ArrayList は size() を使います。',
    code:
        'List<String> names = new ArrayList<>();\nnames.add("Sato");\nSystem.out.println(names.size());',
  ),
  Lesson(
    title: 'HashMap のキーと値',
    level: '基礎',
    summary: 'key から value をすばやく取得します。',
    content:
        'HashMap はキーと値のペアでデータを保存します。一意のキーから値を検索する処理に向いており、put、get、containsKey をよく使います。',
    code:
        'Map<String, Integer> scores = new HashMap<>();\nscores.put("Java", 90);\nSystem.out.println(scores.get("Java"));',
  ),
  Lesson(
    title: 'クラスとオブジェクト',
    level: '基礎',
    summary: 'データと振る舞いをまとめます。',
    content: 'クラスは設計図、オブジェクトはその設計図から作られた実体です。フィールドは状態を持ち、メソッドは振る舞いを表します。',
    code:
        'class Student {\n  String name;\n  void study() {\n    System.out.println(name + " studying");\n  }\n}',
  ),
  Lesson(
    title: '継承とインターフェース',
    level: '発展',
    summary: '共通処理の再利用と能力の定義を学びます。',
    content:
        '継承は is-a 関係を表すときに使います。インターフェースは実装すべき能力やルールを定義します。Java のクラスは 1 つのクラスしか継承できませんが、複数のインターフェースを実装できます。',
    code:
        'interface RunnableTask {\n  void run();\n}\nclass Job implements RunnableTask {\n  public void run() {}\n}',
  ),
  Lesson(
    title: '例外処理',
    level: '発展',
    summary: '実行時エラーに対応します。',
    content:
        'try-catch は例外を捕捉して処理するために使います。例外を無視せず、ログ出力やユーザーへの明確な通知を行うことが大切です。',
    code:
        'try {\n  int value = Integer.parseInt("12");\n} catch (NumberFormatException e) {\n  System.out.println("invalid format");\n}',
  ),
  Lesson(
    title: 'Java Stream',
    level: '発展',
    summary: 'コレクションを宣言的に処理します。',
    content:
        'Stream は filter、map、集計などの処理を読みやすく書けます。ただし複雑な処理では、通常の for 文の方が分かりやすい場合もあります。',
    code:
        'List<Integer> nums = List.of(1, 2, 3);\nint sum = nums.stream().mapToInt(Integer::intValue).sum();',
  ),
  Lesson(
    title: 'REST API 基礎',
    level: '実践',
    summary: 'リクエストとレスポンスを理解します。',
    content:
        'REST API は HTTP メソッドで操作を表し、JSON でデータをやり取りすることが多いです。代表的なステータスコードは 200、201、400、401、404、500 です。',
    code: 'GET /api/questions\nPOST /api/exams\nContent-Type: application/json',
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
