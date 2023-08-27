import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textEditingController = TextEditingController();
  List<Map<String, String>> messages = [];
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage(String message) async {
    final url = Uri.parse('https://sugoi-api.vercel.app/chat?msg=$message');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final responseMsg = jsonResponse['msg'];
      final responseData = jsonResponse['response'];

      setState(() {
        messages.add({'msg': responseMsg, 'response': responseData});
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } else {
      if (kDebugMode) {
        print('Failed to fetch data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sugoi ChatBot"),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    messages = [];
                  });
                },
                icon: const Icon(
                  Icons.delete,
                  size: 24.0,
                ),
                label: const Text('Clear Chat'),
              ),
            ],
          )
        ],
        backgroundColor: const Color.fromRGBO(23, 33, 44, 1),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Expanded(
            child: Scrollbar(
                child: GestureDetector(
              onVerticalDragUpdate: (details) {
                final scrollAmount = details.primaryDelta! / 2;
                _scrollController
                    .jumpTo(_scrollController.offset - scrollAmount);
              },
              child: ListView.builder(
                primary: false,
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: ListTile(
                          title: Text(
                            messages[index]['msg'] ?? '',
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.right,
                          ),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(100),
                                  bottomLeft: Radius.circular(100))),
                          tileColor: const Color.fromRGBO(43, 81, 120, 1.0),
                          trailing: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: ListTile(
                          title: Text(messages[index]['response'] ?? '',
                              style: const TextStyle(color: Colors.white)),
                          leading: const Icon(
                            Icons.computer,
                            color: Colors.white,
                          ),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(32),
                                  bottomRight: Radius.circular(32))),
                          tileColor: const Color.fromRGBO(24, 37, 52, 1.0),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  );
                },
              ),
            )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 0),
                      ),
                      hintText: 'Enter a message',
                      hintStyle: TextStyle(color: Colors.grey),
                      fillColor: Color.fromRGBO(43, 43, 44, 1.0),
                      filled: true,
                    ),
                    onSubmitted: (message) async {
                      if (message.isNotEmpty) {
                        String msg = message;
                        _textEditingController.clear();
                        await _sendMessage(msg);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      if (_textEditingController.text.isNotEmpty) {
                        String msg = _textEditingController.text;
                        _textEditingController.clear();
                        await _sendMessage(msg);
                      }
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
      backgroundColor: const Color.fromRGBO(14, 22, 34, 1.0),
    );
  }
}
