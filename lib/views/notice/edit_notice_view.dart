import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/notice_viewmodel.dart';
import '../../data/models/notice_model.dart';
import '../shared/custom_textfield.dart';

class EditNoticeView extends StatefulWidget {
  final Notice notice;
  const EditNoticeView({super.key, required this.notice});

  @override
  State<EditNoticeView> createState() => _EditNoticeViewState();
}

class _EditNoticeViewState extends State<EditNoticeView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtl;
  late TextEditingController _descCtl;
  late String _selectedCategory;
  bool _isLoading = false;

  final categories = ['Academic', 'Events', 'Urgent', 'General'];

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController(text: widget.notice.title);
    _descCtl = TextEditingController(text: widget.notice.description);
    _selectedCategory = categories.contains(widget.notice.category) 
        ? widget.notice.category 
        : 'General';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Edit Smart Notice', style: TextStyle(color: Colors.white)), backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleCtl,
                label: 'Notice Title',
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: const Color(0xFF1F2937),
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: const Color(0xFF1F2937),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF374151))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF374151))),
                  labelStyle: const TextStyle(color: Color(0xFF9CA3AF))
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(color: Colors.white)));
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedCategory = val!);
                },
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _descCtl,
                label: 'Event Details',
                maxLines: 8,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  return null;
                },
              ),
              const SizedBox(height: 48),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                FilledButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);
                      try {
                        final updatedNotice = widget.notice.copyWith(
                          title: _titleCtl.text.trim(),
                          description: _descCtl.text.trim(),
                          category: _selectedCategory,
                        );
                        await context.read<NoticeViewModel>().updateNotice(updatedNotice);
                        if (mounted) Navigator.pop(context);
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    }
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
                )
            ],
          ),
        ),
      ),
    );
  }
}
