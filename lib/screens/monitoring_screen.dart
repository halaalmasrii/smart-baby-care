import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Monitor App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MonitoringScreen(),
    );
  }
}

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({Key? key}) : super(key: key);

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> with SingleTickerProviderStateMixin {
  final WebviewController _controller = WebviewController(); 
  bool dangerDetected = false;
  bool _isCameraActive = false; // إضافة حالة جديدة للكاميرا
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
  }

  Future<void> toggleCamera() async {
  try {
    // التحقق من التهيئة أولًا
    if (!_isWebViewInitialized) {
      await _controller.initialize();
      setState(() => _isWebViewInitialized = true);
    }

    // بعد التهيئة، شغل أو أوقف الكاميرا
    if (_isCameraActive) {
      await _controller.loadUrl('about:blank');
    } else {
      await _controller.loadUrl('http://172.20.10.4:8080/video');
    }

    setState(() {
      _isCameraActive = !_isCameraActive;
    });

  } catch (e) {
    print("Error toggling camera: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to load camera: $e")),
    );
  }
}


  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void triggerDangerAlert() {
    setState(() => dangerDetected = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isCameraActive ? 
          " Camera is active! Monitoring..." : 
          " Camera is not active!"),
        backgroundColor: _isCameraActive ? Colors.green : Colors.red,
      ),
    );

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => dangerDetected = false);
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
                          color: _isCameraActive ? Colors.green : Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _isCameraActive ? 
                            "Camera is Active" : 
                            "Camera is NOT Active",
                          style: const TextStyle(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await toggleCamera();
                    triggerDangerAlert();
                  },
                  icon: Icon(_isCameraActive ? 
                    Icons.videocam_off : 
                    Icons.videocam),
                  label: Text(_isCameraActive ? 
                    "Stop Camera" : 
                    "Start Camera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCameraActive ? Colors.red : Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: triggerDangerAlert,
                  icon: const Icon(Icons.warning_amber),
                  label: const Text("Check Status"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}