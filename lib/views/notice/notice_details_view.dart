import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/models/notice_model.dart';
import '../../viewmodels/notice_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../shared/background_gradient.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NoticeDetailsView extends StatefulWidget {
  final Notice notice;

  const NoticeDetailsView({super.key, required this.notice});

  @override
  State<NoticeDetailsView> createState() => _NoticeDetailsViewState();
}

class _NoticeDetailsViewState extends State<NoticeDetailsView> {
  final TextEditingController _commentController = TextEditingController();
  bool _viewCounted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_viewCounted) {
        context.read<NoticeViewModel>().incrementViews(widget.notice.id);
        _viewCounted = true;
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatted = DateFormat('MMMM d, yyyy - h:mm a').format(widget.notice.createdAt);
    final vm = context.watch<NoticeViewModel>();
    final auth = context.watch<AuthViewModel>();
    
    final imagePath = 'assets/images/categories/${widget.notice.category.toLowerCase().replaceAll(' ', '')}.png';
    const textColor = Colors.white;
    const subTextColor = Color(0xFF9CA3AF);
    
    return BackgroundGradient(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notice Details', style: theme.textTheme.titleMedium),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               SizedBox(
                 width: double.infinity, height: 260,
                 child: Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: const Color(0xFF1F2937))),
               ),
               
               Transform.translate(
                 offset: const Offset(0, -30),
                 child: Container(
                   margin: const EdgeInsets.symmetric(horizontal: 20),
                   padding: const EdgeInsets.all(24),
                   decoration: BoxDecoration(
                     color: const Color(0xFF111827),
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: const Color(0xFF374151)),
                     boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 4))],
                   ),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(8)),
                              child: Text(widget.notice.category.toUpperCase(), style: const TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                           ),
                           Row(
                             children: [
                               const Icon(Icons.remove_red_eye_outlined, size: 16, color: subTextColor),
                               const SizedBox(width: 4), Text('${widget.notice.views + 1}', style: const TextStyle(color: subTextColor, fontSize: 12)),
                             ],
                           )
                         ]
                       ),
                       const SizedBox(height: 16),
                       Text(
                         widget.notice.title,
                         style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: widget.notice.isUrgent ? const Color(0xFFF87171) : textColor, height: 1.2),
                       ),
                       const SizedBox(height: 12),
                       Row(
                         children: [
                           const Icon(Icons.access_time_outlined, size: 16, color: subTextColor),
                           const SizedBox(width: 8),
                           Text(dateFormatted, style: const TextStyle(color: subTextColor, fontSize: 12)),
                         ],
                       ),
                       const SizedBox(height: 24),
                       
                       if (widget.notice.summary != null && widget.notice.summary!.isNotEmpty)
                         Container(
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: const Color(0xFF2E1065).withOpacity(0.5),
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: const Color(0xFF4C1D95)),
                           ),
                           child: Row(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const Icon(Icons.auto_awesome, color: Color(0xFFA78BFA), size: 18),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: Text(
                                   'AI Summary: ${widget.notice.summary}',
                                   style: const TextStyle(color: Color(0xFFC4B5FD), height: 1.5),
                                 ),
                               ),
                             ],
                           ),
                         ).animate().fadeIn().slideX(begin: 0.1),
                         
                       const SizedBox(height: 24),
                       Text(widget.notice.description, style: const TextStyle(height: 1.8, color: Color(0xFFD1D5DB), fontSize: 16)),
                     ]
                   )
                 )
               ),
               
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 20),
                 child: Wrap(
                   alignment: WrapAlignment.center,
                   spacing: 12,
                   runSpacing: 12,
                   children: [
                     OutlinedButton.icon(
                       onPressed: () {
                         vm.incrementLikes(widget.notice.id);
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Liked!')));
                       },
                       icon: const Icon(Icons.thumb_up_outlined, size: 18),
                       label: Text('\${widget.notice.likes}', style: const TextStyle(color: Colors.white)),
                       style: OutlinedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                         side: const BorderSide(color: Color(0xFF374151)),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                       )
                     ),
                     OutlinedButton.icon(
                       onPressed: () {
                         vm.incrementDislikes(widget.notice.id);
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disliked.')));
                       },
                       icon: const Icon(Icons.thumb_down_outlined, size: 18, color: Color(0xFF9CA3AF)),
                       label: Text('\${widget.notice.dislikes}', style: const TextStyle(color: Color(0xFF9CA3AF))),
                       style: OutlinedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                         side: const BorderSide(color: Color(0xFF374151)),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                       )
                     ),
                     OutlinedButton(
                       onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link Copied to Clipboard!')));
                       },
                       style: OutlinedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                         side: const BorderSide(color: Color(0xFF374151)),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                       ),
                       child: const Icon(Icons.share_outlined, color: Colors.blueAccent, size: 20)
                     )
                   ],
                 ),
               ),
               const SizedBox(height: 16),
               
               if (widget.notice.summary == null || widget.notice.summary!.isEmpty)
                 Padding(
                   padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                   child: SizedBox(
                     width: double.infinity,
                     child: FilledButton.icon(
                       style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                       icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                       label: const Text('Generate AI Summary', style: TextStyle(color: Colors.white)),
                       onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI is analyzing...')));
                       },
                     ),
                   ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2.seconds, color: Colors.white24),
                 ),
               
               const SizedBox(height: 32),
               const Divider(color: Color(0xFF374151), height: 1),
               
               Padding(
                 padding: const EdgeInsets.all(20),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         const Text('Discussion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                         IconButton(
                           icon: const Icon(Icons.qr_code, color: subTextColor),
                           onPressed: () => showDialog(
                             context: context, 
                             builder: (_) => AlertDialog(
                               backgroundColor: const Color(0xFF1F2937),
                               title: const Text('Scan Notice', style: TextStyle(color: Colors.white)), 
                               content: Container(
                                 padding: const EdgeInsets.all(8),
                                 decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                 child: SizedBox(width: 200, height: 200, child: QrImageView(data: widget.notice.id))
                               ),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                             )
                           )
                         )
                       ],
                     ),
                     const SizedBox(height: 16),
                     StreamBuilder<QuerySnapshot>(
                       stream: vm.getCommentsStream(widget.notice.id),
                       builder: (context, snapshot) {
                         if (!snapshot.hasData) return const CircularProgressIndicator();
                         if (snapshot.data!.docs.isEmpty) return const Text('No comments yet.', style: TextStyle(color: subTextColor));
                         return ListView.separated(
                           shrinkWrap: true,
                           physics: const NeverScrollableScrollPhysics(),
                           itemCount: snapshot.data!.docs.length,
                           separatorBuilder: (c,i) => const SizedBox(height: 12),
                           itemBuilder: (ctx, i) {
                             var doc = snapshot.data!.docs[i];
                             return Container(
                               padding: const EdgeInsets.all(16),
                               decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(12)),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Row(
                                     children: [
                                       const CircleAvatar(radius: 12, backgroundColor: Color(0xFF374151), child: Icon(Icons.person, size: 14, color: Colors.white)),
                                       const SizedBox(width: 8),
                                       const Text('Member', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: textColor)),
                                     ],
                                   ),
                                   const SizedBox(height: 8),
                                   Text(doc['text'] ?? '', style: const TextStyle(color: Color(0xFFD1D5DB), height: 1.5)),
                                 ],
                               ),
                             );
                           },
                         );
                       },
                     ),
                     const SizedBox(height: 24),
                     Row(
                       children: [
                         Expanded(
                           child: TextField(
                             controller: _commentController,
                             style: const TextStyle(color: Colors.white),
                             decoration: InputDecoration(
                               hintText: 'Add a comment...',
                               hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                               filled: true,
                               fillColor: const Color(0xFF1F2937),
                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xFF374151))),
                               enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xFF374151))),
                               contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                             ),
                           ),
                         ),
                         const SizedBox(width: 8),
                         Container(
                           decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle),
                           child: IconButton(
                             icon: const Icon(Icons.send, color: Colors.white, size: 18),
                             onPressed: () async {
                               if (_commentController.text.isNotEmpty) {
                                 await vm.addComment(widget.notice.id, auth.authUser?.uid ?? 'anon', _commentController.text);
                                 _commentController.clear();
                               }
                             },
                           ),
                         )
                       ],
                     ),
                     const SizedBox(height: 64), 
                   ],
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
