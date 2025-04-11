import 'package:flutter/material.dart';

// 用于打开添加笔记菜单的按键
class AddNoteButton extends StatelessWidget {
  AddNoteButton({super.key});
  static const double _buttonSize = 64;

  final List<PopupMenuItem<String>> _options = [
    const PopupMenuItem<String>(
      value: 'normal',
      child: Row(
        children: [Icon(Icons.note_add), SizedBox(width: 10), Text('普通笔记')],
      ),
    ),

    const PopupMenuItem<String>(
      value: 'borderless',
      child: Row(
        children: [
          Icon(Icons.all_inclusive_outlined),
          SizedBox(width: 10),
          Text('无界笔记'),
        ],
      ),
    ),

    const PopupMenuItem<String>(
      value: 'pdf',
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf_rounded),
          SizedBox(width: 10),
          Text('PDF笔记'),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(_buttonSize / 2),
      child: SizedBox(
        width: _buttonSize,
        height: _buttonSize,

        child: InkWell(
          onTapDown: (tapDownDetails) {},
          borderRadius: BorderRadius.circular(_buttonSize / 2),
          child: PopupMenuButton(
            itemBuilder: (context) => _options,
            offset: const Offset(-1 * _buttonSize, -3 * _buttonSize),
            borderRadius: BorderRadius.circular(_buttonSize / 2),
            color: Theme.of(context).colorScheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            elevation: 0,
            onSelected: _onSelected,
            child: Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }

  void _onSelected(String e) {
    final Map<String, Function()> optionsMap = {
      "normal": () => _normal(),
      "borderless": () => _borderless(),
      "pdf": () => _pdf(),
    };

    optionsMap[e]?.call();
  }

  // TODO: 添加对应的笔记类型
  void _normal() {
    debugPrint("Normal Note");
  }

  void _borderless() {
    debugPrint("Borderless Note");
  }

  void _pdf() {
    debugPrint("PDF Note");
  }
}
