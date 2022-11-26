import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:syncus/models/data_sources.dart';
import 'package:syncus/models/models.dart';

FutureOr<Response> onRequest(RequestContext context, String id) async {
  id = idSanitizer(id);
  if (!idValidator(id)) {
    return Response(
        statusCode: HttpStatus.notAcceptable, body: 'Not acceptable');
  }

  final dataSource = context.read<InMemoryDataSource<Juncture>>();
  final juncture = await dataSource.read(id);

  if (juncture == null) {
    return Response(statusCode: HttpStatus.notFound, body: 'Not found');
  }

  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context, juncture);
    case HttpMethod.put:
      return _put(context);
    case HttpMethod.delete:
      return _delete(context, id);
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.post:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context, Juncture juncture) async {
  return Response.json(body: juncture);
}

Future<Response> _put(RequestContext context) async {
  final dataSource = context.read<InMemoryDataSource<Juncture>>();
  final updatedTodo = Juncture.fromJson(await context.request.json());
  return Response.json(body: await dataSource.update(updatedTodo));
}

Future<Response> _delete(RequestContext context, String id) async {
  final dataSource = context.read<InMemoryDataSource<Juncture>>();
  await dataSource.delete(id);
  return Response(statusCode: HttpStatus.noContent);
}

String idSanitizer(String id) => id.toUpperCase();

bool idValidator(String id) => RegExp(r'^[A-Z0-9]{6,}$').hasMatch(id);
