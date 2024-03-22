import 'package:flutter/material.dart';
import 'package:flutter_gemini_chatbot/common/globals.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class StreamResponseScreen extends StatefulWidget {
  const StreamResponseScreen({super.key});

  @override
  State<StreamResponseScreen> createState() => _StreamResponseScreenState();
}

class _StreamResponseScreenState extends State<StreamResponseScreen> {
  final String _apiKey = const String.fromEnvironment('API_KEY');
  late GenerativeModel _model;
  String _generatedText = '';
  String? _prompt;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: Globals.geminiProModel,
      apiKey: _apiKey,
    );

    _model.startChat();
  }

  // Function to generate text with streaming
  Future<void> generateTextStream(String prompt) async {
    if (prompt.isEmpty) return;
    _textFieldFocus.unfocus();
    _textController.clear();
    setState(() {
      _prompt = prompt;
      _generatedText = '';
      _loading = true;
    });

    final response = _model.generateContentStream([Content.text(_prompt!)]);
    response.listen((chunk) {
      if (chunk.text == null) return;
      setState(() {
        _generatedText += chunk.text!.replaceAll(RegExp(r'\*\*'), "");
      });
      _scrollDown();
    });

    setState(() {
      _loading = false;
    });
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textFieldDecoration = InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Your prompt here..',
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Gemini Search"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              shrinkWrap: false,
              children: [
                (_prompt != null)
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              10.0), // Adjust the radius as needed
                          color: Colors.yellow,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(bottom: 12.0),
                        alignment: Alignment.center,
                        child: Text(
                          "Prompt: $_prompt",
                          style: const TextStyle(
                              fontSize: 17.0, color: Colors.black),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Image.asset("assets/images/genie_1.png")),
                          const Text(
                            "Start your search with a prompt",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22.0),
                          )
                        ],
                      ),
                Text(
                  _generatedText,
                  style: const TextStyle(fontSize: 17.0),
                ),
              ],
            )),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 25,
                horizontal: 15,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      focusNode: _textFieldFocus,
                      decoration: textFieldDecoration,
                      controller: _textController,
                      onSubmitted: generateTextStream,
                    ),
                  ),
                  const SizedBox.square(dimension: 15),
                  if (!_loading)
                    IconButton(
                      onPressed: () async {
                        generateTextStream(_textController.text);
                      },
                      icon: Icon(
                        Icons.rocket_launch,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  else
                    const CircularProgressIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
