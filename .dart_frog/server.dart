// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';


import '../routes/ping.dart' as ping;
import '../routes/index.dart' as index;
import '../routes/api/juncture/index.dart' as api_juncture_index;
import '../routes/api/juncture/[id].dart' as api_juncture_$id;

import '../routes/api/juncture/_middleware.dart' as api_juncture_middleware;

void main() => hotReload(createServer);

Future<HttpServer> createServer() {
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final handler = Cascade().add(buildRootHandler()).handler;
  return serve(handler, ip, port);
}

Handler buildRootHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..mount('/api/juncture', (context) => buildApiJunctureHandler()(context))
    ..mount('/', (context) => buildHandler()(context));
  return pipeline.addHandler(router);
}

Handler buildApiJunctureHandler() {
  final pipeline = const Pipeline().addMiddleware(api_juncture_middleware.middleware);
  final router = Router()
    ..all('/', (context) => api_juncture_index.onRequest(context,))..all('/<id>', (context,id,) => api_juncture_$id.onRequest(context,id,));
  return pipeline.addHandler(router);
}

Handler buildHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/ping', (context) => ping.onRequest(context,))..all('/', (context) => index.onRequest(context,));
  return pipeline.addHandler(router);
}
