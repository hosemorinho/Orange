// Settings-domain bridge for legacy shared symbols still used by xboard.
export 'package:fl_clash/enum/enum.dart'
    show
        AccessControlMode,
        AccessSortType,
        CommonCardType,
        HotAction,
        KeyboardModifier,
        LoadingTag,
        QueryTag;
export 'package:fl_clash/models/common.dart'
    show HotKeyAction, Package, PackagesExt, PopupMenuItemData;
export 'package:fl_clash/models/config.dart'
    show AccessControlProps, AccessControlPropsExt;
export 'package:fl_clash/models/state.dart' show AppBarSearchState, VM2;
export 'package:fl_clash/providers/app.dart'
    show loadingProvider, packagesProvider, queryProvider;
export 'package:fl_clash/providers/config.dart'
    show hotKeyActionsProvider, vpnSettingProvider;
export 'package:fl_clash/providers/state.dart'
    show accessControlStateProvider, getHotKeyActionProvider, isStartProvider;
