import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:echo_note/Pages/note_page/note_controller.dart';
import 'package:echo_note/Pages/note_page/add_button.dart';

class NotePage extends StatelessWidget {
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    final NoteController ctl = Get.put(NoteController());
    return Scaffold(
      appBar: AppBar(title: Text("Notes"), titleSpacing: 64.0, actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            debugPrint("Search Note");
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            debugPrint("Settings");
          },
        ),
      ],),
      body: Obx(() {
        return ListView(
          controller: ctl.scrollController,
          scrollDirection: Axis.vertical,
          children: ctl.showList,
        );
      }),
      floatingActionButton: AddNoteButton()
    );
  }
}
