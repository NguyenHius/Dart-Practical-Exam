import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import '../lib/order.dart';
import '../lib/order_manager.dart';

final String webDirectory =
    '${Directory.current.path}${Platform.pathSeparator}web';

Future<void> main() async {
  final manager = OrderManager();
  await manager.initialize();

  final router = Router();

  router.get('/api/orders', (Request request) {
    return _jsonResponse(manager.getAllOrders().map((o) => o.toJson()).toList());
  });

  router.get('/api/orders/search', (Request request) {
    final query = request.url.queryParameters['name'] ?? '';
    final results = manager.searchByItemName(query);
    return _jsonResponse(results.map((o) => o.toJson()).toList());
  });

  router.post('/api/orders', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final order = Order.fromJson(data);
      final error = manager.validate(order);
      if (error != null) {
        return _jsonResponse({'error': error}, statusCode: 400);
      }

      await manager.addOrder(order);
      return _jsonResponse({
        'message': 'Order added and saved to order.json.',
        'order': order.toJson(),
      }, statusCode: 201);
    } on FormatException {
      return _jsonResponse({'error': 'Invalid JSON request.'}, statusCode: 400);
    } catch (e) {
      return _jsonResponse({'error': e.toString()}, statusCode: 400);
    }
  });

  router.delete('/api/orders/<item>', (Request request, String item) async {
    final removed = await manager.deleteOrder(item);
    if (!removed) {
      return _jsonResponse({'error': 'Order not found.'}, statusCode: 404);
    }
    return _jsonResponse({'message': 'Order deleted.'});
  });

  router.get('/', (Request request) async {
    final indexFile = File('$webDirectory${Platform.pathSeparator}index.html');
    if (!await indexFile.exists()) return Response.notFound('index.html not found');
    return Response.ok(
      indexFile.openRead(),
      headers: {'content-type': 'text/html; charset=utf-8'},
    );
  });

  router.get('/<file|.*>', (Request request, String file) async {
    final requested = file.isEmpty ? 'index.html' : file;
    final safePath = requested.replaceAll('..', '');
    final target = File('$webDirectory${Platform.pathSeparator}$safePath');
    if (await FileSystemEntity.type(target.path) !=
    FileSystemEntityType.file) {
  return Response.notFound('File not found');
  }

    final extension = safePath.split('.').last.toLowerCase();
    final contentType = switch (extension) {
      'html' => 'text/html; charset=utf-8',
      'css' => 'text/css; charset=utf-8',
      'js' => 'application/javascript; charset=utf-8',
      _ => 'application/octet-stream',
    };

    return Response.ok(
      target.openRead(),
      headers: {'content-type': contentType},
    );
  });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );

  print('Order Management website is running: http://localhost:${server.port}');
  print('Data file: ${manager.dataFilePath}');
  print('Press Ctrl+C to stop the server.');
}

Response _jsonResponse(Object data, {int statusCode = 200}) {
  return Response(
    statusCode,
    body: jsonEncode(data),
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
