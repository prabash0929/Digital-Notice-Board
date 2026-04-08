import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/notice_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../shared/notice_card.dart';
import '../notice/add_notice_view.dart';
import '../notice/edit_notice_view.dart';
import '../filter/category_filter_view.dart';
import '../kiosk/kiosk_view.dart';
import '../shared/background_gradient.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<NoticeViewModel>().setSearchQuery(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final noticeViewModel = context.watch<NoticeViewModel>();
    final themeViewModel = context.watch<ThemeViewModel>();
    final isAdmin = authViewModel.isAdmin;

    final isWideScreen = MediaQuery.of(context).size.width > 800; // Trigger desktop/TV layout

    return BackgroundGradient(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Smart Notice Board'),
          actions: [
          IconButton(
            icon: const Icon(Icons.tv),
            tooltip: 'Launch Kiosk Mode',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const KioskView()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
               showModalBottomSheet(
                 context: context,
                 backgroundColor: Colors.transparent,
                 builder: (_) => const CategoryFilterView(),
               );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authViewModel.logout(),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notices or AI summaries...',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (noticeViewModel.notices.any((n) => n.isUrgent))
            Container(
              width: double.infinity,
              color: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Text('🚨 URGENT NOTICES ACTIVE - PLEASE REVIEW IMMEDIATELY 🚨', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: noticeViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : noticeViewModel.notices.isEmpty
                    ? const Center(child: Text('No active notices.'))
                    : isWideScreen
                        ? GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 450,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: noticeViewModel.notices.length,
                            itemBuilder: (context, index) => _buildNoticeCard(context, noticeViewModel, authViewModel, index),
                          )
                        : ListView.builder(
                            itemCount: noticeViewModel.notices.length,
                            itemBuilder: (context, index) => _buildNoticeCard(context, noticeViewModel, authViewModel, index),
                          ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddNoticeView()),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('New Smart Notice'),
            )
          : null,
      ),
    );
  }

  Widget _buildNoticeCard(BuildContext context, NoticeViewModel vm, AuthViewModel auth, int index) {
    final notice = vm.notices[index];
    final isAdmin = auth.isAdmin;
    
    return NoticeCard(
      key: ValueKey(notice.id),
      notice: notice,
      isAdmin: isAdmin,
      onEdit: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => EditNoticeView(notice: notice)));
      },
      onDelete: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Delete Notice?'),
            content: const Text('Are you sure you want to delete this notice?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await vm.deleteNotice(notice.id);
        }
      },
    );
  }
}
