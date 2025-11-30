// presentation/widgets/exercise_card.dart

import 'package:flutter/material.dart';
import '../../domain/entities/exercise_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseEntity exercise;
  final VoidCallback onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 250),
      tween: Tween(begin: 1, end: 1),
      builder: (context, value, child) {
        return GestureDetector(
          onTap: () {
            onTap();
          },
          child: Transform.scale(
            scale: value,
            child: Container(
              height: 120,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1E),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Row(
                children: [
                  // IMAGE
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                    child: CachedNetworkImage(
                      imageUrl: exercise.imageUrl.isNotEmpty
                          ? exercise.imageUrl
                          : "https://picsum.photos/seed/${exercise.id}/300/300",
                      width: 125,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 40),
                      ),
                    ),
                  ),

                  // RIGHT SIDE
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Title
                          Text(
                            exercise.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// Short description
                          Text(
                            exercise.description,
                            style: TextStyle(color: Colors.white.withOpacity(0.75)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const Spacer(),

                          Row(
                            children: [
                              _difficultyTag(exercise.difficulty),

                              const Spacer(),

                              Row(
                                children: [
                                  const Icon(Icons.timer, size: 18, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${exercise.durationSeconds ~/ 60} min",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Difficulty tag widget
  Widget _difficultyTag(String level) {
    Color color;
    switch (level.toLowerCase()) {
      case "easy":
        color = Colors.greenAccent.shade400;
        break;
      case "medium":
        color = Colors.orangeAccent.shade400;
        break;
      case "hard":
        color = Colors.redAccent.shade400;
        break;
      default:
        color = Colors.blueGrey.shade400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        level.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
