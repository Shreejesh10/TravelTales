import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EsewaWebViewScreen extends StatefulWidget {
  final String formUrl;
  final Map<String, dynamic> fields;

  const EsewaWebViewScreen({
    super.key,
    required this.formUrl,
    required this.fields,
  });

  @override
  State<EsewaWebViewScreen> createState() => _EsewaWebViewScreenState();
}

class _EsewaWebViewScreenState extends State<EsewaWebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;

  String _buildHtmlForm() {
    final inputs = widget.fields.entries.map((entry) {
      return '<input type="hidden" name="${entry.key}" value="${entry.value}">';
    }).join();

    return '''
<!DOCTYPE html>
<html>
  <body onload="document.forms[0].submit();">
    <form method="POST" action="${widget.formUrl}">
      $inputs
    </form>
    <p>Redirecting to eSewa...</p>
  </body>
</html>
''';
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (_) {
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            final url = request.url;

            if (url.contains('/bookings/esewa/success')) {
              Navigator.pop(context, "success");
              return NavigationDecision.prevent;
            }

            if (url.contains('/bookings/esewa/failure')) {
              Navigator.pop(context, "failure");
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_buildHtmlForm());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay with eSewa"),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}