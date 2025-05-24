import 'package:flutter/material.dart';
import 'package:mudepocflutter/models/event.dart';
import 'package:mudepocflutter/db/event_database.dart';
import 'package:mudepocflutter/screens/event_details_screen.dart';
import 'package:mudepocflutter/screens/event_form_screen.dart';
import 'package:mudepocflutter/screens/home_screen.dart';
import 'package:mudepocflutter/screens/profile_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Event> _events = [];
  int _currentIndex = 1;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadEvents();
  }

  // Carrega todos os eventos do banco de dados
  Future<void> _loadEvents() async {
    final events = await EventDatabase().getAllEvents();
    setState(() {
      _events = events;
    });
  }

  // Navega para a tela de formulário de evento (criação ou edição)
  void _navigateToForm({Event? event}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventFormScreen(event: event)),
    );

    if (result == true) _loadEvents();
  }

  // Remove um evento do banco de dados
  void _deleteEvent(int id) async {
    await EventDatabase().deleteEvent(id);
    _loadEvents();
  }

  // Verifica se duas datas são o mesmo dia
  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Obtém todos os eventos para um dia específico
  List<Event> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      final eventDate = DateFormat('yyyy-MM-dd').parse(event.date);
      return _isSameDay(eventDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          ),
        ),
        title: const Text('Calendário de eventos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Seção do calendário
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => _isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                // Estilo para o dia selecionado
                selectedDecoration: BoxDecoration(
                  color: const Color(0xFFF99226),
                  shape: BoxShape.circle,
                ),
                // Estilo para o dia atual (hoje)
                todayDecoration: BoxDecoration(
                  color: Colors.transparent, // Fundo transparente
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black, // Borda preta para o dia atual
                    width: 1.5,
                  ),
                ),
                // Cor do texto para o dia atual
                todayTextStyle: const TextStyle(
                  color: Colors.black, // Texto preto para o dia atual
                  fontWeight: FontWeight.bold,
                ),
                // Cor do texto para dias normais
                defaultTextStyle: const TextStyle(
                  color: Colors.black,
                ),
                // Cor do texto para dias de outros meses
                outsideTextStyle: TextStyle(
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),

          // Lista de eventos para o dia selecionado
          Expanded(
            child: ListView.builder(
              itemCount: _getEventsForDay(_selectedDay!).length,
              itemBuilder: (context, index) {
                final event = _getEventsForDay(_selectedDay!)[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: const Color(0xFFF99226),
                  child: ListTile(
                    tileColor: _isSameDay(DateFormat('yyyy-MM-dd').parse(event.date), _selectedDay)
                        ? const Color(0xFF039DAE).withOpacity(0.1)
                        : null,
                    title: Text(event.name),
                    subtitle: Text('${event.date} – ${event.time}\n${event.location}'),
                    isThreeLine: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsScreen(event: event),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _navigateToForm(event: event),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteEvent(event.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Botão flutuante modificado para ser um botão estendido com texto
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: const Color(0xFFF99226), // Cor laranja
        label: const Text(
          'Adicionar evento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
      ),
      // Barra de navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Navegação para a HomeScreen quando clicar no Dashboard (índice 2) ou Início (índice 0)
          if (index == 0 || index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_customize_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}