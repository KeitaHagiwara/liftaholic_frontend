import 'package:flutter/material.dart';
import 'tab_item.dart';

const tabTitle = <TabItem, String>{
  TabItem.planning: 'プランニング',
  TabItem.workout: 'ワークアウト',
  TabItem.notification: 'お知らせ',
  TabItem.account: 'マイページ',
};
const tabIcon = <TabItem, IconData>{
  TabItem.planning: Icons.event_note,
  TabItem.workout: Icons.fitness_center,
  TabItem.notification: Icons.notifications,
  TabItem.account: Icons.person,
};

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    Key? key,
    required this.currentTab,
    required this.onSelect,
  }) : super(key: key);

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelect;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        bottomItem(
          context,
          tabItem: TabItem.planning,
        ),
        bottomItem(
          context,
          tabItem: TabItem.workout,
        ),
        bottomItem(
          context,
          tabItem: TabItem.notification,
        ),
        bottomItem(
          context,
          tabItem: TabItem.account,
        ),
      ],
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        onSelect(TabItem.values[index]);
      },
      selectedFontSize: 12,
      selectedLabelStyle: const TextStyle(color: Colors.blue),
      selectedIconTheme: const IconThemeData(size: 32, color: Colors.blue),
      unselectedIconTheme: const IconThemeData(size: 32),
      showSelectedLabels: true, // 選択されたメニューのラベルの表示設定
      showUnselectedLabels: true, // 選択されてないメニューのラベルの表示設定
    );
  }

  BottomNavigationBarItem bottomItem(
    BuildContext context, {
    TabItem? tabItem,
  }) {
    final color = currentTab == tabItem ? Colors.blue : Colors.white70;
    return BottomNavigationBarItem(
      icon: Icon(
        tabIcon[tabItem],
        color: color,
      ),
      label: tabTitle[tabItem]
    );
  }
}