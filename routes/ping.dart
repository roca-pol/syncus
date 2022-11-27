import 'package:dart_frog/dart_frog.dart';
import 'package:syncus/utils.dart';

Response onRequest(RequestContext context) {
  return Response.json(
      body: {'serverTimestamp': DateTime.now().microsecondsSinceEpoch});
}
