import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:todo_app/controller/firbase_controller.dart';
import 'package:todo_app/controller/index_controller.dart';
import 'package:todo_app/model/task.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final TextEditingController _titlecon = TextEditingController();
  final TextEditingController _titleconEdit = TextEditingController();
  final IndexController _indexController = Get.put(IndexController());
  final FirebaseController _firebaseController = Get.put(FirebaseController());

  final addSnackBar = const SnackBar(
    content: Text('Added data'),
    behavior: SnackBarBehavior.floating,
    duration: Duration(milliseconds: 2000),
  );

  final emptySnakbar = const SnackBar(
    content: Text('No text, Type somthing'),
    behavior: SnackBarBehavior.floating,
    duration: Duration(milliseconds: 2000),
  );

  final deleteSnakbar = const SnackBar(
    content: Text('Deleted'),
    behavior: SnackBarBehavior.floating,
    duration: Duration(milliseconds: 2000),
  );

  final updateSnakbar = const SnackBar(
    content: Text('Data updated'),
    behavior: SnackBarBehavior.floating,
    duration: Duration(milliseconds: 2000),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
          child: Column(
            children: [
              const Center(
                child: Text(
                  "TO DO APP",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 4.5 / 6,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: TextField(
                        autofocus: false,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 20),
                            hintText: "Type something here..."),
                        controller: _titlecon,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_titlecon.text != '') {
                        await _firebaseController.addTask(Task(
                            DateTime.now().millisecondsSinceEpoch.toString(),
                            _titlecon.text,
                            false));
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        ScaffoldMessenger.of(context).showSnackBar(addSnackBar);
                        _titlecon.text = '';
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(emptySnakbar);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(50)),
                      child: const Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: Obx(() => ListView.builder(
                    itemCount: _firebaseController.taskList.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height / 10,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Checkbox(
                                  shape: const CircleBorder(),
                                  value: _firebaseController
                                      .taskList[index].iscomplte,
                                  onChanged: (ischaged) async {
                                    await _firebaseController.updateStatus(
                                        _firebaseController.taskList[index].id!,
                                        ischaged ?? false);
                                  },
                                  activeColor: Colors.black,
                                ),
                              ),
                              Obx(() => Expanded(
                                    flex: 5,
                                    child: _indexController.isEditing.value &&
                                            _indexController
                                                    .clickedIndex.value ==
                                                index
                                        ? TextField(
                                            style: TextStyle(color: Colors.red),
                                            controller: _titleconEdit,
                                            autofocus: true,
                                            decoration: const InputDecoration(
                                                hintText: "Edit here",
                                                border: InputBorder.none),
                                          )
                                        : Text(
                                            "${_firebaseController.taskList[index].title}",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                  )),
                              Obx(() => Expanded(
                                    flex: 1,
                                    child: IconButton(
                                        onPressed: () async {
                                          if (_indexController
                                                  .isEditing.value &&
                                              _indexController
                                                      .clickedIndex.value ==
                                                  index) {
                                            _indexController.isEditing.value =
                                                false;
                                            _indexController
                                                .clickedIndex.value = -1;
                                            await _firebaseController
                                                .updateTask(
                                                    _firebaseController
                                                        .taskList[index].id!,
                                                    _titleconEdit.text);
                                            SystemChannels.textInput
                                                .invokeMethod('TextInput.hide');

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(updateSnakbar);
                                          } else {
                                            _indexController.isEditing.value =
                                                true;
                                            _indexController
                                                .clickedIndex.value = index;

                                            _titleconEdit.text =
                                                _firebaseController
                                                        .taskList[index]
                                                        .title ??
                                                    "";
                                          }
                                        },
                                        icon:
                                            _indexController.isEditing.value &&
                                                    _indexController
                                                            .clickedIndex
                                                            .value ==
                                                        index
                                                ? const Icon(Icons.save)
                                                : const Icon(Icons.edit)),
                                  )),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                    onPressed: () async {
                                      await _firebaseController.deleteTask(
                                          _firebaseController
                                              .taskList[index].id!);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(deleteSnakbar);
                                    },
                                    icon: const Icon(Icons.delete)),
                              ),
                            ],
                          ),
                        ),
                      );
                    })),
              )
            ],
          ),
        ),
      ),
    );
  }
}
