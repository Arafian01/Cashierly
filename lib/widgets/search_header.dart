import 'dart:async';
import 'package:flutter/material.dart';
import 'app_theme.dart';

class SearchHeader extends StatefulWidget {
  final String title;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onCartPressed;
  final bool hasActiveFilter;
  final int? cartItemCount;

  const SearchHeader({
    super.key,
    required this.title,
    required this.searchController,
    required this.onSearchChanged,
    this.onFilterPressed,
    this.onCartPressed,
    this.hasActiveFilter = false,
    this.cartItemCount,
  });

  @override
  State<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  bool _isSearchActive = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        widget.searchController.clear();
        widget.onSearchChanged('');
      }
    });
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onSearchChanged(value);
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
                    onChanged: _onSearchChanged,
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
            
            // Cart Icon (if callback provided)
            if (widget.onCartPressed != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: IconButton(
                      onPressed: widget.onCartPressed,
                      icon: const Icon(Icons.shopping_cart, color: AppColors.onSurfaceVariant),
                      tooltip: 'Keranjang',
                    ),
                  ),
                  if (widget.cartItemCount != null && widget.cartItemCount! > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${widget.cartItemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
