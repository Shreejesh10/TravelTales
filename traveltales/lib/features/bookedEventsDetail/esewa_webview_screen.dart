import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EsewaWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final Map<String, dynamic> formData;
  final String successUrlPrefix;
  final String failureUrlPrefix;

  const EsewaWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.formData,
    required this.successUrlPrefix,
    required this.failureUrlPrefix,
  });

  @override
  State<EsewaWebViewScreen> createState() => _EsewaWebViewScreenState();
}

class _EsewaWebViewScreenState extends State<EsewaWebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;
  bool hasReturned = false;

  String _buildHtmlForm() {
    final inputs = widget.formData.entries.map((entry) {
      return '<input type="hidden" name="${entry.key}" value="${entry.value}">';
    }).join();

    return '''
<!DOCTYPE html>
<html>
  <body onload="document.forms[0].submit();">
    <form method="POST" action="${widget.paymentUrl}">
      $inputs
    </form>
    <p>Redirecting to eSewa...</p>
  </body>
</html>
''';
  }

  void _handleFinalResult(String url) {
    if (hasReturned) return;

    if (url.startsWith(widget.successUrlPrefix)) {
      hasReturned = true;
      Navigator.pop(context, true);
    } else if (url.startsWith(widget.failureUrlPrefix)) {
      hasReturned = true;
      Navigator.pop(context, false);
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() => isLoading = true);
          },
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() => isLoading = false);
            _handleFinalResult(url);
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_buildHtmlForm());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pay with eSewa")),
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