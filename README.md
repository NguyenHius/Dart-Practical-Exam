# Dart Order Management – SET01 Practical

## Requirements
- Dart SDK 3.3 or newer
- Visual Studio Code
- Internet connection for the first `dart pub get`

## VS Code extensions
Install:
1. **Dart** (`Dart-Code.dart-code`) – required for Dart language support, analysis and debugging.
2. **Error Lens** (`usernamehw.errorlens`) – optional; shows diagnostics inline.
3. **REST Client** (`humao.rest-client`) – optional; useful for testing HTTP endpoints from a `.http` file.

This project does not use Flutter, so the Flutter extension is not required.

## Run the application
Open this project folder in VS Code, then open Terminal > New Terminal.

```bash
dart --version
dart pub get
dart run bin/server.dart
```

Open `http://localhost:8080` in your browser. Keep the terminal running while using the website. Press `Ctrl+C` to stop the server.

The server creates `order.json` in the project root on its first run. It starts with the two sample records from the exam. Added and deleted orders are written to that file.

## Test checklist
1. Initial display: expect A1000 / Iphone 15 / 1200 USD and A1001 / Iphone 16 / 1500 USD.
2. Add: A1002, Iphone 17, 1700, quantity 2, USD. Expect success and a third row.
3. Persistence: stop the server with Ctrl+C, start it again, refresh the page. A1002 should still exist.
4. Search: type `iphone 16`; only A1001 should appear. Search is case-insensitive and partial.
5. Search no match: type `Pixel`; expect “No matching orders found.”
6. Validation: try an empty item name, zero price, zero quantity, or duplicate item code. Expect an error.
7. Delete: delete A1002 and confirm. It should disappear from the table and from `order.json`.
8. Clear: click Clear; all remaining orders should return.

## HTTP API
- `GET /api/orders` – list all orders
- `GET /api/orders/search?name=iphone` – search by ItemName
- `POST /api/orders` – insert an order; JSON body uses `Item`, `ItemName`, `Price`, `Currency`, `Quantity`
- `DELETE /api/orders/A1002` – optional delete feature

## Project structure
- `lib/order.dart` – Order model and JSON conversion
- `lib/order_manager.dart` – in-memory list, JSON loading, searching, file persistence
- `bin/server.dart` – Dart HTTP server and API routes
- `web/` – website UI
- `order.json` – persistent order data, generated on first run
