import 'package:flutter/material.dart';
import 'package:talawa/enums/enums.dart';
import 'package:talawa/models/user/user_info.dart';
import 'package:talawa/widgets/custom_avatar.dart';

class CheckinListTile extends StatefulWidget {
  const CheckinListTile(
      {required Key key,
      required this.index,
      required this.type,
      this.userInfo,
      this.isChecked,
      this.toggleCheckBoxState})
      : super(key: key);

  final int index;
  final TileType type;
  final User? userInfo;

  final bool? isChecked;
  final Function? toggleCheckBoxState;

  @override
  _CheckinListTileState createState() => _CheckinListTileState();
}

class _CheckinListTileState extends State<CheckinListTile> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: CustomAvatar(
                isImageNull: widget.userInfo!.image == null,
                imageUrl: widget.userInfo!.image,
                firstAlphabet: widget.userInfo!.firstName!.substring(0, 1),
                fontSize: 18,
              )),
          Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${widget.userInfo!.firstName!} ${widget.userInfo!.lastName!}',
                      style: Theme.of(context).textTheme.headline6),
                ],
              )),
          Flexible(
            flex: 1,
            child: Checkbox(
              activeColor: Colors.green,
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
