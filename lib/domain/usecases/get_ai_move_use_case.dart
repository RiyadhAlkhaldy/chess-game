// // lib/domain/usecases/get_ai_move.dart
// import 'dart:developer';
// import 'dart:isolate'; // استيراد Isolates


// import '../entities/board.dart';
// import '../entities/move.dart';
// import '../repositories/game_repository.dart';

// // /// [GetAIMoveUseCase]
// // /// حالة الاستخدام هذه مسؤولة عن الحصول على أفضل حركة للذكاء الاصطناعي.
// // /// This use case is responsible for getting the best move for the AI.
// // class GetAIMoveUseCase {
// //   final AIGameRepository _aiGameRepository;

// //   GetAIMoveUseCase(this._aiGameRepository);

// //   /// [execute]
// //   /// ينفذ عملية البحث عن أفضل حركة للذكاء الاصطناعي.
// //   /// Execution the process of searching for the best move for the AI.
// //   Future<Move?> execute(Board board, int depth) async {
// //     return await _aiGameRepository.findBestMove(board, depth);
// //   }
// // }

// /// حالة استخدام لطلب حركة من الذكاء الاصطناعي.
// /// تعتمد على [GameRepository] للحصول على الحركات وتحديد الأفضل.
// class GetAIMoveUseCase {
//   final AIGameRepository repository;

//   GetAIMoveUseCase(this.repository);

//   /// تنفذ حالة الاستخدام.
//   /// [board] هي اللوحة الحالية.
//   /// [aiPlayerColor] هو لون القطع التي يلعب بها الذكاء الاصطناعي.
//   /// تعيد [Move] المقترحة من الذكاء الاصطناعي، أو null إذا لم تكن هناك حركات ممكنة.
//   Future<Move?> execute(Board board, int aiDepth) async {
//     final ReceivePort receivePort = ReceivePort();
//     final SendPort sendPort = receivePort.sendPort;

//     // البدء في Isolate جديد لتشغيل منطق الذكاء الاصطناعي
//     final Isolate aiIsolate = await Isolate.spawn(
//       _aiEntrypoint, // الدالة التي سيتم تشغيلها في الـ Isolate
//       {'sendPort': sendPort, 'board': board, 'aiDepth': aiDepth},
//     );

//     // انتظار النتيجة من الـ Isolate
//     final dynamic result = await receivePort.first;

//     // إغلاق الـ Isolate عندما ينتهي
//     aiIsolate.kill();

//     if (result is Move) {
//       log('GetAiMove: AI returned a move: ${result.start} -> ${result.end}');
//       return result;
//     } else if (result == null) {
//       log('GetAiMove: AI returned null (no legal moves or game ended).');
//       return null;
//     } else {
//       log('GetAiMove: Unexpected result from AI Isolate: $result');
//       return null;
//     }
//   }

//   /// نقطة الدخول لـ Isolate الذكاء الاصطناعي.
//   /// هذه الدالة يجب أن تكون دالة على مستوى أعلى (top-level) أو ثابتة (static).
//   void _aiEntrypoint(Map<String, dynamic> message) async {
//     final SendPort sendPort = message['sendPort'] as SendPort;
//     final Board board = message['board'] as Board;
//     final int aiDepth = message['aiDepth'] as int;

//     // إنشاء GameRepositoryImpl مؤقت داخل الـ Isolate
//     // (لا يمكن الوصول إلى Get.find() هنا، لذا يجب إنشاء المثيل يدوياً)
//     final AIGameRepositoryImpl repository = AIGameRepositoryImpl();

//     // استدعاء دالة الذكاء الاصطناعي من الـ repository
//     final Move? aiMove = await repository.findBestMove(board, aiDepth);

//     // إرسال النتيجة مرة أخرى إلى الـ Isolate الرئيسي
//     sendPort.send(aiMove);
//   }
// }
