import 'package:dart_frog/dart_frog.dart';
import 'package:syncus/definitions.dart';

Response onRequest(RequestContext context) {
  return Response.json(
      body: {'serverTimestamp': DateTime.now().microsecondsSinceEpoch});
}
