/// Leaf proxy core integration for Orange.
///
/// Replaces the Go-based Clash.Meta core with the Rust-based leaf core.
/// Communication is entirely via dart:ffi (no REST API).
library leaf;

// Config
export 'config/clash_proxy_converter.dart';
export 'config/config_writer.dart';
export 'config/leaf_config.dart';

// FFI
export 'ffi/leaf_bindings.dart';
export 'ffi/leaf_errors.dart';
export 'ffi/leaf_ffi.dart';

// Core
export 'leaf_controller.dart';
export 'leaf_app_adapter.dart';
export 'leaf_initializer.dart';
export 'models/leaf_node.dart';
export 'providers/leaf_providers.dart';

// Platform
export 'platform/leaf_desktop.dart';

// Widgets
export 'widgets/leaf_connect_button.dart';
export 'widgets/leaf_connection_status_card.dart';
export 'widgets/leaf_logout_dialog.dart';
export 'widgets/leaf_node_list.dart';
export 'widgets/leaf_tv_connect_button.dart';
export 'widgets/leaf_tv_node_grid.dart';
export 'widgets/leaf_vpn_hero_card.dart';
