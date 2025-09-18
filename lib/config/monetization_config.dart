/// Studio Wiz Monetization Configuration
/// Defines pricing, features, and subscription tiers
class MonetizationConfig {
  // App Store Pricing (USD)
  static const double freeVersionPrice = 0.0;
  static const double proVersionPrice = 19.99;
  static const double studioVersionPrice = 49.99;
  
  // Subscription Pricing (USD)
  static const double monthlySubscriptionPrice = 4.99;
  static const double yearlySubscriptionPrice = 49.99;
  
  // In-App Purchase Prices (USD)
  static const double premiumEffectsPrice = 2.99;
  static const double cloudStoragePrice = 1.99;
  static const double exportFormatsPrice = 2.99;
  static const double collaborationToolsPrice = 3.99;
  
  // Feature Limits
  static const int freeTrackLimit = 3;
  static const int freeProjectLimit = 5;
  static const int freeStorageLimitMB = 100;
  
  // Premium Features
  static const List<String> proFeatures = [
    'Unlimited tracks',
    'Advanced effects',
    'Cloud sync',
    'Export to multiple formats',
    'Priority support',
  ];
  
  static const List<String> studioFeatures = [
    'All Pro features',
    'AI-powered mastering',
    'Collaboration tools',
    'Advanced automation',
    'Plugin support',
    'Live performance mode',
  ];
  
  // Subscription Benefits
  static const List<String> subscriptionBenefits = [
    'All Pro features',
    'Cloud storage (10GB)',
    'Regular updates',
    'Priority support',
    'Beta access',
  ];
  
  // App Store IDs (replace with actual IDs when created)
  static const String androidProProductId = 'studio_wiz_pro';
  static const String androidStudioProductId = 'studio_wiz_studio';
  static const String androidMonthlySubscriptionId = 'studio_wiz_monthly';
  static const String androidYearlySubscriptionId = 'studio_wiz_yearly';
  
  static const String iosProProductId = 'studio_wiz_pro';
  static const String iosStudioProductId = 'studio_wiz_studio';
  static const String iosMonthlySubscriptionId = 'studio_wiz_monthly';
  static const String iosYearlySubscriptionId = 'studio_wiz_yearly';
  
  // Feature Flags
  static const bool enableInAppPurchases = true;
  static const bool enableSubscriptions = true;
  static const bool enableCloudSync = true;
  static const bool enableCollaboration = false; // Future feature
  
  // Trial Periods
  static const int freeTrialDays = 7;
  static const int gracePeriodDays = 3;
  
  // Revenue Optimization
  static const int maxFreeProjects = 3;
  static const int maxFreeTracks = 3;
  static const int maxFreeEffects = 5;
  
  // Upgrade Prompts
  static const int projectsBeforeUpgradePrompt = 2;
  static const int tracksBeforeUpgradePrompt = 2;
  static const int effectsBeforeUpgradePrompt = 3;
  
  // Analytics Events
  static const String eventUpgradePrompted = 'upgrade_prompted';
  static const String eventUpgradeCompleted = 'upgrade_completed';
  static const String eventSubscriptionStarted = 'subscription_started';
  static const String eventSubscriptionCancelled = 'subscription_cancelled';
  static const String eventFeatureLimitReached = 'feature_limit_reached';
  
  // A/B Testing
  static const bool enableABTesting = true;
  static const List<String> pricingVariants = [
    'standard',
    'premium',
    'value'
  ];
  
  // Localization
  static const Map<String, Map<String, String>> localizedPricing = {
    'en_US': {
      'pro': '\$19.99',
      'studio': '\$49.99',
      'monthly': '\$4.99/month',
      'yearly': '\$49.99/year',
    },
    'en_GB': {
      'pro': '£14.99',
      'studio': '£39.99',
      'monthly': '£3.99/month',
      'yearly': '£39.99/year',
    },
    'en_EU': {
      'pro': '€17.99',
      'studio': '€44.99',
      'monthly': '€4.49/month',
      'yearly': '€44.99/year',
    },
  };
  
  // Marketing Messages
  static const Map<String, String> upgradeMessages = {
    'tracks': 'Unlock unlimited tracks with Studio Wiz Pro',
    'projects': 'Create unlimited projects with Studio Wiz Pro',
    'effects': 'Access premium effects and processing tools',
    'export': 'Export to professional formats',
    'cloud': 'Sync your projects across all devices',
  };
  
  // Conversion Optimization
  static const int maxUpgradePromptsPerSession = 2;
  static const int upgradePromptCooldownHours = 24;
  static const bool showUpgradeOnAppLaunch = false;
  static const bool showUpgradeOnFeatureUse = true;
  
  // Support and Help
  static const String supportEmail = 'support@studiowiz.app';
  static const String billingEmail = 'billing@studiowiz.app';
  static const String refundPolicyUrl = 'https://studiowiz.app/refund-policy';
  static const String termsOfServiceUrl = 'https://studiowiz.app/terms';
  static const String privacyPolicyUrl = 'https://studiowiz.app/privacy';
}

