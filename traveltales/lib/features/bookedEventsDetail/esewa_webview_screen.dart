import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer';

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

    log('eSewa redirect: $url');

    if (_matchesRedirect(url, widget.successUrlPrefix)) {
      hasReturned = true;
      Navigator.pop(context, {
        'success': true,
        'url': url,
      });
    } else if (_matchesRedirect(url, widget.failureUrlPrefix)) {
      hasReturned = true;
      Navigator.pop(context, {
        'success': false,
        'url': url,
      });
    }
  }

  void _returnAsFailed() {
    if (hasReturned) return;
    hasReturned = true;
    Navigator.pop(context, {
      'success': false,
      'url': '',
    });
  }

  bool _matchesRedirect(String currentUrl, String expectedPrefix) {
    if (currentUrl.startsWith(expectedPrefix)) {
      return true;
    }

    final currentUri = Uri.tryParse(currentUrl);
    final expectedUri = Uri.tryParse(expectedPrefix);

    if (currentUri == null || expectedUri == null) {
      return false;
    }

    final currentPath = currentUri.path.endsWith('/')
        ? currentUri.path.substring(0, currentUri.path.length - 1)
        : currentUri.path;
    final expectedPath = expectedUri.path.endsWith('/')
        ? expectedUri.path.substring(0, expectedUri.path.length - 1)
        : expectedUri.path;

    return currentUri.host == expectedUri.host && currentPath == expectedPath;
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() => isLoading = true);
            _handleFinalResult(url);
          },
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() => isLoading = false);
            _handleFinalResult(url);
          },
          onUrlChange: (change) {
            final url = change.url;
            if (url != null) {
              _handleFinalResult(url);
            }
          },
          onNavigationRequest: (request) {
            _handleFinalResult(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_buildHtmlForm());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _returnAsFailed();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pay with eSewa"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _returnAsFailed,
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
