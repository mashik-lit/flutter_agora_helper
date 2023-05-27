import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../gen/assets.gen.dart';

class NoVideoView extends StatelessWidget {
  const NoVideoView({
    super.key,
    required this.avatarUrl,
    required this.bgColor,
  });

  final String avatarUrl;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              CachedNetworkImage(
                imageUrl: avatarUrl,
                imageBuilder: (context, imageProvider) => Container(
                  height: MediaQuery.of(context).size.width * 0.25 + 84,
                  width: MediaQuery.of(context).size.width * 0.25 + 84,
                  padding: const EdgeInsets.all(42.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.contain,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                errorWidget: (context, url, error) => _placeholder(
                  MediaQuery.of(context).size.width * 0.25,
                ),
                progressIndicatorBuilder: (context, url, progress) =>
                    _placeholder(
                  MediaQuery.of(context).size.width * 0.25,
                ),
              ),
              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(double width) => Container(
        padding: const EdgeInsets.all(42.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Assets.icons.profileLight2.svg(
            width: width,
            fit: BoxFit.contain,
            color: Colors.black.withOpacity(0.5)),
      );
}
