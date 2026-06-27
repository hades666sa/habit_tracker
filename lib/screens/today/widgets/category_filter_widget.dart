import 'package:flutter/material.dart';

class CategoryFilterWidget extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final List<Map<String, dynamic>> categories;

  const CategoryFilterWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final catName = cat['name'] as String;
          final catIcon = cat['icon'] as IconData;
          final isSelected = selectedCategory == catName;
          
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onCategorySelected(catName),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check : catIcon, 
                      color: isSelected ? Colors.white : (isDark ? Colors.grey : Colors.black45), 
                      size: 16
                    ),
                    const SizedBox(width: 8),
                    Text(
                      catName, 
                      style: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? Colors.grey : Colors.black87), 
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                      )
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
