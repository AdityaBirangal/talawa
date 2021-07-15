import 'package:flutter/material.dart';
import 'package:talawa/enums/enums.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/utils/app_localization.dart';
import 'package:talawa/views/after_auth_screens/events/qr_scan_screen.dart';
import 'package:talawa/widgets/checkin_list_tile.dart';

class CheckinEventScreen extends StatefulWidget {
  @override
  _CheckinEventScreenState createState() => _CheckinEventScreenState();
}

class _CheckinEventScreenState extends State<CheckinEventScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        key: const Key("Check-inAppBar"),
        title: Text(
          'Check-in',
          style: Theme.of(context).textTheme.headline6!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xfffabc57),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => QRScanScreen()));
          },
          child: const Icon(Icons.qr_code_scanner)),
      body: Column(
        children: [
          const Divider(),
          const Text(
            'Check-ins : 25\nTotal : 50',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
          const Divider(),
          ListView.builder(
              padding: const EdgeInsets.all(0.0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 7,
              itemBuilder: (BuildContext context, int index) {
                return CheckinListTile(
                  key: Key(
                      '${AppLocalizations.of(context)!.strictTranslate("AttendeeCheckin")}$index'),
                  index: index,
                  type: TileType.user,
                  userInfo: userConfig.currentUser,
                  isChecked: true,
                  toggleCheckBoxState: () {},
                );
              })
        ],
      ),
    );
  }
}
