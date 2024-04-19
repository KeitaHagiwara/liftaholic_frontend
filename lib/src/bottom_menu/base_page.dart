import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:badges/badges.dart' as badges;

import 'package:liftaholic_frontend/src/bottom_menu/navigator/tab_item.dart';
import 'package:liftaholic_frontend/src/common/provider.dart';

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

    final unreadMessageCounter = ref.watch(unreadMessageCounterProvider);

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
                      // 通知件数のバッチを設定する
                      icon: tabItem.title == 'お知らせ'
                          ? informationBadge(unreadMessageCounter, tabItem)
                          : Icon(tabItem.icon),
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

  // 通知バッチのwidget
  Widget informationBadge(unreadMessageCounter, tabItem) {
    return badges.Badge(
      badgeContent: unreadMessageCounter! <= 999 ? Text(unreadMessageCounter.toString(), style: const TextStyle(color: Colors.white, fontSize: 10)) : Text('999+', style: const TextStyle(color: Colors.white, fontSize: 9)),
      position: badgePosition(unreadMessageCounter),
      showBadge: unreadMessageCounter! > 0 ? true : false,
      // key: const Key('news-icon'),
      child: Icon(tabItem.icon),
    );
  }

  // badgeの位置を指定する
  badges.BadgePosition badgePosition(unreadMessageCounter) {
    badges.BadgePosition position = badges.BadgePosition.topEnd();
    if (unreadMessageCounter! >= 10 && unreadMessageCounter! < 100) {
      position = badges.BadgePosition.topEnd(top: -8, end: -8);
    } else if (unreadMessageCounter! >= 100) {
      position = badges.BadgePosition.topEnd(top: -8, end: -12);
    }
    return position;
  }

}
