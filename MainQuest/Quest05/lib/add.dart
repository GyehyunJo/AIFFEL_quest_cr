import 'package:flutter/material.dart';
import 'player.dart';

class AddEditPlayerPage extends StatefulWidget {
  final Player? player;
  final Function(Player) onSave;

  AddEditPlayerPage({this.player, required this.onSave});

  @override
  _AddEditPlayerPageState createState() => _AddEditPlayerPageState();
}

class _AddEditPlayerPageState extends State<AddEditPlayerPage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String position;
  late bool isStarter;
  late int number;

  @override
  void initState() {
    super.initState();
    if (widget.player != null) {
      name = widget.player!.name;
      position = widget.player!.position;
      isStarter = widget.player!.isStarter;
      number = widget.player!.number;
    } else {
      name = '';
      position = '';
      isStarter = false;
      number = 0;
    }
  }

  void _savePlayer() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        Player(
          name: name,
          position: position,
          isStarter: isStarter,
          number: number,
          redCards: widget.player?.redCards ?? 0,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.player == null ? "Add Player" : "Edit Player")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter a name" : null,
                onChanged: (value) => name = value,
              ),
              TextFormField(
                initialValue: position,
                decoration:
                    InputDecoration(labelText: "Position (GK/DF/MF/FW)"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter a position" : null,
                onChanged: (value) => position = value.toUpperCase(),
              ),
              TextFormField(
                initialValue: number.toString(),
                decoration: InputDecoration(labelText: "Number"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || int.tryParse(value) == null
                        ? "Enter a valid number"
                        : null,
                // onChanged 수정: 숫자가 아닌 값이나 빈 값이 들어오지 않도록 처리
                onChanged: (value) {
                  if (value.isNotEmpty && int.tryParse(value) != null) {
                    number = int.parse(value);
                  } else {
                    number = 0; // 기본값 설정
                  }
                },
              ),
              SwitchListTile(
                title: Text("Starter"),
                value: isStarter,
                onChanged: (value) => setState(() => isStarter = value),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePlayer,
                child:
                    Text(widget.player == null ? "Add Player" : "Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
