import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini_chatbot/common/globals.dart';
import 'package:flutter_gemini_chatbot/common/widgets/chat_message_widget.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class TextResponseScreen extends StatefulWidget {
  const TextResponseScreen({super.key});

  @override
  State<TextResponseScreen> createState() => _TextResponseScreenState();
}

class _TextResponseScreenState extends State<TextResponseScreen> {
  final String _apiKey = const String.fromEnvironment('API_KEY');
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<({Image? image, String? text, bool fromUser})> _generatedContent =
      <({Image? image, String? text, bool fromUser})>[];
  bool _loading = false;
  final List<SafetySetting> _safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
  ];

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: Globals.geminiProModel,
      apiKey: _apiKey,
      safetySettings: _safetySettings,
    );
    _visionModel = GenerativeModel(
        model: Globals.geminiProVisionModel,
        apiKey: _apiKey,
        safetySettings: _safetySettings);
    _chat = _model.startChat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(const AssetImage('assets/images/genie_2.png'), context);
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
        title: const Text("Chat with Gemini"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (_generatedContent.isNotEmpty)
                ? Expanded(
                    child: _apiKey.isNotEmpty
                        ? ListView.builder(
                            controller: _scrollController,
                            itemBuilder: (context, idx) {
                              final content = _generatedContent[idx];
                              return ChatMessageWidget(
                                text: content.text,
                                image: content.image,
                                isFromUser: content.fromUser,
                              );
                            },
                            itemCount: _generatedContent.length,
                          )
                        : ListView(
                            children: const [
                              Text(
                                'No API key found. Please provide an API Key using '
                                "'--dart-define' to set the 'API_KEY' declaration.",
                              ),
                            ],
                          ),
                  )
                : Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Image.asset("assets/images/genie_2.png")),
                          const Text(
                            "Feels so lonely here, \nStart with a wish",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0),
                          )
                        ],
                      ),
                    ),
                  ),
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
                      onSubmitted: _sendChatMessage,
                    ),
                  ),
                  const SizedBox.square(dimension: 15),
                  IconButton(
                    onPressed: !_loading
                        ? () async {
                            _sendImagePrompt(_textController.text);
                          }
                        : null,
                    icon: Icon(
                      Icons.image,
                      color: _loading
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (!_loading)
                    IconButton(
                      onPressed: () async {
                        _sendChatMessage(_textController.text);
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

  Future<void> _sendImagePrompt(String message) async {
    setState(() {
      _loading = true;
    });
    try {
      _textFieldFocus.unfocus();
      _textController.clear();

      if (message.isNotEmpty) {
        _generatedContent.add((image: null, text: message, fromUser: true));
      }

      List<Part> promptContent = [TextPart(message)];
      final ImagePicker picker = ImagePicker();
      //final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      final List<XFile> pickedImages = await picker.pickMultiImage();
      if (pickedImages.isEmpty) return;

      for (XFile image in pickedImages) {
        _generatedContent.add(
            (image: Image.file(File(image.path)), text: null, fromUser: true));
        final bytes = await image.readAsBytes();
        ByteData imageBytes = ByteData.view(bytes.buffer);
        promptContent
            .add(DataPart('image/jpeg', imageBytes.buffer.asUint8List()));
      }

      setState(() {});

      _scrollDown();

      final response =
          await _visionModel.generateContent([Content.multi(promptContent)]);
      final text = response.text;
      _generatedContent.add((image: null, text: text, fromUser: false));

      if (text == null) {
        _showError('No response from API.');
        return;
      } else {
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      //_textFieldFocus.requestFocus();
    }
  }

  Future<void> _sendChatMessage(String message) async {
    if (_textController.text.trim().isEmpty) return;

    _textFieldFocus.unfocus();
    _textController.clear();
    _scrollDown();

    setState(() {
      _loading = true;
    });

    try {
      _generatedContent.add((image: null, text: message, fromUser: true));
      final response = await _chat.sendMessage(
        Content.text(message),
      );
      final text = response.text;
      _generatedContent.add((image: null, text: text, fromUser: false));

      if (text == null) {
        _showError('No response from API.');
        return;
      } else {
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      //_textFieldFocus.requestFocus();
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
}
