import 'package:edurank/presentation/pages/home/common.dart';
import 'package:edurank/presentation/pages/home/home_screen.dart';
import 'package:edurank/presentation/pages/home/stage1_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_bar/menu_bar.dart';
void main()=>runApp(MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  List<BarButton> _menuBarButtons() {
    return [
      BarButton(
        text: const Text(
          'File',
          style: TextStyle(color: Colors.black),
        ),
        submenu: SubMenu(
          menuItems: [
            MenuButton(
              onTap: () => print('Save'),
              text: const Text('Save'),
              shortcutText: 'Ctrl+S',
              shortcut:
              const SingleActivator(LogicalKeyboardKey.keyS, control: true),
            ),
            MenuButton(
              onTap: () {},
              text: const Text('Save as'),
              shortcutText: 'Ctrl+Shift+S',
            ),
            const MenuDivider(),
            MenuButton(
              onTap: () {},
              text: const Text('Open File'),
            ),
            MenuButton(
              onTap: () {},
              text: const Text('Open Folder'),
            ),
            const MenuDivider(),
            MenuButton(
              text: const Text('Preferences'),
              icon: const Icon(Icons.settings),
              submenu: SubMenu(
                menuItems: [
                  MenuButton(
                    onTap: () {},
                    icon: const Icon(Icons.keyboard),
                    text: const Text('Shortcuts'),
                  ),
                  const MenuDivider(),
                  MenuButton(
                    onTap: () {},
                    icon: const Icon(Icons.extension),
                    text: const Text('Extensions'),
                  ),
                  const MenuDivider(),
                  MenuButton(
                    icon: const Icon(Icons.looks),
                    text: const Text('Change theme'),
                    submenu: SubMenu(
                      menuItems: [
                        MenuButton(
                          onTap: () {},
                          icon: const Icon(Icons.light_mode),
                          text: const Text('Light theme'),
                        ),
                        const MenuDivider(),
                        MenuButton(
                          onTap: () {},
                          icon: const Icon(Icons.dark_mode),
                          text: const Text('Dark theme'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const MenuDivider(),
            MenuButton(
              onTap: () {},
              shortcutText: 'Ctrl+Q',
              text: const Text('Exit'),
              icon: const Icon(Icons.exit_to_app),
            ),
          ],
        ),
      ),
      BarButton(
        text: const Text(
          'Edit',
          style: TextStyle(color: Colors.black),
        ),
        submenu: SubMenu(
          menuItems: [
            MenuButton(
              onTap: () {},
              text: const Text('Undo'),
              shortcutText: 'Ctrl+Z',
            ),
            MenuButton(
              onTap: () {},
              text: const Text('Redo'),
              shortcutText: 'Ctrl+Y',
            ),
            const MenuDivider(),
            MenuButton(
              onTap: () {},
              text: const Text('Cut'),
              shortcutText: 'Ctrl+X',
            ),
            MenuButton(
              onTap: () {},
              text: const Text('Copy'),
              shortcutText: 'Ctrl+C',
            ),
            MenuButton(
              onTap: () {},
              text: const Text('Paste'),
              shortcutText: 'Ctrl+V',
            ),
            const MenuDivider(),
            MenuButton(
              onTap: () {},
              text: const Text('Find'),
              shortcutText: 'Ctrl+F',
            ),
          ],
        ),
      ),
      BarButton(
        text: const Text(
          'Help',
          style: TextStyle(color: Colors.black),
        ),
        submenu: SubMenu(
          menuItems: [
            MenuButton(
              onTap: () {},
              text: const Text('Check for updates'),
            ),
            const MenuDivider(),
            MenuButton(
              onTap: () {},
              text: const Text('View License'),
            ),
            const MenuDivider(),
            MenuButton(
              onTap: () {},
              icon: const Icon(Icons.info),
              text: const Text('About'),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        menuTheme: const MenuThemeData(
          style: MenuStyle(
            padding:
            MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 16.0)),
          ),
        ),
      ),

      home: MenuBarWidget(
          barButtons: _menuBarButtons(),
          barStyle: const MenuStyle(
            padding: MaterialStatePropertyAll(EdgeInsets.zero),
            backgroundColor: MaterialStatePropertyAll(Colors.grey),
            maximumSize: MaterialStatePropertyAll(Size(double.infinity, 28.0)),
          ),

          barButtonStyle: const ButtonStyle(
            padding:
            MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 6.0)),
            minimumSize: MaterialStatePropertyAll(Size(0.0, 40.0)),
          ),

          // Style the menu and submenu buttons. Hover over [ButtonStyle] for all the options
          menuButtonStyle: const ButtonStyle(
            minimumSize: MaterialStatePropertyAll(Size.fromHeight(36.0)),
            padding: MaterialStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0)),
          ),
          enabled: true,

          // Set the child, i.e. the application under the menu bar
          child: HomeScreen()
      ),
    );

  }
}


