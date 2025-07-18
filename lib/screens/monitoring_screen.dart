import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({Key? key}) : super(key: key);

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> with SingleTickerProviderStateMixin {
  final WebviewController _controller = WebviewController(); 

  bool dangerDetected = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isWebViewInitialized = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();

    initializeWebView();
  }

  Future<void> initializeWebView() async {
    await _controller.initialize();
    await _controller.loadUrl('http://192.168.1.4:8080/video'); 
    setState(() {
      _isWebViewInitialized = true;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void triggerDangerAlert() {
    setState(() {
      dangerDetected = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⚠️ Dangerous movement detected!"),
        backgroundColor: Colors.redAccent,
      ),
    );

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => dangerDetected = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Baby Monitor"),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _isWebViewInitialized
                          ? Webview(_controller)
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  if (dangerDetected)
                    Positioned(
                      top: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Dangerous Movement Detected!",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: triggerDangerAlert,
              icon: const Icon(Icons.warning_amber),
              label: const Text("Trigger Danger Alert"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
