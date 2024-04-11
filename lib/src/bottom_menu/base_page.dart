import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'navigator/tab_item.dart';
import '../common/provider.dart';

final _navigatorKeys = <TabItem, GlobalKey<NavigatorState>>{
  TabItem.planning: GlobalKey<NavigatorState>(),
  TabItem.workout: GlobalKey<NavigatorState>(),
  TabItem.notification: GlobalKey<NavigatorState>(),
  TabItem.account: GlobalKey<NavigatorState>(),
};

class BasePage extends HookConsumerWidget {
  const BasePage({super.key, required this.appName});

  final String appName;

  Widget build(BuildContext context, WidgetRef ref) {
    // 初期ページを設定する
    final currentTab = useState(TabItem.planning);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appName,
          style: TextStyle(fontFamily: 'Honk', fontSize: 36, color: Colors.blue),
        ),
      ),
      body: Stack(
        children: TabItem.values
            .map(
              (tabItem) => Offstage(
                offstage: currentTab.value != tabItem,
                child: Navigator(
                  key: _navigatorKeys[tabItem],
                  onGenerateRoute: (settings) {
                    return MaterialPageRoute<Widget>(
                      builder: (context) => tabItem.page,
                    );
                  },
                ),
              ),
            )
            .toList(),
      ),
      // ワークアウト実施中はbottomNavigationBarは非表示にする
      bottomNavigationBar: ref.watch(isDoingWorkoutProvider)
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: TabItem.values.indexOf(currentTab.value),
              items: TabItem.values
                  .map(
                    (tabItem) => BottomNavigationBarItem(
                      icon: Icon(tabItem.icon),
                      label: tabItem.title,
                    ),
                  )
                  .toList(),
              onTap: (index) {
                final selectedTab = TabItem.values[index];
                if (currentTab.value == selectedTab) {
                  _navigatorKeys[selectedTab]?.currentState?.popUntil((route) => route.isFirst);
                } else {
                  // 未選択
                  currentTab.value = selectedTab;
                }
              },
              selectedFontSize: 12,
              selectedLabelStyle: const TextStyle(color: Colors.blue),
              selectedIconTheme: const IconThemeData(size: 32, color: Colors.blue),
              unselectedIconTheme: const IconThemeData(size: 32),
              showSelectedLabels: true, // 選択されたメニューのラベルの表示設定
              showUnselectedLabels: true, // 選択されてないメニューのラベルの表示設定
            ),
    );
  }
}
