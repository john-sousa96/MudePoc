import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mudepocflutter/db/event_database.dart';
import 'package:mudepocflutter/models/event.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event;

  const EventFormScreen({Key? key, this.event}) : super(key: key);

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _location;
  late String _time;
  late String _date;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _name = e?.name ?? '';
    _location = e?.location ?? '';
    _time = e?.time ?? '';
    _date = e?.date ?? '';
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final event = Event(
        id: widget.event?.id,
        name: _name,
        location: _location,
        time: _time,
        date: _date,
      );

      if (widget.event == null) {
        await EventDatabase().insertEvent(event);
      } else {
        await EventDatabase().updateEvent(event);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Evento' : 'Novo Evento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nome'),
                onSaved: (value) => _name = value!,
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                initialValue: _location,
                decoration: const InputDecoration(labelText: 'Local'),
                onSaved: (value) => _location = value!,
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe o local' : null,
              ),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(text: _date),
                decoration: const InputDecoration(labelText: 'Data'),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _date = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    });
                  }
                },
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe a data' : null,
              ),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(text: _time),
                decoration: const InputDecoration(labelText: 'Horário'),
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _time = pickedTime.format(context);
                    });
                  }
                },
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe o horário' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
