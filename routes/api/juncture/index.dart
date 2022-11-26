import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:syncus/models/models.dart';
import 'package:syncus/models/data_sources.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context);
    case HttpMethod.post:
      return _post(context);
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.put:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context) async {
  final dataSource = context.read<InMemoryDataSource<Juncture>>();
  final junctures = await dataSource.readAll();
  return Response.json(body: junctures);
}

Future<Response> _post(RequestContext context) async {
  final dataSource = context.read<InMemoryDataSource<Juncture>>();
  final juncture = Juncture.fromJson(await context.request.json());

  return Response.json(
    statusCode: HttpStatus.created,
    body: await dataSource.create(juncture),
  );
}
