// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(rate) => "Current commission rate: ${rate}%";

  static String m1(count) =>
      "${Intl.plural(count, one: '1 day ago', other: '${count} days ago')}";

  static String m2(label) =>
      "Are you sure you want to delete the selected ${label}?";

  static String m3(label) =>
      "Are you sure you want to delete the current ${label}?";

  static String m4(label) => "${label} details";

  static String m5(label) => "${label} cannot be empty";

  static String m6(label) => "Current ${label} already exists";

  static String m7(email) => "Full email: ${email}";

  static String m8(count) =>
      "${Intl.plural(count, one: '1 hour ago', other: '${count} hours ago')}";

  static String m9(error) => "Logout failed: ${error}";

  static String m10(amount) => "Max transferable: ¥${amount}";

  static String m11(count) =>
      "${Intl.plural(count, one: '1 minute ago', other: '${count} minutes ago')}";

  static String m12(count) =>
      "${Intl.plural(count, one: '1 month ago', other: '${count} months ago')}";

  static String m13(label) => "No ${label} yet";

  static String m14(label) => "${label} must be a number";

  static String m15(statusCode) => "Failed to get messages: ${statusCode}";

  static String m16(error) => "Failed to select images: ${error}";

  static String m17(method) => "Unsupported HTTP method: ${method}";

  static String m18(error) => "Upload failed: ${error}";

  static String m19(amount) => "Order amount: ${amount}";

  static String m20(orderNo) => "Order: ${orderNo}";

  static String m21(page) => "Page ${page}";

  static String m22(label) => "${label} must be between 1024 and 49151";

  static String m23(e) => "Registration failed: ${e}";

  static String m24(count) => "${count} items have been selected";

  static String m25(e) => "Failed to send verification code: ${e}";

  static String m26(date) =>
      "Plan expired on ${date}, please renew to continue using";

  static String m27(days) =>
      "Plan will expire in ${days} days, please renew in time";

  static String m28(days) => "Subscription will expire in ${days} days";

  static String m29(count) => "Total ${count} records";

  static String m30(amount) => "Transfer amount cannot exceed ¥${amount}";

  static String m31(error) => "Transfer failed: ${error}";

  static String m32(amount) =>
      "Transfer success! Transferred ¥${amount} to wallet";

  static String m33(version) => "Current version: ${version}";

  static String m34(version) => "Force update: ${version}";

  static String m35(version) => "New version found: ${version}";

  static String m36(statusCode) =>
      "Server returned error status code ${statusCode}";

  static String m37(label) => "${label} must be a url";

  static String m38(email) =>
      "Verification code has been sent to ${email}, please check and enter the verification code and new password";

  static String m39(error) => "Withdrawal failed: ${error}";

  static String m40(amount) => "Withdrawable amount: ${amount}";

  static String m41(count) => "${count} rules configured";

  static String m42(error) => "Failed to check payment status: ${error}";

  static String m43(error) => "Copy failed: ${error}";

  static String m44(limit) => "${limit} devices";

  static String m45(traffic) => "Download: ${traffic}";

  static String m46(error) => "Failed to open payment link: ${error}";

  static String m47(error) => "Failed to open payment page: ${error}";

  static String m48(error) => "Operation failed: ${error}";

  static String m49(message) => "Payment failed: ${message}";

  static String m50(planId) => "Plan #${planId}";

  static String m51(url) => "Proxy (${url})";

  static String m52(days) => "${days} days";

  static String m53(attempt) =>
      "Attempt ${attempt} failed, waiting to retry...";

  static String m54(time) => "Running time: ${time}";

  static String m55(traffic) => "Upload: ${traffic}";

  static String m56(count) =>
      "${Intl.plural(count, one: '1 year ago', other: '${count} years ago')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "accessControl": MessageLookupByLibrary.simpleMessage("AccessControl"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Only allow selected app to enter VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Configure application access proxy",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "The selected application will be excluded from VPN",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Access Control Settings",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "action": MessageLookupByLibrary.simpleMessage("Action"),
    "action_mode": MessageLookupByLibrary.simpleMessage("Switch mode"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "action_start": MessageLookupByLibrary.simpleMessage("Start/Stop"),
    "action_tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("Show/Hide"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Add Profile"),
    "addRule": MessageLookupByLibrary.simpleMessage("Add rule"),
    "addedOriginRules": MessageLookupByLibrary.simpleMessage(
      "Attach on the original rules",
    ),
    "addedRules": MessageLookupByLibrary.simpleMessage("Added rules"),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV server address",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid WebDAV address",
    ),
    "adminAutoLaunch": MessageLookupByLibrary.simpleMessage(
      "Admin auto launch",
    ),
    "adminAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Boot up by using admin mode",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "Advanced configuration",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Provide diverse configuration options",
    ),
    "ago": MessageLookupByLibrary.simpleMessage(" Ago"),
    "agree": MessageLookupByLibrary.simpleMessage("Agree"),
    "allApps": MessageLookupByLibrary.simpleMessage("All apps"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Allow applications to bypass VPN",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "Some apps can bypass VPN when turned on",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("AllowLan"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "Allow access proxy through the LAN",
    ),
    "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Already have an account?",
    ),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "App access control",
    ),
    "appDesc": MessageLookupByLibrary.simpleMessage(
      "Processing app related settings",
    ),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Append System DNS",
    ),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "Forcefully append system DNS to the configuration",
    ),
    "application": MessageLookupByLibrary.simpleMessage("Application"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "Modify application related settings",
    ),
    "applicationSettings": MessageLookupByLibrary.simpleMessage(
      "Application Settings",
    ),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Auto check updates",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "Auto check for updates when the app starts",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Auto close connections",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Auto close connections after change node",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Auto launch"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Follow the system self startup",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("AutoRun"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Auto run when the application is opened",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Auto set system DNS",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Auto update"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto update interval (minutes)",
    ),
    "availableCommission": MessageLookupByLibrary.simpleMessage("Available"),
    "backToLogin": MessageLookupByLibrary.simpleMessage("Back to Login"),
    "backup": MessageLookupByLibrary.simpleMessage("Backup"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage(
      "Backup and Recovery",
    ),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Sync data via WebDAV or file",
    ),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Backup and Restore",
    ),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Sync data via WebDAV or files",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("Backup success"),
    "basicConfig": MessageLookupByLibrary.simpleMessage("Basic configuration"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Modify the basic configuration globally",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Bind"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Blacklist mode"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Bypass domain"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Only takes effect when the system proxy is enabled",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "The cache is corrupt. Do you want to clear it?",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelFilterSystemApp": MessageLookupByLibrary.simpleMessage(
      "Cancel filter system app",
    ),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "Cancel select all",
    ),
    "cannotGetWebUrl": MessageLookupByLibrary.simpleMessage(
      "Cannot get web URL, please contact support",
    ),
    "cannotOpenBrowser": MessageLookupByLibrary.simpleMessage(
      "Cannot open browser, please visit web manually",
    ),
    "cannotSelectSpecialProxy": MessageLookupByLibrary.simpleMessage(
      "Cannot select DIRECT or REJECT special proxy",
    ),
    "checkError": MessageLookupByLibrary.simpleMessage("Check error"),
    "checkNetwork": MessageLookupByLibrary.simpleMessage(
      "Please check network and retry",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Check for updates"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "The current application is already the latest version",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("Checking..."),
    "clearData": MessageLookupByLibrary.simpleMessage("Clear Data"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("Export clipboard"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("Clipboard import"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "color": MessageLookupByLibrary.simpleMessage("Color"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("Color schemes"),
    "columns": MessageLookupByLibrary.simpleMessage("Columns"),
    "commissionHistory": MessageLookupByLibrary.simpleMessage(
      "Commission History",
    ),
    "commissionRate": MessageLookupByLibrary.simpleMessage("Rate"),
    "commissionSettled": MessageLookupByLibrary.simpleMessage(
      "Commission settled after friend subscription",
    ),
    "compatible": MessageLookupByLibrary.simpleMessage("Compatibility mode"),
    "compatibleDesc": MessageLookupByLibrary.simpleMessage(
      "Opening it will lose part of its application ability and gain the support of full amount of Clash.",
    ),
    "complete": MessageLookupByLibrary.simpleMessage("Complete"),
    "completeWithdrawal": MessageLookupByLibrary.simpleMessage(
      "Web version provides complete withdrawal features",
    ),
    "configurationError": MessageLookupByLibrary.simpleMessage(
      "Application configuration error, please contact support",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to clear all data?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force crash the core?",
    ),
    "confirmLogout": MessageLookupByLibrary.simpleMessage("Confirm Logout"),
    "confirmNewPassword": MessageLookupByLibrary.simpleMessage(
      "Confirm New Password",
    ),
    "confirmTransfer": MessageLookupByLibrary.simpleMessage("Confirm Transfer"),
    "confirmWithdraw": MessageLookupByLibrary.simpleMessage(
      "Confirm Withdrawal",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Connected"),
    "connecting": MessageLookupByLibrary.simpleMessage("Connecting..."),
    "connection": MessageLookupByLibrary.simpleMessage("Connection"),
    "connections": MessageLookupByLibrary.simpleMessage("Connections"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "View current connections data",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Connectivity："),
    "contactMe": MessageLookupByLibrary.simpleMessage("Contact me"),
    "contactSupport": MessageLookupByLibrary.simpleMessage("Support"),
    "content": MessageLookupByLibrary.simpleMessage("Content"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Content"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Control global added rules",
    ),
    "copiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "Copied to clipboard",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Copying environment variables",
    ),
    "copyInviteLink": MessageLookupByLibrary.simpleMessage("Copy Link"),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copy link"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Copy success"),
    "core": MessageLookupByLibrary.simpleMessage("Core"),
    "coreConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "Core configuration change detected",
    ),
    "coreInfo": MessageLookupByLibrary.simpleMessage("Core info"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Core status"),
    "country": MessageLookupByLibrary.simpleMessage("Country"),
    "crashTest": MessageLookupByLibrary.simpleMessage("Crash test"),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "createAccount": MessageLookupByLibrary.simpleMessage("Create Account"),
    "creationTime": MessageLookupByLibrary.simpleMessage("Creation time"),
    "credentialsSaved": MessageLookupByLibrary.simpleMessage(
      "Credentials saved",
    ),
    "currentCommissionRate": m0,
    "cut": MessageLookupByLibrary.simpleMessage("Cut"),
    "dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "days": MessageLookupByLibrary.simpleMessage("Days"),
    "daysAgo": m1,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "Default nameserver",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "For resolving DNS server",
    ),
    "defaultSort": MessageLookupByLibrary.simpleMessage("Sort by default"),
    "defaultText": MessageLookupByLibrary.simpleMessage("Default"),
    "delay": MessageLookupByLibrary.simpleMessage("Delay"),
    "delaySort": MessageLookupByLibrary.simpleMessage("Sort by delay"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Delay Test"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteMultipTip": m2,
    "deleteTip": m3,
    "desc": MessageLookupByLibrary.simpleMessage(
      "A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Destination"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "Destination GeoIP",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "Destination IPASN",
    ),
    "details": m4,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Relying on third-party api is for reference only",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Developer mode"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Developer mode is enabled.",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Direct"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Disclaimer"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "This software is only used for non-commercial purposes such as learning exchanges and scientific research. It is strictly prohibited to use this software for commercial purposes. Any commercial activity, if any, has nothing to do with this software.",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Disconnected"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "Discover the new version",
    ),
    "discovery": MessageLookupByLibrary.simpleMessage(
      "Discovery a new version",
    ),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "Update DNS related settings",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS hijacking"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS mode"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "Do you want to pass",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("Domain"),
    "domainStatusAvailable": MessageLookupByLibrary.simpleMessage(
      "Service Available",
    ),
    "domainStatusChecking": MessageLookupByLibrary.simpleMessage("Checking..."),
    "domainStatusUnavailable": MessageLookupByLibrary.simpleMessage(
      "Service Unavailable",
    ),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Edit global rules",
    ),
    "editRule": MessageLookupByLibrary.simpleMessage("Edit rule"),
    "emailAddress": MessageLookupByLibrary.simpleMessage("Email Address"),
    "emailPrefixHint": MessageLookupByLibrary.simpleMessage("Email prefix"),
    "emailVerificationCode": MessageLookupByLibrary.simpleMessage(
      "Email Verification Code",
    ),
    "emptyTip": m5,
    "en": MessageLookupByLibrary.simpleMessage("English"),
    "enableOverride": MessageLookupByLibrary.simpleMessage("Enable override"),
    "enterEmailForReset": MessageLookupByLibrary.simpleMessage(
      "Please enter your email address and we will send a verification code to your email",
    ),
    "enterTransferAmount": MessageLookupByLibrary.simpleMessage(
      "Enter transfer amount",
    ),
    "enterTransferAmountError": MessageLookupByLibrary.simpleMessage(
      "Please enter transfer amount",
    ),
    "enterWithdrawAccount": MessageLookupByLibrary.simpleMessage(
      "Enter withdrawal account",
    ),
    "entries": MessageLookupByLibrary.simpleMessage(" entries"),
    "exclude": MessageLookupByLibrary.simpleMessage("Hidden from recent tasks"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "When the app is in the background, the app is hidden from the recent task",
    ),
    "existsTip": m6,
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "expand": MessageLookupByLibrary.simpleMessage("Standard"),
    "expirationTime": MessageLookupByLibrary.simpleMessage("Expiration time"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Export file"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Export logs"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Export Success"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Expressive"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "ExternalController",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Once enabled, the Clash kernel can be controlled on port 9090",
    ),
    "externalFetch": MessageLookupByLibrary.simpleMessage("External fetch"),
    "externalLink": MessageLookupByLibrary.simpleMessage("External link"),
    "externalResources": MessageLookupByLibrary.simpleMessage(
      "External resources",
    ),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fakeip filter"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fakeip range"),
    "fallback": MessageLookupByLibrary.simpleMessage("Fallback"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Generally use offshore DNS",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Fallback filter"),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("Fidelity"),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("Directly upload profile"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "The file has been modified. Do you want to save the changes?",
    ),
    "fillInfoToRegister": MessageLookupByLibrary.simpleMessage(
      "Please fill in the following information to complete registration",
    ),
    "filterSystemApp": MessageLookupByLibrary.simpleMessage(
      "Filter system app",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Find process"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "There is a certain performance loss after opening",
    ),
    "fontFamily": MessageLookupByLibrary.simpleMessage("FontFamily"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force restart the core?",
    ),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("Forgot Password"),
    "fourColumns": MessageLookupByLibrary.simpleMessage("Four columns"),
    "friendInviteReward": MessageLookupByLibrary.simpleMessage(
      "Earn commission when your invited friends spend",
    ),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("FruitSalad"),
    "fullEmailPreview": m7,
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "generalDesc": MessageLookupByLibrary.simpleMessage(
      "Modify general settings",
    ),
    "generatingInviteCode": MessageLookupByLibrary.simpleMessage(
      "Generating invite code...",
    ),
    "geoData": MessageLookupByLibrary.simpleMessage("GeoData"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Geo Low Memory Mode",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "Enabling will use the Geo low memory loader",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("Geoip code"),
    "getOriginRules": MessageLookupByLibrary.simpleMessage(
      "Get original rules",
    ),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "go": MessageLookupByLibrary.simpleMessage("Go"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Go to download"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Go to configure script",
    ),
    "goToWeb": MessageLookupByLibrary.simpleMessage("Go to Web"),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Do you want to cache the changes?",
    ),
    "host": MessageLookupByLibrary.simpleMessage("Host"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("Add Hosts"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("Hotkey conflict"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Hotkey Management",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Use keyboard to control applications",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("Hours"),
    "hoursAgo": m8,
    "iUnderstand": MessageLookupByLibrary.simpleMessage("I Understand"),
    "icon": MessageLookupByLibrary.simpleMessage("Icon"),
    "iconConfiguration": MessageLookupByLibrary.simpleMessage(
      "Icon configuration",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Icon style"),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "importFile": MessageLookupByLibrary.simpleMessage("Import from file"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "importUrl": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Long term effective"),
    "init": MessageLookupByLibrary.simpleMessage("Init"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "Please enter the correct hotkey",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Intelligent selection",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "interval": MessageLookupByLibrary.simpleMessage("Interval"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Intranet IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Invalid backup file",
    ),
    "invalidEmailFormat": MessageLookupByLibrary.simpleMessage(
      "Invalid email format",
    ),
    "invalidTransferAmount": MessageLookupByLibrary.simpleMessage(
      "Please enter valid transfer amount",
    ),
    "invite": MessageLookupByLibrary.simpleMessage("Invite"),
    "inviteCode": MessageLookupByLibrary.simpleMessage("Invite Code"),
    "inviteCodeGenFailed": MessageLookupByLibrary.simpleMessage(
      "Invite code generation failed",
    ),
    "inviteCodeIncorrect": MessageLookupByLibrary.simpleMessage(
      "Invite code may be incorrect, please check and re-enter",
    ),
    "inviteCodeOptional": MessageLookupByLibrary.simpleMessage(
      "Invite Code (optional)",
    ),
    "inviteCodeRequired": MessageLookupByLibrary.simpleMessage(
      "Invite Code Required",
    ),
    "inviteCodeRequiredMessage": MessageLookupByLibrary.simpleMessage(
      "Registration requires an invite code. Please contact a registered user to get an invite code before registering.",
    ),
    "inviteLinkCopied": MessageLookupByLibrary.simpleMessage(
      "Invite link copied, share with friends",
    ),
    "inviteRegisterReward": MessageLookupByLibrary.simpleMessage(
      "Invite friends to register and subscribe to earn commission",
    ),
    "inviteRules": MessageLookupByLibrary.simpleMessage("Invite Rules"),
    "inviteStats": MessageLookupByLibrary.simpleMessage("Invite Stats"),
    "ipcidr": MessageLookupByLibrary.simpleMessage("Ipcidr"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "When turned on it will be able to receive IPv6 traffic",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Allow IPv6 inbound",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("Japanese"),
    "just": MessageLookupByLibrary.simpleMessage("Just"),
    "justNow": MessageLookupByLibrary.simpleMessage("Just now"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "Tcp keep alive interval",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Key"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "layout": MessageLookupByLibrary.simpleMessage("Layout"),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "list": MessageLookupByLibrary.simpleMessage("List"),
    "listen": MessageLookupByLibrary.simpleMessage("Listen"),
    "loadMore": MessageLookupByLibrary.simpleMessage("Load More"),
    "loadTest": MessageLookupByLibrary.simpleMessage("Load test"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "local": MessageLookupByLibrary.simpleMessage("Local"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Backup local data to local",
    ),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Recovery data from file",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Log"),
    "logLevel": MessageLookupByLibrary.simpleMessage("LogLevel"),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Disabling will hide the log entry",
    ),
    "loggedOutSuccess": MessageLookupByLibrary.simpleMessage(
      "Logged out successfully",
    ),
    "loginNow": MessageLookupByLibrary.simpleMessage("Login Now"),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "logoutConfirmMsg": MessageLookupByLibrary.simpleMessage(
      "Are you sure to logout? You need to login again.",
    ),
    "logoutFailed": m9,
    "logs": MessageLookupByLibrary.simpleMessage("Logs"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("Log capture records"),
    "logsTest": MessageLookupByLibrary.simpleMessage("Logs test"),
    "loopback": MessageLookupByLibrary.simpleMessage("Loopback unlock tool"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "Used for UWP loopback unlocking",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Loose"),
    "maxTransferable": m10,
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Memory info"),
    "messageTest": MessageLookupByLibrary.simpleMessage("Message test"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "This is a message.",
    ),
    "min": MessageLookupByLibrary.simpleMessage("Min"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("Minimize on exit"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Modify the default system exit event",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("Minutes"),
    "minutesAgo": m11,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixed Port"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "months": MessageLookupByLibrary.simpleMessage("Months"),
    "monthsAgo": m12,
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "myInviteQr": MessageLookupByLibrary.simpleMessage("My Invite QR"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameSort": MessageLookupByLibrary.simpleMessage("Sort by name"),
    "nameserver": MessageLookupByLibrary.simpleMessage("Nameserver"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "For resolving domain",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "Nameserver policy",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Specify the corresponding nameserver policy",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Network"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "Modify network-related settings",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "Network detection",
    ),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "Network exception, please check your connection and try again",
    ),
    "networkRequestException": MessageLookupByLibrary.simpleMessage(
      "Network request exception, please try again later.",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Network speed"),
    "networkType": MessageLookupByLibrary.simpleMessage("Network type"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Neutral"),
    "newMessageFromSupport": MessageLookupByLibrary.simpleMessage(
      "New message from support",
    ),
    "newPassword": MessageLookupByLibrary.simpleMessage("New Password"),
    "noAccount": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account?",
    ),
    "noCommissionRecord": MessageLookupByLibrary.simpleMessage(
      "No commission records",
    ),
    "noData": MessageLookupByLibrary.simpleMessage("No data"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("No HotKey"),
    "noIcon": MessageLookupByLibrary.simpleMessage("None"),
    "noInfo": MessageLookupByLibrary.simpleMessage("No info"),
    "noInvitationData": MessageLookupByLibrary.simpleMessage(
      "No invitation data",
    ),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "Don\'t remind again",
    ),
    "noMoreInfoDesc": MessageLookupByLibrary.simpleMessage("No more info"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("No network"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("No network APP"),
    "noProxy": MessageLookupByLibrary.simpleMessage("No proxy"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Please create a profile or add a valid profile",
    ),
    "noResolve": MessageLookupByLibrary.simpleMessage("No resolve IP"),
    "none": MessageLookupByLibrary.simpleMessage("none"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "The current proxy group cannot be selected.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "No profile, Please add a profile",
    ),
    "nullTip": m13,
    "numberTip": m14,
    "oneColumn": MessageLookupByLibrary.simpleMessage("One column"),
    "onlineSupport": MessageLookupByLibrary.simpleMessage("Support"),
    "onlineSupportAddMore": MessageLookupByLibrary.simpleMessage("Add More"),
    "onlineSupportApiConfigNotFound": MessageLookupByLibrary.simpleMessage(
      "Online support API configuration not found, please check configuration",
    ),
    "onlineSupportCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "onlineSupportClearHistory": MessageLookupByLibrary.simpleMessage(
      "Clear history",
    ),
    "onlineSupportClearHistoryConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to clear all chat history? This action cannot be undone.",
    ),
    "onlineSupportClickToSelect": MessageLookupByLibrary.simpleMessage(
      "Click to select images",
    ),
    "onlineSupportConfirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "onlineSupportConnected": MessageLookupByLibrary.simpleMessage(
      "Successfully connected to support system",
    ),
    "onlineSupportConnecting": MessageLookupByLibrary.simpleMessage(
      "Connecting...",
    ),
    "onlineSupportConnectionError": MessageLookupByLibrary.simpleMessage(
      "Connection error",
    ),
    "onlineSupportDisconnected": MessageLookupByLibrary.simpleMessage(
      "Disconnected",
    ),
    "onlineSupportGetMessagesFailed": m15,
    "onlineSupportInputHint": MessageLookupByLibrary.simpleMessage(
      "Please enter your question...",
    ),
    "onlineSupportNoMessages": MessageLookupByLibrary.simpleMessage(
      "No messages yet, send a message to start consultation",
    ),
    "onlineSupportSelectImages": MessageLookupByLibrary.simpleMessage(
      "Select Images",
    ),
    "onlineSupportSelectImagesFailed": m16,
    "onlineSupportSend": MessageLookupByLibrary.simpleMessage("Send"),
    "onlineSupportSendImage": MessageLookupByLibrary.simpleMessage(
      "Send image",
    ),
    "onlineSupportSendMessageFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to send message: Unable to get authentication token",
    ),
    "onlineSupportSupportedFormats": MessageLookupByLibrary.simpleMessage(
      "Supports JPG, PNG, GIF, WebP, BMP\nMax 10MB",
    ),
    "onlineSupportTitle": MessageLookupByLibrary.simpleMessage(
      "Online Support",
    ),
    "onlineSupportTokenNotFound": MessageLookupByLibrary.simpleMessage(
      "Authentication token not found",
    ),
    "onlineSupportUnsupportedHttpMethod": m17,
    "onlineSupportUploadFailed": m18,
    "onlineSupportWebSocketConfigNotFound": MessageLookupByLibrary.simpleMessage(
      "Online support WebSocket configuration not found, please check configuration",
    ),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Icon"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage(
      "Only third-party apps",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Only statistics proxy",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "When turned on, only statistics proxy traffic",
    ),
    "openWebFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to open web, please visit manually",
    ),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "orderAmount": m19,
    "orderNumber": m20,
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Other contributors",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Outbound mode"),
    "override": MessageLookupByLibrary.simpleMessage("Override"),
    "overrideDesc": MessageLookupByLibrary.simpleMessage(
      "Override Proxy related config",
    ),
    "overrideDns": MessageLookupByLibrary.simpleMessage("Override Dns"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Turning it on will override the DNS options in the profile",
    ),
    "overrideInvalidTip": MessageLookupByLibrary.simpleMessage(
      "Does not take effect in script mode",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage("Override mode"),
    "overrideOriginRules": MessageLookupByLibrary.simpleMessage(
      "Override the original rule",
    ),
    "overrideScript": MessageLookupByLibrary.simpleMessage("Override script"),
    "overwriteTypeCustom": MessageLookupByLibrary.simpleMessage("Custom"),
    "overwriteTypeCustomDesc": MessageLookupByLibrary.simpleMessage(
      "Custom mode, fully customize proxy groups and rules",
    ),
    "pageNumber": m21,
    "palette": MessageLookupByLibrary.simpleMessage("Palette"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordMin8Chars": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 8 characters",
    ),
    "passwordMinLength": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "passwordMismatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "passwordResetFailed": MessageLookupByLibrary.simpleMessage(
      "Password reset failed",
    ),
    "passwordResetSuccessful": MessageLookupByLibrary.simpleMessage(
      "Password reset successful! Please login with your new password",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "paste": MessageLookupByLibrary.simpleMessage("Paste"),
    "pendingCommission": MessageLookupByLibrary.simpleMessage("Pending"),
    "plans": MessageLookupByLibrary.simpleMessage("Plans"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Please bind WebDAV",
    ),
    "pleaseConfirmNewPassword": MessageLookupByLibrary.simpleMessage(
      "Please re-enter new password",
    ),
    "pleaseConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "Please confirm password",
    ),
    "pleaseEnterAtLeast8CharsPassword": MessageLookupByLibrary.simpleMessage(
      "Please enter at least 8 characters password",
    ),
    "pleaseEnterEmail": MessageLookupByLibrary.simpleMessage(
      "Please enter email address",
    ),
    "pleaseEnterEmailAddress": MessageLookupByLibrary.simpleMessage(
      "Please enter email address",
    ),
    "pleaseEnterEmailPrefix": MessageLookupByLibrary.simpleMessage(
      "Please enter email prefix",
    ),
    "pleaseEnterEmailVerificationCode": MessageLookupByLibrary.simpleMessage(
      "Please enter email verification code",
    ),
    "pleaseEnterInviteCode": MessageLookupByLibrary.simpleMessage(
      "Please enter invite code",
    ),
    "pleaseEnterNewPassword": MessageLookupByLibrary.simpleMessage(
      "Please enter new password",
    ),
    "pleaseEnterPassword": MessageLookupByLibrary.simpleMessage(
      "Please enter password",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Please enter a script name",
    ),
    "pleaseEnterValidEmail": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email address",
    ),
    "pleaseEnterValidEmailAddress": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email address",
    ),
    "pleaseEnterValidVerificationCode": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid verification code",
    ),
    "pleaseEnterVerificationCode": MessageLookupByLibrary.simpleMessage(
      "Please enter email verification code",
    ),
    "pleaseEnterYourEmailAddress": MessageLookupByLibrary.simpleMessage(
      "Please enter your email address",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "Please enter the admin password",
    ),
    "pleaseReEnterPassword": MessageLookupByLibrary.simpleMessage(
      "Please re-enter password",
    ),
    "pleaseSelectEmailSuffix": MessageLookupByLibrary.simpleMessage(
      "Please select email suffix",
    ),
    "pleaseSelectSuffix": MessageLookupByLibrary.simpleMessage(
      "Please select suffix",
    ),
    "pleaseUploadFile": MessageLookupByLibrary.simpleMessage(
      "Please upload file",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Please upload a valid QR code",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a different port",
    ),
    "portTip": m22,
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "Prioritize the use of DOH\'s http/3",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Please press the keyboard.",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "process": MessageLookupByLibrary.simpleMessage("Process"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Please input a valid interval time format",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Please enter the auto update interval time",
        ),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "The profile has been modified. Do you want to disable auto update?",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please input the profile name",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage(
      "profile parse error",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please input a valid profile URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please input the profile URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Profiles"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Profiles sort"),
    "project": MessageLookupByLibrary.simpleMessage("Project"),
    "providers": MessageLookupByLibrary.simpleMessage("Providers"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("Proxies setting"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("Proxy chains"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proxy group"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("Proxy nameserver"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Domain for resolving proxy nodes",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("ProxyPort"),
    "proxyPortDesc": MessageLookupByLibrary.simpleMessage(
      "Set the Clash listening port",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Proxy providers"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Prune cache"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Pure black mode"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR code"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Scan QR code to obtain profile",
    ),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Rainbow"),
    "recovery": MessageLookupByLibrary.simpleMessage("Recovery"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("Recovery all data"),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage(
      "Only recovery profiles",
    ),
    "recoveryStrategy": MessageLookupByLibrary.simpleMessage(
      "Recovery strategy",
    ),
    "recoveryStrategy_compatible": MessageLookupByLibrary.simpleMessage(
      "Compatible",
    ),
    "recoveryStrategy_override": MessageLookupByLibrary.simpleMessage(
      "Override",
    ),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage("Recovery success"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir Port"),
    "redo": MessageLookupByLibrary.simpleMessage("redo"),
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "regExp": MessageLookupByLibrary.simpleMessage("RegExp"),
    "registerAccount": MessageLookupByLibrary.simpleMessage("Register Account"),
    "registerSuccessSaveCredentials": MessageLookupByLibrary.simpleMessage(
      "Registration successful - Saving credentials:",
    ),
    "registrationFailed": m23,
    "reload": MessageLookupByLibrary.simpleMessage("Reload"),
    "rememberPassword": MessageLookupByLibrary.simpleMessage(
      "Remember your password?",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("Remote"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Backup local data to WebDAV",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Remote destination",
    ),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Recovery data from WebDAV",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "rename": MessageLookupByLibrary.simpleMessage("Rename"),
    "request": MessageLookupByLibrary.simpleMessage("Request"),
    "requests": MessageLookupByLibrary.simpleMessage("Requests"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "View recently request records",
    ),
    "resendVerificationCode": MessageLookupByLibrary.simpleMessage(
      "Resend Verification Code",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "The current page has changes. Are you sure you want to reset?",
    ),
    "resetPassword": MessageLookupByLibrary.simpleMessage("Reset Password"),
    "resetTip": MessageLookupByLibrary.simpleMessage("Make sure to reset"),
    "resources": MessageLookupByLibrary.simpleMessage("Resources"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "External resource related info",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Respect rules"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS connection following rules, need to configure proxy-server-nameserver",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("Restart"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to restart the core?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restore"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("Restore all data"),
    "restoreException": MessageLookupByLibrary.simpleMessage(
      "Recovery exception",
    ),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data via file",
    ),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data via WebDAV",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Restore configuration files only",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("Restore strategy"),
    "restoreStrategy_compatible": MessageLookupByLibrary.simpleMessage(
      "Compatible",
    ),
    "restoreStrategy_override": MessageLookupByLibrary.simpleMessage(
      "Override",
    ),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("Restore success"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Route address"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "Config listen route address",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("Route mode"),
    "routeMode_bypassPrivate": MessageLookupByLibrary.simpleMessage(
      "Bypass private route address",
    ),
    "routeMode_config": MessageLookupByLibrary.simpleMessage("Use config"),
    "ru": MessageLookupByLibrary.simpleMessage("Russian"),
    "rule": MessageLookupByLibrary.simpleMessage("Rule"),
    "ruleName": MessageLookupByLibrary.simpleMessage("Rule name"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Rule providers"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Rule target"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "Do you want to save the changes?",
    ),
    "saveQr": MessageLookupByLibrary.simpleMessage("Save QR"),
    "saveQrCodeFeature": MessageLookupByLibrary.simpleMessage(
      "Save QR feature coming soon",
    ),
    "saveTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to save?",
    ),
    "script": MessageLookupByLibrary.simpleMessage("Script"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Script mode, use external extension scripts, provide one-click override configuration capability",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "seconds": MessageLookupByLibrary.simpleMessage("Seconds"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Select all"),
    "selectTheme": MessageLookupByLibrary.simpleMessage("Select Theme"),
    "selectWithdrawMethod": MessageLookupByLibrary.simpleMessage(
      "Select withdrawal method",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "selectedCountTitle": m24,
    "sendCodeFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to send verification code",
    ),
    "sendVerificationCode": MessageLookupByLibrary.simpleMessage(
      "Send Verification Code",
    ),
    "sendVerificationCodeFailed": m25,
    "setNewPassword": MessageLookupByLibrary.simpleMessage("Set New Password"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "show": MessageLookupByLibrary.simpleMessage("Show"),
    "shrink": MessageLookupByLibrary.simpleMessage("Shrink"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("SilentLaunch"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Start in the background",
    ),
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "socksPort": MessageLookupByLibrary.simpleMessage("Socks Port"),
    "sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "source": MessageLookupByLibrary.simpleMessage("Source"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("Source IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Special proxy"),
    "specialRules": MessageLookupByLibrary.simpleMessage("special rules"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("Speed statistics"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Stack mode"),
    "standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Standard mode, override basic configuration, provide simple rule addition capability",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Starting VPN..."),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "System DNS will be used when turned off",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Stop"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Stopping VPN..."),
    "style": MessageLookupByLibrary.simpleMessage("Style"),
    "subRule": MessageLookupByLibrary.simpleMessage("Sub rule"),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Subscription expired",
    ),
    "subscriptionExpiredDetail": m26,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "Subscription expires today",
    ),
    "subscriptionExpiresTodayDetail": MessageLookupByLibrary.simpleMessage(
      "Plan will expire today, please renew immediately to avoid service interruption",
    ),
    "subscriptionExpiringInDays": MessageLookupByLibrary.simpleMessage(
      "Subscription expiring soon",
    ),
    "subscriptionExpiringInDaysDetail": m27,
    "subscriptionNoSubscription": MessageLookupByLibrary.simpleMessage(
      "No subscription",
    ),
    "subscriptionNoSubscriptionDetail": MessageLookupByLibrary.simpleMessage(
      "No available subscription plan found, please purchase a plan to use",
    ),
    "subscriptionNotLoggedIn": MessageLookupByLibrary.simpleMessage(
      "Not logged in",
    ),
    "subscriptionNotLoggedInDetail": MessageLookupByLibrary.simpleMessage(
      "Please login first",
    ),
    "subscriptionTrafficExhausted": MessageLookupByLibrary.simpleMessage(
      "Traffic exhausted",
    ),
    "subscriptionTrafficExhaustedDetail": MessageLookupByLibrary.simpleMessage(
      "Plan traffic has been used up, please purchase more traffic or upgrade plan",
    ),
    "subscriptionValid": MessageLookupByLibrary.simpleMessage(
      "Subscription valid",
    ),
    "subscriptionValidDetail": m28,
    "switchTheme": MessageLookupByLibrary.simpleMessage("Switch Theme"),
    "sync": MessageLookupByLibrary.simpleMessage("Sync"),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "systemApp": MessageLookupByLibrary.simpleMessage("System APP"),
    "systemFont": MessageLookupByLibrary.simpleMessage("System font"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Attach HTTP proxy to VpnService",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("Tab"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Tab animation"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Effective only in mobile view",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP concurrent"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "Enabling it will allow TCP concurrency",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("Test url"),
    "textScale": MessageLookupByLibrary.simpleMessage("Text Scaling"),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Theme color"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Set dark mode,adjust the color",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Theme mode"),
    "threeColumns": MessageLookupByLibrary.simpleMessage("Three columns"),
    "tight": MessageLookupByLibrary.simpleMessage("Tight"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "tip": MessageLookupByLibrary.simpleMessage("tip"),
    "toggle": MessageLookupByLibrary.simpleMessage("Toggle"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("TonalSpot"),
    "tools": MessageLookupByLibrary.simpleMessage("Tools"),
    "totalCommission": MessageLookupByLibrary.simpleMessage("Earnings"),
    "totalInvites": MessageLookupByLibrary.simpleMessage("Invites"),
    "totalRecords": m29,
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxy Port"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Traffic usage"),
    "transfer": MessageLookupByLibrary.simpleMessage("Transfer"),
    "transferAmount": MessageLookupByLibrary.simpleMessage("Transfer Amount"),
    "transferAmountExceeded": m30,
    "transferFailed": m31,
    "transferNote": MessageLookupByLibrary.simpleMessage(
      "Transferred balance can be used for in-app purchases",
    ),
    "transferSuccess": MessageLookupByLibrary.simpleMessage(
      "Transfer Success!",
    ),
    "transferSuccessMsg": m32,
    "transferToWallet": MessageLookupByLibrary.simpleMessage(
      "Transfer to Wallet",
    ),
    "transferring": MessageLookupByLibrary.simpleMessage("Transferring..."),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "only effective in administrator mode",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("Turn Off"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Turn On"),
    "twoColumns": MessageLookupByLibrary.simpleMessage("Two columns"),
    "unableToUpdateCurrentProfileDesc": MessageLookupByLibrary.simpleMessage(
      "unable to update current profile",
    ),
    "undo": MessageLookupByLibrary.simpleMessage("undo"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Unified delay"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "Remove extra delays such as handshaking",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Unknown network error",
    ),
    "unnamed": MessageLookupByLibrary.simpleMessage("Unnamed"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "updateCheckAllServersUnavailable": MessageLookupByLibrary.simpleMessage(
      "All configured update servers are unavailable",
    ),
    "updateCheckCurrentVersion": m33,
    "updateCheckForceUpdate": m34,
    "updateCheckMustUpdate": MessageLookupByLibrary.simpleMessage(
      "Must Update",
    ),
    "updateCheckNewVersionFound": m35,
    "updateCheckNoServerUrlsConfigured": MessageLookupByLibrary.simpleMessage(
      "No update server URLs configured, please check configuration",
    ),
    "updateCheckReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "Release Notes:",
    ),
    "updateCheckServerError": m36,
    "updateCheckServerTemporarilyUnavailable":
        MessageLookupByLibrary.simpleMessage(
          "Server temporarily unavailable, please try again later",
        ),
    "updateCheckServerUrlNotConfigured": MessageLookupByLibrary.simpleMessage(
      "Update server URL not configured, please check configuration",
    ),
    "updateCheckUpdateLater": MessageLookupByLibrary.simpleMessage(
      "Update Later",
    ),
    "updateCheckUpdateNow": MessageLookupByLibrary.simpleMessage("Update Now"),
    "upload": MessageLookupByLibrary.simpleMessage("Upload"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "Obtain profile through URL",
    ),
    "urlTip": m37,
    "useHosts": MessageLookupByLibrary.simpleMessage("Use hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("Use system hosts"),
    "userCenter": MessageLookupByLibrary.simpleMessage("User Center"),
    "value": MessageLookupByLibrary.simpleMessage("Value"),
    "verificationCode": MessageLookupByLibrary.simpleMessage(
      "Verification Code",
    ),
    "verificationCode6Digits": MessageLookupByLibrary.simpleMessage(
      "Verification code should be 6 digits",
    ),
    "verificationCodeSent": MessageLookupByLibrary.simpleMessage(
      "Verification code has been sent to your email, please check",
    ),
    "verificationCodeSentCheckEmail": MessageLookupByLibrary.simpleMessage(
      "Verification code sent, please check your email",
    ),
    "verificationCodeSentTo": m38,
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Vibrant"),
    "view": MessageLookupByLibrary.simpleMessage("View"),
    "viewHistory": MessageLookupByLibrary.simpleMessage("View History"),
    "visitWebVersion": MessageLookupByLibrary.simpleMessage(
      "Please visit web version to withdraw",
    ),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN configuration change detected",
    ),
    "vpnDesc": MessageLookupByLibrary.simpleMessage(
      "Modify VPN related settings",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Auto routes all system traffic through VpnService",
    ),
    "vpnSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Attach HTTP proxy to VpnService",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Changes take effect after restarting the VPN",
    ),
    "walletBalance": MessageLookupByLibrary.simpleMessage("Balance"),
    "walletDetails": MessageLookupByLibrary.simpleMessage("Wallet Details"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV configuration",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Whitelist mode"),
    "withdraw": MessageLookupByLibrary.simpleMessage("Withdraw"),
    "withdrawAccount": MessageLookupByLibrary.simpleMessage(
      "Withdrawal Account",
    ),
    "withdrawClosed": MessageLookupByLibrary.simpleMessage(
      "Withdrawal is currently unavailable",
    ),
    "withdrawCommission": MessageLookupByLibrary.simpleMessage(
      "Withdraw Commission",
    ),
    "withdrawFailed": m39,
    "withdrawMethod": MessageLookupByLibrary.simpleMessage("Withdrawal Method"),
    "withdrawSubmitted": MessageLookupByLibrary.simpleMessage(
      "Withdrawal request submitted",
    ),
    "withdrawableAmount": m40,
    "withdrawalAvailable": MessageLookupByLibrary.simpleMessage(
      "Available commission can be withdrawn",
    ),
    "withdrawing": MessageLookupByLibrary.simpleMessage("Submitting..."),
    "xboard": MessageLookupByLibrary.simpleMessage("Home"),
    "xboard24HourCustomerService": MessageLookupByLibrary.simpleMessage(
      "24-hour customer service support",
    ),
    "xboardAccountBalance": MessageLookupByLibrary.simpleMessage(
      "Account balance",
    ),
    "xboardAccountInfo": MessageLookupByLibrary.simpleMessage(
      "Account Information",
    ),
    "xboardAccountSettings": MessageLookupByLibrary.simpleMessage(
      "Account Settings",
    ),
    "xboardActive": MessageLookupByLibrary.simpleMessage("Active"),
    "xboardAddLinkToConfig": MessageLookupByLibrary.simpleMessage(
      "Add this subscription link to your configuration",
    ),
    "xboardAddingProfile": MessageLookupByLibrary.simpleMessage(
      "Adding profile",
    ),
    "xboardAddingToConfigList": MessageLookupByLibrary.simpleMessage(
      "Adding to configuration list",
    ),
    "xboardAfterPurchasingPlan": MessageLookupByLibrary.simpleMessage(
      "After purchasing a plan, you will enjoy:",
    ),
    "xboardAllDownloadTasksFailed": MessageLookupByLibrary.simpleMessage(
      "All download tasks failed",
    ),
    "xboardAllOrders": MessageLookupByLibrary.simpleMessage("All"),
    "xboardAllowLan": MessageLookupByLibrary.simpleMessage("Share to LAN"),
    "xboardApiUrlNotConfigured": MessageLookupByLibrary.simpleMessage(
      "API URL not configured",
    ),
    "xboardAppearance": MessageLookupByLibrary.simpleMessage("Appearance"),
    "xboardAutoCheckEvery5Seconds": MessageLookupByLibrary.simpleMessage(
      "System checks every 5 seconds, will redirect automatically after payment",
    ),
    "xboardAutoCheckPaymentDesc": MessageLookupByLibrary.simpleMessage(
      "System checks every 5 seconds, auto-redirects on payment completion",
    ),
    "xboardAutoDetectPaymentStatus": MessageLookupByLibrary.simpleMessage(
      "Auto-detecting payment status",
    ),
    "xboardAutoOpeningPayment": MessageLookupByLibrary.simpleMessage(
      "Auto-opening payment page, please return to app after payment",
    ),
    "xboardAutoOpeningPaymentPage": MessageLookupByLibrary.simpleMessage(
      "Auto-opening payment page, please return to app after payment",
    ),
    "xboardAutoTesting": MessageLookupByLibrary.simpleMessage("Auto testing"),
    "xboardAvailableCommission": MessageLookupByLibrary.simpleMessage(
      "Available Commission",
    ),
    "xboardBack": MessageLookupByLibrary.simpleMessage("Back"),
    "xboardBalanceAmount": MessageLookupByLibrary.simpleMessage(
      "Balance Payment",
    ),
    "xboardBalancePaymentFailed": MessageLookupByLibrary.simpleMessage(
      "Balance payment failed",
    ),
    "xboardBasePrice": MessageLookupByLibrary.simpleMessage("Base price"),
    "xboardBrowsePlans": MessageLookupByLibrary.simpleMessage(
      "Browse available plans",
    ),
    "xboardBrowsePlansButton": MessageLookupByLibrary.simpleMessage(
      "Browse Plans",
    ),
    "xboardBrowserNotOpenedNote": MessageLookupByLibrary.simpleMessage(
      "Tip: If browser doesn\'t open automatically, click \"Reopen\" or copy link manually",
    ),
    "xboardBrowserNotOpenedTip": MessageLookupByLibrary.simpleMessage(
      "If browser doesn\'t open automatically, click \\\"Reopen\\\" or copy link manually",
    ),
    "xboardBuyMoreTrafficOrUpgrade": MessageLookupByLibrary.simpleMessage(
      "Please buy more traffic or upgrade plan",
    ),
    "xboardBuyNow": MessageLookupByLibrary.simpleMessage("Buy Now"),
    "xboardBuyoutPlan": MessageLookupByLibrary.simpleMessage("Buyout plan"),
    "xboardBypassDomain": MessageLookupByLibrary.simpleMessage(
      "Bypass Domain/IP",
    ),
    "xboardBypassDomainCount": m41,
    "xboardBypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Add domains and IPs for direct connection",
    ),
    "xboardCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "xboardCancelFailed": MessageLookupByLibrary.simpleMessage("Cancel failed"),
    "xboardCancelImport": MessageLookupByLibrary.simpleMessage("Cancel import"),
    "xboardCancelOrder": MessageLookupByLibrary.simpleMessage("Cancel Order"),
    "xboardCancelOrderConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to cancel this order?",
    ),
    "xboardCancelPayment": MessageLookupByLibrary.simpleMessage(
      "Cancel Payment",
    ),
    "xboardCancelledOrders": MessageLookupByLibrary.simpleMessage("Cancelled"),
    "xboardCannotLaunchBrowser": MessageLookupByLibrary.simpleMessage(
      "Cannot launch external browser",
    ),
    "xboardCannotOpenPaymentLink": MessageLookupByLibrary.simpleMessage(
      "Cannot open payment link",
    ),
    "xboardCannotOpenPaymentUrl": MessageLookupByLibrary.simpleMessage(
      "Cannot open payment link",
    ),
    "xboardChangePassword": MessageLookupByLibrary.simpleMessage(
      "Change Password",
    ),
    "xboardChanging": MessageLookupByLibrary.simpleMessage("Changing..."),
    "xboardCheckPaymentFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to check payment status",
    ),
    "xboardCheckPaymentStatusError": m42,
    "xboardCheckStatus": MessageLookupByLibrary.simpleMessage("Check Status"),
    "xboardChecking": MessageLookupByLibrary.simpleMessage("Checking..."),
    "xboardCleaningOldConfig": MessageLookupByLibrary.simpleMessage(
      "Cleaning old configuration",
    ),
    "xboardCleaningPendingOrders": MessageLookupByLibrary.simpleMessage(
      "Cleaning up previous pending orders...",
    ),
    "xboardClearError": MessageLookupByLibrary.simpleMessage("Clear error"),
    "xboardClearOldOrders": MessageLookupByLibrary.simpleMessage(
      "Clear old orders",
    ),
    "xboardClickToCopy": MessageLookupByLibrary.simpleMessage("Click to copy"),
    "xboardClickToSetupNodes": MessageLookupByLibrary.simpleMessage(
      "Click to setup nodes",
    ),
    "xboardClose": MessageLookupByLibrary.simpleMessage("Close"),
    "xboardCloseTicket": MessageLookupByLibrary.simpleMessage("Close Ticket"),
    "xboardCoreLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to load config, core could not parse nodes",
    ),
    "xboardCloseTicketConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to close this ticket? You won\'t be able to reply after closing.",
    ),
    "xboardClosed": MessageLookupByLibrary.simpleMessage("Closed"),
    "xboardCodeCopied": MessageLookupByLibrary.simpleMessage(
      "Code copied to clipboard",
    ),
    "xboardComingSoon": MessageLookupByLibrary.simpleMessage("Coming soon"),
    "xboardCommissionBalance": MessageLookupByLibrary.simpleMessage(
      "Commission Balance",
    ),
    "xboardCommissionRate": MessageLookupByLibrary.simpleMessage(
      "Commission Rate",
    ),
    "xboardCommissionStatusCompleted": MessageLookupByLibrary.simpleMessage(
      "Distributed",
    ),
    "xboardCommissionStatusNone": MessageLookupByLibrary.simpleMessage(
      "No Commission",
    ),
    "xboardCommissionStatusPending": MessageLookupByLibrary.simpleMessage(
      "Pending Confirmation",
    ),
    "xboardCommissionStatusProcessing": MessageLookupByLibrary.simpleMessage(
      "Processing",
    ),
    "xboardCompletePaymentInBrowser": MessageLookupByLibrary.simpleMessage(
      "2. Please complete payment in your browser",
    ),
    "xboardCompletedOrders": MessageLookupByLibrary.simpleMessage("Completed"),
    "xboardConfigDownloadError": MessageLookupByLibrary.simpleMessage(
      "Failed to download configuration",
    ),
    "xboardConfigDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Configuration download failed, please check subscription link",
    ),
    "xboardConfigDownloadFailedBadRequest": MessageLookupByLibrary.simpleMessage(
      "Configuration download failed: HTTP request header format error, please try again later",
    ),
    "xboardConfigDownloadFailedCheckLink": MessageLookupByLibrary.simpleMessage(
      "Configuration download failed, please check if the subscription link is correct",
    ),
    "xboardConfigDownloadFailedInvalidRequest":
        MessageLookupByLibrary.simpleMessage(
          "Configuration download failed: Invalid request format, please try again later",
        ),
    "xboardConfigFormatError": MessageLookupByLibrary.simpleMessage(
      "Configuration format error, please contact service provider",
    ),
    "xboardConfigFormatInvalid": MessageLookupByLibrary.simpleMessage(
      "Configuration file format error",
    ),
    "xboardConfigImportFailed": MessageLookupByLibrary.simpleMessage(
      "Configuration import failed",
    ),
    "xboardConfigImportSuccess": MessageLookupByLibrary.simpleMessage(
      "Configuration imported successfully",
    ),
    "xboardConfigImportedSuccessDetail": MessageLookupByLibrary.simpleMessage(
      "Configuration has been successfully imported and added to the configuration list",
    ),
    "xboardConfigSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Configuration save failed, please check storage space",
    ),
    "xboardConfigSaveFailedCheckStorage": MessageLookupByLibrary.simpleMessage(
      "Failed to save configuration, please check storage space",
    ),
    "xboardConfigValidationFailed": MessageLookupByLibrary.simpleMessage(
      "Configuration format validation failed, please contact service provider to check configuration format",
    ),
    "xboardConfigurationError": MessageLookupByLibrary.simpleMessage(
      "Configuration error",
    ),
    "xboardConfirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "xboardConfirmAction": MessageLookupByLibrary.simpleMessage("Confirm"),
    "xboardConfirmAndPay": MessageLookupByLibrary.simpleMessage(
      "Confirm & Pay",
    ),
    "xboardConfirmOrder": MessageLookupByLibrary.simpleMessage("Confirm Order"),
    "xboardConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "Confirm Password",
    ),
    "xboardConfirmPurchase": MessageLookupByLibrary.simpleMessage(
      "Confirm purchase",
    ),
    "xboardCongratulationsSubscriptionActivated":
        MessageLookupByLibrary.simpleMessage(
          "Congratulations! Your subscription has been successfully purchased and activated",
        ),
    "xboardConnectGlobalQualityNodes": MessageLookupByLibrary.simpleMessage(
      "Connect to global quality nodes",
    ),
    "xboardConnected": MessageLookupByLibrary.simpleMessage("Connected"),
    "xboardConnectionTimeout": MessageLookupByLibrary.simpleMessage(
      "Connection timeout, please check network connection",
    ),
    "xboardContinuePurchase": MessageLookupByLibrary.simpleMessage(
      "Continue Purchase",
    ),
    "xboardContinueToPayment": MessageLookupByLibrary.simpleMessage(
      "Continue to Payment",
    ),
    "xboardCopied": MessageLookupByLibrary.simpleMessage("Copied"),
    "xboardCopyCode": MessageLookupByLibrary.simpleMessage("Copy Code"),
    "xboardCopyFailed": MessageLookupByLibrary.simpleMessage("Copy failed"),
    "xboardCopyFailedError": m43,
    "xboardCopyLink": MessageLookupByLibrary.simpleMessage("Copy Link"),
    "xboardCopyPaymentLink": MessageLookupByLibrary.simpleMessage("Copy Link"),
    "xboardCopySubscriptionLinkAbove": MessageLookupByLibrary.simpleMessage(
      "Copy the subscription link above",
    ),
    "xboardCouponDiscount": MessageLookupByLibrary.simpleMessage(
      "Coupon discount",
    ),
    "xboardCouponExpired": MessageLookupByLibrary.simpleMessage(
      "Coupon expired",
    ),
    "xboardCouponNotYetActive": MessageLookupByLibrary.simpleMessage(
      "Coupon not yet active",
    ),
    "xboardCouponOptional": MessageLookupByLibrary.simpleMessage(
      "Coupon (optional)",
    ),
    "xboardCreateInviteCode": MessageLookupByLibrary.simpleMessage(
      "Create Code",
    ),
    "xboardCreateTicket": MessageLookupByLibrary.simpleMessage("Create Ticket"),
    "xboardCreateYourFirstTicket": MessageLookupByLibrary.simpleMessage(
      "Create your first ticket",
    ),
    "xboardCreatedAt": MessageLookupByLibrary.simpleMessage("Created At"),
    "xboardCreating": MessageLookupByLibrary.simpleMessage("Creating..."),
    "xboardCreatingOrder": MessageLookupByLibrary.simpleMessage(
      "Creating order",
    ),
    "xboardCreatingOrderPleaseWait": MessageLookupByLibrary.simpleMessage(
      "We are creating a new order for you, please wait",
    ),
    "xboardCurrentNode": MessageLookupByLibrary.simpleMessage("Current Node"),
    "xboardCurrentVersion": MessageLookupByLibrary.simpleMessage(
      "Current version",
    ),
    "xboardCustomCommissionRate": MessageLookupByLibrary.simpleMessage(
      "Custom Rate",
    ),
    "xboardDailyTraffic": MessageLookupByLibrary.simpleMessage("Daily Traffic"),
    "xboardDays": MessageLookupByLibrary.simpleMessage("days"),
    "xboardDaysAgo": MessageLookupByLibrary.simpleMessage("days ago"),
    "xboardDeductibleDuringPayment": MessageLookupByLibrary.simpleMessage(
      "Deductible during payment",
    ),
    "xboardDetail": MessageLookupByLibrary.simpleMessage("Detail"),
    "xboardDeviceLimitCount": m44,
    "xboardDevices": MessageLookupByLibrary.simpleMessage("devices"),
    "xboardDirectConnectionLabel": MessageLookupByLibrary.simpleMessage(
      "Direct",
    ),
    "xboardDisconnected": MessageLookupByLibrary.simpleMessage("Disconnected"),
    "xboardDiscount": MessageLookupByLibrary.simpleMessage("Discount"),
    "xboardDiscountAmount": MessageLookupByLibrary.simpleMessage(
      "Discount Amount",
    ),
    "xboardDiscounted": MessageLookupByLibrary.simpleMessage("Discounted"),
    "xboardDomainNotReady": MessageLookupByLibrary.simpleMessage(
      "Domain status not ready",
    ),
    "xboardDomainUnavailable": MessageLookupByLibrary.simpleMessage(
      "Domain unavailable",
    ),
    "xboardDownloadTimeout": MessageLookupByLibrary.simpleMessage(
      "Download timeout",
    ),
    "xboardDownloadTimeoutError": MessageLookupByLibrary.simpleMessage(
      "Download timeout",
    ),
    "xboardDownloadTrafficLabel": m45,
    "xboardDownloadingConfig": MessageLookupByLibrary.simpleMessage(
      "Downloading configuration file",
    ),
    "xboardDownloadingProfile": MessageLookupByLibrary.simpleMessage(
      "Downloading profile",
    ),
    "xboardEarnCommission": MessageLookupByLibrary.simpleMessage(
      "Earn commission by inviting",
    ),
    "xboardEmail": MessageLookupByLibrary.simpleMessage("Email"),
    "xboardEnableTun": MessageLookupByLibrary.simpleMessage("Enable TUN"),
    "xboardEnjoyFastNetworkExperience": MessageLookupByLibrary.simpleMessage(
      "Enjoy fast network experience",
    ),
    "xboardEnterCouponCode": MessageLookupByLibrary.simpleMessage(
      "Enter coupon code",
    ),
    "xboardEnterMessage": MessageLookupByLibrary.simpleMessage(
      "Please enter a message",
    ),
    "xboardEnterSubject": MessageLookupByLibrary.simpleMessage(
      "Please enter a subject",
    ),
    "xboardError": MessageLookupByLibrary.simpleMessage("Error"),
    "xboardExcellent": MessageLookupByLibrary.simpleMessage("Excellent"),
    "xboardExpirationTime": MessageLookupByLibrary.simpleMessage(
      "Expiration Time",
    ),
    "xboardExpired": MessageLookupByLibrary.simpleMessage("Expired"),
    "xboardExpiringSoon": MessageLookupByLibrary.simpleMessage("Expiring Soon"),
    "xboardExpiryTime": MessageLookupByLibrary.simpleMessage("Expiry time"),
    "xboardFailedToCheckPaymentStatus": MessageLookupByLibrary.simpleMessage(
      "Failed to check payment status",
    ),
    "xboardFailedToGetSubscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Failed to get subscription information",
    ),
    "xboardFailedToOpenPaymentLink": MessageLookupByLibrary.simpleMessage(
      "Failed to open payment link",
    ),
    "xboardFailedToOpenPaymentPage": MessageLookupByLibrary.simpleMessage(
      "Failed to open payment page",
    ),
    "xboardFair": MessageLookupByLibrary.simpleMessage("Fair"),
    "xboardFallbackModeUsed": MessageLookupByLibrary.simpleMessage(
      "Initialized using fallback mode",
    ),
    "xboardFirstStartTip": MessageLookupByLibrary.simpleMessage(
      "First startup may take some time\nPlease wait patiently...",
    ),
    "xboardFirstStartupNote": MessageLookupByLibrary.simpleMessage(
      "First startup may take some time\nPlease be patient...",
    ),
    "xboardFixedFee": MessageLookupByLibrary.simpleMessage("Fixed"),
    "xboardForceUpdate": MessageLookupByLibrary.simpleMessage("Force update"),
    "xboardForgotPassword": MessageLookupByLibrary.simpleMessage(
      "Forgot Password",
    ),
    "xboardGetSupport": MessageLookupByLibrary.simpleMessage(
      "Get help from support",
    ),
    "xboardGettingIP": MessageLookupByLibrary.simpleMessage("Getting..."),
    "xboardGlobalNodes": MessageLookupByLibrary.simpleMessage("Global nodes"),
    "xboardGoBack": MessageLookupByLibrary.simpleMessage("Go Back"),
    "xboardGoToPay": MessageLookupByLibrary.simpleMessage("Go to Pay"),
    "xboardGood": MessageLookupByLibrary.simpleMessage("Good"),
    "xboardGroup": MessageLookupByLibrary.simpleMessage("Group"),
    "xboardHalfYearPayment": MessageLookupByLibrary.simpleMessage(
      "Half-yearly",
    ),
    "xboardHalfYearlyPayment": MessageLookupByLibrary.simpleMessage(
      "Half-yearly",
    ),
    "xboardHandleLater": MessageLookupByLibrary.simpleMessage("Handle later"),
    "xboardHandlingFee": MessageLookupByLibrary.simpleMessage("Handling Fee"),
    "xboardHighPriority": MessageLookupByLibrary.simpleMessage("High"),
    "xboardHighSpeedNetwork": MessageLookupByLibrary.simpleMessage(
      "High-speed network",
    ),
    "xboardHome": MessageLookupByLibrary.simpleMessage("Home"),
    "xboardHoursAgo": MessageLookupByLibrary.simpleMessage("hours ago"),
    "xboardHttpRequestError": MessageLookupByLibrary.simpleMessage(
      "HTTP request failed",
    ),
    "xboardHttpRequestFailed": MessageLookupByLibrary.simpleMessage(
      "HTTP request failed",
    ),
    "xboardImportCancelled": MessageLookupByLibrary.simpleMessage(
      "Import cancelled",
    ),
    "xboardImportErrorDownload": MessageLookupByLibrary.simpleMessage(
      "Configuration download failed, please check subscription link",
    ),
    "xboardImportErrorNetwork": MessageLookupByLibrary.simpleMessage(
      "Network connection failed, please check network settings",
    ),
    "xboardImportErrorStorage": MessageLookupByLibrary.simpleMessage(
      "Failed to save configuration, please check storage space",
    ),
    "xboardImportErrorUnknown": MessageLookupByLibrary.simpleMessage(
      "Unknown error, please retry",
    ),
    "xboardImportErrorValidation": MessageLookupByLibrary.simpleMessage(
      "Configuration format error, please contact service provider",
    ),
    "xboardImportFailed": MessageLookupByLibrary.simpleMessage(
      "Configuration import failed",
    ),
    "xboardImportFailedAppConfigError": MessageLookupByLibrary.simpleMessage(
      "Import failed: Application configuration error, please try again later or restart the app",
    ),
    "xboardImportFailedRetryOrSupport": MessageLookupByLibrary.simpleMessage(
      "Import failed, please try again later or contact support",
    ),
    "xboardImportInProgress": MessageLookupByLibrary.simpleMessage(
      "Import in progress, please wait",
    ),
    "xboardImportStatusAdding": MessageLookupByLibrary.simpleMessage(
      "Adding to configuration list",
    ),
    "xboardImportStatusCleaning": MessageLookupByLibrary.simpleMessage(
      "Cleaning old configuration",
    ),
    "xboardImportStatusDownloading": MessageLookupByLibrary.simpleMessage(
      "Downloading configuration",
    ),
    "xboardImportStatusFailed": MessageLookupByLibrary.simpleMessage(
      "Import failed",
    ),
    "xboardImportStatusIdle": MessageLookupByLibrary.simpleMessage(
      "Preparing to import",
    ),
    "xboardImportStatusSuccess": MessageLookupByLibrary.simpleMessage(
      "Import successful",
    ),
    "xboardImportStatusValidating": MessageLookupByLibrary.simpleMessage(
      "Validating configuration",
    ),
    "xboardImportSuccess": MessageLookupByLibrary.simpleMessage(
      "Configuration imported successfully",
    ),
    "xboardImportingConfiguration": MessageLookupByLibrary.simpleMessage(
      "Importing configuration",
    ),
    "xboardImportingSubscription": MessageLookupByLibrary.simpleMessage(
      "Loading subscription...",
    ),
    "xboardInactive": MessageLookupByLibrary.simpleMessage("Inactive"),
    "xboardInitializationComplete": MessageLookupByLibrary.simpleMessage(
      "Initialization complete",
    ),
    "xboardInitializationFailed": MessageLookupByLibrary.simpleMessage(
      "Initialization Failed",
    ),
    "xboardInitializationTimeout": MessageLookupByLibrary.simpleMessage(
      "Initialization timeout",
    ),
    "xboardInitializing": MessageLookupByLibrary.simpleMessage("Initializing"),
    "xboardInsufficientBalance": MessageLookupByLibrary.simpleMessage(
      "Insufficient balance",
    ),
    "xboardInvalidCredentials": MessageLookupByLibrary.simpleMessage(
      "Invalid username or password",
    ),
    "xboardInvalidOrExpiredCoupon": MessageLookupByLibrary.simpleMessage(
      "Invalid or expired coupon code",
    ),
    "xboardInvalidResponseFormat": MessageLookupByLibrary.simpleMessage(
      "Invalid response format from server",
    ),
    "xboardInvite": MessageLookupByLibrary.simpleMessage("Invite"),
    "xboardInviteCode": MessageLookupByLibrary.simpleMessage("Invite Code"),
    "xboardInviteCodeCreated": MessageLookupByLibrary.simpleMessage(
      "Invite code created successfully",
    ),
    "xboardInviteCodes": MessageLookupByLibrary.simpleMessage("Invite Codes"),
    "xboardInviteFriends": MessageLookupByLibrary.simpleMessage(
      "Invite Friends",
    ),
    "xboardInviteSubtitle": MessageLookupByLibrary.simpleMessage(
      "Share your invite code and earn commission from referrals",
    ),
    "xboardInviteTitle": MessageLookupByLibrary.simpleMessage(
      "Invite Friends & Earn Commission",
    ),
    "xboardJustNow": MessageLookupByLibrary.simpleMessage("Just now"),
    "xboardKeepSubscriptionLinkSafe": MessageLookupByLibrary.simpleMessage(
      "Please keep your subscription link safe and don\'t share with others",
    ),
    "xboardLanSharing": MessageLookupByLibrary.simpleMessage(
      "LAN Proxy Sharing",
    ),
    "xboardLanSharingDesc": MessageLookupByLibrary.simpleMessage(
      "Allow LAN devices to use this proxy",
    ),
    "xboardLatencyAutoTesting": MessageLookupByLibrary.simpleMessage(
      "Auto Testing",
    ),
    "xboardLatencyExcellent": MessageLookupByLibrary.simpleMessage("Excellent"),
    "xboardLatencyExcellentDesc": MessageLookupByLibrary.simpleMessage(
      "Excellent network quality, suitable for all applications",
    ),
    "xboardLatencyFair": MessageLookupByLibrary.simpleMessage("Fair"),
    "xboardLatencyFairDesc": MessageLookupByLibrary.simpleMessage(
      "Fair network quality, usable for basic applications",
    ),
    "xboardLatencyGood": MessageLookupByLibrary.simpleMessage("Good"),
    "xboardLatencyGoodDesc": MessageLookupByLibrary.simpleMessage(
      "Good network quality, suitable for most applications",
    ),
    "xboardLatencyPoor": MessageLookupByLibrary.simpleMessage("Poor"),
    "xboardLatencyPoorDesc": MessageLookupByLibrary.simpleMessage(
      "Poor network quality, may affect experience",
    ),
    "xboardLatencyTesting": MessageLookupByLibrary.simpleMessage("Testing"),
    "xboardLatencyTimeout": MessageLookupByLibrary.simpleMessage("Timeout"),
    "xboardLatencyTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "Connection timeout, please check network",
    ),
    "xboardLatencyVeryPoor": MessageLookupByLibrary.simpleMessage("Very Poor"),
    "xboardLatencyVeryPoorDesc": MessageLookupByLibrary.simpleMessage(
      "Very poor network quality, recommend changing node",
    ),
    "xboardLater": MessageLookupByLibrary.simpleMessage("Later"),
    "xboardLinkCopied": MessageLookupByLibrary.simpleMessage(
      "Link copied to clipboard",
    ),
    "xboardLoadError": MessageLookupByLibrary.simpleMessage(
      "Failed to load data",
    ),
    "xboardLoadFailed": MessageLookupByLibrary.simpleMessage("Load Failed"),
    "xboardLoadingFailed": MessageLookupByLibrary.simpleMessage(
      "Loading failed",
    ),
    "xboardLoadingPaymentPage": MessageLookupByLibrary.simpleMessage(
      "Loading payment page",
    ),
    "xboardLocalIP": MessageLookupByLibrary.simpleMessage("Local IP"),
    "xboardLoggedIn": MessageLookupByLibrary.simpleMessage("Logged In"),
    "xboardLogin": MessageLookupByLibrary.simpleMessage("Login"),
    "xboardLoginExpired": MessageLookupByLibrary.simpleMessage(
      "Login expired, please login again",
    ),
    "xboardLoginFailed": MessageLookupByLibrary.simpleMessage("Login failed"),
    "xboardLoginSuccess": MessageLookupByLibrary.simpleMessage(
      "Login successful",
    ),
    "xboardLoginToViewSubscription": MessageLookupByLibrary.simpleMessage(
      "Please login to view subscription usage",
    ),
    "xboardLogout": MessageLookupByLibrary.simpleMessage("Logout"),
    "xboardLogoutConfirmContent": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to logout? You will need to re-enter your credentials.",
    ),
    "xboardLogoutConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Confirm Logout",
    ),
    "xboardLogoutFailed": MessageLookupByLibrary.simpleMessage("Logout failed"),
    "xboardLogoutSuccess": MessageLookupByLibrary.simpleMessage(
      "Successfully logged out",
    ),
    "xboardLowPriority": MessageLookupByLibrary.simpleMessage("Low"),
    "xboardLowestPrice": MessageLookupByLibrary.simpleMessage("Lowest Price"),
    "xboardMaxInviteCodesReached": MessageLookupByLibrary.simpleMessage(
      "Maximum 5 invite codes allowed",
    ),
    "xboardMediumPriority": MessageLookupByLibrary.simpleMessage("Medium"),
    "xboardMemberSince": MessageLookupByLibrary.simpleMessage("Member since"),
    "xboardMinutesAgo": MessageLookupByLibrary.simpleMessage("minutes ago"),
    "xboardMissingRequiredField": MessageLookupByLibrary.simpleMessage(
      "Missing required field",
    ),
    "xboardMonthlyPayment": MessageLookupByLibrary.simpleMessage("Monthly"),
    "xboardMonthlyPrice": MessageLookupByLibrary.simpleMessage("Monthly Price"),
    "xboardMonthlyRenewal": MessageLookupByLibrary.simpleMessage(
      "Monthly renewal",
    ),
    "xboardMonthsAgo": MessageLookupByLibrary.simpleMessage("months ago"),
    "xboardMultipleRetriesFailed": MessageLookupByLibrary.simpleMessage(
      "Still failed after multiple retries",
    ),
    "xboardMustUpdate": MessageLookupByLibrary.simpleMessage("Must update"),
    "xboardMyOrders": MessageLookupByLibrary.simpleMessage("My Orders"),
    "xboardNetworkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Network connection failed",
    ),
    "xboardNetworkConnectionFailed": MessageLookupByLibrary.simpleMessage(
      "Network connection failed, please check network settings",
    ),
    "xboardNetworkConnectionFailedCheckSettings":
        MessageLookupByLibrary.simpleMessage(
          "Network connection failed, please check network settings and retry",
        ),
    "xboardNetworkSettings": MessageLookupByLibrary.simpleMessage(
      "Network Settings",
    ),
    "xboardNeverExpire": MessageLookupByLibrary.simpleMessage("Never Expire"),
    "xboardNewPassword": MessageLookupByLibrary.simpleMessage("New Password"),
    "xboardNewVersionFound": MessageLookupByLibrary.simpleMessage(
      "New version found",
    ),
    "xboardNext": MessageLookupByLibrary.simpleMessage("Next"),
    "xboardNoAvailableNodes": MessageLookupByLibrary.simpleMessage(
      "No available nodes",
    ),
    "xboardNoAvailablePlan": MessageLookupByLibrary.simpleMessage(
      "No available plan",
    ),
    "xboardNoAvailablePlans": MessageLookupByLibrary.simpleMessage(
      "No available plans",
    ),
    "xboardNoAvailableSubscription": MessageLookupByLibrary.simpleMessage(
      "No available subscription",
    ),
    "xboardNoInternetConnection": MessageLookupByLibrary.simpleMessage(
      "No internet connection, please check network settings",
    ),
    "xboardNoInviteCodes": MessageLookupByLibrary.simpleMessage(
      "No invite codes yet",
    ),
    "xboardNoInviteCodesDesc": MessageLookupByLibrary.simpleMessage(
      "Create your first invite code to start earning commission",
    ),
    "xboardNoOrders": MessageLookupByLibrary.simpleMessage("No orders yet"),
    "xboardNoOrdersDesc": MessageLookupByLibrary.simpleMessage(
      "Your order history will appear here",
    ),
    "xboardNoPaymentMethodsAvailable": MessageLookupByLibrary.simpleMessage(
      "No payment methods available, please check your network or try again later",
    ),
    "xboardNoServerData": MessageLookupByLibrary.simpleMessage(
      "No server data available",
    ),
    "xboardNoSubscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "No subscription information",
    ),
    "xboardNoSubscriptionPlans": MessageLookupByLibrary.simpleMessage(
      "No subscription plans",
    ),
    "xboardNoTickets": MessageLookupByLibrary.simpleMessage("No tickets"),
    "xboardNoTicketsDesc": MessageLookupByLibrary.simpleMessage(
      "Create your first ticket to get support",
    ),
    "xboardNoTitle": MessageLookupByLibrary.simpleMessage("No Title"),
    "xboardNodeName": MessageLookupByLibrary.simpleMessage("Node Name"),
    "xboardNodesUpdated": MessageLookupByLibrary.simpleMessage(
      "Nodes updated successfully",
    ),
    "xboardNone": MessageLookupByLibrary.simpleMessage("None"),
    "xboardNotLoggedIn": MessageLookupByLibrary.simpleMessage("Not Logged In"),
    "xboardNoticeDialogGotIt": MessageLookupByLibrary.simpleMessage("Got it"),
    "xboardNotificationUpdateError": MessageLookupByLibrary.simpleMessage(
      "Failed to update notification settings",
    ),
    "xboardNotificationUpdateSuccess": MessageLookupByLibrary.simpleMessage(
      "Notification settings updated",
    ),
    "xboardNotifications": MessageLookupByLibrary.simpleMessage(
      "Notifications",
    ),
    "xboardOffline": MessageLookupByLibrary.simpleMessage("offline"),
    "xboardOldPassword": MessageLookupByLibrary.simpleMessage(
      "Current Password",
    ),
    "xboardOneTimePayment": MessageLookupByLibrary.simpleMessage("One-time"),
    "xboardOnetimePayment": MessageLookupByLibrary.simpleMessage("One-time"),
    "xboardOnline": MessageLookupByLibrary.simpleMessage("online"),
    "xboardOpen": MessageLookupByLibrary.simpleMessage("Open"),
    "xboardOpenPaymentFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to open payment page",
    ),
    "xboardOpenPaymentLinkError": m46,
    "xboardOpenPaymentLinkFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to open payment link",
    ),
    "xboardOpenPaymentPageError": m47,
    "xboardOperationFailed": MessageLookupByLibrary.simpleMessage(
      "Operation failed",
    ),
    "xboardOperationFailedError": m48,
    "xboardOperationStep1": MessageLookupByLibrary.simpleMessage(
      "1. Payment page has been opened automatically",
    ),
    "xboardOperationStep2": MessageLookupByLibrary.simpleMessage(
      "2. Please complete payment in your browser",
    ),
    "xboardOperationStep3": MessageLookupByLibrary.simpleMessage(
      "3. Return to app after payment, system will detect automatically",
    ),
    "xboardOperationStep4": MessageLookupByLibrary.simpleMessage(
      "4. To reopen, click the \"Reopen\" button below",
    ),
    "xboardOperationTips": MessageLookupByLibrary.simpleMessage("Instructions"),
    "xboardOrderCancelled": MessageLookupByLibrary.simpleMessage(
      "Order cancelled successfully",
    ),
    "xboardOrderCreationFailed": MessageLookupByLibrary.simpleMessage(
      "Order creation failed",
    ),
    "xboardOrderDetails": MessageLookupByLibrary.simpleMessage("Order Details"),
    "xboardOrderHistory": MessageLookupByLibrary.simpleMessage("Order History"),
    "xboardOrderHistoryDesc": MessageLookupByLibrary.simpleMessage(
      "View and manage your order history",
    ),
    "xboardOrderInfo": MessageLookupByLibrary.simpleMessage(
      "Order Information",
    ),
    "xboardOrderInfoNotFound": MessageLookupByLibrary.simpleMessage(
      "Order information not found",
    ),
    "xboardOrderNotFound": MessageLookupByLibrary.simpleMessage(
      "Order not found",
    ),
    "xboardOrderNumber": MessageLookupByLibrary.simpleMessage("Order number"),
    "xboardOrderStatusCanceled": MessageLookupByLibrary.simpleMessage(
      "Canceled",
    ),
    "xboardOrderStatusCompleted": MessageLookupByLibrary.simpleMessage(
      "Completed",
    ),
    "xboardOrderStatusDiscounted": MessageLookupByLibrary.simpleMessage(
      "Discounted",
    ),
    "xboardOrderStatusPending": MessageLookupByLibrary.simpleMessage(
      "Pending Payment",
    ),
    "xboardOrderStatusProcessing": MessageLookupByLibrary.simpleMessage(
      "Processing",
    ),
    "xboardOrderSummary": MessageLookupByLibrary.simpleMessage("Order Summary"),
    "xboardPassword": MessageLookupByLibrary.simpleMessage("Password"),
    "xboardPasswordChangeError": MessageLookupByLibrary.simpleMessage(
      "Failed to change password",
    ),
    "xboardPasswordChangedSuccess": MessageLookupByLibrary.simpleMessage(
      "Password changed successfully",
    ),
    "xboardPasswordMinLength": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 8 characters",
    ),
    "xboardPay": MessageLookupByLibrary.simpleMessage("Pay"),
    "xboardPaymentCancelled": MessageLookupByLibrary.simpleMessage(
      "Payment cancelled",
    ),
    "xboardPaymentComplete": MessageLookupByLibrary.simpleMessage(
      "Payment Complete",
    ),
    "xboardPaymentCompleted": MessageLookupByLibrary.simpleMessage(
      "Payment completed!",
    ),
    "xboardPaymentDetails": MessageLookupByLibrary.simpleMessage(
      "Payment Details",
    ),
    "xboardPaymentFailed": MessageLookupByLibrary.simpleMessage(
      "Payment Failed",
    ),
    "xboardPaymentFailedBalanceError": MessageLookupByLibrary.simpleMessage(
      "Payment failed: balance payment unsuccessful",
    ),
    "xboardPaymentFailedEmptyResult": MessageLookupByLibrary.simpleMessage(
      "Payment failed: empty result returned",
    ),
    "xboardPaymentFailedInvalidData": MessageLookupByLibrary.simpleMessage(
      "Payment failed: invalid payment data received",
    ),
    "xboardPaymentFailedMessage": m49,
    "xboardPaymentGateway": MessageLookupByLibrary.simpleMessage(
      "Payment gateway",
    ),
    "xboardPaymentInfo": MessageLookupByLibrary.simpleMessage(
      "Payment information",
    ),
    "xboardPaymentInstructions1": MessageLookupByLibrary.simpleMessage(
      "1. Payment page has been opened automatically",
    ),
    "xboardPaymentInstructions2": MessageLookupByLibrary.simpleMessage(
      "2. Please complete payment in your browser",
    ),
    "xboardPaymentInstructions3": MessageLookupByLibrary.simpleMessage(
      "3. Return to app after payment, system will detect automatically",
    ),
    "xboardPaymentLink": MessageLookupByLibrary.simpleMessage("Payment link"),
    "xboardPaymentLinkCopied": MessageLookupByLibrary.simpleMessage(
      "Payment link copied to clipboard",
    ),
    "xboardPaymentLinkCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "Payment link copied to clipboard",
    ),
    "xboardPaymentMethod": MessageLookupByLibrary.simpleMessage(
      "Payment Method",
    ),
    "xboardPaymentMethodVerified": MessageLookupByLibrary.simpleMessage(
      "Payment method verified",
    ),
    "xboardPaymentMethodVerifiedPreparing":
        MessageLookupByLibrary.simpleMessage(
          "Payment method verified, preparing to redirect to payment page",
        ),
    "xboardPaymentPageAutoOpened": MessageLookupByLibrary.simpleMessage(
      "1. Payment page has been opened automatically",
    ),
    "xboardPaymentPageOpenedCompleteAndReturn":
        MessageLookupByLibrary.simpleMessage(
          "Payment page opened, please complete payment and return to app",
        ),
    "xboardPaymentPageOpenedCopyDesc": MessageLookupByLibrary.simpleMessage(
      "Payment page opened and link copied to clipboard. If not redirected automatically, please paste the link in your browser.",
    ),
    "xboardPaymentPageOpenedInBrowser": MessageLookupByLibrary.simpleMessage(
      "Payment page opened in browser, please return to app after payment",
    ),
    "xboardPaymentPageOpenedInBrowserNote":
        MessageLookupByLibrary.simpleMessage(
          "Payment page opened in browser, please return to app after payment",
        ),
    "xboardPaymentSuccess": MessageLookupByLibrary.simpleMessage(
      "Payment successful",
    ),
    "xboardPaymentSuccessful": MessageLookupByLibrary.simpleMessage(
      "🎉 Payment successful!",
    ),
    "xboardPaymentSummary": MessageLookupByLibrary.simpleMessage(
      "Payment Summary",
    ),
    "xboardPending": MessageLookupByLibrary.simpleMessage("Pending"),
    "xboardPendingCommission": MessageLookupByLibrary.simpleMessage(
      "Pending Commission",
    ),
    "xboardPendingOrders": MessageLookupByLibrary.simpleMessage("Pending"),
    "xboardPercentFee": MessageLookupByLibrary.simpleMessage("Percent"),
    "xboardPeriod": MessageLookupByLibrary.simpleMessage("Period"),
    "xboardPlanConflictMessage": MessageLookupByLibrary.simpleMessage(
      "You are purchasing a different subscription plan. The system will recycle the value of your current subscription with price adjustment (refund or supplement).",
    ),
    "xboardPlanConflictTitle": MessageLookupByLibrary.simpleMessage(
      "Subscription Plan Notice",
    ),
    "xboardPlanInfo": MessageLookupByLibrary.simpleMessage("Plan Information"),
    "xboardPlanNotFound": MessageLookupByLibrary.simpleMessage(
      "Plan not found",
    ),
    "xboardPlanPeriodHalfYearly": MessageLookupByLibrary.simpleMessage(
      "Half-yearly",
    ),
    "xboardPlanPeriodMonthly": MessageLookupByLibrary.simpleMessage("Monthly"),
    "xboardPlanPeriodOnetime": MessageLookupByLibrary.simpleMessage("One-time"),
    "xboardPlanPeriodQuarterly": MessageLookupByLibrary.simpleMessage(
      "Quarterly",
    ),
    "xboardPlanPeriodReset": MessageLookupByLibrary.simpleMessage(
      "Reset Traffic",
    ),
    "xboardPlanPeriodThreeYear": MessageLookupByLibrary.simpleMessage(
      "Three-year",
    ),
    "xboardPlanPeriodTwoYear": MessageLookupByLibrary.simpleMessage("Two-year"),
    "xboardPlanPeriodYearly": MessageLookupByLibrary.simpleMessage("Yearly"),
    "xboardPlanSummary": MessageLookupByLibrary.simpleMessage("Plan Summary"),
    "xboardPlanWithId": m50,
    "xboardPlans": MessageLookupByLibrary.simpleMessage("Plans"),
    "xboardPleaseLogin": MessageLookupByLibrary.simpleMessage(
      "Please login first",
    ),
    "xboardPleaseSelectPaymentPeriod": MessageLookupByLibrary.simpleMessage(
      "Please select payment period",
    ),
    "xboardPleaseTryLaterOrContactSupport":
        MessageLookupByLibrary.simpleMessage(
          "Please try again later or contact support",
        ),
    "xboardPoor": MessageLookupByLibrary.simpleMessage("Poor"),
    "xboardPreferences": MessageLookupByLibrary.simpleMessage("Preferences"),
    "xboardPreparingImport": MessageLookupByLibrary.simpleMessage(
      "Preparing to import configuration",
    ),
    "xboardPreparingImportStatus": MessageLookupByLibrary.simpleMessage(
      "Preparing import",
    ),
    "xboardPreparingPaymentPage": MessageLookupByLibrary.simpleMessage(
      "Preparing payment page, redirecting soon",
    ),
    "xboardPrevious": MessageLookupByLibrary.simpleMessage("Previous"),
    "xboardPriority": MessageLookupByLibrary.simpleMessage("Priority"),
    "xboardPriorityLabel": MessageLookupByLibrary.simpleMessage("Priority"),
    "xboardProcessing": MessageLookupByLibrary.simpleMessage("Processing..."),
    "xboardProcessingFee": MessageLookupByLibrary.simpleMessage(
      "Processing fee",
    ),
    "xboardProcessingOrders": MessageLookupByLibrary.simpleMessage(
      "Processing",
    ),
    "xboardProfessionalSupport": MessageLookupByLibrary.simpleMessage(
      "Professional support",
    ),
    "xboardProfile": MessageLookupByLibrary.simpleMessage("Profile"),
    "xboardProfileImportCancelTooltip": MessageLookupByLibrary.simpleMessage(
      "Cancel import",
    ),
    "xboardProfileImportClearError": MessageLookupByLibrary.simpleMessage(
      "Clear error",
    ),
    "xboardProfileImportCloseTooltip": MessageLookupByLibrary.simpleMessage(
      "Close",
    ),
    "xboardProfileImportConfirm": MessageLookupByLibrary.simpleMessage("OK"),
    "xboardProfileImportFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Configuration import failed",
    ),
    "xboardProfileImportInProgress": MessageLookupByLibrary.simpleMessage(
      "Importing configuration",
    ),
    "xboardProfileImportPreparing": MessageLookupByLibrary.simpleMessage(
      "Preparing to import configuration",
    ),
    "xboardProfileImportRetry": MessageLookupByLibrary.simpleMessage("Retry"),
    "xboardProfileImportSuccessDetail": MessageLookupByLibrary.simpleMessage(
      "Configuration has been successfully imported and added to the configuration list",
    ),
    "xboardProfileImportSuccessTitle": MessageLookupByLibrary.simpleMessage(
      "Configuration imported successfully",
    ),
    "xboardProtectNetworkPrivacy": MessageLookupByLibrary.simpleMessage(
      "Protect your network privacy",
    ),
    "xboardProxy": MessageLookupByLibrary.simpleMessage("Proxy"),
    "xboardProxyCommands": MessageLookupByLibrary.simpleMessage(
      "Set Proxy Commands",
    ),
    "xboardProxyConnectionLabel": m51,
    "xboardProxyInfo": MessageLookupByLibrary.simpleMessage(
      "Proxy Information",
    ),
    "xboardProxyMode": MessageLookupByLibrary.simpleMessage("Proxy Mode"),
    "xboardProxyModeDirectDescription": MessageLookupByLibrary.simpleMessage(
      "All traffic connects directly without proxy",
    ),
    "xboardProxyModeGlobalDescription": MessageLookupByLibrary.simpleMessage(
      "All traffic goes through proxy server",
    ),
    "xboardProxyModeRuleDescription": MessageLookupByLibrary.simpleMessage(
      "Automatically select direct or proxy based on rules",
    ),
    "xboardProxyPort": MessageLookupByLibrary.simpleMessage("Proxy Port"),
    "xboardPurchasePlan": MessageLookupByLibrary.simpleMessage("Purchase plan"),
    "xboardPurchasePlanPrompt": MessageLookupByLibrary.simpleMessage(
      "Please purchase a plan first",
    ),
    "xboardPurchaseSubscription": MessageLookupByLibrary.simpleMessage(
      "Purchase Plan",
    ),
    "xboardPurchaseSubscriptionToUse": MessageLookupByLibrary.simpleMessage(
      "Please purchase a subscription to use",
    ),
    "xboardPurchaseTraffic": MessageLookupByLibrary.simpleMessage(
      "Purchase traffic",
    ),
    "xboardQuarterlyPayment": MessageLookupByLibrary.simpleMessage("Quarterly"),
    "xboardQuickActions": MessageLookupByLibrary.simpleMessage("Quick Actions"),
    "xboardRecommended": MessageLookupByLibrary.simpleMessage("Recommended"),
    "xboardRefresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "xboardRefreshStatus": MessageLookupByLibrary.simpleMessage(
      "Refresh status",
    ),
    "xboardRefreshSubscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Refresh subscription info",
    ),
    "xboardRefreshSubscriptionSuccess": MessageLookupByLibrary.simpleMessage(
      "Subscription refreshed successfully",
    ),
    "xboardRefundAmount": MessageLookupByLibrary.simpleMessage("Refund Amount"),
    "xboardRegister": MessageLookupByLibrary.simpleMessage("Register"),
    "xboardRegisterFailed": MessageLookupByLibrary.simpleMessage(
      "Registration failed",
    ),
    "xboardRegisterSuccess": MessageLookupByLibrary.simpleMessage(
      "Registration successful! Redirecting to login page...",
    ),
    "xboardRegisteredUsers": MessageLookupByLibrary.simpleMessage(
      "Registered Users",
    ),
    "xboardReload": MessageLookupByLibrary.simpleMessage("Reload"),
    "xboardRelogin": MessageLookupByLibrary.simpleMessage("Login Again"),
    "xboardRemaining": MessageLookupByLibrary.simpleMessage("Remaining"),
    "xboardRemainingDaysCount": m52,
    "xboardRemainingDaysLabel": MessageLookupByLibrary.simpleMessage(
      "Days Remaining",
    ),
    "xboardRememberPassword": MessageLookupByLibrary.simpleMessage(
      "Remember Password",
    ),
    "xboardRemindExpire": MessageLookupByLibrary.simpleMessage(
      "Remind when plan expires",
    ),
    "xboardRemindTraffic": MessageLookupByLibrary.simpleMessage(
      "Remind when traffic is low",
    ),
    "xboardRenewPlan": MessageLookupByLibrary.simpleMessage("Renew plan"),
    "xboardRenewToContinue": MessageLookupByLibrary.simpleMessage(
      "Please renew to continue using",
    ),
    "xboardReopen": MessageLookupByLibrary.simpleMessage("Reopen"),
    "xboardReopenPayment": MessageLookupByLibrary.simpleMessage("Reopen"),
    "xboardReopenPaymentNote": MessageLookupByLibrary.simpleMessage(
      "To reopen, click the \"Reopen\" button below",
    ),
    "xboardReopenPaymentPageTip": MessageLookupByLibrary.simpleMessage(
      "To reopen, click the \\\"Reopen\\\" button below",
    ),
    "xboardReplaceOldConfig": MessageLookupByLibrary.simpleMessage(
      "Replacing old subscription configuration",
    ),
    "xboardReplacingProfile": MessageLookupByLibrary.simpleMessage(
      "Replacing profile",
    ),
    "xboardReplied": MessageLookupByLibrary.simpleMessage("Replied"),
    "xboardReply": MessageLookupByLibrary.simpleMessage("Reply"),
    "xboardReplyFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to send reply",
    ),
    "xboardReplySent": MessageLookupByLibrary.simpleMessage(
      "Reply sent successfully",
    ),
    "xboardResetConfirmDesc": MessageLookupByLibrary.simpleMessage(
      "This will generate a new subscription URL. The old URL will become invalid and you will need to re-import the subscription. Are you sure?",
    ),
    "xboardResetConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Reset Subscription",
    ),
    "xboardResetSubscription": MessageLookupByLibrary.simpleMessage(
      "Reset Subscription",
    ),
    "xboardResetSubscriptionDesc": MessageLookupByLibrary.simpleMessage(
      "This will generate a new subscription URL and invalidate the old one",
    ),
    "xboardResetSubscriptionError": MessageLookupByLibrary.simpleMessage(
      "Failed to reset subscription",
    ),
    "xboardResetSubscriptionSuccess": MessageLookupByLibrary.simpleMessage(
      "Subscription reset successfully. Please re-import.",
    ),
    "xboardResetTraffic": MessageLookupByLibrary.simpleMessage("Reset traffic"),
    "xboardResetTrafficDescription": MessageLookupByLibrary.simpleMessage(
      "Reset traffic usage",
    ),
    "xboardResetting": MessageLookupByLibrary.simpleMessage("Resetting..."),
    "xboardRetry": MessageLookupByLibrary.simpleMessage("Retry"),
    "xboardRetryAttemptFailed": m53,
    "xboardRetryGet": MessageLookupByLibrary.simpleMessage("Retry"),
    "xboardRetryLoadConfig": MessageLookupByLibrary.simpleMessage("Retry"),
    "xboardReturn": MessageLookupByLibrary.simpleMessage("Return"),
    "xboardReturnAfterPaymentAutoDetect": MessageLookupByLibrary.simpleMessage(
      "3. Return to app after payment, system will detect automatically",
    ),
    "xboardRunningTime": m54,
    "xboardSearchNode": MessageLookupByLibrary.simpleMessage("Search nodes"),
    "xboardSecureEncryption": MessageLookupByLibrary.simpleMessage(
      "Secure encryption",
    ),
    "xboardSecurity": MessageLookupByLibrary.simpleMessage("Security"),
    "xboardSelectPaymentMethod": MessageLookupByLibrary.simpleMessage(
      "Select payment method",
    ),
    "xboardSelectPaymentPeriod": MessageLookupByLibrary.simpleMessage(
      "Select payment period",
    ),
    "xboardSelectPeriod": MessageLookupByLibrary.simpleMessage(
      "Please select purchase period",
    ),
    "xboardSelectPriority": MessageLookupByLibrary.simpleMessage(
      "Select priority",
    ),
    "xboardSend": MessageLookupByLibrary.simpleMessage("Send"),
    "xboardSendVerificationCode": MessageLookupByLibrary.simpleMessage(
      "Send Verification Code",
    ),
    "xboardServerError": MessageLookupByLibrary.simpleMessage("Server error"),
    "xboardServerHost": MessageLookupByLibrary.simpleMessage("Server Host"),
    "xboardServerName": MessageLookupByLibrary.simpleMessage("Server Name"),
    "xboardServerOffline": MessageLookupByLibrary.simpleMessage("Unavailable"),
    "xboardServerOnline": MessageLookupByLibrary.simpleMessage("Available"),
    "xboardServerStatus": MessageLookupByLibrary.simpleMessage("Server Status"),
    "xboardServersOffline": MessageLookupByLibrary.simpleMessage(
      "servers offline",
    ),
    "xboardServersOnline": MessageLookupByLibrary.simpleMessage(
      "servers online",
    ),
    "xboardSettings": MessageLookupByLibrary.simpleMessage("Settings"),
    "xboardSettledCommission": MessageLookupByLibrary.simpleMessage(
      "Settled Commission",
    ),
    "xboardSetup": MessageLookupByLibrary.simpleMessage("Setup"),
    "xboardSixMonthCycle": MessageLookupByLibrary.simpleMessage(
      "6-month cycle",
    ),
    "xboardSkip": MessageLookupByLibrary.simpleMessage("Skip"),
    "xboardSpeedLimit": MessageLookupByLibrary.simpleMessage("Speed"),
    "xboardStartImportingSubscription": MessageLookupByLibrary.simpleMessage(
      "Starting subscription import",
    ),
    "xboardStartProxy": MessageLookupByLibrary.simpleMessage("Start Proxy"),
    "xboardStatusCheckFailed": MessageLookupByLibrary.simpleMessage(
      "Status check failed",
    ),
    "xboardStop": MessageLookupByLibrary.simpleMessage("Stop"),
    "xboardStopProxy": MessageLookupByLibrary.simpleMessage("Stop Proxy"),
    "xboardSubscription": MessageLookupByLibrary.simpleMessage("Subscription"),
    "xboardSubscriptionCopied": MessageLookupByLibrary.simpleMessage(
      "Subscription link copied to clipboard",
    ),
    "xboardSubscriptionDetails": MessageLookupByLibrary.simpleMessage(
      "Subscription Details",
    ),
    "xboardSubscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Subscription expired",
    ),
    "xboardSubscriptionHasExpired": MessageLookupByLibrary.simpleMessage(
      "Subscription has expired",
    ),
    "xboardSubscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Subscription information",
    ),
    "xboardSubscriptionLink": MessageLookupByLibrary.simpleMessage(
      "Subscription link",
    ),
    "xboardSubscriptionLinkCopied": MessageLookupByLibrary.simpleMessage(
      "Subscription link copied to clipboard",
    ),
    "xboardSubscriptionPurchase": MessageLookupByLibrary.simpleMessage(
      "Subscription purchase",
    ),
    "xboardSubscriptionStatus": MessageLookupByLibrary.simpleMessage(
      "Subscription status",
    ),
    "xboardSubtotal": MessageLookupByLibrary.simpleMessage("Subtotal"),
    "xboardSupportTickets": MessageLookupByLibrary.simpleMessage(
      "Support Tickets",
    ),
    "xboardSurplusAmount": MessageLookupByLibrary.simpleMessage(
      "Surplus Amount",
    ),
    "xboardSwitch": MessageLookupByLibrary.simpleMessage("Switch"),
    "xboardSwitchNode": MessageLookupByLibrary.simpleMessage("Switch Node"),
    "xboardSystemCommissionRate": MessageLookupByLibrary.simpleMessage(
      "System Rate",
    ),
    "xboardTapToConnect": MessageLookupByLibrary.simpleMessage(
      "Tap to connect",
    ),
    "xboardTapToCopy": MessageLookupByLibrary.simpleMessage("Tap to copy"),
    "xboardTaskCancelled": MessageLookupByLibrary.simpleMessage(
      "Task cancelled",
    ),
    "xboardTestAllNodes": MessageLookupByLibrary.simpleMessage(
      "Test all nodes",
    ),
    "xboardTestComplete": MessageLookupByLibrary.simpleMessage("Test complete"),
    "xboardTesting": MessageLookupByLibrary.simpleMessage("Testing"),
    "xboardThirtySixMonthCycle": MessageLookupByLibrary.simpleMessage(
      "36-month cycle",
    ),
    "xboardThreeMonthCycle": MessageLookupByLibrary.simpleMessage(
      "3-month cycle",
    ),
    "xboardThreeYearPayment": MessageLookupByLibrary.simpleMessage(
      "Three-year",
    ),
    "xboardTicketClosed": MessageLookupByLibrary.simpleMessage("Ticket closed"),
    "xboardTicketCreateFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to create ticket",
    ),
    "xboardTicketCreated": MessageLookupByLibrary.simpleMessage(
      "Ticket created successfully",
    ),
    "xboardTicketDetail": MessageLookupByLibrary.simpleMessage(
      "Ticket Details",
    ),
    "xboardTicketMessage": MessageLookupByLibrary.simpleMessage("Message"),
    "xboardTicketStatus": MessageLookupByLibrary.simpleMessage("Ticket Status"),
    "xboardTicketStatusClosed": MessageLookupByLibrary.simpleMessage("Closed"),
    "xboardTicketStatusPending": MessageLookupByLibrary.simpleMessage(
      "Pending",
    ),
    "xboardTicketSubject": MessageLookupByLibrary.simpleMessage("Subject"),
    "xboardTickets": MessageLookupByLibrary.simpleMessage("Tickets"),
    "xboardTimeInfo": MessageLookupByLibrary.simpleMessage("Time Information"),
    "xboardTimeout": MessageLookupByLibrary.simpleMessage("Timeout"),
    "xboardToday": MessageLookupByLibrary.simpleMessage("Today"),
    "xboardTokenExpiredContent": MessageLookupByLibrary.simpleMessage(
      "Your login session has expired. Please login again to continue.",
    ),
    "xboardTokenExpiredTitle": MessageLookupByLibrary.simpleMessage(
      "Login Expired",
    ),
    "xboardTomorrow": MessageLookupByLibrary.simpleMessage("Tomorrow"),
    "xboardTotal": MessageLookupByLibrary.simpleMessage("Total"),
    "xboardTotalAmount": MessageLookupByLibrary.simpleMessage("Total Amount"),
    "xboardTradeNo": MessageLookupByLibrary.simpleMessage("Trade No"),
    "xboardTraffic": MessageLookupByLibrary.simpleMessage("Traffic"),
    "xboardTrafficExhausted": MessageLookupByLibrary.simpleMessage(
      "Traffic Exhausted",
    ),
    "xboardTrafficHistory": MessageLookupByLibrary.simpleMessage(
      "Traffic History",
    ),
    "xboardTrafficHistoryTitle": MessageLookupByLibrary.simpleMessage(
      "Traffic Usage History",
    ),
    "xboardTrafficNoData": MessageLookupByLibrary.simpleMessage(
      "No traffic data available",
    ),
    "xboardTrafficTotal": MessageLookupByLibrary.simpleMessage("Total"),
    "xboardTrafficUsage": MessageLookupByLibrary.simpleMessage("Traffic Usage"),
    "xboardTrafficUsedUp": MessageLookupByLibrary.simpleMessage(
      "Traffic used up",
    ),
    "xboardTunEnabled": MessageLookupByLibrary.simpleMessage("TUN enabled"),
    "xboardTunFeatureFullTraffic": MessageLookupByLibrary.simpleMessage(
      "Full Traffic Proxy",
    ),
    "xboardTunFeatureFullTrafficDesc": MessageLookupByLibrary.simpleMessage(
      "Captures network traffic from all apps without separate configuration",
    ),
    "xboardTunFeaturePerformance": MessageLookupByLibrary.simpleMessage(
      "Performance Optimization",
    ),
    "xboardTunFeaturePerformanceDesc": MessageLookupByLibrary.simpleMessage(
      "Reduces proxy layers and improves network access speed",
    ),
    "xboardTunFeatureTransparent": MessageLookupByLibrary.simpleMessage(
      "Transparent Proxy",
    ),
    "xboardTunFeatureTransparentDesc": MessageLookupByLibrary.simpleMessage(
      "App-agnostic proxy mode with better compatibility",
    ),
    "xboardTunLater": MessageLookupByLibrary.simpleMessage("Later"),
    "xboardTunModeDescription": MessageLookupByLibrary.simpleMessage(
      "TUN mode is an advanced network proxy technology that enables more complete traffic proxying through a virtual network interface.",
    ),
    "xboardTunModeTitle": MessageLookupByLibrary.simpleMessage("TUN Mode"),
    "xboardTunRecommendGlobal": MessageLookupByLibrary.simpleMessage(
      "• Backup: Global + TUN (Use when rule mode has issues)",
    ),
    "xboardTunRecommendRule": MessageLookupByLibrary.simpleMessage(
      "• Daily use: Rule + TUN (Smart routing, best performance)",
    ),
    "xboardTunRecommendations": MessageLookupByLibrary.simpleMessage(
      "Recommended Usage",
    ),
    "xboardTwelveMonthCycle": MessageLookupByLibrary.simpleMessage(
      "12-month cycle",
    ),
    "xboardTwentyFourMonthCycle": MessageLookupByLibrary.simpleMessage(
      "24-month cycle",
    ),
    "xboardTwoYearPayment": MessageLookupByLibrary.simpleMessage("Two-year"),
    "xboardUnauthorizedAccess": MessageLookupByLibrary.simpleMessage(
      "Unauthorized access, please login first",
    ),
    "xboardUnknownErrorRetry": MessageLookupByLibrary.simpleMessage(
      "Unknown error, please retry",
    ),
    "xboardUnknownPriority": MessageLookupByLibrary.simpleMessage("Unknown"),
    "xboardUnknownUser": MessageLookupByLibrary.simpleMessage("Unknown User"),
    "xboardUnlimited": MessageLookupByLibrary.simpleMessage("Unlimited"),
    "xboardUnlimitedDevices": MessageLookupByLibrary.simpleMessage(
      "Unlimited devices",
    ),
    "xboardUnlimitedTime": MessageLookupByLibrary.simpleMessage("Unlimited"),
    "xboardUnselected": MessageLookupByLibrary.simpleMessage("Unselected"),
    "xboardUnsupportedCouponType": MessageLookupByLibrary.simpleMessage(
      "Unsupported coupon type",
    ),
    "xboardUpdateContent": MessageLookupByLibrary.simpleMessage(
      "Update content:",
    ),
    "xboardUpdateLater": MessageLookupByLibrary.simpleMessage("Update Later"),
    "xboardUpdateNodes": MessageLookupByLibrary.simpleMessage("Update nodes"),
    "xboardUpdateNow": MessageLookupByLibrary.simpleMessage("Update Now"),
    "xboardUpdateSubscriptionRegularly": MessageLookupByLibrary.simpleMessage(
      "Update subscription regularly to get latest nodes",
    ),
    "xboardUploadTrafficLabel": m55,
    "xboardUsageInstructions": MessageLookupByLibrary.simpleMessage(
      "Usage instructions",
    ),
    "xboardUsed": MessageLookupByLibrary.simpleMessage("Used"),
    "xboardUsedTraffic": MessageLookupByLibrary.simpleMessage("Used"),
    "xboardUserSpecificRate": MessageLookupByLibrary.simpleMessage(
      "User-specific",
    ),
    "xboardUsingFallbackMode": MessageLookupByLibrary.simpleMessage(
      "Using fallback mode",
    ),
    "xboardValidatingConfigFormat": MessageLookupByLibrary.simpleMessage(
      "Validating configuration format",
    ),
    "xboardValidatingProfile": MessageLookupByLibrary.simpleMessage(
      "Validating profile",
    ),
    "xboardValidationFailed": MessageLookupByLibrary.simpleMessage(
      "Validation failed",
    ),
    "xboardValidityPeriod": MessageLookupByLibrary.simpleMessage("Expires"),
    "xboardVerify": MessageLookupByLibrary.simpleMessage("Verify"),
    "xboardVeryPoor": MessageLookupByLibrary.simpleMessage("Very poor"),
    "xboardViewChart": MessageLookupByLibrary.simpleMessage("View Chart"),
    "xboardViewList": MessageLookupByLibrary.simpleMessage("View List"),
    "xboardViewOrders": MessageLookupByLibrary.simpleMessage(
      "View order history",
    ),
    "xboardWaitingForPayment": MessageLookupByLibrary.simpleMessage(
      "Waiting for payment...",
    ),
    "xboardWaitingPaymentCompletion": MessageLookupByLibrary.simpleMessage(
      "Waiting for payment completion",
    ),
    "xboardWeeks": MessageLookupByLibrary.simpleMessage("weeks"),
    "xboardWeeksAgo": MessageLookupByLibrary.simpleMessage("weeks ago"),
    "xboardWithdrawTransferComingSoon": MessageLookupByLibrary.simpleMessage(
      "Withdrawal and transfer features coming soon",
    ),
    "xboardYearlyPayment": MessageLookupByLibrary.simpleMessage("Yearly"),
    "xboardYearsAgo": MessageLookupByLibrary.simpleMessage("years ago"),
    "xboardYesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "years": MessageLookupByLibrary.simpleMessage("Years"),
    "yearsAgo": m56,
    "zh_CN": MessageLookupByLibrary.simpleMessage("Simplified Chinese"),
  };
}
