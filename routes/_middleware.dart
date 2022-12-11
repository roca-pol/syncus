import 'package:dart_frog/dart_frog.dart';
import 'package:syncus/models/data_sources.dart';
import 'package:syncus/models/models.dart';
import 'package:syncus/definitions.dart';

final _dataSource = InMemoryDataSource<Juncture>();

Handler middleware(Handler handler) {
  return (context) async {
    final response = await handler(context);
    return response.copyWith(headers: responseHeaders);
  };
}
