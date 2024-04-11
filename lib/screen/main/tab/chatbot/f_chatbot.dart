import 'package:GADI/common/dart/extension/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:GADI/screen/main/tab/chatbot/langchain_service.dart';


class ChatMessage {
  String text; // Base64-encoded image data
  bool isSentByMe;
  bool isImg;
  DateTime timestamp; // Timestamp for the message

  ChatMessage({
    required this.text,
    this.isSentByMe = true,
    this.isImg = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotFragment extends StatefulWidget {
  const ChatbotFragment({super.key});

  @override
  State<ChatbotFragment> createState() => _ChatbotFragmentState();
}

class _ChatbotFragmentState extends State<ChatbotFragment> {
  final List<ChatMessage> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? imgFile;
  final apiService = ApiService();
  bool isBotTyping = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      imgFile = base64Encode(bytes);
      setState(() {
        messages.add(ChatMessage(text: imgFile!, isSentByMe: true, isImg: true));
        isBotTyping = true;
      });
      _scrollToBottom();
      _handleSendImage();
    } else {
      imgFile = null;
    }
  }

  Future<void> _handleSendMessage() async {
    var text = _controller.text;
    if (text.isNotEmpty) {
      setState(() {
        messages.add(ChatMessage(text: text, isSentByMe: true));
        _controller.clear();
        isBotTyping = true;
      });
      _scrollToBottom();

      final response = await apiService.sendMessageGPT(message: text);

      if (response.isNotEmpty) {
        setState(() {
          isBotTyping = false;
          messages.add(ChatMessage(text: response, isSentByMe: false));
        });
        _scrollToBottom();

      }
    }
  }

  Future<void> _handleSendImage() async {
    final String response = await apiService.sendImageToGPT4Vision(image64: imgFile);
    setState(() {
      imgFile = null;
    });
    if (response.isNotEmpty) {
      setState(() {
        messages.add(ChatMessage(text: response, isSentByMe: false));
        isBotTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      final position = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        position, // Adding some extra space for better UX
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset("assets/image/logo/gadi_new.png",
          height: 32,
        ),
        backgroundColor: context.appColors.sub1,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: context.appColors.sub1,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) => Row(
                  mainAxisAlignment: messages[index].isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (messages[index].isSentByMe) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          DateFormat('hh:mm a').format(messages[index].timestamp),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Bubble(
                        radius: const Radius.circular(10),
                        margin: const BubbleEdges.only(top: 12, bottom: 12),
                        alignment: messages[index].isSentByMe ? Alignment.topRight : Alignment.topLeft,
                        color: messages[index].isSentByMe ? Colors.white : context.appColors.seedColor,
                        nip: messages[index].isSentByMe ? BubbleNip.rightTop : BubbleNip.leftTop,
                        nipWidth: 5,
                        nipHeight: 20,
                        child: messages[index].isImg
                            ? Image.memory(
                          base64Decode(messages[index].text),
                          height: 180,
                          fit: BoxFit.fitWidth,
                        )
                            : Container(
                          constraints: const BoxConstraints(maxWidth: 270),
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(messages[index].text,
                              style: TextStyle(
                                fontSize: 20,
                                color: messages[index].isSentByMe ? Colors.black : Colors.white,
                              )),
                        ),
                      ),
                    ),
                    if (!messages[index].isSentByMe) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          DateFormat('hh:mm a').format(messages[index].timestamp),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !isBotTyping, // Disable text field when AI is typing
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(10),
                          hintText: isBotTyping ? '답변 중...' : '메시지',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send_outlined,
                      ),
                      onPressed: isBotTyping ? null : _handleSendMessage, // Disable send button when AI is typing
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 30,
                      ),
                      onPressed: isBotTyping ? null : _pickImage, // Disable image picker when AI is typing
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
