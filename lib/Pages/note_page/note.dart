import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteRect extends StatelessWidget {
  static const double _noteWidth = 90; // 笔记宽度
  static const double _noteHeight = 127.26; // 笔记高度
  static const double _radius = 8; // 圆角半径

  final RxString noteName; // 笔记名称，使用 RxString 来实现动态更新
  final String notePicPath; // 笔记封面图片路径
  final VoidCallback onDelete; // 删除回调函数：用于删除当前笔记
  final Key noteKey; // 用于区分每个笔记的唯一 Key

  NoteRect({
    super.key,  // 传递给父类
    required this.noteName,
    required this.notePicPath,
    required this.onDelete, // 接收删除回调函数
    required this.noteKey,  // 修改为 noteKey 以避免与父类 key 冲突
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: noteKey, // Key放在最外层Container上
      child: SizedBox(
        width: _noteWidth,
        height: _noteHeight + 80,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _noteWidth,
                height: _noteHeight,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 115, 221, 235),
                  borderRadius: BorderRadius.circular(_radius),
                ),
                child: Image.asset(notePicPath, fit: BoxFit.cover),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        Obx(() => Text(
                          noteName.value, // 使用 .value 来访问 RxString 的值
                          style: TextStyle(color: Colors.blue, fontSize: 14),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                      ],
                    ),
                  ),
                  SizedBox(width: 5),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "rename") {
                        _showRenameDialog(context); // 弹出重命名对话框
                      } else if (value == "delete") {
                        _showDeleteConfirmationDialog(context); // 弹出删除确认框
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: "rename",
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text("重命名"),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: "delete",
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16),
                              SizedBox(width: 8),
                              Text("删除"),
                            ],
                          ),
                        ),
                      ];
                    },
                    icon: Icon(
                      Icons.more_vert,
                      color: const Color.fromARGB(255, 201, 184, 23),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 弹出重命名对话框
  void _showRenameDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController(text: noteName.value);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("重命名笔记"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "输入新名称"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("取消"),
            ),
            TextButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  noteName.value = _controller.text;
                }
                Navigator.of(context).pop();
              },
              child: Text("确定"),
            ),
          ],
        );
      },
    );
  }

  // 弹出删除确认框
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("确认删除"),
          content: Text("您确定要删除这个笔记吗？"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("取消"),
            ),
            TextButton(
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
              child: Text("删除"),
            ),
          ],
        );
      },
    );
  }
}