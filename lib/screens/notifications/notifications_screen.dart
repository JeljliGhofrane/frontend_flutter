import 'package:flutter/material.dart';
import 'package:nettemp_guard/generated/l10n.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/notifications_provider.dart';
import '../../services/notifications_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _filter = 0; // 0=all, 1=unread

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final provider = context.watch<NotificationsProvider>();
    final all = provider.items;
    final items = _filter == 1 ? all.where((n) => !n.read).toList() : all;

    return Scaffold(
      backgroundColor: pageBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 128,
            backgroundColor: AppColors.navyDark,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D2557), Color(0xFF1055CC)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 18,
                      right: 16,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.notificationsTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  provider.unreadCount == 0
                                      ? 'Aucune alerte non lue'
                                      : '${provider.unreadCount} non lue(s)',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.60),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (provider.unreadCount > 0)
                            TextButton(
                              onPressed: provider.markAllRead,
                              child: Text(
                                l10n.markAllRead,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _FilterPills(
                    selected: _filter,
                    onChanged: (v) => setState(() => _filter = v),
                    border: border,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),

                  // Actions (test backend + demo local)
                  _ActionsRow(
                    cardBg: cardBg,
                    border: border,
                    isDark: isDark,
                    onSendBackend: () async {
                      final err = await NotificationsService().sendDangerTemperatureNotification();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(err ?? 'Notification envoyée ✅'),
                        backgroundColor: err == null ? AppColors.success : AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ));
                    },
                    onAddDemo: () async {
                      await NotificationsService().addLocalDemoNotification(context.read<NotificationsProvider>());
                    },
                    onClear: provider.clear,
                  ),

                  const SizedBox(height: 12),

                  if (items.isEmpty)
                    _EmptyState(cardBg: cardBg, border: border, isDark: isDark)
                  else
                    ...items.map((n) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _NotificationTile(
                            id: n.id,
                            title: n.title,
                            body: n.body,
                            time: _timeAgo(n.createdAt),
                            read: n.read,
                            icon: n.icon,
                            color: n.color(Theme.of(context).colorScheme),
                            cardBg: cardBg,
                            border: border,
                            isDark: isDark,
                            onTap: () => context.read<NotificationsProvider>().markRead(n.id),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'À l’instant';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return '${diff.inDays} j';
  }
}

class _FilterPills extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  final Color border;
  final bool isDark;
  const _FilterPills({
    required this.selected,
    required this.onChanged,
    required this.border,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkCard : Colors.white;
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondary =
        isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.75) : AppColors.lightTextSecondary;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border.withValues(alpha: isDark ? 0.7 : 1)),
      ),
      child: Row(
        children: [
          _pill(
            context,
            label: 'Tout',
            selected: selected == 0,
            text: text,
            secondary: secondary,
            onTap: () => onChanged(0),
          ),
          const SizedBox(width: 8),
          _pill(
            context,
            label: 'Non lues',
            selected: selected == 1,
            text: text,
            secondary: secondary,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }

  Widget _pill(
    BuildContext context, {
    required String label,
    required bool selected,
    required Color text,
    required Color secondary,
    required VoidCallback onTap,
  }) {
    final accent = Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: selected ? Border.all(color: accent.withValues(alpha: 0.22)) : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? text : secondary,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final Color cardBg;
  final Color border;
  final bool isDark;
  final VoidCallback onSendBackend;
  final VoidCallback onAddDemo;
  final VoidCallback onClear;
  const _ActionsRow({
    required this.cardBg,
    required this.border,
    required this.isDark,
    required this.onSendBackend,
    required this.onAddDemo,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final secondary =
        isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.75) : AppColors.lightTextSecondary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border.withValues(alpha: isDark ? 0.7 : 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: TextStyle(
              color: secondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Test Backend',
                  icon: Icons.wifi_tethering_rounded,
                  color: AppColors.navyMid,
                  onTap: onSendBackend,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: 'Démo Local',
                  icon: Icons.add_alert_rounded,
                  color: AppColors.success,
                  onTap: onAddDemo,
                ),
              ),
              const SizedBox(width: 10),
              _ActionIconButton(
                icon: Icons.delete_outline_rounded,
                color: AppColors.error,
                onTap: onClear,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: title, fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionIconButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color cardBg;
  final Color border;
  final bool isDark;
  const _EmptyState({required this.cardBg, required this.border, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final title = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondary =
        isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.75) : AppColors.lightTextSecondary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border.withValues(alpha: isDark ? 0.7 : 1)),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.navyMid.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.notifications_off_rounded, color: AppColors.navyMid, size: 28),
          ),
          const SizedBox(height: 12),
          Text('Rien à signaler', style: TextStyle(color: title, fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            'Les alertes reçues apparaîtront ici.',
            textAlign: TextAlign.center,
            style: TextStyle(color: secondary, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String id;
  final String title;
  final String body;
  final String time;
  final bool read;
  final IconData icon;
  final Color color;
  final Color cardBg;
  final Color border;
  final bool isDark;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.read,
    required this.icon,
    required this.color,
    required this.cardBg,
    required this.border,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondary =
        isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.75) : AppColors.lightTextSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: read ? border.withValues(alpha: isDark ? 0.45 : 0.85) : color.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.16)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: titleColor,
                            fontWeight: read ? FontWeight.w700 : FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (!read)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(body, style: TextStyle(color: secondary, fontSize: 12, height: 1.4)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 14, color: secondary.withValues(alpha: 0.8)),
                      const SizedBox(width: 6),
                      Text(time, style: TextStyle(color: secondary, fontSize: 11, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: color.withValues(alpha: 0.16)),
                        ),
                        child: Text(
                          read ? 'Lu' : 'Nouveau',
                          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}