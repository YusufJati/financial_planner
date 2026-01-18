import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'text_styles.dart';
import 'radius.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          surface: AppColors.surface,
          error: AppColors.expense,
        ),
        textTheme: AppTextStyles.textTheme,
        fontFamily: GoogleFonts.spaceMono().fontFamily,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.silkscreen(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusSm,
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusSm,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusSm,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusSm,
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: GoogleFonts.spaceMono(color: AppColors.textSecondary),
          hintStyle: GoogleFonts.spaceMono(color: AppColors.textTertiary),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusXxl,
            side: const BorderSide(color: AppColors.border),
          ),
          titleTextStyle:
              AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
          contentTextStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primary,
          contentTextStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.surface),
          actionTextColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          elevation: 2,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          textStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusSm,
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusSm,
              side: const BorderSide(color: AppColors.primaryDark),
            ),
            textStyle: AppTextStyles.labelLarge,
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: GoogleFonts.spaceMono(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primarySoft,
          elevation: 0,
          height: 68,
          labelTextStyle: MaterialStateProperty.all(
            GoogleFonts.spaceMono(
              fontSize: 11,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconTheme: MaterialStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(MaterialState.selected)
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusSm,
          ),
          elevation: 2,
        ),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: AppColors.primary),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surface,
          labelStyle: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusSm,
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          surface: AppColors.surfaceDark,
          error: AppColors.expense,
        ),
        textTheme: AppTextStyles.textTheme,
        fontFamily: GoogleFonts.spaceMono().fontFamily,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.silkscreen(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryDark,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusSm,
            side: const BorderSide(color: AppColors.borderDark),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusSm,
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusSm,
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusSm,
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: GoogleFonts.spaceMono(color: AppColors.textSecondaryDark),
          hintStyle: GoogleFonts.spaceMono(color: AppColors.textSecondaryDark),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceDark,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusXxl,
            side: const BorderSide(color: AppColors.borderDark),
          ),
          titleTextStyle:
              AppTextStyles.h4.copyWith(color: AppColors.textPrimaryDark),
          contentTextStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondaryDark),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primary,
          contentTextStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.surface),
          actionTextColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          elevation: 2,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.surfaceDark,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            side: const BorderSide(color: AppColors.borderDark),
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.surfaceDark,
          surfaceTintColor: Colors.transparent,
          textStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimaryDark,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusSm,
            side: const BorderSide(color: AppColors.borderDark),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusSm,
              side: const BorderSide(color: AppColors.primaryDark),
            ),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textPrimaryDark,
            textStyle: GoogleFonts.spaceMono(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          indicatorColor: AppColors.primary.withAlpha(40),
          elevation: 0,
          height: 68,
          labelTextStyle: MaterialStateProperty.all(
            GoogleFonts.spaceMono(
              fontSize: 11,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconTheme: MaterialStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(MaterialState.selected)
                  ? AppColors.textPrimaryDark
                  : AppColors.textSecondaryDark,
            ),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondaryDark,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusSm,
          ),
          elevation: 2,
        ),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: AppColors.primary),
        dividerTheme: const DividerThemeData(
          color: AppColors.borderDark,
          thickness: 1,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceDark,
          labelStyle: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textPrimaryDark,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusSm,
            side: const BorderSide(color: AppColors.borderDark),
          ),
        ),
      );
}
