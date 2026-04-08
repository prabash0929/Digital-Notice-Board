import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/notice_viewmodel.dart';

class CategoryFilterView extends StatelessWidget {
  const CategoryFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    final noticeViewModel = context.watch<NoticeViewModel>();
    final categories = ['All', 'Academic', 'Events', 'Urgent', 'General'];

    return Container(
      padding: const EdgeInsets.all(16.0),
      // Need a fixed height for bottom sheet ideally
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter by Category',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              final isSelected = noticeViewModel.selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    noticeViewModel.setCategoryFilter(cat);
                    Navigator.pop(context); // Close sheet on selection
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
