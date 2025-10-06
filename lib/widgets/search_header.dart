import 'package:flutter/material.dart';
import 'app_theme.dart';

class SearchHeader extends StatefulWidget {
  final String title;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onFilterPressed;
  final bool hasActiveFilter;

  const SearchHeader({
    super.key,
    required this.title,
    required this.searchController,
    required this.onSearchChanged,
    this.onFilterPressed,
    this.hasActiveFilter = false,
  });

  @override
  State<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  bool _isSearchActive = false;

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        widget.searchController.clear();
        widget.onSearchChanged('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.light,
      ),
      child: Row(
        children: [
          // Title or Search Field
          Expanded(
            child: _isSearchActive
                ? TextField(
                    controller: widget.searchController,
                    onChanged: widget.onSearchChanged,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Cari ${widget.title.toLowerCase()}...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(color: AppColors.grey200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(color: AppColors.grey200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      suffixIcon: IconButton(
                        onPressed: _toggleSearch,
                        icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  )
                : Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
          ),
          
          // Action Buttons
          if (!_isSearchActive) ...[
            const SizedBox(width: AppSpacing.md),
            // Search Icon
            Container(
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: IconButton(
                onPressed: _toggleSearch,
                icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                tooltip: 'Cari',
              ),
            ),
            
            // Filter Icon (if callback provided)
            if (widget.onFilterPressed != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: widget.hasActiveFilter 
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.grey100,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: IconButton(
                  onPressed: widget.onFilterPressed,
                  icon: Icon(
                    Icons.tune,
                    color: widget.hasActiveFilter 
                        ? AppColors.primary 
                        : AppColors.onSurfaceVariant,
                  ),
                  tooltip: 'Filter',
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
