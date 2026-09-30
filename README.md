# Moonova 🌙

Moonova is a Flutter-based movie discovery and personal movie library application.

It allows users to discover movies, search for titles, view detailed movie information, and organize movies into personalized lists such as Favorites, Watched, Watching, and Want to Watch.

## ✨ Features

* 🎬 Browse popular and trending movies
* 🔎 Search for movies
* 📖 View detailed movie information
* 👥 View movie cast
* ⭐ View movie ratings
* ❤️ Add movies to Favorites
* 👁️ Mark movies as Watched
* ▶️ Add movies to Watching
* 🔖 Add movies to Want to Watch
* 📚 Manage a personal movie library
* 🔐 Firebase Authentication
* ☁️ Cloud Firestore for user data
* 🎨 Modern and responsive UI
* ✨ Smooth page transitions and animations
* 💀 Loading skeletons
* ⚠️ Error and empty states

## 🛠️ Tech Stack

* **Flutter**
* **Dart**
* **Provider** — State Management
* **Firebase Authentication** — User Authentication
* **Cloud Firestore** — User Movie Library
* **TMDB API** — Movie Data
* **HTTP** — API Requests

## 🏗️ Architecture

Moonova follows a layered architecture based on separation of responsibilities:

```text
Screen
   ↓
Provider
   ↓
Controller
   ↓
Service
   ↓
API / Firebase
```

### Project Structure

```text
lib/
├── controllers/
├── core/
│   ├── constants/
│   ├── routes/
│   ├── theme/
│   └── utils/
├── models/
├── providers/
├── screens/
├── services/
└── widgets/
```

## 🎨 Design

Moonova uses a dark, cinematic visual style with a purple and cyan color palette.

| Color     | Hex       |
| --------- | --------- |
| Primary   | `#994DEC` |
| Secondary | `#06B6D4` |

## 🎥 Movie Data

Movie information is provided by **The Movie Database (TMDB)** API.

Moonova uses TMDB for:

* Movie information
* Popular movies
* Trending movies
* Search results
* Genres
* Cast information
* Movie recommendations

This product uses the TMDB API but is not endorsed or certified by TMDB.

## 🔥 Firebase

Firebase is used for user-related functionality.

### Authentication

Users can:

* Create an account
* Sign in
* Sign out

### Firestore

Each authenticated user can manage their own movie library:

* Favorites
* Watched
* Watching
* Want to Watch

## 🚀 Getting Started

### Prerequisites

Make sure you have:

* Flutter SDK installed
* Dart SDK
* Android Studio or another Flutter-supported IDE
* A Firebase project
* A TMDB API key

### Installation

Clone the repository:

```bash
git clone https://github.com/EslamVx/Moonova.git
```

Navigate to the project:

```bash
cd Moonova
```

Install dependencies:

```bash
flutter pub get
```

Configure Firebase for the project and add the required Firebase configuration files.

Configure the TMDB API key using the project's environment configuration.

Run the application:

```bash
flutter run
```

## 📱 Release APK

The latest release APK is available through the GitHub Releases section.

**Moonova v1.0.0**

[Download the latest APK](https://github.com/EslamVx/Moonova/releases)

## 📸 Screenshots

Add screenshots of the application here.

Recommended screenshots:

* Home
* Search
* Movie Details
* Library
* Profile

## 🧪 Project Status

Moonova is currently at version **1.0.0** and is ready for demonstration and submission.

## 👨‍💻 Author

**Eslam Ahmed**

Computer Science Student
Port Said University

GitHub: [EslamVx](https://github.com/EslamVx)

## 📄 License

This project was created for educational and academic purposes.
