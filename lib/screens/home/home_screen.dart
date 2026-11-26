import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../navigation/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/project_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final GlobalKey _howItWorksKey = GlobalKey();

  static const List<Project> _featuredProjects = [
    Project(
      id: 'demo-1',
      title: 'EcoTrack',
      description:
          'Günlük alışkanlıkların çevresel etkisini takip etmeyi kolaylaştıran sürdürülebilirlik uygulaması.',
      ownerId: 'demo-owner-1',
      ownerName: 'Elif Yılmaz',
      technologies: ['Flutter', 'Firebase', 'UI/UX'],
      neededRoles: ['Flutter geliştirici', 'UI/UX'],
    ),
    Project(
      id: 'demo-2',
      title: 'Campus Connect',
      description:
          'Üniversite öğrencilerini etkinliklerde, topluluklarda ve ortak ilgi alanlarında buluşturur.',
      ownerId: 'demo-owner-2',
      ownerName: 'Mert Kaya',
      technologies: ['Flutter', 'Dart', 'Firestore'],
      neededRoles: ['Mobil geliştirici', 'Backend'],
    ),
    Project(
      id: 'demo-3',
      title: 'DataLens AI',
      description:
          'Karmaşık veri setlerini anlaşılır grafikler ve kısa içgörülerle keşfetmeye yardımcı olur.',
      ownerId: 'demo-owner-3',
      ownerName: 'Zeynep Demir',
      technologies: ['Python', 'AI', 'Data'],
      neededRoles: ['Python', 'Veri analisti'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1220),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 18 : 34,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TopBar(isMobile: isMobile),
                        const SizedBox(height: 26),
                        _HeroSection(isMobile: isMobile),
                        const SizedBox(height: 28),
                        _TrustStrip(isMobile: isMobile),
                        const SizedBox(height: 68),
                        _SectionHeading(
                          eyebrow: 'KEŞFET VE ÜRET',
                          title: 'Bir sonraki projen burada başlıyor.',
                          description:
                              'İlgi alanına uygun bir ekibe katıl veya fikrini birlikte geliştireceğin insanları bul.',
                          actionLabel: 'Tüm projeleri gör',
                          onAction: () => _navigate(context, AppRoutes.projects),
                          isMobile: isMobile,
                        ),
                        const SizedBox(height: 24),
                        _FeaturedProjectGrid(
                          projects: _featuredProjects,
                          isMobile: isMobile,
                        ),
                        const SizedBox(height: 68),
                        _HowItWorksSection(key: _howItWorksKey, isMobile: isMobile),
                        const SizedBox(height: 28),
                        _BottomCta(isMobile: isMobile),
                        const SizedBox(height: 26),
                        _Footer(isMobile: isMobile),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static void _navigate(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          const _BrandMark(),
          const SizedBox(width: 10),
          const Text(
            'DevHub',
            style: TextStyle(
              fontSize: 22,
              color: AppTheme.ink,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const Spacer(),
          if (!isMobile) ...[
            _NavTextButton(
              label: 'Projeleri keşfet',
              onPressed: () => HomeScreen._navigate(context, AppRoutes.projects),
            ),
            const SizedBox(width: 8),
            _NavTextButton(
              label: 'Nasıl çalışır?',
              onPressed: () {
                final target = HomeScreen._howItWorksKey.currentContext;
                if (target != null) {
                  Scrollable.ensureVisible(
                    target,
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () => HomeScreen._navigate(context, AppRoutes.profile),
              child: const Text('Profilim'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => HomeScreen._navigate(context, AppRoutes.login),
              child: const Text('Giriş yap'),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => HomeScreen._navigate(context, AppRoutes.register),
              icon: const Icon(Icons.arrow_forward_rounded, size: 17),
              label: const Text('Ücretsiz katıl'),
            ),
          ] else ...[
            IconButton(
              tooltip: 'Projeleri keşfet',
              onPressed: () => HomeScreen._navigate(context, AppRoutes.projects),
              icon: const Icon(Icons.explore_outlined),
            ),
            PopupMenuButton<String>(
              tooltip: 'Menüyü aç',
              icon: const Icon(Icons.menu_rounded),
              onSelected: (value) => HomeScreen._navigate(context, value),
              itemBuilder: (context) => const [
                PopupMenuItem(value: AppRoutes.projects, child: Text('Projeleri keşfet')),
                PopupMenuItem(value: AppRoutes.login, child: Text('Giriş yap')),
                PopupMenuItem(value: AppRoutes.register, child: Text('Kayıt ol')),
                PopupMenuItem(value: AppRoutes.profile, child: Text('Profilim')),
                PopupMenuItem(value: AppRoutes.applications, child: Text('Başvurularım')),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF8586FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.hub_rounded, color: Colors.white, size: 23),
    );
  }
}

class _NavTextButton extends StatelessWidget {
  const _NavTextButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.muted,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF171A32), Color(0xFF292A61), Color(0xFF4546A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -70,
            child: Container(
              width: 310,
              height: 310,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF9293FF).withOpacity(0.11),
              ),
            ),
          ),
          Positioned(
            right: 150,
            bottom: -190,
            child: Container(
              width: 330,
              height: 330,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 24 : 48),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _HeroCopy(isMobile: true),
                      const SizedBox(height: 28),
                      const _HeroPreview(),
                    ],
                  )
                : const Row(
                    children: [
                      Expanded(flex: 11, child: _HeroCopy(isMobile: false)),
                      SizedBox(width: 30),
                      Expanded(flex: 9, child: _HeroPreview()),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.09),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppTheme.mint, size: 15),
              SizedBox(width: 8),
              Text(
                'Öğrenciler için proje topluluğu',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text.rich(
          TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 37 : 52,
              height: 1.08,
              fontWeight: FontWeight.w800,
              letterSpacing: isMobile ? -1.4 : -2.2,
            ),
            children: const [
              TextSpan(text: 'Fikrini bul.\n'),
              TextSpan(
                text: 'Ekibini kur.\n',
                style: TextStyle(color: AppTheme.mint),
              ),
              TextSpan(text: 'Birlikte üret.'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Tek başına başlamak zorunda değilsin. Projeni paylaş, sana uygun ekibi keşfet ve fikirlerini çalışan ürünlere dönüştür.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.76),
            fontSize: isMobile ? 14 : 16,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: () => HomeScreen._navigate(context, AppRoutes.projects),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mint,
                foregroundColor: AppTheme.ink,
                padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 17),
              ),
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text('Projeleri keşfet'),
            ),
            OutlinedButton.icon(
              onPressed: () => HomeScreen._navigate(context, AppRoutes.createProject),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.25)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Proje oluştur'),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 18,
          runSpacing: 12,
          children: const [
            _HeroPerk(icon: Icons.check_circle_rounded, label: 'Ücretsiz katılım'),
            _HeroPerk(icon: Icons.groups_rounded, label: 'Ekip çalışması'),
          ],
        ),
      ],
    );
  }
}

