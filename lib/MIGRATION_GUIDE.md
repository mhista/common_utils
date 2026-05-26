# Universal Video Player: Package Migration Guide

This guide outlines how to extract the current video architecture from `mycut` and move it into a dedicated, reusable Flutter package (e.g., `universal_video_player`).

## 📦 Package Structure

Your new package should follow this structure to remain clean and engine-agnostic:

```text
universal_video_player/
├── lib/
│   ├── src/
│   │   ├── abstraction/          # Interfaces & Config
│   │   ├── engines/              # Concrete Factories (VLC, FVP, etc.)
│   │   ├── cubit/                # UniversalVideoCubit & State
│   │   └── ui/                   # UniversalVideoPlayer & FullscreenVideoPlayer
│   └── universal_video_player.dart # Public Barrel File
├── pubspec.yaml
└── README.md
```

---

## 🚀 Migration Steps

### 1. Extract the Core (Abstraction)
Move all files from `lib/shared/widgets/media/abstraction/` to your new package. 
*   **Recommendation**: Keep the `IVideoPlayerController` and `IVideoPlayerEngineFactory` interfaces in a `src/abstraction` folder.
*   **Internalize Factories**: Move the 5 concrete factories (Standard, VLC, MediaKit, BetterPlayer, FVP) into `src/engines`.

### 2. Move the UI (Including Fullscreen)
**Yes**, you can and should ship the `FullscreenVideoPlayer` with the package. 
*   Move `fullscreen_video_player.dart` and `universal_video_player.dart` (the widget) to `src/ui`.
*   **Dependency Note**: Ensure the UI only depends on `IMyCutVideoController`. This allows the UI to remain identical even if you add a new 6th engine later.

### 3. Transition the Cubit
Move `universal_video_cubit.dart` to `src/cubit`.
*   **Important**: Since the Cubit uses `freezed`, you will need to add `freezed_annotation` to your new package's `dependencies` and `build_runner`/`freezed` to `dev_dependencies`.
*   Run `dart run build_runner build` in the new package directory.

### 4. Handling Dependencies
Your new package's `pubspec.yaml` will need to include all the media plugins:
```yaml
dependencies:
  flutter: { sdk: flutter }
  flutter_bloc: ^9.0.0
  video_player: ^2.0.0
  flutter_vlc_player: ^7.0.0
  media_kit: ^1.0.0
  media_kit_video: ^2.0.0
  media_kit_libs_video: ^1.0.0
  fvp: ^0.37.0
  better_player_plus:
    path: ../path_to_better_player # or git/pub reference
```

---

## 🧐 What about `better_player_plus`?

**Is it still relevant?**
*   **Yes**, but with a caveat. You currently have it as a local package path in `mycut/packages/better_player_plus`.
*   **The Fix**: When you move to the new package, you have two choices:
    1.  **Monorepo**: Keep `better_player_plus` in a `packages/` folder alongside your new `universal_video_player` and use a relative path.
    2.  **Git Reference**: If `better_player_plus` is stable on GitHub, reference it via Git in the new package's `pubspec.yaml`. This is cleaner for distribution.

---

## 🛠️ Implementation Checklist

1.  **Namespace Cleanup**: Rename `IMyCutVideoController` to something generic like `IUniversalVideoController`.
2.  **Barrel File**: Export only what the user needs in `lib/universal_video_player.dart`:
    ```dart
    export 'src/abstraction/video_player_interface.dart';
    export 'src/abstraction/video_player_initializer.dart';
    export 'src/cubit/universal_video_cubit.dart';
    export 'src/ui/universal_video_player.dart';
    export 'src/ui/fullscreen_video_player.dart';
    ```
3.  **ProGuard & Manifests**: Include the ProGuard rules and Manifest instructions in the new package's `README.md` so that consumers of your package know how to configure their Android/iOS apps.

By following this structure, your video system becomes a "plug-and-play" module that you can drop into any project.
