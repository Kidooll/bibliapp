import 'package:flutter/material.dart';

class ProgressCardWidget extends StatelessWidget {
  const ProgressCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF5E9EA0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bom trabalho!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 250,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Text(
                '0/2 missões completas hoje!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }
} 