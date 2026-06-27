import 'package:flutter/material.dart';
import 'focus_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                children: [
                  _progressSegment(true),
                  const SizedBox(width: 8),
                  _progressSegment(false),
                  const SizedBox(width: 8),
                  _progressSegment(false),
                ],
              ),
              const Spacer(),
              const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFFE8F5E9),
                child: Text('👋', style: TextStyle(fontSize: 60)),
              ),
              const SizedBox(height: 32),
              const Text(
                "Welcome to Loop",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "Let's start by getting to know you. What should we call you?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Your Name",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.trim().isNotEmpty) {
                       Navigator.push(
                         context, 
                         MaterialPageRoute(
                           builder: (_) => FocusSelectionScreen(name: _nameController.text.trim())
                         )
                       );
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text("Please enter your name"))
                       );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressSegment(bool active) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: active ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
