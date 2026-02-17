// Leaf-local bridge for legacy shared types.
//
// Keep leaf-specific dependencies explicit and avoid importing broad
// app-level aggregator files from leaf modules.
export 'package:fl_clash/common/bridges/legacy_enum_bridge.dart'
    show GroupName, Mode;
