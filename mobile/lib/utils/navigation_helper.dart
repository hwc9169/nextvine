import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../view_model/auth_view_model.dart';

class NavigationHelper {
  static final Logger _logger = Logger();

  /// Navigate to login screen and clear all previous routes
  static void navigateToLogin(BuildContext context) {
    _logger.i('Navigating to login screen');

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false, // Remove all previous routes
    );
  }

  /// Show session expired dialog and navigate to login
  static void showSessionExpiredDialog(BuildContext context) {
    _logger.i('Showing session expired dialog');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session Expired'),
          content: const Text(
            'Your session has expired. Please sign in again to continue using the app.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                navigateToLogin(context);
              },
              child: const Text('Sign In'),
            ),
          ],
        );
      },
    );
  }

  /// Handle authentication errors and redirect to login
  static void handleAuthError(BuildContext context, String error) {
    _logger.e('Authentication error: $error');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authentication Error'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                navigateToLogin(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Check if user is authenticated before navigation
  static bool isAuthenticated(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    return authViewModel.isSignedIn;
  }

  /// Secure navigation that checks authentication first
  static void secureNavigate(BuildContext context, String routeName,
      {Object? arguments}) {
    if (isAuthenticated(context)) {
      Navigator.of(context).pushNamed(routeName, arguments: arguments);
    } else {
      _logger.w('Attempted navigation without authentication');
      showSessionExpiredDialog(context);
    }
  }

  /// Logout user and navigate to login
  static Future<void> logoutAndNavigateToLogin(BuildContext context) async {
    _logger.i('Logging out user');

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.signOut();

      // Check if context is still mounted before navigating
      if (context.mounted) {
        navigateToLogin(context);
      }
    } catch (error) {
      _logger.e('Error during logout: $error');
      // Still navigate to login even if logout fails
      if (context.mounted) {
        navigateToLogin(context);
      }
    }
  }
}