class _HeroPerk extends StatelessWidget {
  const _HeroPerk({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.mint, size: 16),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HeroPreview extends StatelessWidget {
  const _HeroPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Topluluğundan seçkiler',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.mint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PreviewProjectTile(
            icon: Icons.eco_rounded,
            iconColor: const Color(0xFF69E0B3),
            title: 'EcoTrack',
            subtitle: 'Sürdürülebilirlik · 2 rol açık',
            tags: const ['Flutter', 'Firebase'],
          ),
          const SizedBox(height: 10),
          _PreviewProjectTile(
            icon: Icons.auto_awesome_rounded,
            iconColor: const Color(0xFF9FBFFF),
            title: 'DataLens AI',
            subtitle: 'Yapay zekâ · 3 rol açık',
            tags: const ['Python', 'AI'],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppTheme.mint.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppTheme.mint,
                  child: Icon(Icons.group_add_rounded, color: AppTheme.ink, size: 18),
                ),
                SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doğru ekiple tanış',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Fikrini bir sonraki seviyeye taşı.',
                        style: TextStyle(color: Color(0xFFD9DDF7), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: AppTheme.mint, size: 17),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewProjectTile extends StatelessWidget {
  const _PreviewProjectTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.tags,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF171A32).withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFB9BEDD), fontSize: 11),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final tag in tags)
                      Text(
                        tag,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFB9BEDD)),
        ],
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final items = const [
      _TrustItem(icon: Icons.lightbulb_outline_rounded, label: 'Fikrini paylaş'),
      _TrustItem(icon: Icons.people_alt_outlined, label: 'Ekip arkadaşını bul'),
      _TrustItem(icon: Icons.rocket_launch_outlined, label: 'Birlikte geliştir'),
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 17 : 22, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: isMobile
          ? Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  items[i],
                  if (i < items.length - 1) const SizedBox(height: 14),
                ],
              ],
            )
          : Row(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  Expanded(child: Center(child: items[i])),
                  if (i < items.length - 1)
                    Container(width: 1, height: 28, color: AppTheme.border),
                ],
              ],
            ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.softPurple,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.ink,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    required this.isMobile,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: isMobile ? 28 : 34,
              ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Text(description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.muted, fontSize: 14)),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.arrow_forward_rounded, size: 17),
              label: Text(actionLabel),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: heading),
        const SizedBox(width: 18),
        OutlinedButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.arrow_forward_rounded, size: 17),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _FeaturedProjectGrid extends StatelessWidget {
  const _FeaturedProjectGrid({required this.projects, required this.isMobile});
  final List<Project> projects;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          for (var i = 0; i < projects.length; i++) ...[
            SizedBox(
              height: 290,
              child: ProjectCard(
                project: projects[i],
                compact: true,
                onTap: () => HomeScreen._navigate(context, AppRoutes.projects),
              ),
            ),
            if (i < projects.length - 1) const SizedBox(height: 14),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < projects.length; i++) ...[
          Expanded(
            child: SizedBox(
              height: 310,
              child: ProjectCard(
                project: projects[i],
                onTap: () => HomeScreen._navigate(context, AppRoutes.projects),
              ),
            ),
          ),
          if (i < projects.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection({super.key, required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    const steps = [
      _StepData(
        number: '01',
        icon: Icons.travel_explore_rounded,
        title: 'Keşfet',
        description: 'İlgini çeken projeleri ve ekiplerin aradığı rolleri incele.',
        tint: AppTheme.softBlue,
        accent: Color(0xFF3478D4),
      ),
      _StepData(
        number: '02',
        icon: Icons.handshake_outlined,
        title: 'Katıl veya paylaş',
        description: 'Bir ekibe başvur ya da kendi fikrin için ekip arkadaşları ara.',
        tint: AppTheme.softPurple,
        accent: AppTheme.primary,
      ),
      _StepData(
        number: '03',
        icon: Icons.rocket_launch_rounded,
        title: 'Birlikte üret',
        description: 'Yeni beceriler kazan ve fikrini gerçek bir projeye dönüştür.',
        tint: Color(0xFFE5F8EF),
        accent: Color(0xFF159B78),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BASİT BİR BAŞLANGIÇ',
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Fikirden ekibe, üç adımda.',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: isMobile ? 28 : 34,
              ),
        ),
        const SizedBox(height: 24),
        if (isMobile)
          Column(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                _StepCard(data: steps[i]),
                if (i < steps.length - 1) const SizedBox(height: 13),
              ],
            ],
          )
        else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  Expanded(child: _StepCard(data: steps[i])),
                  if (i < steps.length - 1) const SizedBox(width: 16),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _StepData {
  const _StepData({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.tint,
    required this.accent,
  });

  final String number;
  final IconData icon;
  final String title;
  final String description;
  final Color tint;
  final Color accent;
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.data});
  final _StepData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: data.tint,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(data.icon, color: data.accent, size: 24),
              ),
              const Spacer(),
              Text(
                data.number,
                style: TextStyle(
                  color: data.accent.withOpacity(0.65),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(data.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(data.description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 22 : 34, vertical: 28),
      decoration: BoxDecoration(
        color: AppTheme.softPurple,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDFDFFF)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CtaCopy(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => HomeScreen._navigate(context, AppRoutes.register),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('DevHub’a katıl'),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const Expanded(child: _CtaCopy()),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () => HomeScreen._navigate(context, AppRoutes.register),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('DevHub’a katıl'),
                ),
              ],
            ),
    );
  }
}

class _CtaCopy extends StatelessWidget {
  const _CtaCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bir fikrin mi var?',
          style: TextStyle(
            color: AppTheme.ink,
            fontWeight: FontWeight.w800,
            fontSize: 23,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 7),
        Text(
          'İlk adımını bugün at. Ekibini bul, birlikte geliştirmeye başla.',
          style: TextStyle(color: AppTheme.muted, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return isMobile
        ? const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [_BrandMark(), SizedBox(width: 10), Text('DevHub', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.ink))]),
              SizedBox(height: 12),
              Text('Öğrenciler için, öğrencilerle birlikte.', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
              SizedBox(height: 10),
              Text('© DevHub · Üniversite projelerini birlikte geliştir.', style: TextStyle(color: AppTheme.muted, fontSize: 11)),
            ],
          )
        : const Row(
            children: [
              _BrandMark(),
              SizedBox(width: 10),
              Text('DevHub', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.ink)),
              SizedBox(width: 18),
              Text('Öğrenciler için, öğrencilerle birlikte.', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
              Spacer(),
              Text('© DevHub · Birlikte üret.', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
            ],
          );
  }
}
