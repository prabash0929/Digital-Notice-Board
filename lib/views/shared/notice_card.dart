import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/notice_model.dart';
import '../notice/notice_details_view.dart';
import '../../core/theme/glass_container.dart';

class NoticeCard extends StatelessWidget {
  final Notice notice;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isAdmin;

  const NoticeCard({
    super.key,
    required this.notice,
    this.onEdit,
    this.onDelete,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatted = DateFormat('MMM d, yyyy').format(notice.createdAt);

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF111827),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => NoticeDetailsView(notice: notice)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/categories/${notice.category.toLowerCase().replaceAll(' ', '')}.png',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: const Color(0xFF1F2937)),
                  ),
                  if (notice.isUrgent)
                    Positioned(
                      top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(8)),
                        child: const Text('URGENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                      ).animate(onPlay: (c)=>c.repeat(reverse:true)).scale(end: const Offset(1.05, 1.05)),
                    )
                  else if (notice.isPinned)
                    Positioned(
                      top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(8)),
                        child: const Text('PINNED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                      ),
                    ),
                  
                  Positioned(
                    top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                      child: Text(notice.category.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                    ),
                  )
                ]
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notice.title,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: Colors.white, height: 1.2),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAdmin)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, size: 20), color: const Color(0xFF9CA3AF), onPressed: onEdit, constraints: const BoxConstraints(), padding: const EdgeInsets.all(4)),
                            IconButton(icon: const Icon(Icons.close, size: 20), color: const Color(0xFFEF4444), onPressed: onDelete, constraints: const BoxConstraints(), padding: const EdgeInsets.all(4)),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notice.summary ?? notice.description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6, color: const Color(0xFFD1D5DB)),
                    maxLines: notice.summary != null ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFF374151), height: 1),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      Text(dateFormatted, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        children: [
                          const Icon(Icons.remove_red_eye_outlined, size: 16, color: Color(0xFF9CA3AF)),
                          Text('${notice.views}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Color(0xFF9CA3AF)),
                          Text('${notice.likes}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          const Icon(Icons.thumb_down_alt_outlined, size: 16, color: Color(0xFF9CA3AF)),
                          Text('${notice.dislikes}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          const Icon(Icons.share_outlined, size: 16, color: Color(0xFF9CA3AF)),
                        ],
                      )
                    ],
                  )
                ]
              )
            )
          ]
        )
      )
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
