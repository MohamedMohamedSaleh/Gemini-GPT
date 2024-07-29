import 'dart:async';
import 'dart:developer';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../feature/message.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  bool isLoading = false;

  //TODO: this is callGeminiModel
  callGeminiModel() async {
    if (_textController.text.isNotEmpty) {
      try {
        isLoading = true;
        setState(() {});
        final prompt = _textController.text.trim();
        _sendMessage();
        await Future.delayed(const Duration(milliseconds: 400));
        FocusManager.instance.primaryFocus?.unfocus();
        final model = GenerativeModel(
            model: 'gemini-pro', apiKey: dotenv.env['GOOGLE_API_KEY']!);
        final content = [Content.text(prompt)];
        final response = await model.generateContent(content);
        setState(() {
          isLoading = false;
        });
        setState(() {
          _messages.insert(0, Message(text: response.text!, isUser: false));
        });
      } catch (ex) {
        log("message: $ex");
        isLoading = false;
        setState(() {});
      }
    }
  }

  bool _showFab = false;
  @override
  void initState() {
    super.initState();
    listenToScrolll();
  }

//TODO: this is listen to _scrollController
  void listenToScrolll() {
    _scrollController.addListener(() {
      if (_scrollController.offset >= 500) {
        if (!_showFab) {
          setState(() {
            _showFab = true;
          });
        }
      } else {
        if (_showFab) {
          setState(() {
            _showFab = false;
          });
        }
      }
    });
  }

//TODO: this is send data to list and scroll to bottom
  void Function()? _sendMessage() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _messages.insert(0, Message(text: _textController.text, isUser: true));
        _textController.clear();
      });
      scrollToBottom();
    }
    return null;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  final List<Message> _messages = [
    Message(text: "Hi, How can I help you?", isUser: false),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/gemini_icon.png',
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              "Gemini GPT",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const Spacer(),
            InkWell(
              // onTap: () => changeTheme(),
              child: Transform.rotate(
                angle: 200 * 3.14 / 180,
                child: const Icon(
                  Icons.nightlight_round_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView.builder(
          shrinkWrap: true,
          reverse: true,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          controller: _scrollController,
          // dragStartBehavior: DragStartBehavior.down,
          itemBuilder: (context, index) {
            final message = _messages[index];
            return FadeIn(
              duration: const Duration(milliseconds: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    // key: index == 0 ? itemKey : null,
                    title: Align(
                      alignment: message.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                          constraints: BoxConstraints(
                            // maxHeight: 300,
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                  message.isUser ? 16 : 0,
                                ),
                                bottomRight:
                                    Radius.circular(message.isUser ? 0 : 16),
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16)),
                            gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: message.isUser
                                    ? [
                                        Colors.deepPurpleAccent,
                                        Colors.deepPurpleAccent.withOpacity(.8)
                                      ]
                                    : [
                                        Colors.grey.shade300.withOpacity(.7),
                                        Colors.grey.shade400.withOpacity(.7),
                                      ]),
                            color:
                                !message.isUser ? Colors.grey.shade300 : null,
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                                color: message.isUser
                                    ? Colors.white
                                    : Colors.black),
                          )),
                    ),
                  ),
                  isLoading && index == 0
                      ? Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              alignment: Alignment.center,
                              height: 30,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(15),
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                              ),
                              child: const _CustomLoading(),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            );
          },
          itemCount: _messages.length,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.only(
                right: 16.0, left: 16.0, bottom: 16.0, top: 6),
            child: SizedBox(
              width: double.infinity,
              // height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      // offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: TextField(
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(fontSize: 18),
                      contentPadding: const EdgeInsets.all(13.0),
                      hintText: 'Message',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          callGeminiModel();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CircleAvatar(
                            maxRadius: 18,
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(.2),
                            child: Icon(
                              Icons.send,
                              color: Theme.of(context).primaryColor,
                              // size: 29,
                            ),
                          ),
                        ),
                      ),
                    ),
                    minLines: 1,
                    maxLines: 4,
                    controller: _textController,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _showFab
          ? ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: SizedBox(
                height: 40,
                width: 40,
                child: FloatingActionButton(
                  onPressed: () {
                    scrollToBottom();
                  },
                  child: const Icon(Icons.arrow_downward_rounded),
                ),
              ),
            )
          : null,
    );
  }
// TODO: this is scroll to buttom function
  void scrollToBottom() {
    return WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }
}
  //TODO: this is loading widget 
class _CustomLoading extends StatefulWidget {
  const _CustomLoading();

  @override
  State<_CustomLoading> createState() => __CustomLoadingState();
}

class __CustomLoadingState extends State<_CustomLoading> {
  late Timer timer;
  int isIndex = 0;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 150), (timer) async {
      if (isIndex < 3) {
        isIndex++;
      } else {
        await Future.delayed(const Duration(milliseconds: 50));
        isIndex = 0;
      }
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      width: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...List.generate(
            4,
            (index) => CircleAvatar(
              backgroundColor: Colors.grey[700],
              radius: index == isIndex ? 5 : 0,
            ),
          ),
        ],
      ),
    );
  }
}
