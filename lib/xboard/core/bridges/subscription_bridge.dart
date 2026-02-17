// Subscription-domain bridge for legacy shared symbols still used by xboard.
export 'package:fl_clash/common/bridges/legacy_enum_bridge.dart'
    show FunctionTag, GroupName, GroupType, Mode;
export 'package:fl_clash/models/common.dart' show Group, Proxy;
export 'package:fl_clash/models/profile.dart' show SubscriptionInfo;
export 'package:fl_clash/providers/app.dart' show groupsProvider;
export 'package:fl_clash/providers/config.dart'
    show appSettingProvider, patchClashConfigProvider;
export 'package:fl_clash/providers/database.dart' show profilesProvider;
export 'package:fl_clash/providers/state.dart'
    show
        currentProfileProvider,
        getDelayProvider,
        isStartProvider,
        selectedMapProvider;
