import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:omnilearn/l10n/app_localizations.dart';
import 'package:omnilearn/pages/flashcards/flashcards_main_page.dart';
import 'package:omnilearn/pages/home_page.dart';
import 'package:omnilearn/pages/profile_page.dart';
import 'package:omnilearn/pages/quizzes/quizzes_main_page.dart';
import 'package:omnilearn/pages/task_scanner/task_scanner_main_page.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:omnilearn/style/style_options.dart';

// ==================================
// MAIN PAGE NAVIGATION & SHELL
// ==================================

/// Notifier holding the active bottom navigation page index
final ValueNotifier<int> pageIndex = ValueNotifier<int>(0);

/// Main shell widget containing bottom neumorphic navigation bar and active tab pages
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int _pageIndex = 0;

  List _pages = [
    HomePage(),
    FlashcardsMainPage(),
    QuizzesMainPage(),
    TaskScannerMainPage(),
    ProfilePage(),
  ];

  void _changePage(int index) {
    setState(() {
      pageIndex.value = index;
    });
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final bool isSelected = pageIndex.value == index;
    return NeumorphicRadio<int>(
      groupValue: pageIndex.value,
      value: index,
      onChanged: (int? value) {
        if (value != null) _changePage(value);
      },
      style: NeumorphicRadioStyle(
        boxShape: NeumorphicBoxShape.stadium(),
        selectedDepth: StyleOptions.neumorphicDepth * -1,
        unselectedDepth: StyleOptions.neumorphicDepth,
        intensity: StyleOptions.neumorphicIntensity
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeumorphicIcon(
            style: NeumorphicStyle(
              depth: StyleOptions.neumorphicDepth,
              intensity: StyleOptions.neumorphicIntensity,
              color: isSelected
                  ? NeumorphicTheme.accentColor(context)
                  : NeumorphicTheme.disabledColor(context),
            ),
            isSelected ? activeIcon : icon,
            size: 20,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? NeumorphicTheme.accentColor(context)
                  : NeumorphicTheme.disabledColor(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: pageIndex,
        builder: (context, _pageIndex, child) {
          return Scaffold(
            appBar: NeumorphicAppBar(
              title: Text(
                  "OmniLearn",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: NeumorphicTheme.defaultTextColor(context)
                ),
              ),
              actions: [
                NeumorphicButton(
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.circle(),
                    depth: _pageIndex == 4 ? StyleOptions.neumorphicDepth * -1 : StyleOptions.neumorphicDepth,
                    intensity: StyleOptions.neumorphicIntensity
                  ),
                onPressed: () {
                  _changePage(4);
                }, child: Center(
                  child: Icon(
                    BootstrapIcons.person_fill,
                    color: NeumorphicTheme.defaultTextColor(context),
                  ),
                ))
              ],
            ),
              body: AnimatedSwitcher(
                duration: StyleOptions.animationDuration,
                switchInCurve: StyleOptions.switchInCurve,
                switchOutCurve: StyleOptions.switchOutCurve,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_pageIndex),
                  child: _pages[_pageIndex],
                ),
              ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(8),
                  child: NeumorphicToggle(
                    height: 70,
                    selectedIndex: _pageIndex,
                    displayForegroundOnlyIfSelected: true,
                    duration: StyleOptions.animationDuration,
                    movingCurve: StyleOptions.movingCurve,
                    thumb: Neumorphic(
                      style: NeumorphicStyle(
                        depth: StyleOptions.neumorphicDepth,
                        intensity: StyleOptions.neumorphicIntensity,
                      )
                    ),
                    onChanged: (index) {
                      _changePage(index);
                    },
                    children: [
                      ToggleElement(
                        background: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              BootstrapIcons.house,
                              color: NeumorphicTheme.disabledColor(context),
                            ),
                            Text(
                              AppLocalizations.of(context)!.home,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: NeumorphicTheme.disabledColor(context)
                              ),
                            )
                          ],
                        ),
                        foreground: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              BootstrapIcons.house_fill,
                              color: NeumorphicTheme.accentColor(context),
                            ),
                            Text(
                              AppLocalizations.of(context)!.home,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: NeumorphicTheme.accentColor(context)
                              ),
                            )
                          ],
                        )
                      ),
                      ToggleElement(
                          background: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                BootstrapIcons.tag,
                                color: NeumorphicTheme.disabledColor(context),
                              ),
                              Text(
                                AppLocalizations.of(context)!.flashcards,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: NeumorphicTheme.disabledColor(context)
                                ),
                              )
                            ],
                          ),
                          foreground: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                BootstrapIcons.tag_fill,
                                color: NeumorphicTheme.accentColor(context),
                              ),
                              Text(
                                AppLocalizations.of(context)!.flashcards,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: NeumorphicTheme.accentColor(context)
                                ),
                              )
                            ],
                          )
                      ),
                      ToggleElement(
                          background: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                BootstrapIcons.question_lg,
                                color: NeumorphicTheme.disabledColor(context),
                              ),
                              Text(
                                AppLocalizations.of(context)!.quizzes,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: NeumorphicTheme.disabledColor(context)
                                ),
                              )
                            ],
                          ),
                          foreground: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                BootstrapIcons.question_lg,
                                color: NeumorphicTheme.accentColor(context),
                              ),
                              Text(
                                AppLocalizations.of(context)!.quizzes,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: NeumorphicTheme.accentColor(context)
                                ),
                              )
                            ],
                          )
                      ),
                      ToggleElement(
                          background: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                BootstrapIcons.camera,
                                color: NeumorphicTheme.disabledColor(context),
                              ),
                              Text(
                                AppLocalizations.of(context)!.task_scanner,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: NeumorphicTheme.disabledColor(context)
                                ),
                              )
                            ],
                          ),
                          foreground: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                BootstrapIcons.camera_fill,
                                color: NeumorphicTheme.accentColor(context),
                              ),
                              Text(
                                AppLocalizations.of(context)!.task_scanner,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: NeumorphicTheme.accentColor(context)
                                ),
                              )
                            ],
                          )
                      ),
                      ToggleElement(
                          background: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                BootstrapIcons.person,
                                color: NeumorphicTheme.disabledColor(context),
                              ),
                              Text(
                                AppLocalizations.of(context)!.profile,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: NeumorphicTheme.disabledColor(context)
                                ),
                              )
                            ],
                          ),
                          foreground: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                BootstrapIcons.person_fill,
                                color: NeumorphicTheme.accentColor(context),
                              ),
                              Text(
                                AppLocalizations.of(context)!.profile,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: NeumorphicTheme.accentColor(context)
                                ),
                              )
                            ],
                          )
                      ),
                    ],
                  ),
              ),
            )
          );
        }
    );
  }
}
