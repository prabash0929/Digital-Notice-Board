import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../viewmodels/notice_viewmodel.dart';
import '../../core/theme/glass_container.dart';

class KioskView extends StatefulWidget {
  const KioskView({super.key});

  @override
  State<KioskView> createState() => _KioskViewState();
}

class _KioskViewState extends State<KioskView> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _timer = Timer.periodic(const Duration(seconds: 12), (Timer timer) {
      if (!mounted) return;
      final vm = context.read<NoticeViewModel>();
      if (vm.notices.isEmpty) return;

      setState(() {
        _currentPage = (_currentPage + 1) % vm.notices.length;
      });

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NoticeViewModel>();
    final theme = Theme.of(context);

    if (vm.isLoading) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }
    if (vm.notices.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('No Active Notices', style: theme.textTheme.displayMedium?.copyWith(color: const Color(0xFF6B7280))),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), 
            itemCount: vm.notices.length,
            itemBuilder: (context, index) {
              final notice = vm.notices[index];
              final dateFormatted = DateFormat('MMM d, yyyy').format(notice.createdAt);

              return Container(
                color: Colors.black,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    padding: const EdgeInsets.all(64),
                    child: Container( // Instead of GlassContainer
                      padding: const EdgeInsets.all(64),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: notice.isUrgent ? const Color(0xFFEF4444) : const Color(0xFF374151), width: notice.isUrgent ? 2 : 1),
                        boxShadow: [BoxShadow(color: notice.isUrgent ? Colors.redAccent.withOpacity(0.2) : Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 10))]
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (notice.isUrgent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(30)),
                                    child: const Text('URGENT', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 1.seconds, end: const Offset(1.1, 1.1)),
                                const SizedBox(height: 24),
                                Text(
                                  notice.title,
                                  style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white, height: 1.2, letterSpacing: -1),
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  notice.summary ?? notice.description,
                                  style: theme.textTheme.headlineMedium?.copyWith(color: const Color(0xFF9CA3AF), height: 1.5),
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, color: Color(0xFF6B7280), size: 28),
                                    const SizedBox(width: 12),
                                    Text(dateFormatted, style: theme.textTheme.headlineSmall?.copyWith(color: const Color(0xFF6B7280))),
                                    const SizedBox(width: 48),
                                    Chip(
                                      label: Text(notice.category.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
                                      backgroundColor: notice.isUrgent ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      side: BorderSide.none,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 64),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40)]),
                                  child: QrImageView(
                                    data: notice.id,
                                    version: QrVersions.auto,
                                    size: 300.0,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text('Scan to view details', style: theme.textTheme.titleLarge?.copyWith(color: const Color(0xFF9CA3AF))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 800.ms).slideX(begin: 0.05, end: 0);
            },
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TweenAnimationBuilder<double>(
              key: ValueKey(_currentPage),
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 12),
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.transparent,
                  color: const Color(0xFF3B82F6).withOpacity(0.5),
                  minHeight: 6,
                );
              },
            ),
          ),

          Positioned(
            top: 24,
            right: 24,
            child: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF6B7280), size: 40),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
