import 'package:flutter/material.dart';

class IconPickerDialog extends StatelessWidget {
  const IconPickerDialog({super.key});

  static const List<String> emojis = [
    "✅",
    "💧",
    "📚",
    "💪",
    "🏃",
    "🚶",
    "🚴",
    "💻",
    "🧠",
    "🎯",
    "⭐",
    "❤️",
    "🍎",
    "🥗",
    "☕",
    "💊",
    "😴",
    "🛌",
    "🧘",
    "🙏",
    "🎵",
    "🎸",
    "🎨",
    "📷",
    "✍️",
    "💰",
    "📈",
    "🌱",
    "🧹",
    "🏠",
    "🐶",
    "✈️",
    "🚗",
    "🏊",
    "⚽",
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Choose Icon"),
      content: SizedBox(
        width: 360,
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: emojis.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (_, index) {
            final emoji = emojis[index];

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context, emoji),
              child: SizedBox(
                width: 52,
                height: 52,
                child: Card(
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              ),
            );
          },
        ),
      ),
    );
  }
}