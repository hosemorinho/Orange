/// Leaf proxy core integration for Orange.
///
/// Replaces the Go-based Clash.Meta core with the Rust-based leaf core.
/// Communication is entirely via dart:ffi (no REST API).
library leaf;

export 'config/clash_proxy_converter.dart';
export 'config/config_writer.dart';
export 'config/leaf_config.dart';
export 'ffi/leaf_bindings.dart';
export 'ffi/leaf_errors.dart';
export 'ffi/leaf_ffi.dart';
export 'leaf_controller.dart';
export 'models/leaf_node.dart';
export 'providers/leaf_providers.dart';
