import 'package:flutter/material.dart';
import 'package:mudepocflutter/screens/certificacao_screen.dart';
import 'package:mudepocflutter/screens/profile_screen.dart';
import 'package:mudepocflutter/screens/main_screen.dart'; // Importe a MainScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Índice inicial da navbar

  // Metodo para navegar para MainScreen
  void _navigateToMainScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  // Metodo para navegar para MainScreen
  void _navigateToCerticacaoScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CertificacaoPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Verifica se o ícone clicado foi o de agenda (índice 1)
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CertificacaoPage()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Bem-vindo!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                children: [
                  // Botão de Calendário
                  InkWell(
                    onTap: () => _navigateToMainScreen(context),
                    child: _buildHomeButton(
                      icon: Icons.calendar_month_outlined,
                      color: Colors.orange,
                    ),
                  ),
                  _buildHomeButton(
                    icon: Icons.dashboard_outlined,
                    color: Colors.purple,
                  ),
                  _buildHomeButton(
                    icon: Icons.person_outline,
                    color: Colors.teal,
                  ),

                    InkWell(
                      onTap: () => _navigateToCerticacaoScreen(context),
                      child: _buildHomeButton(
                      icon: Icons.favorite_border,
                      color: Colors.red,
                    )

                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeButton({required IconData icon, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(icon, size: 40, color: color),
      ),
    );
  }
}