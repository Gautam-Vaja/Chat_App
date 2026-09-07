import 'package:chat_app/core/app_images.dart';
import 'package:chat_app/core/app_strings.dart';
import 'package:chat_app/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const HomeScreen({super.key, this.onProfileTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _buildHeading(),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              _buildSearch(),
              const SizedBox(height: 20),
              _buildPinned(),
              const SizedBox(height: 20),
              _buildOther(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeading() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.onProfileTap != null) {
              widget.onProfileTap!();
            } else {
              context.push(AppRoutes.profile);
            }
          },

          child: const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(AppImages.sarah),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          "Messages",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF3525CD),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search, color: Color(0xFF3525CD), size: 24),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.edit_document,
            color: Color(0xFF3525CD),
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search chats',
          hintStyle: TextStyle(color: Color(0xFF6F7585), fontSize: 16),
          prefixIcon: Icon(Icons.search, color: Color(0xFF3F4659), size: 22),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPinned() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.pinned, style: TextStyle(fontWeight: FontWeight.w400)),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            context.push(AppRoutes.user, extra: 'Gemini');
          },
          child: const Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(AppImages.gemini),
              ),
              SizedBox(width: 20),
              Text(
                "Gemini",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOther() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        InkWell(
          onTap: () {},
          child: const Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(AppImages.sarah),
              ),
              SizedBox(width: 20),
              Text(
                "Guest",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
