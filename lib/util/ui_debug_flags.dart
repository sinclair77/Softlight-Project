/// Global UI debug toggles. During development we expose some sized boxes
/// and boundary paints to surface layout problems like overflow.
library ui_debug_flags;

/// When true, debug widgets render a narrow sentinel box so we can inspect
/// for overflows visually in release-like builds.
const bool showLayoutDebugging = false;
