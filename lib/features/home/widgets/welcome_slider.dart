import 'package:flutter/material.dart';
import '../../../app/theme.dart';

/// Slider de bienvenida animado con 3 slides de presentación de Ocupa2.
class WelcomeSlider extends StatefulWidget {
  const WelcomeSlider({super.key});

  @override
  State<WelcomeSlider> createState() => _WelcomeSliderState();
}

class _WelcomeSliderState extends State<WelcomeSlider> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.search_rounded,
      gradientColors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
      title: 'Bienvenido a Ocupa2',
      subtitle: 'La plataforma de empleos temporales\nexclusiva para estudiantes del ITLA.',
      accentColor: Color(0xFF818CF8),
    ),
    _SlideData(
      icon: Icons.swap_horiz_rounded,
      gradientColors: [Color(0xFF06B6D4), Color(0xFF4F46E5)],
      title: 'Publica o Aplica',
      subtitle: 'Tú decides tu rol. Publica una oferta\no encuentra el trabajo perfecto para ti.',
      accentColor: Color(0xFF06B6D4),
    ),
    _SlideData(
      icon: Icons.school_rounded,
      gradientColors: [Color(0xFF10B981), Color(0xFF06B6D4)],
      title: 'Solo Estudiantes ITLA',
      subtitle: 'Una comunidad exclusiva y de confianza.\nTu matrícula es tu llave de acceso.',
      accentColor: Color(0xFF10B981),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-advance cada 4 segundos
    Future.delayed(const Duration(seconds: 4), _autoAdvance);
  }

  void _autoAdvance() {
    if (!mounted) return;
    final next = (_currentPage + 1) % _slides.length;
    _pageCtrl.animateToPage(
      next,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    Future.delayed(const Duration(seconds: 4), _autoAdvance);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return _SlideCard(data: _slides[index]);
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildDots(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: isActive ? AppColors.primaryGradient : null,
            color: isActive ? null : AppColors.textHint,
          ),
        );
      }),
    );
  }
}

class _SlideData {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
  final Color accentColor;

  const _SlideData({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}

class _SlideCard extends StatelessWidget {
  final _SlideData data;

  const _SlideCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono con gradiente
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: data.accentColor.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(data.icon, color: Colors.white, size: 60),
          ),
          const SizedBox(height: 36),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            data.subtitle,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
