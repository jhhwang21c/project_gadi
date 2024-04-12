# GADI

Your AI Art Concierge.

## Getting Started

This project is made with flutter.
To run the app, use android studio with android emulator and run "flutter run main.dart" (with the proper files copied and dependencies installed).


## Detail
This is a serverless app that utilizes Google Firebase / Firestore / Authentication. All interaction are real and not hard-coded.
Most of the text data is stored on the Firestore Database, which is a NoSql db.
Large data such as images or videos is stored on Firestore Stroage and passed as an URL to the Firestore Database.

Below is a short description of each tab items. More README files are in each directories.

- Home: user can access "Monthly Best", "Recommendation", etc. through the Home tab.
- Gallery: shows the list of the "starred" or favorite artworks. Users can also see AR rendering of these artworks.
- Gadi (chatbot): an AI chatbot that gives you tailored information on many artworks around the world. Powered by Langchain with GPT-4 and agents.
- Community: YouTube Shorts-like page, where users can scroll to watch streams of videos/images posted by other users.
- Profile: a page where user can check their user profile, followers/followees, and posts.
