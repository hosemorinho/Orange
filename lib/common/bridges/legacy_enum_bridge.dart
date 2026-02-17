// Thin enum bridge used by leaf/xboard modules.
//
// This keeps leaf/xboard from directly depending on the broad legacy enum
// aggregator entrypoint.
export 'package:fl_clash/enum/enum.dart'
    show
        AccessControlMode,
        AccessSortType,
        CommonCardType,
        CoreStatus,
        FunctionTag,
        GroupName,
        GroupType,
        HotAction,
        KeyboardModifier,
        LoadingTag,
        Mode,
        ProfileType,
        QueryTag;
