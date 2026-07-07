import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Optimized image widget with caching and placeholder
class OptimizedImage extends StatelessWidget {
  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorPlaceholder,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorPlaceholder;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return errorPlaceholder ?? _buildErrorPlaceholder();
        },
        cacheWidth: width != null ? (width! * 2).toInt() : null,
        cacheHeight: height != null ? (height! * 2).toInt() : null,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: borderRadius,
      ),
      child: placeholder ??
          Icon(
            Icons.image_outlined,
            size: 32,
            color: AppColors.onSurfaceVariant.withAlpha(128),
          ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: borderRadius,
      ),
      child: placeholder ??
          Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary.withAlpha(128),
              ),
            ),
          ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: borderRadius,
      ),
      child: errorPlaceholder ??
          Icon(
            Icons.broken_image_outlined,
            size: 32,
            color: AppColors.onSurfaceVariant.withAlpha(128),
          ),
    );
  }
}

/// Avatar image with fallback to initials
class OptimizedAvatar extends StatelessWidget {
  const OptimizedAvatar({
    super.key,
    required this.imageUrl,
    this.name,
    this.size = 48,
    this.showBorder = false,
  });

  final String imageUrl;
  final String? name;
  final double size;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceContainerHigh,
        border: showBorder
            ? Border.all(color: AppColors.surfaceContainerLowest, width: 3)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? OptimizedImage(
                imageUrl: imageUrl,
                width: size,
                height: size,
                placeholder: _buildInitialsAvatar(),
                errorPlaceholder: _buildInitialsAvatar(),
              )
            : _buildInitialsAvatar(),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    final initials = _getInitials(name ?? '');
    return Container(
      width: size,
      height: size,
      color: AppColors.primaryContainer,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

/// Shimmer loading effect for images
class ShimmerImagePlaceholder extends StatefulWidget {
  const ShimmerImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  State<ShimmerImagePlaceholder> createState() => _ShimmerImagePlaceholderState();
}

class _ShimmerImagePlaceholderState extends State<ShimmerImagePlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.surfaceContainerHigh,
                AppColors.surfaceContainer,
                AppColors.surfaceContainerHigh,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}
