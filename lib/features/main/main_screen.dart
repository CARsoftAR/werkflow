import 'dart:ui';
import 'package:flutter/material.dart';
import '../citas/citas_list_page.dart';
import '../budgets/budgets_list_page.dart';
import '../clients/clients_list_page.dart';
import '../finanzas/finanzas_page.dart';
import '../citas/new_cita_page.dart';
import '../budgets/new_budget_page.dart';
import '../clients/new_client_page.dart';
import '../../core/theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _previousIndex = 0;

  final List<Widget> _pages = [
    const CitasListPage(),
    const BudgetsListPage(),
    const ClientsListPage(),
    const FinanzasPage(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
  }

  void _onFabPressed() {
    Widget? nextPage;
    switch (_selectedIndex) {
      case 0:
        nextPage = NewCitaPage();
        break;
      case 1:
        nextPage = NewBudgetPage();
        break;
      case 2:
        nextPage = NewClientPage();
        break;
    }

    if (nextPage != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => nextPage!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Body Pages
          ...List.generate(_pages.length, (index) {
            final double offset;
            if (index == _selectedIndex) {
              offset = 0;
            } else if (index < _selectedIndex) {
              offset = -1;
            } else {
              offset = 1;
            }

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              left: offset * MediaQuery.of(context).size.width,
              right: -offset * MediaQuery.of(context).size.width,
              top: 0,
              bottom: 0,
              child: Visibility(
                visible: offset == 0 || (index == _previousIndex && offset != 0),
                maintainState: true,
                child: _pages[index],
              ),
            );
          }),
          
          // True Floating Glass Footer
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: _buildGlassFooter(context, colorScheme),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex != 3 ? _buildFloatingActionButton(colorScheme) : null,
      floatingActionButtonLocation: _FloatAboveFooterLocation(120), // Custom Location
    );
  }

  Widget _buildFloatingActionButton(ColorScheme colorScheme) {
    return Container(
      height: 56, // Un poco más bajo para estilo rectangular
      width: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // Rectangular con puntas redondeadas
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.sunriseGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onFabPressed,
          borderRadius: BorderRadius.circular(20),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }


  Widget _buildGlassFooter(BuildContext context, ColorScheme colorScheme) {
    return Stack(
      children: [
        // Sombra de flotación
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
          ),
        ),
        // Glass Effect
        ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.6),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.calendar_today_rounded, 'Agenda', colorScheme),
                  _buildNavItem(1, Icons.description_outlined, 'Presupuestos', colorScheme),
                  _buildNavItem(2, Icons.group_rounded, 'Clientes', colorScheme),
                  _buildNavItem(3, Icons.account_balance_wallet_rounded, 'Finanzas', colorScheme),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, ColorScheme colorScheme) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.4);

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatAboveFooterLocation extends FloatingActionButtonLocation {
  final double offset;
  _FloatAboveFooterLocation(this.offset);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double x = scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width - 24;
    final double y = scaffoldGeometry.scaffoldSize.height - scaffoldGeometry.floatingActionButtonSize.height - offset;
    return Offset(x, y);
  }
}
