## chatbot details

f_chatbot.dart is the rendering fragment for the GADI chat bot;
Its logic depends on langchain_service.dart which utilizes agent tool in the agent_tool.dart file.
The agent uses noSQL query tool that I built, which query data on the Firestore database.
Upon fetching the relevant data, ChatGPT-4 uses the data to formulate an answer.
The conversation is stored on the conversation buffer window memory with k=5.