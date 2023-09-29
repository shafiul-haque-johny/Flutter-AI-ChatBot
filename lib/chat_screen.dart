import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'chat_message.dart';
import 'gradient_text.dart';
import 'three_dots.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  final List<ChatMessage> messages = [];

  late OpenAI? chatGpt;
  bool isImageSearch = false;
  bool isTyping = false;

  @override
  void initState() {
    chatGpt = OpenAI.instance.build(
      token: dotenv.env['API_KEY'],
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 60000),
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    //chatGpt?.close();
    super.dispose();
  }

  void sendMessage() async {
    if (controller.text.isEmpty) return;
    ChatMessage message = ChatMessage(
      text: controller.text,
      sender: 'User',
      isImage: false,
    );
    setState(() {
      messages.insert(0, message);
      isTyping = true;
    });

    controller.clear();

    if (isImageSearch) {
      final request = GenerateImage(
        message.text,
        1,
        size: ImageSize.size256,
        responseFormat: Format.url,
      );

      final response = await chatGpt!.generateImage(request);
      Vx.log("img url :${response!.data?.last?.url}");
      insertNewData(response.data!.last!.url!, isImage: true);
    } else {
      final request =
          CompleteText(prompt: message.text, model: TextDavinci3Model());
      final response = await chatGpt!.onCompletion(request: request);
      Vx.log(response!.choices[0].text);
      insertNewData(response.choices[0].text, isImage: false);
    }
  }

  void insertNewData(String response, {bool isImage = false}) {
    ChatMessage botMessage = ChatMessage(
      text: response,
      sender: "Bot",
      isImage: isImage,
    );

    setState(() {
      isTyping = false;
      messages.insert(0, botMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GradientText(
          'JOHNY\'S AI CHATBOT',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade900,
              Colors.purple.shade300,
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff36e8da),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                reverse: true,
                padding: Vx.m8,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return messages[index];
                },
              ),
            ),
            //if (isTyping) const Text('typing...'),
            if (isTyping) const ThreeDots(),
            const Divider(
              height: 1.0,
            ),
            Container(
              decoration: BoxDecoration(
                color: context.cardColor,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: controller,
                        onSubmitted: (value) => sendMessage(),
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Send a Message',
                        ),
                      ),
                    ),
                  ),
                  ButtonBar(
                    children: [
                      IconButton(
                        onPressed: () {
                          isImageSearch = false;
                          sendMessage();
                        },
                        icon: const Icon(
                          Icons.send,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          isImageSearch = true;
                          sendMessage();
                        },
                        child: const Text(
                          "Generate Image",
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
