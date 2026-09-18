import 'package:flutter/material.dart';

import '../../../../core/layout/responsive.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../widgets/dashboard_tile.dart';

/// Page opened from Quick Access "View All".
/// Same surface color as the home dashboard; extra modules as dashboard tiles.
class ViewAllModulesScreen extends StatelessWidget {
  const ViewAllModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final columns = context.dashboardColumns().clamp(2, 3);
    final hPad = context.isCompact ? 12.0 : 16.0;
    final theme = Theme.of(context);

    // Match home dashboard (`scheme.surface`) — avoid scaffold grey split.
    return Theme(
      data: theme.copyWith(scaffoldBackgroundColor: scheme.surface),
      child: PakFasalScaffold(
        title: l10n.t('viewAll'),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final spacing = 10.0;
            final tileWidth =
                (constraints.maxWidth - hPad * 2 - (columns - 1) * spacing) /
                    columns;
            final tileHeight = tileWidth * 1.05;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 8),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppBreakpoints.maxContentWidth,
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: columns,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: tileWidth / tileHeight,
                    children: [
                      DashboardTile(
                        imageAsset:
                            'assets/images/dashboard/tile_govt_schemes.png',
                        title: l10n.t('govtSchemes'),
                        imageScale: 1.08,
                        showLightBackdrop: true,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.govtSchemes,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
