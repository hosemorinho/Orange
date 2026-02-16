import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/leaf/services/mmdb_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' hide context;

@immutable
class GeoItem {
  final String label;
  final String fileName;

  const GeoItem({required this.label, required this.fileName});
}

class ResourcesView extends StatelessWidget {
  const ResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Leaf mode: only Country.mmdb is needed for rule-based routing
    const geoItems = <GeoItem>[
      GeoItem(label: 'Country MMDB', fileName: 'Country.mmdb'),
    ];

    return CommonScaffold(
      title: appLocalizations.resources,
      body: ListView.separated(
        itemBuilder: (_, index) {
          final geoItem = geoItems[index];
          return GeoDataListItem(geoItem: geoItem);
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(height: 0);
        },
        itemCount: geoItems.length,
      ),
    );
  }
}

class GeoDataListItem extends StatefulWidget {
  final GeoItem geoItem;

  const GeoDataListItem({super.key, required this.geoItem});

  @override
  State<GeoDataListItem> createState() => _GeoDataListItemState();
}

class _GeoDataListItemState extends State<GeoDataListItem> {
  final isUpdating = ValueNotifier<bool>(false);

  GeoItem get geoItem => widget.geoItem;

  Future<FileInfo> _getGeoFileLastModified(String fileName) async {
    // For leaf, Country.mmdb is in the leaf home directory
    String homePath;
    if (fileName == 'Country.mmdb') {
      homePath = await appPath.homeDirPath;
    } else {
      homePath = await appPath.homeDirPath;
    }
    final file = File(join(homePath, fileName));
    if (!await file.exists()) {
      return FileInfo(size: 0, lastModified: DateTime.now());
    }
    final lastModified = await file.lastModified();
    final size = await file.length();
    return FileInfo(size: size, lastModified: lastModified);
  }

  Widget _buildSubtitle() {
    // For leaf, Country.mmdb has a fixed source URL (no editing needed)
    const url =
        'https://github.com/Loyalsoldier/geoip/releases/latest/download/Country.mmdb';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        FutureBuilder<FileInfo>(
          future: _getGeoFileLastModified(geoItem.fileName),
          builder: (_, snapshot) {
            final height = globalState.measure.bodyMediumHeight;
            return SizedBox(
              height: height,
              child: snapshot.data == null
                  ? SizedBox(width: height, height: height)
                  : Text(
                      snapshot.data!.desc,
                      style: context.textTheme.bodyMedium,
                    ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(url, style: context.textTheme.bodyMedium?.toLight),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              child: ValueListenableBuilder(
                valueListenable: isUpdating,
                builder: (_, isUpdating, _) {
                  return isUpdating
                      ? SizedBox(
                          height: 30,
                          width: 30,
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : CommonChip(
                          avatar: const Icon(Icons.sync),
                          label: appLocalizations.sync,
                          onPressed: () {
                            _handleUpdateGeoDataItem();
                          },
                        );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Future<void> _handleUpdateGeoDataItem() async {
    await appController.safeRun<void>(() async {
      await updateGeoDateItem();
    }, silence: false);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> updateGeoDateItem() async {
    isUpdating.value = true;
    try {
      if (geoItem.fileName == 'Country.mmdb') {
        // Download Country.mmdb for leaf rule mode
        final homePath = await appPath.homeDirPath;
        await MmdbManager.download(homePath);
      } else {
        throw 'Unknown resource: ${geoItem.fileName}';
      }
    } catch (e) {
      isUpdating.value = false;
      rethrow;
    }
    isUpdating.value = false;
    return;
  }

  @override
  void dispose() {
    super.dispose();
    isUpdating.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListItem(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(geoItem.label),
      subtitle: _buildSubtitle(),
    );
  }
}
