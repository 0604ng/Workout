import 'dart:async';
import 'package:flutter/material.dart';
import '../../injection_container.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/exercise_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseId;
  final String categoryId;

  const ExerciseDetailScreen(
      {
        super.key,
        required this.exerciseId,
        required this.categoryId,
      });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late final ExerciseRepository repo;
  ExerciseEntity? exercise;
  bool loading = true;

  Timer? timer;
  int elapsedSeconds = 0;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    repo = sl<ExerciseRepository>();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await repo.fetchExerciseByCategoryAndId(
        widget.categoryId,
        widget.exerciseId,
      );

      if (!mounted) return;

      setState(() {
        exercise = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        exercise = null;
        loading = false;
      });
    }
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => elapsedSeconds++);
    });
    setState(() => isRunning = true);
  }

  void _pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void _resetTimer() {
    timer?.cancel();
    setState(() {
      elapsedSeconds = 0;
      isRunning = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111115),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : exercise == null
            ? const Center(
          child: Text(
            "Exercise not found",
            style: TextStyle(color: Colors.white),
          ),
        )
            : _buildDetail(),
      ),
    );
  }

  Widget _buildDetail() {
    final ex = exercise!;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: Colors.black,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(ex.title),
            background: ex.imageUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: ex.imageUrl,
              fit: BoxFit.cover,
              errorWidget: (context, _, __) =>
                  Container(color: Colors.grey[800], child: const Icon(Icons.error)),
            )
                : Container(
              color: Colors.grey[800],
              child: const Icon(Icons.image_not_supported,
                  size: 80, color: Colors.white70),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ex.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),

                _buildStats(ex),
                const SizedBox(height: 30),

                _stopwatchSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(ExerciseEntity ex) {
    return Row(
      children: [
        Expanded(child: _statTile(Icons.timer, "${ex.durationSeconds}s", "Duration")),
        const SizedBox(width: 10),
        Expanded(child: _statTile(Icons.local_fire_department, "${ex.calories}", "Calories")),
        const SizedBox(width: 10),
        Expanded(child: _statTile(Icons.category, ex.category, "Category")),
      ],
    );
  }

  Widget _statTile(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _stopwatchSection() {
    final mm = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final ss = (elapsedSeconds % 60).toString().padLeft(2, '0');

    return Column(
      children: [
        const Text(
          "Workout Timer",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 16),

        Text(
          "$mm : $ss",
          style: const TextStyle(
              fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _timerButton(
              isRunning ? Icons.pause : Icons.play_arrow,
              isRunning ? _pauseTimer : _startTimer,
            ),
            const SizedBox(width: 14),
            _timerButton(Icons.stop, _resetTimer),
          ],
        )
      ],
    );
  }

  Widget _timerButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color.fromRGBO(98, 0, 238, 0.25), // Fixed: using RGBO instead of withOpacity
          border: Border.all(color: Colors.deepPurple, width: 1.4),
        ),
        child: Icon(icon, color: Colors.white, size: 35),
      ),
    );
  }
}