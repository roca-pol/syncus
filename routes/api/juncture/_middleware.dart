import 'package:dart_frog/dart_frog.dart';
import 'package:syncus/models/data_sources.dart';
import 'package:syncus/models/models.dart';

final _dataSource = InMemoryDataSource<Juncture>();

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<InMemoryDataSource<Juncture>>((_) => _dataSource));
}
