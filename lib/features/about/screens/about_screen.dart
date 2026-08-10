import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/drawer_menu_button.dart';

/// Modelo de datos para un miembro del equipo de desarrollo.
class TeamMember {
  final String name;
  final String matricula;
  final String phone;
  final String? telegramUsername;
  final String? telegramUrl;
  final String photoAsset;
  final Color avatarColor;

  const TeamMember({
    required this.name,
    required this.matricula,
    required this.phone,
    this.telegramUsername,
    this.telegramUrl,
    required this.photoAsset,
    required this.avatarColor,
  });
}

/// Pantalla "Acerca de".
/// Muestra el equipo de desarrollo con opciones de llamada y Telegram.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // Datos del equipo de desarrollo del proyecto Ocupa2
  static const List<TeamMember> _team = [
    TeamMember(
      name: 'Said Abel De Oleo Reyes',
      matricula: '2024-1789',
      phone: '+18098699144',
      telegramUsername: 'bOBo_2606',
      telegramUrl: 'https://t.me/bOBo_2606',
      photoAsset: 'assets/images/saiddeoleo_perfil.jpeg',
      avatarColor: Color(0xFF4F46E5),
    ),
    TeamMember(
      name: 'Luis David Morillo Luciano',
      matricula: '2024-0004',
      phone: '+18299155254',
      telegramUsername: 'lobomentor',
      telegramUrl: 'https://t.me/lobomentor',
      photoAsset: 'assets/images/luismorillo_perfil.jpeg',
      avatarColor: Color(0xFF10B981),
    ),
    TeamMember(
      name: 'José David Castillo Castillo',
      matricula: '2024-1546',
      phone: '+18098492337',
      telegramUsername: 'jdcastilloc',
      telegramUrl: 'https://t.me/jdcastilloc',
      photoAsset: 'assets/images/josecastillo_perfil.jpeg',
      avatarColor: Color(0xFF06B6D4),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el marcador de llamadas.'),
          ),
        );
      }
    }
  }

  Future<void> _launchTelegram(String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Telegram.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // App Bar con gradiente, logo y botón de menú
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.background,
              leading: const Center(child: DrawerMenuButton()),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Logo de la app
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(100),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.work_outline,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Ocupa2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Plataforma de Empleos Temporales · ITLA',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Contenido
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Versión y descripción
                    _buildInfoCard(),
                    const SizedBox(height: 28),

                    // Sección del equipo
                    const Text(
                      'Equipo de Desarrollo',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Proyecto académico · Instituto Tecnológico de Las Américas',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cards del equipo
                    ..._team.map(
                      (member) => _TeamMemberCard(
                        member: member,
                        onCall: () => _launchPhone(member.phone),
                        onTelegram: member.telegramUrl != null
                            ? () => _launchTelegram(member.telegramUrl!)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 28),
                    // Footer tecnologías
                    _buildTechStack(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.success.withAlpha(60)),
                ),
                child: const Text(
                  'API v2.0.0',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Ocupa2 es una plataforma de empleos temporales para estudiantes del ITLA. '
            'Permite publicar ofertas de trabajo, aplicar a ellas, gestionar contratos '
            'y más — todo desde tu móvil.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          _infoRow(
            Icons.school_outlined,
            'Instituto',
            'ITLA - Instituto Tecnológico de Las Américas',
          ),
          const SizedBox(height: 8),
          _infoRow(
            Icons.api_outlined,
            'Backend',
            'https://ocupa2.ia3x.com/apix',
          ),
          const SizedBox(height: 8),
          _infoRow(
            Icons.smartphone_outlined,
            'Plataforma',
            'Android (Flutter)',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textHint, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTechStack() {
    final techs = [
      (
        'Flutter',
        Icons.flutter_dash,
        AppColors.accent,
        'Framework principal para desarrollo multiplataforma, permitiendo una experiencia nativa fluida en Android.',
      ),
      (
        'Dart',
        Icons.code,
        const Color(0xFF0175C2),
        'Lenguaje de programación base que impulsa toda la lógica y reactividad de la aplicación.',
      ),
      (
        'provider',
        Icons.hub_outlined,
        AppColors.primary,
        'Gestor de estado elegido por su simplicidad y eficiencia en la propagación de cambios a la UI. (v6.1.2)',
      ),
      (
        'go_router',
        Icons.route_outlined,
        const Color(0xFF10B981),
        'Manejo de navegación declarativa y profunda, vital para el ruteo basado en shells y autenticación. (v14.2.0)',
      ),
      (
        'http',
        Icons.cloud_outlined,
        const Color(0xFFF59E0B),
        'Consumo de servicios REST del backend de Ocupa2 mediante peticiones HTTP con autenticación JWT. (v1.2.0)',
      ),
      (
        'shared_preferences',
        Icons.storage_outlined,
        const Color(0xFF8B5CF6),
        'Almacenamiento persistente ligero utilizado para guardar el token de sesión entre arranques de la app. (v2.3.2)',
      ),
      (
        'google_fonts',
        Icons.text_fields_outlined,
        const Color(0xFFEC4899),
        'Tipografías premium de Google Fonts para una interfaz moderna y legible. (v6.2.1)',
      ),
      (
        'image_picker',
        Icons.photo_camera_outlined,
        const Color(0xFFEF4444),
        'Selección de imágenes desde la galería del dispositivo para actualizar la foto de perfil. (v1.1.2)',
      ),
      (
        'url_launcher',
        Icons.open_in_new_outlined,
        const Color(0xFF06B6D4),
        'Apertura de URLs, llamadas telefónicas y enlaces a Telegram desde dentro de la app. (v6.3.0)',
      ),
      (
        'youtube_player_flutter',
        Icons.play_circle_outline,
        const Color(0xFFFF0000),
        'Reproducción de videos de YouTube embebidos directamente en la pantalla de videos. (v10.0.1)',
      ),
      (
        'flutter_map',
        Icons.map_outlined,
        const Color(0xFF16A34A),
        'Mapas interactivos basados en OpenStreetMap para visualizar las ofertas de trabajo por ubicación. (v7.0.2)',
      ),
      (
        'latlong2',
        Icons.my_location_outlined,
        const Color(0xFF0891B2),
        'Cálculos de coordenadas geográficas (latitud/longitud) usados junto con flutter_map. (v0.9.1)',
      ),
      (
        'geolocator',
        Icons.gps_fixed_outlined,
        const Color(0xFFF97316),
        'Acceso al GPS del dispositivo para centrar el mapa en la posición actual del usuario. (v13.0.3)',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tecnologías y Paquetes',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: techs
              .map(
                (t) => _TechItem(
                  name: t.$1,
                  icon: t.$2,
                  color: t.$3,
                  description: t.$4,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _TechItem extends StatefulWidget {
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  const _TechItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });

  @override
  State<_TechItem> createState() => _TechItemState();
}

class _TechItemState extends State<_TechItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: widget.color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.color.withAlpha(40)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(widget.icon, size: 20, color: widget.color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.name,
                        style: TextStyle(
                          color: widget.color,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: widget.color,
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10, left: 30),
                          child: Text(
                            widget.description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de un integrante del equipo.
class _TeamMemberCard extends StatefulWidget {
  final TeamMember member;
  final VoidCallback onCall;
  final VoidCallback? onTelegram;

  const _TeamMemberCard({
    required this.member,
    required this.onCall,
    this.onTelegram,
  });

  @override
  State<_TeamMemberCard> createState() => _TeamMemberCardState();
}

class _TeamMemberCardState extends State<_TeamMemberCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _hoverCtrl;
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _hoverCtrl.reverse(),
      onTapUp: (_) => _hoverCtrl.forward(),
      onTapCancel: () => _hoverCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.member.avatarColor.withAlpha(60)),
            boxShadow: [
              BoxShadow(
                color: widget.member.avatarColor.withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header con avatar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.member.avatarColor.withAlpha(15),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.member.avatarColor,
                            widget.member.avatarColor.withAlpha(180),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.member.avatarColor.withAlpha(80),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          widget.member.photoAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.person_outline,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Nombre y rol
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.member.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Info y acciones
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Matrícula
                    _infoRow(
                      Icons.badge_outlined,
                      'Matrícula',
                      widget.member.matricula,
                    ),
                    const SizedBox(height: 10),

                    // Teléfono
                    _infoRow(
                      Icons.phone_outlined,
                      'Teléfono',
                      widget.member.phone,
                    ),
                    const SizedBox(height: 16),

                    // Botones de acción
                    Row(
                      children: [
                        // Llamar
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onCall,
                            icon: const Icon(Icons.call, size: 18),
                            label: const Text('Llamar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.success,
                              side: BorderSide(
                                color: AppColors.success.withAlpha(100),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Telegram
                        if (widget.onTelegram != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.onTelegram,
                              icon: const Icon(Icons.send, size: 18),
                              label: const Text('Telegram'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2AABEE),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        ),
      ],
    );
  }
}
