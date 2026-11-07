import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:it_class/main.dart';

// Contracts from Downloads/11.md. Every response goes through the real API
// decoder; the injected client never delegates to a network client.
void main() {
  late AuthSession? originalSession;

  setUp(() {
    originalSession = ItClassSession.current;
    ItClassSession.current = AuthSession.fromJson({
      'userId': 9001,
      'accessToken': 'shared-resources-test-token',
      'refreshToken': 'shared-resources-test-refresh',
      'schoolAccountId': 501,
      'schoolAccountType': schoolAccountTypeStudent,
      'realName': '未所属の学生',
      'programmingLanguage': 'Java',
    });
  });

  tearDown(() {
    ItClassSession.current = originalSession;
  });

  group('global AI without a classroom', () {
    test(
      'uses the configured welcome message and a title-only create',
      () async {
        final fixture = _ApiFixture((request) {
          switch (request.url.path) {
            case '/app-api/school/ai-tutor/config/get':
              _expectRequest(request, 'GET', '/school/ai-tutor/config/get');
              return _envelope({
                'classroomId': null,
                'classroomName': '全言語',
                'programmingLanguage': 'ALL',
                'welcomeMessage': 'PythonもJavaも質問できます。',
                'autoAnswerEnabled': true,
              });
            case '/app-api/school/ai-tutor/conversation/create':
              _expectRequest(
                request,
                'POST',
                '/school/ai-tutor/conversation/create',
              );
              expect(_body(request).keys, unorderedEquals(['title']));
              expect(
                _body(request)['title'],
                isA<String>().having(
                  (title) => title.trim(),
                  'nonempty title',
                  isNotEmpty,
                ),
              );
              return _envelope(301);
            default:
              throw StateError('Unexpected request: ${request.url}');
          }
        });

        expect(
          await fixture.api.aiTutorWelcomeMessage(),
          'PythonもJavaも質問できます。',
        );
        expect(await fixture.api.ensureAiConversation(), 301);
        expect(fixture.requests, hasLength(2));
      },
    );

    test(
      'sends Java and Python questions to the same global conversation',
      () async {
        final contents = ['Javaの配列とは？', 'Pythonのリストとは？'];
        final fixture = _ApiFixture((request) {
          _expectRequest(request, 'POST', '/school/ai-tutor/ask');
          return _envelope({'status': 10, 'effectiveAnswer': 'モックの回答'});
        });

        for (final content in contents) {
          expect(
            await fixture.api.askAi(conversationId: 301, content: content),
            'モックの回答',
          );
        }
        expect(fixture.requests.map(_body), [
          for (final content in contents)
            {'conversationId': 301, 'content': content},
        ]);
      },
    );
  });

  group('public resources and signed details', () {
    test(
      'video page keeps resource language and both responsible teachers',
      () async {
        final fixture = _ApiFixture((request) {
          _expectRequest(
            request,
            'GET',
            '/school/course-video/page',
            query: {'pageNo': '1', 'pageSize': '100'},
          );
          return _envelope(_page([_videoJson]));
        });

        final page = await fixture.api.courseVideos();
        expect(page.total, 1);
        final video = page.list.single;
        expect(video.id, 101);
        expect(video.classroomId, isNull);
        expect(video.category, 'Python');
        expect(video.contentVersion, 7);
        _expectTeachers(video.teachers);
        expect(fixture.requests, hasLength(1));
      },
    );

    test(
      'video detail preserves the signed URL and current content version',
      () async {
        final fixture = _ApiFixture((request) {
          _expectRequest(
            request,
            'GET',
            '/school/course-video/get',
            query: {'id': '101'},
          );
          return _envelope(_videoJson);
        });

        final video = await fixture.api.courseVideo(101);
        expect(video.classroomId, isNull);
        expect(video.videoUrl, _videoJson['playUrl']);
        expect(video.videoUrl, isNot(_videoJson['videoUrl']));
        expect(video.contentVersion, 7);
        expect(video.category, 'Python');
        _expectTeachers(video.teachers);
        expect(fixture.requests, hasLength(1));
      },
    );

    test(
      'document page is global and parses its own language and teachers',
      () async {
        final fixture = _ApiFixture((request) {
          _expectRequest(
            request,
            'GET',
            '/school/course-document/page',
            query: {'pageNo': '1', 'pageSize': '100'},
          );
          return _envelope(_page([_documentJson]));
        });

        final page = await fixture.api.courseDocuments();
        expect(page.total, 1);
        final document = page.list.single;
        expect(document.id, 201);
        expect(document.classroomId, isNull);
        expect(document.level, 'TypeScript');
        _expectTeachers(document.teachers);
        expect(fixture.requests, hasLength(1));
      },
    );

    test(
      'document detail preserves its signed access URL without a classroom',
      () async {
        final fixture = _ApiFixture((request) {
          _expectRequest(
            request,
            'GET',
            '/school/course-document/get',
            query: {'id': '201'},
          );
          return _envelope(_documentJson);
        });

        final document = await fixture.api.courseDocument(201);
        expect(document.classroomId, isNull);
        expect(document.documentUrl, _documentJson['accessUrl']);
        expect(document.documentUrl, isNot(_documentJson['documentUrl']));
        expect(document.level, 'TypeScript');
        _expectTeachers(document.teachers);
        expect(fixture.requests, hasLength(1));
      },
    );

    for (final resourceType in [
      'VIDEO',
      'DOCUMENT',
      'QUESTION',
      'PAPER',
      'EXAM',
    ]) {
      test('$resourceType teacher lookup uses school account IDs', () async {
        final fixture = _ApiFixture((request) {
          _expectRequest(
            request,
            'GET',
            '/school/resource/teachers',
            query: {'resourceType': resourceType, 'resourceId': '101'},
          );
          return _envelope(_teachersJson);
        });

        _expectTeachers(await fixture.api.resourceTeachers(resourceType, 101));
        expect(fixture.requests, hasLength(1));
      });
    }

    test('empty responsible teachers remain empty', () async {
      final fixture = _ApiFixture((request) {
        _expectRequest(
          request,
          'GET',
          '/school/resource/teachers',
          query: {'resourceType': 'DOCUMENT', 'resourceId': '201'},
        );
        return _envelope([]);
      });
      expect(await fixture.api.resourceTeachers('DOCUMENT', 201), isEmpty);
      expect(fixture.requests, hasLength(1));
    });
  });

  group('resource conversation identity', () {
    test(
      'passes the full resource/teacher key and preserves returned IDs',
      () async {
        // Backend uniqueness is represented by fixtures, not implemented by this
        // test: the client must forward every key and keep each returned ID.
        const cases = [
          (type: 'VIDEO', resource: 101, teacher: 11, conversation: 301),
          (type: 'VIDEO', resource: 101, teacher: 11, conversation: 301),
          (type: 'VIDEO', resource: 101, teacher: 12, conversation: 302),
          (type: 'VIDEO', resource: 102, teacher: 11, conversation: 303),
          (type: 'DOCUMENT', resource: 101, teacher: 11, conversation: 304),
        ];
        var index = 0;
        final fixture = _ApiFixture((request) {
          _expectRequest(
            request,
            'POST',
            '/school/chat/conversation/get-or-create',
          );
          final expected = cases[index++];
          expect(_body(request), {
            'resourceType': expected.type,
            'resourceId': expected.resource,
            'peerAccountId': expected.teacher,
          });
          return _envelope(expected.conversation);
        });

        final ids = <int>[];
        for (final item in cases) {
          ids.add(
            await fixture.api.getOrCreateChat(
              resourceType: item.type,
              resourceId: item.resource,
              peerAccountId: item.teacher,
            ),
          );
        }
        expect(ids, [301, 301, 302, 303, 304]);
        expect(fixture.requests, hasLength(cases.length));
      },
    );

    test(
      'resource consultation omits a legacy classroom even when supplied',
      () async {
        final fixture = _ApiFixture((request) {
          _expectRequest(
            request,
            'POST',
            '/school/chat/conversation/get-or-create',
          );
          expect(_body(request), {
            'resourceType': 'DOCUMENT',
            'resourceId': 201,
            'peerAccountId': 12,
          });
          return _envelope(302);
        });
        expect(
          await fixture.api.getOrCreateChat(
            classroomId: 99,
            resourceType: 'DOCUMENT',
            resourceId: 201,
            peerAccountId: 12,
          ),
          302,
        );
        expect(fixture.requests, hasLength(1));
      },
    );

    test(
      'history keeps the same teacher on multiple resources across pages',
      () async {
        final rows = [
          _conversationJson(301, 11, 'VIDEO', 101, '公開Python動画', unread: 2),
          _conversationJson(303, 11, 'VIDEO', 102, 'Python続編', unread: 5),
          _conversationJson(304, 11, 'DOCUMENT', 101, '公開TypeScript教材'),
        ];
        final fixture = _ApiFixture((request) {
          final pageNo = request.url.queryParameters['pageNo'];
          expect(pageNo, anyOf('1', '2'));
          _expectRequest(
            request,
            'GET',
            '/school/chat/conversation/page',
            query: {'pageNo': pageNo!, 'pageSize': '100'},
          );
          return _envelope({
            'list': pageNo == '1'
                ? rows.take(2).toList()
                : rows.skip(2).toList(),
            'total': rows.length,
          });
        });

        final contacts = await fixture.api.chatContacts();
        expect(contacts.map((contact) => contact.conversationId), [
          301,
          303,
          304,
        ]);
        expect(contacts.map((contact) => contact.accountId), [11, 11, 11]);
        expect(contacts.map((contact) => contact.resourceType), [
          'VIDEO',
          'VIDEO',
          'DOCUMENT',
        ]);
        expect(contacts.map((contact) => contact.resourceId), [101, 102, 101]);
        expect(contacts.map((contact) => contact.resourceName), [
          '公開Python動画',
          'Python続編',
          '公開TypeScript教材',
        ]);
        expect(contacts.map((contact) => contact.unreadCount), [2, 5, 0]);
        expect(
          contacts.every((contact) => contact.classroomId == null),
          isTrue,
        );
        expect(fixture.requests, hasLength(2));
      },
    );
  });

  group('versioned video progress', () {
    for (final version in [0, 7]) {
      test(
        'reports contentVersion=$version without dropping zero values',
        () async {
          final fixture = _ApiFixture((request) {
            _expectRequest(request, 'POST', '/school/video-progress/save');
            expect(_body(request), {
              'courseVideoId': 101,
              'contentVersion': version,
              'positionSeconds': 0,
              'durationSeconds': 600,
              'ended': false,
            });
            return _envelope(true);
          });
          await fixture.api.saveVideoProgress(
            courseVideoId: 101,
            contentVersion: version,
            positionSeconds: 0,
            durationSeconds: 600,
            ended: false,
          );
          expect(fixture.requests, hasLength(1));
        },
      );
    }

    test(
      'unwatched current content returns the zero progress object',
      () async {
        const progress = {
          'lastPositionSeconds': 0,
          'maxPositionSeconds': 0,
          'progressPercent': 0,
          'completed': false,
        };
        final fixture = _ApiFixture((request) {
          _expectRequest(
            request,
            'GET',
            '/school/video-progress/get',
            query: {'courseVideoId': '101'},
          );
          return _envelope(progress);
        });
        expect(await fixture.api.videoProgress(101), progress);
        expect(fixture.requests, hasLength(1));
      },
    );
  });

  group('always available exams', () {
    for (final limits in [
      (label: 'defaults', duration: null, attempts: null),
      (label: 'explicit unlimited', duration: 0, attempts: 0),
      (label: 'positive limits', duration: 45, attempts: 3),
    ]) {
      test(
        'saves ${limits.label} once without publish, dates or classroom',
        () async {
          final fixture = _ApiFixture((request) {
            _expectRequest(request, 'POST', '/school/exam-teacher/exam/save');
            expect(_body(request), {
              'paperId': 31,
              'title': '公開テスト',
              'description': '保存後すぐ受験可能',
              'teacherAccountIds': [11, 12],
              'durationMinutes': limits.duration ?? 0,
              'passScore': 60,
              'maxAttempts': limits.attempts ?? 0,
              'shuffleQuestions': false,
              'shuffleOptions': false,
              'resultPublishType': 0,
              'showAnswer': true,
            });
            return _envelope(41);
          });

          final id = limits.duration == null
              ? await fixture.api.createAndPublishExam(
                  paperId: 31,
                  title: '公開テスト',
                  description: '保存後すぐ受験可能',
                  teacherAccountIds: [11, 12],
                )
              : await fixture.api.createAndPublishExam(
                  classroomId: 99,
                  paperId: 31,
                  title: '公開テスト',
                  description: '保存後すぐ受験可能',
                  durationMinutes: limits.duration!,
                  maxAttempts: limits.attempts!,
                  teacherAccountIds: [11, 12],
                );
          expect(id, 41);
          expect(fixture.requests, hasLength(1));
        },
      );
    }

    test('parses null dates, unlimited values and all teachers', () async {
      final fixture = _ApiFixture((request) {
        _expectRequest(
          request,
          'GET',
          '/school/exam/page',
          query: {'pageNo': '1', 'pageSize': '100'},
        );
        return _envelope(_page([_examJson]));
      });

      final exam = (await fixture.api.examPage()).list.single;
      expect(exam.id, 41);
      expect(exam.startTime, isNull);
      expect(exam.endTime, isNull);
      expect(exam.durationMinutes, 0);
      expect(exam.maxAttempts, 0);
      expect(exam.alwaysAvailable, isTrue);
      expect(exam.isAvailable, isTrue);
      _expectTeachers(exam.teachers);
    });

    test('legacy dates do not restrict open exams but closed status does', () {
      for (final year in [2000, 2999]) {
        final json = {
          ..._examJson,
          'startTime': '$year-01-01T00:00:00Z',
          'endTime': '$year-12-31T00:00:00Z',
        };
        expect(SchoolExamSummary.fromJson(json).isAvailable, isTrue);
        expect(
          SchoolExamSummary.fromJson({...json, 'status': 20}).isAvailable,
          isFalse,
        );
      }
    });

    for (final deadline in [null, '2026-11-07T12:30:00Z']) {
      test(
        'starts an exam with ${deadline == null ? 'no' : 'a timed'} deadline',
        () async {
          final fixture = _ApiFixture((request) {
            _expectRequest(
              request,
              'POST',
              '/school/exam/start',
              query: {'examId': '41'},
            );
            expect(_body(request), isEmpty);
            return _envelope({..._attemptJson, 'deadlineTime': deadline});
          });

          final attempt = await fixture.api.startExam(41);
          expect(attempt.attemptId, 401);
          expect(
            attempt.deadlineTime,
            deadline == null ? isNull : DateTime.parse(deadline),
          );
          expect(attempt.questions.single.paperQuestionId, 51);
          expect(attempt.questions.single.question, 'Pythonのリストを選んでください。');
          expect(attempt.questions.single.options, ['[1, 2]', '42']);
          expect(attempt.questions.single.answerIndex, -1);
          expect(fixture.requests, hasLength(1));
        },
      );
    }
  });

  group('business errors carried by HTTP 200', () {
    const errors = {
      1004002043: '少なくとも一人の担当講師を選択してください',
      1004002044: 'リソースが存在しないか、現在利用できません',
      1004002045: '他の講師が内容を更新しました。再読み込みしてから保存してください',
      1004002046: 'この言語の自動採点には対応していません',
    };
    for (final entry in errors.entries) {
      test(
        'preserves ApiException.code=${entry.key} and does not retry',
        () async {
          final fixture = _ApiFixture(
            (_) => _envelope(null, code: entry.key, message: entry.value),
          );
          final Future<Object?> operation;
          switch (entry.key) {
            case 1004002043:
              operation = fixture.api.createAndPublishExam(
                paperId: 31,
                title: '公開テスト',
                description: '',
                teacherAccountIds: [],
              );
            case 1004002044:
              operation = fixture.api.courseDocument(201);
            case 1004002045:
              operation = fixture.api.saveVideoProgress(
                courseVideoId: 101,
                contentVersion: 0,
                positionSeconds: 95,
                durationSeconds: 600,
                ended: false,
              );
            default:
              operation = fixture.api.scoreCode(
                assignmentId: 61,
                code: 'print(1)',
              );
          }
          await expectLater(
            operation,
            throwsA(
              isA<ApiException>()
                  .having((error) => error.code, 'business code', entry.key)
                  .having(
                    (error) => error.message,
                    'server message',
                    entry.value,
                  ),
            ),
          );
          expect(fixture.requests, hasLength(1));
        },
      );
    }
  });

  testWidgets(
    'teacher shared edit reads fresh details, sends full PUT and requires manual conflict recovery',
    (tester) async {
      ItClassSession.current = AuthSession.fromJson({
        'userId': 1012,
        'accessToken': 'shared-resources-test-token',
        'schoolAccountId': 12,
        'schoolAccountType': schoolAccountTypeTeacher,
        'realName': 'B先生',
      });
      final latestDetail = {
        ..._videoJson,
        'title': 'A先生の最新動画',
        'description': '最新の説明とメタデータ',
        'version': 7,
        'contentVersion': 2,
        'status': 1,
        'teacherAccountId': 11,
        'ownerTeacherAccountId': 11,
        'chapterNo': 4,
        'sort': 9,
        'videoPath': 'video/python-v2.mp4',
        'fileName': 'python-v2.mp4',
        'fileSize': 4096,
        'contentType': 'video/mp4',
        'coverUrl':
            'https://example.invalid/private/cover.png?X-Amz-Signature=temporary',
      };
      final reloadedDetail = {
        ...latestDetail,
        'title': 'A先生がさらに更新した動画',
        'description': '競合後の最新説明',
        'version': 8,
        'sort': 10,
      };
      const fullUpdate = {
        'id': 101,
        'version': 7,
        'status': 1,
        'classroomId': null,
        'programmingLanguage': 'Python',
        'teacherAccountIds': [11, 12],
        'title': 'B先生の編集',
        'description': '最新の説明とメタデータ',
        'chapterNo': 4,
        'sort': 9,
        'videoUrl': 'https://example.invalid/private/lesson.mp4',
        'videoPath': 'video/python-v2.mp4',
        'fileName': 'python-v2.mp4',
        'fileSize': 4096,
        'contentType': 'video/mp4',
        'durationSeconds': 600,
        'coverUrl': 'https://example.invalid/private/cover.png',
      };
      final pendingDetail = Completer<http.Response>();
      final operations = <String>[];
      final updates = <Map<String, dynamic>>[];
      final unexpectedRequests = <String>[];
      var detailReads = 0;
      final fixture = _ApiFixture((request) {
        switch (request.url.path) {
          case '/app-api/school/classroom/my-list':
          case '/app-api/school/account/student/list-simple':
            expect(request.method, 'GET');
            return _envelope([]);
          case '/app-api/school/ai-teacher/question/page':
          case '/app-api/school/chat/conversation/page':
          case '/app-api/school/exam-teacher/attempt/page':
            expect(request.method, 'GET');
            return _envelope(_page([]));
          case '/app-api/school/account/teacher/list-simple':
            _expectRequest(
              request,
              'GET',
              '/school/account/teacher/list-simple',
            );
            return _envelope(_teachersJson);
          case '/app-api/school/course-video/teacher-page':
            _expectRequest(
              request,
              'GET',
              '/school/course-video/teacher-page',
              query: {'pageNo': '1', 'pageSize': '20'},
            );
            return _envelope(
              _page([
                updates.length == 2
                    ? {...reloadedDetail, 'title': 'B先生が再確認して編集'}
                    : {...latestDetail, 'title': '一覧の古い動画タイトル', 'version': 1},
              ]),
            );
          case '/app-api/school/course-video/teacher-get':
            _expectRequest(
              request,
              'GET',
              '/school/course-video/teacher-get',
              query: {'id': '101'},
            );
            detailReads++;
            operations.add('GET detail');
            return detailReads == 1
                ? pendingDetail.future
                : _envelope(reloadedDetail);
          case '/app-api/school/course-video/teacher-update':
            _expectRequest(
              request,
              'PUT',
              '/school/course-video/teacher-update',
            );
            operations.add('PUT update');
            updates.add(_body(request));
            if (updates.length == 1) {
              expect(updates.single, fullUpdate);
              return _envelope(
                null,
                code: 1004002045,
                message: '他の講師が内容を更新しました。再読み込みしてから保存してください',
              );
            }
            expect(updates.last, {
              ...fullUpdate,
              'version': 8,
              'title': 'B先生が再確認して編集',
              'description': '競合後の最新説明',
              'sort': 10,
            });
            return _envelope(true);
          default:
            unexpectedRequests.add('${request.method} ${request.url}');
            return _envelope(
              null,
              code: 500,
              message: 'Unexpected mocked endpoint',
            );
        }
      });
      addTearDown(() => expect(unexpectedRequests, isEmpty));
      final originalApi = ItClassApi.instance;
      ItClassApi.instance = fixture.api;
      addTearDown(() => ItClassApi.instance = originalApi);
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: TeacherHomePage()));
      await tester.pumpAndSettle();
      await _tapAndSettle(tester, find.text('教材・テストアップロード'));
      expect(find.text('一覧の古い動画タイトル'), findsOneWidget);
      expect(detailReads, 0);
      final edit = find.byTooltip('詳細を取得して編集');
      await tester.ensureVisible(edit);
      await tester.tap(edit);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final save = find.widgetWithText(FilledButton, '保存');
      expect(detailReads, 1);
      expect(
        tester.widget<FilledButton>(save).onPressed,
        isNull,
        reason:
            'The stale list row must not be editable while teacher-get is pending.',
      );
      expect(updates, isEmpty);

      pendingDetail.complete(_envelope(latestDetail));
      await tester.pumpAndSettle();
      final title = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'タイトル',
      );
      expect(tester.widget<TextField>(title).controller!.text, 'A先生の最新動画');
      await tester.enterText(title, 'B先生の編集');
      await _tapAndSettle(tester, save);

      expect(find.text('編集内容が競合しました'), findsOneWidget);
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      expect(tester.widget<TextField>(title).controller!.text, 'B先生の編集');
      await tester.tap(save); // Disabled: even another click cannot overwrite.
      await tester.pump(const Duration(seconds: 5));
      expect(operations, ['GET detail', 'PUT update']);
      expect(updates, hasLength(1));

      await _tapAndSettle(tester, find.text('最新の内容を再読み込み'));
      expect(
        detailReads,
        1,
        reason: 'Opening confirmation must not reload or save.',
      );
      await _tapAndSettle(tester, find.text('戻る'));
      expect(operations, ['GET detail', 'PUT update']);
      await _tapAndSettle(tester, find.text('最新の内容を再読み込み'));
      await _tapAndSettle(tester, find.text('変更を破棄して再読み込み'));

      expect(detailReads, 2);
      expect(
        updates,
        hasLength(1),
        reason: 'Reloading must never automatically retry the PUT.',
      );
      expect(tester.widget<TextField>(title).controller!.text, 'A先生がさらに更新した動画');
      expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
      await tester.enterText(title, 'B先生が再確認して編集');
      await _tapAndSettle(tester, save);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('B先生が再確認して編集'), findsOneWidget);
      expect(operations, [
        'GET detail',
        'PUT update',
        'GET detail',
        'PUT update',
      ]);
      expect(updates, hasLength(2));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final viewport in [
    (name: 'desktop', size: const Size(1280, 900)),
    (name: '390px mobile', size: const Size(390, 844)),
  ]) {
    group('student without a classroom on ${viewport.name}', () {
      testWidgets(
        'teacher directory merges resource teachers without history and creates only the chosen consultation',
        (tester) async {
          final fixture = _StudentApiFixture(
            videos: [
              _videoJson,
              {..._videoJson, 'id': 102, 'title': 'Python応用動画'},
            ],
            documents: [
              {
                ..._documentJson,
                'teachers': [
                  // The same school account can carry an older display name
                  // on another resource. Identity must not depend on the name.
                  {..._teachersJson.first, 'realName': 'A先生（旧表示名）'},
                  _teachersJson.last,
                ],
              },
            ],
            exams: const [],
          );
          await _mountStudent(tester, fixture, viewport.size);
          await _selectStudentSection(tester, 'AI教室');
          await _tapAndSettle(
            tester,
            find.byType(DropdownButtonFormField<String>),
          );
          await _tapAndSettle(tester, find.text('Python').last);
          await _selectStudentSection(tester, '先生に質問');

          for (final teacher in [
            (id: 11, name: 'A先生'),
            (id: 12, name: 'B先生'),
          ]) {
            final card = find.byKey(
              ValueKey('teacher-directory-${teacher.id}'),
            );
            expect(
              card,
              findsOneWidget,
              reason:
                  'Repeated video/document assignments must produce one card per accountId.',
            );
            expect(
              find.descendant(
                of: card,
                matching: find.textContaining(teacher.name),
              ),
              findsOneWidget,
            );
            final languages = find.descendant(
              of: card,
              matching: find.textContaining('担当言語：'),
            );
            expect(languages, findsOneWidget);
            final label = tester.widget<Text>(languages).data!;
            expect(label, contains('Python'));
            expect(
              label,
              contains('TypeScript'),
              reason:
                  'The learning filter must not hide other responsible languages.',
            );
            expect(RegExp('Python').allMatches(label), hasLength(1));
            expect(label, isNot(contains('Java')));
            expect(
              card.hitTestable(),
              findsOneWidget,
              reason:
                  'The initial mobile directory must be usable without opening a drawer.',
            );
          }
          expect(
            find.byKey(const ValueKey('teacher-directory-999')),
            findsNothing,
          );
          expect(fixture.conversations, isEmpty);
          expect(fixture.consultations, isEmpty);
          expect(fixture.readConversationIds, isEmpty);
          expect(
            fixture.requests.where(
              (request) => request.url.path.endsWith('/resource/teachers'),
            ),
            isEmpty,
            reason:
                'The directory must use teachers already returned with resources.',
          );

          final teacherB = find.byKey(const ValueKey('teacher-directory-12'));
          await tester.tap(teacherB);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
          expect(find.text('相談する資料を選択'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('teacher-resource-VIDEO-101')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('teacher-resource-VIDEO-102')),
            findsOneWidget,
          );
          final document = find.byKey(
            const ValueKey('teacher-resource-DOCUMENT-201'),
          );
          expect(document, findsOneWidget);
          expect(
            find.descendant(
              of: document,
              matching: find.text('公開TypeScript教材'),
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: document,
              matching: find.textContaining('TypeScript'),
            ),
            findsWidgets,
          );
          expect(
            fixture.consultations,
            isEmpty,
            reason:
                'Choosing a teacher must wait for the explicit resource choice.',
          );

          await _tapAndSettle(tester, document);
          expect(fixture.consultations, [
            {
              'peerAccountId': 12,
              'resourceType': 'DOCUMENT',
              'resourceId': 201,
            },
          ]);
          expect(fixture.readConversationIds, [312]);
          expect(find.text('先生に質問：B先生'), findsOneWidget);
          expect(find.text('返信: 会話312'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );

      testWidgets(
        'teacher directory preserves separate existing conversations for the same teacher',
        (tester) async {
          final fixture = _StudentApiFixture(
            exams: const [],
            history: [
              _conversationJson(901, 11, 'VIDEO', 101, '公開Python動画', unread: 2),
              _conversationJson(
                902,
                11,
                'DOCUMENT',
                201,
                '公開TypeScript教材',
                unread: 5,
              ),
            ],
          );
          await _mountStudent(tester, fixture, viewport.size);
          await _selectStudentSection(tester, '先生に質問');
          expect(fixture.consultations, isEmpty);
          expect(
            fixture.readConversationIds,
            isEmpty,
            reason:
                'Entering the directory must wait for an explicit conversation choice.',
          );

          for (final conversationId in [902, 901, 902]) {
            await _tapAndSettle(
              tester,
              find.byKey(const ValueKey('teacher-directory-11')),
            );
            final video = find.byKey(
              const ValueKey('teacher-conversation-901'),
            );
            final document = find.byKey(
              const ValueKey('teacher-conversation-902'),
            );
            expect(video, findsOneWidget);
            expect(document, findsOneWidget);
            expect(
              find.descendant(
                of: video,
                matching: find.textContaining('公開Python動画'),
              ),
              findsWidgets,
            );
            expect(
              find.descendant(
                of: document,
                matching: find.textContaining('公開TypeScript教材'),
              ),
              findsWidgets,
            );
            expect(find.text('新しい相談'), findsOneWidget);
            expect(fixture.consultations, isEmpty);

            await _tapAndSettle(
              tester,
              find.byKey(ValueKey('teacher-conversation-$conversationId')),
            );
            expect(fixture.readConversationIds.last, conversationId);
            expect(find.text('返信: 会話$conversationId'), findsOneWidget);
            expect(
              find.text('返信: 会話${conversationId == 901 ? 902 : 901}'),
              findsNothing,
            );
            expect(
              fixture.consultations,
              isEmpty,
              reason:
                  'Existing conversations must open by their own ID, not create another chat.',
            );
            await _tapAndSettle(
              tester,
              find.widgetWithText(TextButton, '先生一覧'),
            );
          }
          expect(fixture.readConversationIds, [902, 901, 902]);
          expect(fixture.conversations.keys, unorderedEquals([901, 902]));
          expect(
            find.byKey(const ValueKey('teacher-directory-11')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('teacher-directory-12')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );

      testWidgets('renders public video and starts an unlimited public exam', (
        tester,
      ) async {
        final fixture = _StudentApiFixture();
        await _mountStudent(tester, fixture, viewport.size);
        expect(find.text(_globalWelcome), findsOneWidget);

        await _selectStudentSection(tester, 'AI教室');
        expect(find.text('公開Python動画'), findsWidgets);
        expect(
          tester
              .widget<DropdownButtonFormField<String>>(
                find.byType(DropdownButtonFormField<String>),
              )
              .initialValue,
          'Python',
        );
        expect(find.text('教室なしで学ぶPython'), findsWidgets);
        expect(find.text('動画がありません'), findsNothing);
        expect(find.text('先生に相談'), findsOneWidget);

        await _selectStudentSection(tester, 'テスト');
        expect(find.textContaining('時間制限なし'), findsWidgets);
        expect(find.textContaining('回数制限なし'), findsWidgets);
        await _tapAndSettle(tester, find.text('テスト開始'));
        expect(find.text('公開Pythonテスト'), findsWidgets);
        expect(find.text('Pythonのリストを選んでください。'), findsOneWidget);
        expect(find.textContaining('残り '), findsNothing);
        expect(find.text('テストを提出'), findsOneWidget);
        expect(
          fixture.requests.where(
            (request) => request.url.path.endsWith('/exam/start'),
          ),
          hasLength(1),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });

      testWidgets('opens the public document through visible learning controls', (
        tester,
      ) async {
        final fixture = _StudentApiFixture();
        await _mountStudent(tester, fixture, viewport.size);
        await _selectStudentSection(tester, 'AI教室');
        final selector = find.byType(DropdownButtonFormField<LearningMode>);
        expect(
          selector,
          findsOneWidget,
          reason:
              'Students must be able to switch to documents at ${viewport.size.width}px.',
        );
        await _tapAndSettle(tester, selector);
        await _tapAndSettle(tester, find.text('文書学習').last);

        await _tapAndSettle(
          tester,
          find.byType(DropdownButtonFormField<String>),
        );
        await _tapAndSettle(tester, find.text('TypeScript').last);

        expect(find.text('公開TypeScript教材'), findsWidgets);
        expect(find.textContaining('教室なしで学ぶTypeScript'), findsWidgets);
        expect(find.text('教材がありません'), findsNothing);
        expect(find.byKey(const ValueKey('DOCUMENT:201')), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });

      testWidgets(
        'two resource teachers keep distinct conversation IDs when revisited',
        (tester) async {
          final fixture = _StudentApiFixture();
          await _mountStudent(tester, fixture, viewport.size);
          const selections = [
            (teacher: 'A先生', account: 11, conversation: 301),
            (teacher: 'B先生', account: 12, conversation: 302),
            (teacher: 'A先生', account: 11, conversation: 301),
          ];

          for (var index = 0; index < selections.length; index++) {
            final selection = selections[index];
            await _selectStudentSection(tester, 'AI教室');
            // The consultation button stays busy while the modal is open.
            // Wait for its entrance animation, not for every spinner to stop.
            await tester.ensureVisible(find.text('先生に相談'));
            await tester.tap(find.text('先生に相談'));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 300));
            final dialog = find.byType(AlertDialog);
            expect(dialog, findsOneWidget);
            expect(
              find.descendant(of: dialog, matching: find.text('A先生')),
              findsOneWidget,
            );
            expect(
              find.descendant(of: dialog, matching: find.text('B先生')),
              findsOneWidget,
            );
            final bounds = tester.getRect(dialog);
            expect(bounds.left, greaterThanOrEqualTo(0));
            expect(bounds.right, lessThanOrEqualTo(viewport.size.width));
            expect(bounds.top, greaterThanOrEqualTo(0));
            expect(bounds.bottom, lessThanOrEqualTo(viewport.size.height));
            final choice = find.descendant(
              of: dialog,
              matching: find.text(selection.teacher),
            );
            expect(choice.hitTestable(), findsOneWidget);
            await _tapAndSettle(tester, choice);

            expect(find.text('先生に質問：${selection.teacher}'), findsOneWidget);
            expect(
              find.text('返信: 会話${selection.conversation}'),
              findsOneWidget,
            );
            final otherConversation = selection.conversation == 301 ? 302 : 301;
            expect(find.text('返信: 会話$otherConversation'), findsNothing);
            expect(fixture.readConversationIds.last, selection.conversation);

            final message = '${selection.teacher}への質問$index';
            await tester.enterText(find.byType(TextField), message);
            await _tapAndSettle(tester, find.text('先生へ送信'));
            expect(fixture.sentMessages.last, {
              'conversationId': selection.conversation,
              'contentType': 1,
              'content': message,
            });
            expect(find.text(message), findsOneWidget);
            expect(tester.takeException(), isNull);
          }
          expect(fixture.consultations, [
            for (final selection in selections)
              {
                'resourceType': 'VIDEO',
                'resourceId': 101,
                'peerAccountId': selection.account,
              },
          ]);
          expect(fixture.readConversationIds, [301, 302, 301]);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );

      testWidgets(
        'empty resource teachers show an empty state without creating a chat',
        (tester) async {
          final fixture = _StudentApiFixture(teachers: const []);
          await _mountStudent(tester, fixture, viewport.size);
          await _selectStudentSection(tester, 'AI教室');
          await _tapAndSettle(tester, find.text('先生に相談'));

          expect(find.textContaining('現在相談できる担当の先生はいません'), findsOneWidget);
          expect(find.byType(AlertDialog), findsNothing);
          expect(fixture.consultations, isEmpty);
          expect(fixture.readConversationIds, isEmpty);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    });
  }
}

Future<void> _mountStudent(
  WidgetTester tester,
  _StudentApiFixture fixture,
  Size size,
) async {
  final originalApi = ItClassApi.instance;
  ItClassApi.instance = fixture.api;
  addTearDown(() => ItClassApi.instance = originalApi);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // The fake session is installed by setUp; accountLogin would open a real WS.
  // Do not start media playback or open document URLs in these UI tests.
  await tester.pumpWidget(const MaterialApp(home: StudentHomePage()));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  for (final path in [
    'course-video/page',
    'course-document/page',
    'exam/page',
  ]) {
    expect(
      fixture.requests.where(
        (request) => request.url.path == '/app-api/school/$path',
      ),
      hasLength(1),
    );
  }
}

Future<void> _selectStudentSection(WidgetTester tester, String label) async {
  if (tester.view.physicalSize.width / tester.view.devicePixelRatio < 980) {
    await _tapAndSettle(tester, find.byTooltip('Open navigation menu'));
  }
  await _tapAndSettle(tester, find.text(label));
}

Future<void> _tapAndSettle(WidgetTester tester, Finder finder) async {
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

const _globalWelcome = '全言語で質問できます（モック設定）';

class _StudentApiFixture {
  _StudentApiFixture({
    this.teachers = _teachersJson,
    this.videos = const [_videoJson],
    this.documents = const [_documentJson],
    this.exams = const [_examJson],
    List<Map<String, Object?>> history = const [],
  }) {
    for (final conversation in history) {
      conversations[conversation['id'] as int] = Map.of(conversation);
    }
    transport = _ApiFixture(_respond);
    addTearDown(
      () => expect(
        unexpectedRequests,
        isEmpty,
        reason:
            'Unexpected requests must fail even when the page catches API errors.',
      ),
    );
  }

  final List<Map<String, Object?>> teachers;
  final List<Map<String, Object?>> videos;
  final List<Map<String, Object?>> documents;
  final List<Map<String, Object?>> exams;
  late final _ApiFixture transport;
  ItClassApi get api => transport.api;
  List<http.Request> get requests => transport.requests;
  final unexpectedRequests = <String>[];
  final consultations = <Map<String, dynamic>>[];
  final readConversationIds = <int>[];
  final sentMessages = <Map<String, dynamic>>[];
  final conversations = <int, Map<String, Object?>>{};

  Map<String, Object?> _resource(String type, int id) {
    final resources = switch (type) {
      'VIDEO' => videos,
      'DOCUMENT' => documents,
      'EXAM' => exams,
      _ => throw StateError('Unexpected resource type: $type'),
    };
    return resources.singleWhere((resource) => resource['id'] == id);
  }

  http.Response _respond(http.Request request) {
    expect(request.url.queryParameters, isNot(contains('classroomId')));
    switch (request.url.path) {
      case '/app-api/school/classroom/my-list':
      case '/app-api/school/practice-question/list':
      case '/app-api/school/code-scoring/assignment/list':
        expect(request.method, 'GET');
        return _envelope([]);
      case '/app-api/school/ai-tutor/config/get':
        _expectRequest(request, 'GET', '/school/ai-tutor/config/get');
        return _envelope({
          'classroomId': null,
          'programmingLanguage': 'ALL',
          'welcomeMessage': _globalWelcome,
          'autoAnswerEnabled': true,
        });
      case '/app-api/school/ai-tutor/conversation/page':
        return _envelope(_page([]));
      case '/app-api/school/course-video/page':
        return _envelope(_page(videos));
      case '/app-api/school/course-document/page':
        return _envelope(_page(documents));
      case '/app-api/school/exam/page':
        return _envelope(_page(exams));
      case '/app-api/school/exam/start':
        _expectRequest(
          request,
          'POST',
          '/school/exam/start',
          query: {'examId': '41'},
        );
        return _envelope(_attemptJson);
      case '/app-api/school/resource/teachers':
        final type = request.url.queryParameters['resourceType']!;
        final id = int.parse(request.url.queryParameters['resourceId']!);
        _expectRequest(
          request,
          'GET',
          '/school/resource/teachers',
          query: {'resourceType': type, 'resourceId': '$id'},
        );
        _resource(type, id);
        return _envelope(teachers);
      case '/app-api/school/chat/conversation/get-or-create':
        _expectRequest(
          request,
          'POST',
          '/school/chat/conversation/get-or-create',
        );
        final body = _body(request);
        final teacher = body['peerAccountId'] as int;
        final type = body['resourceType'] as String;
        final resourceId = body['resourceId'] as int;
        final resource = _resource(type, resourceId);
        expect(teacher, anyOf(11, 12));
        expect(body, {
          'resourceType': type,
          'resourceId': resourceId,
          'peerAccountId': teacher,
        });
        consultations.add(body);
        final existing = conversations.values.where(
          (conversation) =>
              conversation['peerAccountId'] == teacher &&
              conversation['resourceType'] == type &&
              conversation['resourceId'] == resourceId,
        );
        final id = existing.isNotEmpty
            ? existing.single['id'] as int
            : switch ((type, resourceId, teacher)) {
                ('VIDEO', 101, 11) => 301,
                ('VIDEO', 101, 12) => 302,
                ('DOCUMENT', 201, 11) => 311,
                ('DOCUMENT', 201, 12) => 312,
                _ => 400 + consultations.length,
              };
        conversations[id] = _conversationJson(
          id,
          teacher,
          type,
          resourceId,
          resource['title'] as String,
        );
        return _envelope(id);
      case '/app-api/school/chat/conversation/page':
        _expectRequest(
          request,
          'GET',
          '/school/chat/conversation/page',
          query: {'pageNo': '1', 'pageSize': '100'},
        );
        return _envelope(_page(conversations.values.toList()));
      case '/app-api/school/chat/message/page':
        final id = int.parse(request.url.queryParameters['conversationId']!);
        _expectRequest(
          request,
          'GET',
          '/school/chat/message/page',
          query: {'conversationId': '$id', 'pageNo': '1', 'pageSize': '100'},
        );
        expect(conversations, contains(id));
        readConversationIds.add(id);
        return _envelope(
          _page([
            {
              'id': id + 1000,
              'conversationId': id,
              'senderAccountId': conversations[id]!['peerAccountId'],
              'senderAccountType': schoolAccountTypeTeacher,
              'content': '返信: 会話$id',
            },
          ]),
        );
      case '/app-api/school/chat/message/read':
        _expectRequest(request, 'PUT', '/school/chat/message/read');
        final body = _body(request);
        final id = body['conversationId'] as int;
        expect(conversations, contains(id));
        expect(body, {'conversationId': id, 'messageId': id + 1000});
        return _envelope(true);
      case '/app-api/school/chat/message/send':
        _expectRequest(request, 'POST', '/school/chat/message/send');
        final body = _body(request);
        expect(conversations, contains(body['conversationId']));
        sentMessages.add(body);
        return _envelope({
          ...body,
          'id': 5000 + sentMessages.length,
          'senderAccountId': 501,
          'senderAccountType': schoolAccountTypeStudent,
        });
      default:
        unexpectedRequests.add('${request.method} ${request.url}');
        return _envelope(
          null,
          code: 500,
          message: 'Unexpected mocked endpoint',
        );
    }
  }
}

class _ApiFixture {
  _ApiFixture(FutureOr<http.Response> Function(http.Request) respond) {
    final client = MockClient((request) async {
      requests.add(request);
      expect(request.headers['tenant-id'], ItClassApi.tenantId);
      expect(
        request.headers['authorization'],
        'Bearer shared-resources-test-token',
      );
      expect(request.headers['content-type'], startsWith('application/json'));
      return respond(request);
    });
    api = ItClassApi.forTesting(client);
    addTearDown(client.close);
  }

  late final ItClassApi api;
  final requests = <http.Request>[];
}

http.Response _envelope(Object? data, {int code = 0, String message = ''}) =>
    http.Response(
      jsonEncode({'code': code, 'data': data, 'msg': message}),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

Map<String, dynamic> _body(http.Request request) =>
    jsonDecode(request.body) as Map<String, dynamic>;

void _expectRequest(
  http.Request request,
  String method,
  String path, {
  Map<String, String> query = const {},
}) {
  expect(request.method, method);
  expect(request.url.path, '/app-api$path');
  expect(request.url.queryParameters, query);
  if (method == 'GET') expect(request.body, isEmpty);
}

Map<String, Object?> _page(List<Object?> rows) => {
  'list': rows,
  'total': rows.length,
};

void _expectTeachers(List<ResourceTeacher> teachers) {
  expect(teachers.map((teacher) => teacher.accountId), [11, 12]);
  expect(teachers.map((teacher) => teacher.realName), ['A先生', 'B先生']);
  expect(teachers.map((teacher) => teacher.accountNo), [
    'TWT2026001',
    'TWT2026002',
  ]);
  expect(teachers.map((teacher) => teacher.status), [0, 0]);
  expect(teachers.map((teacher) => teacher.avatar), ['', '']);
}

const _teachersJson = [
  {
    'accountId': 11,
    'userId': 1011,
    'accountNo': 'TWT2026001',
    'realName': 'A先生',
    'avatar': '',
    'status': 0,
  },
  {
    'accountId': 12,
    'userId': 1012,
    'accountNo': 'TWT2026002',
    'realName': 'B先生',
    'avatar': '',
    'status': 0,
  },
];

const _videoJson = {
  'id': 101,
  'classroomId': null,
  'title': '公開Python動画',
  'description': '教室なしで学ぶPython',
  'programmingLanguage': 'Python',
  'classroomProgrammingLanguage': 'Java',
  'version': 2,
  'contentVersion': 7,
  'durationSeconds': 600,
  'progressPercent': 0,
  'teacherAccountId': 999,
  'teacherAccountIds': [11, 12],
  'teachers': _teachersJson,
  'videoUrl': 'https://example.invalid/private/lesson.mp4',
  'playUrl':
      'https://example.invalid/private/lesson.mp4?X-Amz-Signature=video-test&X-Amz-Expires=600',
};

const _documentJson = {
  'id': 201,
  'classroomId': null,
  'title': '公開TypeScript教材',
  'description': '教室なしで学ぶTypeScript',
  'programmingLanguage': 'TypeScript',
  'classroomProgrammingLanguage': 'Java',
  'version': 3,
  'teacherAccountId': 999,
  'teacherAccountIds': [11, 12],
  'teachers': _teachersJson,
  'fileName': 'typescript.pdf',
  'documentUrl': 'https://example.invalid/private/typescript.pdf',
  'accessUrl':
      'https://example.invalid/private/typescript.pdf?X-Amz-Signature=document-test&X-Amz-Expires=600',
};

const _examJson = {
  'id': 41,
  'title': '公開Pythonテスト',
  'description': '教室も時間制限も不要です。',
  'status': 10,
  'classroomId': null,
  'startTime': null,
  'endTime': null,
  'alwaysAvailable': true,
  'durationMinutes': 0,
  'maxAttempts': 0,
  'teachers': _teachersJson,
};

const _attemptJson = {
  'attemptId': 401,
  'examTitle': '公開Pythonテスト',
  'deadlineTime': null,
  'questions': [
    {
      'paperQuestionId': 51,
      'questionId': 61,
      'title': 'リスト',
      'content': 'Pythonのリストを選んでください。',
      'type': 1,
      'score': 10,
      'options': [
        {'optionKey': 'A', 'content': '[1, 2]'},
        {'optionKey': 'B', 'content': '42'},
      ],
    },
  ],
};

Map<String, Object?> _conversationJson(
  int id,
  int teacher,
  String type,
  int resource,
  String name, {
  int unread = 0,
}) => {
  'id': id,
  'classroomId': null,
  'peerAccountId': teacher,
  'peerRealName': teacher == 11 ? 'A先生' : 'B先生',
  'peerAccountNo': teacher == 11 ? 'TWT2026001' : 'TWT2026002',
  'resourceType': type,
  'resourceId': resource,
  'resourceName': name,
  'lastMessageId': id + 1000,
  'lastMessageContent': '会話$idのメッセージ',
  'lastMessageTime': '2026-11-07T10:00:00Z',
  'unreadCount': unread,
};
