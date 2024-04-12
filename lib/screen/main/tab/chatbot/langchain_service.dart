import 'package:GADI/screen/main/tab/chatbot/agent_tool.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String apiKey = dotenv.env['CHATGPT_API_KEY']!;
  final ChatOpenAI chat;
  final ConversationBufferWindowMemory memory;
  final ConversationSummaryMemory memory2;
  final ChatOpenAI imgChat;
  late OpenAIFunctionsAgent agent;
  late AgentExecutor executor;
  final date = DateTime.now();

  ApiService()
      : chat = ChatOpenAI(apiKey: apiKey, defaultOptions: ChatOpenAIOptions(model: 'gpt-4')),
        memory = ConversationBufferWindowMemory(returnMessages: true, k: 5),
        memory2 = ConversationSummaryMemory(
            llm: OpenAI(apiKey: apiKey, defaultOptions: OpenAIOptions(maxTokens: 300)),
            returnMessages: true),
        imgChat = ChatOpenAI(
          apiKey: apiKey,
          defaultOptions: const ChatOpenAIOptions(model: "gpt-4-vision-preview"),
        ) {
    agent = OpenAIFunctionsAgent.fromLLMAndTools(
      llm: chat,
      tools: [runQueryTool], // Make sure this tool is correctly defined and included
      memory: memory,
      systemChatMessage: SystemChatMessagePromptTemplate(
        prompt: PromptTemplate(
            inputVariables: {},
            template: "You are an art concierge who knows everything in detail about artworks, GADI. For example, when a user asks you about certain artwork, you can respond with the artist, detailed description, and estimated price. If you run into something that you don't know, check the database. You should reply back in Korean except for foreign name and title. Do not share any URL. Date and time is ${date}."),
      ),
    );

    executor = AgentExecutor(agent: agent, memory: memory);
  }

  Future<String> sendMessageGPT({required String message}) async {
    return await executor.run(message);
  }

  Future<String> sendImageToGPT4Vision({required String? image64}) async {
    String mimeType = 'image/jpeg';

    if (image64 != null) {
      if (image64.startsWith('data:image/png;base64,')) {
        mimeType = 'image/png';
      }}
    final image = ChatMessageContent.image(data: image64!, mimeType: mimeType);
    final prompt = ChatMessageContent.text("이 그림의 제목과 작가를 알려줘.");

    final messages = ChatMessage.human(ChatMessageContentMultiModal(parts: [image, prompt]));

    memory.chatHistory.addHumanChatMessage("첨부한 그림의 제목과 작가를 알려줘.");

    final aiMsg = await imgChat([messages]);
    memory.chatHistory.addAIChatMessage(aiMsg.content);
    return aiMsg.content;
  }
}