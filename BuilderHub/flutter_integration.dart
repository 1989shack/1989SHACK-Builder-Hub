# Add to your Flutter app lib/screens/builder_hub.dart
# This calls the Builder Hub exe from phone!

Future<void> openBuilderHub() async {
  if(Platform.isWindows){
    await Process.run('C:\\BanglaHost\\BuilderHub\\BuilderHubHub.exe', []);
  } else {
    // On phone, open via RDP or show templates
    launchUrl(Uri.parse('https://1989shack.com/builder-hub-web'));
  }
}
