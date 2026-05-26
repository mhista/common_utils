# Universal Video Player Architecture

A robust, decoupled, and engine-agnostic video player system for Flutter. This architecture allows for seamless switching between different underlying video engines (Standard, BetterPlayer, VLC, MediaKit, FVP) without changing your UI code.

## 🚀 Key Features

- **Engine Decoupling**: Switch your entire app's video engine with one line of code.
- **Lazy Initialization**: Specialized engines (like MediaKit) are only initialized if/when they are actually selected.
- **Silent Resiliency**: Initialization of native FFI libraries is wrapped in silent try-catch blocks to prevent app crashes.
- **Visibility Arbitration**: Integrated with `VisibilityDetector` to automatically play/pause videos based on their visibility score (perfect for feed carousels).
- **Redirection Support**: Includes a VLC implementation specifically tuned to handle HTTP redirects that standard players often fail on.
- **Context-Aware Headers**: Support for global and per-video HTTP headers (e.g., Bearer Tokens).

---

## 🏗️ Architecture Overview

The system is built on four main layers:

1.  **Interface (`IVideoPlayerController`)**: Defines common methods (`play`, `pause`, `initialize`, `seekTo`) that every engine must implement.
2.  **Factory (`VideoPlayerFactory`)**: A registry that maps the `VideoPlayerEngine` enum to specific `IVideoPlayerEngineFactory` implementations.
3.  **Cubit (`UniversalVideoCubit`)**: Manages the lifecycle of multiple controllers, handles concurrent initializations, and arbitrates which video should be playing based on visibility.
4.  **UI (`UniversalVideoPlayer`)**: A single widget that renders whichever engine is currently active in `VideoPlayerConfig`.

---

## 🛠️ Supported Engines

| Engine | Package | Best For |
| :--- | :--- | :--- |
| `standard` | `video_player` | Basic playback, web support, stable. |
| `vlc` | `flutter_vlc_player` | **Complex Redirects**, wide codec support, RTSP/Streams. |
| `betterPlayer` | `better_player_plus` | Advanced HLS/Dash support, built-in cache. |
| `mediaKit` | `media_kit` | High-performance libmpv, custom rendering. |
| `fvp` | `fvp` | Modern libmpv backend for standard `video_player`. |

---

## 📖 Usage Guide

### 1. Global Initialization
Initialize the system in your `main.dart`. This registers all available factories.

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  VideoPlayerInitializer.initialize(); // Registers all engines
  runApp(MyApp());
}
```

### 2. Switching the Active Engine
You can switch the engine at any time (e.g., in an App Settings toggle). The new engine will lazily initialize itself on first use.

```dart
// Switch to VLC to handle redirect issues
VideoPlayerConfig.setEngine(VideoPlayerEngine.vlc);
```

### 3. Using the Cubit in a List/Feed
The `UniversalVideoCubit` is designed to handle multiple videos in a scrolling list efficiently.

```dart
// In your BlocProvider
UniversalVideoCubit(
  headers: {'Authorization': 'Bearer $token'},
)

// In your Widget (within a VisibilityDetector)
onVisibilityChanged: (info) {
  context.read<UniversalVideoCubit>().onVideoVisibilityChanged(
    videoId,
    videoUrl,
    info.visibleFraction,
  );
}
```

### 4. Rendering the Player
Always use the `UniversalVideoPlayer` widget. It automatically resolves the active engine from the config.

```dart
BlocBuilder<UniversalVideoCubit, UniversalVideoState>(
  builder: (context, state) {
    final controller = state.controllers[videoId];
    if (controller == null) return Placeholder();

    return UniversalVideoPlayer(
      controller: controller,
      fit: BoxFit.cover,
    );
  },
);
```

---

## 🛠️ Adding a New Engine

1.  Create a new file `my_new_engine.dart` in the `abstraction/` folder.
2.  Implement `IMyCutVideoController` (the controller logic).
3.  Implement `IVideoPlayerEngineFactory` (how to create the controller and widget).
4.  Register it in `VideoPlayerInitializer.initialize()`:
    ```dart
    VideoPlayerFactory.register(VideoPlayerEngine.myNewOne, MyNewEngineFactory());
    ```

---

## ⚠️ Implementation Notes

- **FFI Safety**: MediaKit and FVP require native libraries. If these fail to load, the system catches the error silently. Ensure you have the required platform dependencies in your `pubspec.yaml`.
- **Memory Management**: The `UniversalVideoCubit` handles controller disposal. Always call `onVideoHidden(videoId)` when a widget is removed from the tree to prevent memory leaks.
- **Audio Bleed**: The `arbitrate()` logic in the Cubit ensures that only the "winner" (most visible video) is playing, preventing multiple audio tracks from playing simultaneously in a feed.
