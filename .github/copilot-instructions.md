# Copilot Instructions for Softlight Studio

## Project Overview
Softlight Studio is a professional photo editing application built with Flutter. It provides advanced image processing capabilities with a modern, Nothing OS-inspired UI design. The app supports cross-platform deployment (Web, iOS, Android, macOS, Windows, Linux).

## Technology Stack
- **Framework**: Flutter 3.9.2+
- **Language**: Dart
- **State Management**: Provider
- **Image Processing**: Custom image manipulation using dart:ui
- **UI Design**: Material Design with custom theming (Nothing OS aesthetic)

## Code Style & Conventions

### Dart/Flutter Best Practices
1. **Always** follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
2. Use `const` constructors wherever possible for performance optimization
3. Prefer `final` over `var` for immutable variables
4. Use meaningful, descriptive variable and function names
5. Follow PascalCase for class names, camelCase for variables and functions
6. Use trailing commas for better formatting and diffs
7. Avoid using `dynamic` type unless absolutely necessary

### Code Organization
```
lib/
├── editor/          # Core editing logic and state management
├── ui/              # UI components and widgets
│   ├── panels/      # Panel widgets (filters, develop, color, etc.)
│   ├── widgets/     # Reusable UI widgets
│   ├── knobs/       # Custom knob controls
│   ├── curves/      # Curve editor components
│   └── histogram/   # Histogram widgets
├── util/            # Utility functions and helpers
└── main.dart        # Application entry point
```

### State Management
- Use `Provider` for global state management
- `EditorState` is the main state class containing image data and editing parameters
- Use `ChangeNotifier` pattern for reactive updates
- Always dispose of resources properly (controllers, listeners, etc.)

### UI/UX Guidelines
1. **Theme Consistency**: Follow the SoftlightTheme color system
   - Use `SoftlightTheme.gray*` colors for consistent appearance
   - Support both light and dark modes
   - Use the dynamic accent color from `editorState.highlightColor`

2. **Responsive Design**: 
   - Use `LayoutBuilder` for adaptive layouts
   - Implement different UIs for mobile (<900px) and desktop (>=900px)
   - Ensure touch targets are at least 44x44 logical pixels

3. **Animations**:
   - Use `Curves.easeOutCubic` and `Curves.easeInCubic` for smooth transitions
   - Keep animation durations between 200-300ms for snappy feel
   - Use `AnimatedContainer`, `AnimatedSwitcher` for implicit animations

4. **Typography**:
   - Use 'Courier New' font for branding and labels
   - Maintain consistent letter spacing (1.2-2.8) for uppercase text
   - Follow the existing font size hierarchy

### Image Processing
1. Work with `dart:ui Image` objects for processing
2. Use `EditorState` methods to manipulate images
3. Always check if image is loaded before processing: `editorState.hasImage`
4. Handle processing asynchronously to avoid blocking UI
5. Show loading indicators during processing: `editorState.isProcessing`

### Performance Considerations
1. Use `const` constructors to reduce widget rebuilds
2. Minimize `setState()` calls - update only what's necessary
3. Use `Consumer` widget to rebuild only specific parts of the widget tree
4. Lazy-load images and process them on-demand
5. Implement proper disposal of resources (Images, controllers, etc.)

## Testing
- Tests are located in the `test/` directory
- Use `flutter test` to run tests
- Write widget tests for UI components
- Write unit tests for business logic and image processing

## Linting & Analysis
- Follow rules defined in `analysis_options.yaml`
- Run `flutter analyze` before committing
- The project uses `flutter_lints` package for recommended lints
- Deprecation warnings are temporarily ignored - avoid adding new deprecated APIs

## Building & Running
```bash
# Get dependencies
flutter pub get

# Run in development mode
flutter run

# Run for specific platform
flutter run -d chrome        # Web
flutter run -d macos         # macOS
flutter run -d windows       # Windows
flutter run -d linux         # Linux

# Build for production
flutter build web
flutter build macos
flutter build windows
flutter build linux
flutter build apk           # Android
flutter build ios           # iOS
```

## Common Patterns

### Adding a New Panel
1. Create panel widget in `lib/ui/panels/`
2. Extend from `StatelessWidget` or `StatefulWidget`
3. Accept `EditorState` as parameter or use `Consumer<EditorState>`
4. Add panel to the switch statement in `_buildPanelBody()` method
5. Add panel shortcut to `_panelShortcuts` list if needed

### Adding a New Parameter
1. Add property to `EditorParams` class (in `editor_state.dart`)
2. Update parameter getter/setter in `EditorState`
3. Implement parameter logic in image processing pipeline
4. Add knob control in appropriate panel
5. Update presets to include new parameter

### Creating Custom Widgets
1. Make widgets reusable and configurable
2. Accept theme-related parameters (isDark, accent color)
3. Use proper const constructors
4. Follow existing naming conventions
5. Document complex widgets with comments

## Dependencies
- Use specific versions in `pubspec.yaml` (avoid `^` for stability)
- Check compatibility with Flutter SDK version before adding new dependencies
- Prefer well-maintained, popular packages
- Always test on multiple platforms when adding new dependencies

## Platform-Specific Considerations
- **Web**: Use `kIsWeb` to check web platform
- **Desktop**: Check `defaultTargetPlatform` for macOS, Windows, Linux
- **Mobile**: Different UI patterns for mobile vs desktop
- Use platform-specific APIs through conditional imports when needed

## Git Workflow
- Keep commits focused and atomic
- Write clear, descriptive commit messages
- Test thoroughly before committing
- Don't commit large binary files or generated code

## Additional Notes
- The app uses a custom "Nothing OS" inspired design language
- Maintain the minimalist, clean aesthetic in all UI additions
- Use haptic feedback for important interactions (via `HapticFeedback` API)
- All text labels should be uppercase with proper letter spacing for brand consistency
- Debug mode is available via `ui_debug_flags.dart` - use for layout debugging only

## When Adding Features
1. Check if similar functionality exists elsewhere in the codebase
2. Follow existing patterns and conventions
3. Consider both mobile and desktop experiences
4. Test on multiple platforms if possible
5. Update this document if introducing new patterns or conventions
