import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme.dart';

/// Modelo de datos para un miembro del equipo de desarrollo.
class TeamMember {
  final String name;
  final String role;
  final String matricula;
  final String phone;
  final String? telegramUsername;
  final String? telegramUrl;
  final IconData avatarIcon;
  final Color avatarColor;

  const TeamMember({
    required this.name,
    required this.role,
    required this.matricula,
    required this.phone,
    this.telegramUsername,
    this.telegramUrl,
    required this.avatarIcon,
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
      name: 'Said Abel',
      role: 'Arquitectura, Auth & Servicios Base',
      matricula: '2023-0001',
      phone: '+18097000001',
      telegramUsername: 'said_abel',
      telegramUrl: 'https://t.me/said_abel',
      avatarIcon: Icons.code,
      avatarColor: Color(0xFF4F46E5),
    ),
    TeamMember(
      name: 'David',
      role: 'Ofertas, Mapas & Publicación',
      matricula: '2023-0002',
      phone: '+18097000002',
      telegramUsername: 'david_dev',
      telegramUrl: 'https://t.me/david_dev',
      avatarIcon: Icons.map_outlined,
      avatarColor: Color(0xFF06B6D4),
    ),
    TeamMember(
      name: 'Luis',
      role: 'Aplicaciones, Perfil & Pagos',
      matricula: '2023-0003',
      phone: '+18097000003',
      telegramUsername: 'luis_dev',
      telegramUrl: 'https://t.me/luis_dev',
      avatarIcon: Icons.person_outline,
      avatarColor: Color(0xFF10B981),
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
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir Telegram.'),
          ),
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
            // App Bar con gradiente y logo
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.background,
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
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withAlpha(60)),
                ),
                child: const Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
          _infoRow(Icons.school_outlined, 'Instituto', 'ITLA - Instituto Tecnológico de Las Américas'),
          const SizedBox(height: 8),
          _infoRow(Icons.api_outlined, 'Backend', 'https://ocupa2.ia3x.com/apix'),
          const SizedBox(height: 8),
          _infoRow(Icons.smartphone_outlined, 'Plataforma', 'Android (Flutter)'),
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
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTechStack() {
    final techs = [
      ('Flutter', Icons.flutter_dash, AppColors.accent),
      ('Provider', Icons.hub_outlined, AppColors.primary),
      ('Go Router', Icons.route_outlined, const Color(0xFF10B981)),
      ('REST API', Icons.cloud_outlined, const Color(0xFFF59E0B)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tecnologías',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: techs.map((t) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: t.$3.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: t.$3.withAlpha(60)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.$2, size: 14, color: t.$3),
                  const SizedBox(width: 6),
                  Text(
                    t.$1,
                    style: TextStyle(
                      color: t.$3,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
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
            border: Border.all(
              color: widget.member.avatarColor.withAlpha(60),
            ),
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
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
                      child: Icon(
                        widget.member.avatarIcon,
                        size: 28,
                        color: Colors.white,
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
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.member.role,
                            style: TextStyle(
                              color:
                                  widget.member.avatarColor.withAlpha(220),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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
                                  color: AppColors.success.withAlpha(100)),
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
                                padding: const EdgeInsets.symmetric(vertical: 12),
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
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
