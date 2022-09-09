import 'package:clash_flt/clash_channel.dart';
import 'package:clash_flt/entity/fetch_status.dart';
import 'package:clash_flt_example/named_proxy_group_view.dart';
import 'package:clash_flt_example/plugin_functions_view.dart';
import 'package:clash_flt_example/sensitive_info.dart';
import 'package:flutter/material.dart';

class PluginExample extends StatefulWidget {
  const PluginExample({Key? key}) : super(key: key);

  @override
  State<PluginExample> createState() => _PluginExampleState();
}

class _PluginExampleState extends State<PluginExample>
    with TickerProviderStateMixin {
  final _clash = ClashChannel.instance;
  FetchStatus? _fetchStatus;
  final _groupNames = <String>[];

  late TabController _uiTab = TabController(length: 1, vsync: this);

  _fetch() async {
    setState(() {
      _fetchStatus = null;
      _groupNames.clear();
      _uiTab.dispose();
      _uiTab = TabController(length: 1, vsync: this);
    });
    await _clash.fetchAndValid(
      url: clashProfileUrl,
      force: false,
      reportStatus: (p0) {
        setState(() {
          _fetchStatus = p0;
        });
      },
    );
    setState(() {
      _fetchStatus = null;
    });
    await _clash.load();
    final groupNames = await _clash.queryGroupNames();
    setState(() {
      _groupNames
        ..clear()
        ..addAll(groupNames);
      _uiTab.dispose();
      _uiTab = TabController(length: groupNames.length + 1, vsync: this);
    });
  }

  @override
  void dispose() {
    _uiTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("clash_flt"),
        bottom: TabBar(
          tabs: [
            "Plugin Functions",
            ..._groupNames,
          ].map((e) => Tab(text: e)).toList(),
          controller: _uiTab,
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          TabBarView(
            controller: _uiTab,
            children: [
              const PluginFunctionsView(),
              ..._groupNames.map((e) => NamedProxyGroupView(groupName: e))
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: _fetchStatus != null ? null : _fetch,
              icon: _fetchStatus == null
                  ? const Icon(Icons.download)
                  : SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
              label: Text(_fetchStatus?.action.name ?? "Fetch"),
            ),
          ),
        ],
      ),
    );
  }
}
