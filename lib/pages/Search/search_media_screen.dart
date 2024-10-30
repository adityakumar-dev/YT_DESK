import 'package:flutter/material.dart';

class SearchMediaScreen extends StatefulWidget {
  const SearchMediaScreen({super.key});

  @override
  State<SearchMediaScreen> createState() => _SearchMediaScreenState();
}

class _SearchMediaScreenState extends State<SearchMediaScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return getWidget(context, size);
  }

  Scaffold getWidget(BuildContext context, Size size) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(size.width, 70),
        child: Container(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              )
            ],
          ),
        ),
      ),
    );
  }
}
