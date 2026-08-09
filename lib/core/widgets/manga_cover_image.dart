import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/manga.dart';
import '../sources/source_registry.dart' show sourceImageHeaders;

/// Renders a manga cover with skeleton shimmer and graceful error fallback.
class MangaCoverImage extends StatelessWidget {
  const MangaCoverImage({
    super.key,
    required this.manga,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  final Manga manga;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = manga.coverUrl;
    final placeholder = Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.menu_book, size: 28)),
    );
    Widget image = url == null
        ? placeholder
        : CachedNetworkImage(
            imageUrl: url,
            httpHeaders: sourceImageHeaders(url),
            fit: fit,
            width: width,
            height: height,
            placeholder: (_, __) => _ShimmerBox(color: Theme.of(context).colorScheme.surfaceContainerHighest),
            errorWidget: (_, __, ___) => placeholder,
          );
    return Semantics(
      label: '${manga.title} cover',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(width: width, height: height, child: image),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(color: color);
  }
}
