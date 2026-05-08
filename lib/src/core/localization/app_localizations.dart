import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ur')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    return localizations ?? AppLocalizations(const Locale('en'));
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'PakFasal',
      'welcome': 'Welcome to PakFasal',
      'login': 'Login',
      'signup': 'Sign Up',
      'or': 'OR',
      'email': 'Email',
      'username': 'Username',
      'usernameHint': 'John Doe',
      'emailHint': 'you@example.com',
      'password': 'Password',
      'passwordHint': '••••••••',
      'phone': 'Phone (Optional)',
      'phoneHint': '+92 300 0000000',
      'forgotPassword': 'Forgot Password?',
      'rememberMe': 'Remember Me',
      'requireBiometricAutofill': 'Require biometric unlock for autofill',
      'rememberMeHint':
          'Credentials are encrypted on this device. Biometric unlock may be required.',
      'resetPassword': 'Reset Password',
      'resetPasswordHint':
          'Enter your email address and we will send you a password reset link.',
      'sending': 'Sending...',
      'backToLogin': 'Back to Login',
      'home': 'Home',
      'learning': 'Learning',
      'learningDashboardHint': 'Pick a topic to start learning',
      'learningHubEyebrow': 'PakFasal · Learning Hub',
      'learningTopicsLabel': 'TOPICS',
      'learningHeadlineQuestion': 'What would you like\nto learn?',
      'learningTipBoldPrefix': 'New topics weekly. ',
      'learningTipRest':
          'Content is curated for Pakistani farmers — in Urdu and English.',
      'learningStatusAvailable': 'Available',
      'learningOptionYoutubeDesc': 'Expert tutorials by crop',
      'learningOptionArticlesDesc': 'Guides, tips & research',
      'learningOptionPestsDesc': 'Identify & treat problems',
      'learningOptionCropStagesDesc': 'Growth & harvest timelines',
      'learningYoutubeVideos': 'YouTube Learning Videos',
      'learningOptionYoutube': 'YouTube Learning Videos',
      'learningOptionArticles': 'Learning Articles',
      'learningOptionPests': 'Keera (Pests) aur Bimariyaan',
      'learningOptionCropStages': 'Fasal Ki Kasht Ke Marahil',
      'comingSoon': 'Coming soon',
      'cropDiseasePickCrop': 'Choose a crop',
      'cropDiseasePickCropHint':
          'Tap a crop to see common diseases, symptoms, and treatment tips.',
      'cropDiseaseMoreCropsSoon': 'More crops coming soon.',
      'cropDiseaseDetailSubtitle': 'Common diseases & treatment tips',
      'cropDiseaseSymptoms': 'Symptoms',
      'cropDiseaseSolution': 'Treatment',
      'cropDiseaseTopicsShort': 'topics',
      'cdCottonLcvName': 'Leaf Curl Virus',
      'cdCottonLcvDesc':
          'A viral disease spread by whiteflies that stunts growth and distorts leaves.',
      'cdCottonLcvSym1': 'Leaves curl upward or downward',
      'cdCottonLcvSym2': 'Plant growth is stunted',
      'cdCottonLcvSol1': 'Use resistant seed varieties',
      'cdCottonLcvSol2': 'Control whitefly populations',
      'cdCottonBollName': 'Boll Rot',
      'cdCottonBollDesc':
          'Fungal decay of cotton bolls, common in warm humid conditions.',
      'cdCottonBollSym1': 'Bolls soften and rot',
      'cdCottonBollSym2': 'Discoloration on bolls',
      'cdCottonBollSol1': 'Maintain proper irrigation — avoid waterlogging',
      'cdCottonBollSol2': 'Apply recommended fungicide sprays',
      'cdCottonWfName': 'Whitefly Attack',
      'cdCottonWfDesc':
          'Sap-sucking pests that weaken plants and spread viral diseases.',
      'cdCottonWfSym1': 'Yellowing leaves',
      'cdCottonWfSym2': 'Sticky honeydew on leaves',
      'cdCottonWfSol1': 'Use approved insecticides as directed',
      'cdCottonWfSol2': 'Neem-based sprays as a supplementary measure',
      'cdWheatRustName': 'Rust Disease',
      'cdWheatRustDesc':
          'Fungal infection producing rusty pustules on leaves and stems.',
      'cdWheatRustSym1': 'Orange or brown spots on leaves',
      'cdWheatRustSol1': 'Plant rust-resistant varieties',
      'cdWheatRustSol2': 'Apply fungicides when advised',
      'cdWheatSmutName': 'Smut Disease',
      'cdWheatSmutDesc':
          'Fungal disease that replaces grains with black spore masses.',
      'cdWheatSmutSym1': 'Black powder inside affected grains',
      'cdWheatSmutSol1': 'Treat seed before sowing',
      'cdWheatAphidName': 'Aphid Attack',
      'cdWheatAphidDesc':
          'Small insects that suck sap and can transmit viruses.',
      'cdWheatAphidSym1': 'Weak, stunted plants',
      'cdWheatAphidSym2': 'Curled or distorted leaves',
      'cdWheatAphidSol1':
          'Apply insecticide spray when thresholds are reached',
      'cdRiceBlbName': 'Bacterial Leaf Blight',
      'cdRiceBlbDesc':
          'Bacterial infection that spreads quickly in warm humid weather.',
      'cdRiceBlbSym1': 'Yellowing and drying of leaf edges',
      'cdRiceBlbSol1': 'Improve field drainage',
      'cdRiceBlbSol2': 'Use resistant seed varieties',
      'cdRiceBlastName': 'Blast Disease',
      'cdRiceBlastDesc':
          'Major fungal disease affecting leaves, nodes, and panicles.',
      'cdRiceBlastSym1': 'Diamond-shaped spots on leaves',
      'cdRiceBlastSol1': 'Timely fungicide application',
      'cdRiceBlastSol2': 'Balanced fertilizer use',
      'cdRiceBorerName': 'Stem Borer',
      'cdRiceBorerDesc':
          'Larvae tunnel inside stems and disrupt water and nutrient flow.',
      'cdRiceBorerSym1': 'Dead heart in young plants',
      'cdRiceBorerSol1':
          'Pheromone traps for monitoring and mass trapping',
      'cdRiceBorerSol2': 'Insecticides when economically justified',
      'weather': 'Weather',
      'askAi': 'Ask AI',
      'sensorData': 'Sensor Data',
      'marketplace': 'Marketplace',
      'cropCalendar': 'Crop Calendar',
      'offline': 'Offline',
      'online': 'Online',
      'cached': 'Cached',
      'lightMode': 'Light Mode',
      'darkMode': 'Dark Mode',
      'language': 'Language',
      'chat': 'Chat',
      'alerts': 'Alerts',
      'profile': 'Profile',
      'saveChanges': 'Save Changes',
      'saving': 'Saving...',
      'profileUpdated': 'Profile updated successfully.',
      'voice': 'Voice',
      'notifications': 'Notifications',
      'quickAccess': 'Quick Access',
      'goodMorning': 'Good Morning!',
      'goodAfternoon': 'Good Afternoon!',
      'goodEvening': 'Good Evening!',
      'appTagline': 'Smart Farming, Better Tomorrow',
      'notificationIrrigationReminder':
          'Irrigation reminder: Check soil moisture today.',
      'notificationWeatherAlert':
          'Weather alert: Possible rain in next 24 hours.',
      'notificationMarketplaceOffer':
          'Marketplace: New fertilizer offer available.',
      'feelsLike': 'Feels like',
      'updatedJustNow': 'Updated just now',
      'wind': 'Wind',
      'latest': 'Latest',
      'dayShort': 'D',
      'temperature': 'Temperature',
      'humidity': 'Humidity',
      'rainChance': 'Rain Chance',
      'weatherClear': 'Clear',
      'weatherCloudy': 'Cloudy',
      'weatherRain': 'Rain',
      'weatherSnow': 'Snow',
      'weatherStorm': 'Storm',
      'weatherGeneral': 'Weather',

      // ── Weather screen redesign ──
      'weatherToday': 'Today',
      'weatherTomorrow': 'Tomorrow',
      'weatherNow': 'Now',
      'weatherHourlyTitle': 'Hourly forecast',
      'weather7DayTitle': '7-day forecast',
      'weatherHighlights': 'Today\u2019s highlights',
      'weatherSunrise': 'Sunrise',
      'weatherSunset': 'Sunset',
      'weatherUVIndex': 'UV Index',
      'weatherUVLow': 'Low',
      'weatherUVModerate': 'Moderate',
      'weatherUVHigh': 'High',
      'weatherUVVeryHigh': 'Very high',
      'weatherUVExtreme': 'Extreme',
      'weatherAirQuality': 'Air quality',
      'weatherPressure': 'Pressure',
      'weatherVisibility': 'Visibility',
      'weatherDewPoint': 'Dew point',
      'weatherCloudCover': 'Cloud cover',
      'weatherHigh': 'H',
      'weatherLow': 'L',
      'weatherMinMax': 'Min/Max',
      'weatherRefresh': 'Refresh',
      'weatherSearchCity': 'Search city',
      'weatherSearchCityHint': 'Type a city name (e.g. Lahore)',
      'weatherUseCurrentLocation': 'Use current location',
      'weatherSavedLocations': 'Saved locations',
      'weatherRemove': 'Remove',
      'weatherNoSearchResults': 'No matching cities found.',
      'dowMon': 'Mon',
      'dowTue': 'Tue',
      'dowWed': 'Wed',
      'dowThu': 'Thu',
      'dowFri': 'Fri',
      'dowSat': 'Sat',
      'dowSun': 'Sun',
      'weatherSearchError': 'Could not search cities. Try again.',
      'weatherLocationDenied': 'Location permission is required.',
      'weatherLocationDisabled': 'Please turn on device location services.',
      'weatherOpenSettings': 'Open settings',
      'weatherOfflineNotice':
          'You\u2019re offline. Showing last saved weather.',
      'weatherFetchError':
          'Could not load latest weather. Pull down to retry.',
      'weatherNoApiKeyNotice':
          'OPENWEATHER_API_KEY not set. Using free fallback provider.',
      'weatherCancel': 'Cancel',

      // ── Crop alerts ──
      'cropAlertHeavyRain': 'Heavy rain alert',
      'cropAlertHeavyRainBody':
          'Heavy rainfall expected. Postpone irrigation and secure produce.',
      'cropAlertHeatwave': 'Heatwave alert',
      'cropAlertHeatwaveBody':
          'Extreme heat expected. Irrigate early morning and protect young crops.',
      'cropAlertHighWind': 'High wind alert',
      'cropAlertHighWindBody':
          'Strong winds expected. Avoid spraying and secure field covers.',
      'cropAlertFrost': 'Frost warning',
      'cropAlertFrostBody':
          'Frost likely tonight. Protect sensitive crops and seedlings.',
      'cropAlertThunderstorm': 'Thunderstorm warning',
      'cropAlertThunderstormBody':
          'Thunderstorms expected. Stay away from open fields and tall trees.',

      // ── Farmer advisories ──
      'farmerAdvisory': 'Farmer advisory',
      'advisoryGoodIrrigation': 'Good day for irrigation',
      'advisoryGoodIrrigationBody':
          'Mild temperature with low rain chance. Ideal window to water your fields.',
      'advisoryAvoidIrrigation': 'Skip irrigation today',
      'advisoryAvoidIrrigationBody':
          'Rain expected within 24 hours \u2014 save water and let nature do the work.',
      'advisoryAvoidSpraying': 'Avoid pesticide spray today',
      'advisoryAvoidSprayingBody':
          'High wind or rain reduces spray efficiency and may harm nearby crops.',
      'advisoryGoodSpraying': 'Good window for spraying',
      'advisoryGoodSprayingBody':
          'Calm winds and dry weather \u2014 a safe time to apply pesticides early morning.',
      'advisoryRainTomorrow': 'Rain expected tomorrow',
      'advisoryRainTomorrowBody':
          'Plan field operations today; harvest mature produce if possible.',
      'advisoryHarvestWindow': 'Good harvest window',
      'advisoryHarvestWindowBody':
          'Dry, mild weather expected next 48 hours. Plan harvesting accordingly.',
      'advisoryProtectFromHeat': 'Protect crops from heat',
      'advisoryProtectFromHeatBody':
          'Use mulching and irrigate early morning to reduce heat stress.',

      // ── Misc weather UI ──
      'mph': 'mph',
      'kmh': 'km/h',
      'percent': '%',
      'degreeC': '°C',
      'hpa': 'hPa',
      'km': 'km',
      'soilMoisture': 'Soil Moisture',
      'phLevel': 'pH Level',
      'contact': 'Contact',
      'send': 'Send',
      'typeMessage': 'Type your question...',
      'listening': 'Listening...',
      'voiceInputUnavailable':
          'Voice input is unavailable. Please allow microphone permission.',
      'voicePermissionDenied':
          'Microphone permission is denied. Enable it from app settings.',
      'voiceServiceUnavailable':
          'Speech service is unavailable on this device. Please install/update Google Speech services.',
      'voiceInputStartFailed':
          'Could not start voice input. Please try again.',
      'voiceTapToSpeak': 'Tap mic to speak',
      'voiceListeningNow': 'Listening... speak now',
      'voiceProcessing': 'Processing voice input...',
      'openSettings': 'Open Settings',
      'good': 'Good',
      'moderate': 'Moderate',
      'bad': 'Bad',
      'errorState': 'Something went wrong.',
      'retry': 'Retry',
      'loading': 'Loading...',
      'learningSubtitle': 'Trusted farming videos by crop category',
      'featuredLearning': 'Featured Lesson',
      'watchNow': 'Watch Now',
      'learningEmpty': 'No videos found for this category yet.',
      'learningFilterByCrop': 'Filter by crop',
      'learningSearchHint': 'Search videos by title or channel...',
      'learningNoSearchResults': 'No videos match your search.',
      'learningDemoMode':
          'Demo videos are shown. Add YOUTUBE_API_KEY using --dart-define to load live YouTube data.',
      'marketSearchHint': 'Search product name',
      'marketFilterCompany': 'Filter by company',
      'marketOfflineCached': 'Showing cached products while offline.',
      'marketNoProducts': 'No products match your search or filters.',
      'marketCompany': 'Company',
      'marketCategory': 'Category',
      'marketDetail': 'Product Detail',
      'marketLocation': 'Location',
      'callCompany': 'Call Company',
      'whatsapp': 'WhatsApp',
      'verified': 'Verified',
      'soilMoistureTrend': 'Soil Moisture Trend (7 days)',
      'phTrend': 'pH Trend (7 days)',
      'dssRecommendation': 'Smart Recommendation',
      'sensorRecommendationText':
          'Soil moisture is healthy. Keep next irrigation after 24-36 hours and apply balanced fertilizer this week.',
      'lastUpdated': 'Last updated',
      'sensorCloudLive': 'Live cloud sensor stream connected.',
      'sensorCloudError': 'Cloud unavailable. Showing cached/demo sensor data.',
      'sensorManualInputTitle': 'Manual Sensor Input',
      'sensorCropLabel': 'Crop',
      'sensorMoistureInput': 'Soil Moisture (%)',
      'sensorPhInput': 'Soil pH',
      'sensorRainExpected': 'Rain expected in next 24 hours',
      'sensorGenerateDss': 'Generate DSS Recommendation',
      'sensorSaveSession': 'Save Session',
      'sensorExportReadings': 'Export Readings',
      'sensorSessionSaved': 'Sensor session saved.',
      'sensorCopiedClipboard': 'Readings copied as CSV to clipboard.',
      'sensorRecIrrigateSoon': 'Irrigation needed within 12-24 hours',
      'sensorRecWaitRain':
          'Moisture is low but rain is expected, wait and recheck',
      'sensorRecReduceIrrigation':
          'Reduce irrigation frequency to avoid water logging',
      'sensorRecMoistureOk': 'Moisture is in acceptable range',
      'sensorRecAcidic': 'Soil is acidic, add lime and balanced fertilizer',
      'sensorRecAlkaline': 'Soil is alkaline, apply gypsum and organic matter',
      'sensorRecPhSuitable': 'pH is suitable for',
      'splashTagline': 'Smart farming for Pakistan',
      'authSubtitle': 'Sign in to continue',
      'continueAsGuest': 'Continue as Guest',
      'authSignOut': 'Sign out',
      'authLoggingIn': 'Signing in...',
      'authCreatingAccount': 'Creating account...',
      'emailRequired': 'Email is required',
      'usernameRequired': 'Username is required',
      'usernameMinLength': 'Username must be at least 3 characters',
      'passwordMin': 'Minimum 6 characters required',
      'weakPasswordForm': 'Password must be at least 6 characters',
      'invalidEmail': 'Enter a valid email address',
      'userDisabled': 'This account has been disabled.',
      'userNotFound': 'No account found for this email.',
      'wrongPassword': 'Incorrect password. Try again.',
      'emailInUse': 'This email is already registered.',
      'weakPasswordAuth': 'Password is too weak.',
      'tooManyRequests': 'Too many attempts. Try again later.',
      'networkFailed': 'Network error. Check your connection.',
      'authUnknown': 'Authentication failed. Please try again.',
      'resetEmailSent': 'Password reset link sent to your email.',
      'confirmPassword': 'Confirm password',
      'confirmPasswordRequired': 'Please confirm your password',
      'passwordsMismatch': 'Passwords do not match.',
      'invalidPhone': 'Enter a valid phone number',
      'selectCrop': 'Select Crop',
      'cropWheat': 'Wheat',
      'cropRice': 'Rice',
      'cropCotton': 'Cotton',
      'cropSugarcane': 'Sugarcane',
      'cropMaize': 'Maize',
      'couldNotOpenVideo': 'Could not open video link',
      'couldNotOpenDialer': 'Could not open dialer',
      'couldNotOpenWhatsapp': 'Could not open WhatsApp',
      'aiSampleQuestion': 'How to save wheat from pests?',
      'aiSampleAnswer':
          'Use approved pesticide early morning and monitor weekly.',
      'aiPendingResponse':
          'Thanks! AI response will be connected in backend integration.',
      'aiHistory': 'History',
      'aiNewChat': 'New chat',
      'aiNoMessagesTitle': 'Start your first AI chat',
      'aiNoMessagesSubtitle':
          'Ask about crops, pests, weather, or fertilizer recommendations.',
      'aiAssistantLabel': 'PakFasal AI',
      'aiYouLabel': 'You',
      'aiHistoryLoaded': 'Chat history loaded',
      'aiTyping': 'AI is typing...',
      'skip': 'Skip',
      'next': 'Next',
      'getStarted': 'Get Started',
      'onboardingTitle1': 'Weather-smart crop planning',
      'onboardingDesc1':
          'Get daily weather updates and farm-friendly insights before every field decision.',
      'onboardingTitle2': 'Learn better farming practices',
      'onboardingDesc2':
          'Watch trusted lessons by crop type and improve yield with practical guidance.',
      'onboardingTitle3': 'Track your farm with confidence',
      'onboardingDesc3':
          'Use sensor trends and recommendations to plan irrigation and soil care on time.',
      // ── Crop Calendar — UI ─────────────────────────────────────────────
      'cropCalendarRegion': 'Punjab area',
      'cropCalendarRegionLahore': 'Lahore (Central Punjab)',
      'cropCalendarRegionMultan': 'Multan (South Punjab)',
      'cropCalendarSetSowingDate': 'Set sowing date',
      'cropCalendarChangeSowingDate': 'Change date',
      'cropCalendarSowingDateLabel': 'Sowing date',
      'cropCalendarHarvestEta': 'Estimated harvest',
      'cropCalendarRecommendedWindow': 'Recommended sowing window',
      'cropCalendarSeasonProgress': 'Season progress',
      'cropCalendarDaysSinceSowing': 'Days since sowing',
      'cropCalendarDaysToHarvest': 'Days to harvest',
      'cropCalendarTodayBadge': 'TODAY',
      'cropCalendarStatusPast': 'Done',
      'cropCalendarStatusCurrent': 'In progress',
      'cropCalendarStatusUpcoming': 'Upcoming',
      'cropCalendarNoSowingTitle': 'Personalize your calendar',
      'cropCalendarNoSowingHint':
          'Tap below to choose when you sowed (or plan to sow) this crop. Stages and reminders will be calculated from that date.',
      'cropCalendarStartsIn': 'Starts in',
      'cropCalendarEndedAgo': 'Ended',
      'cropCalendarDaysShort': 'd',
      'cropCalendarReset': 'Reset plan',
      'cropCalendarResetConfirmTitle': 'Reset sowing plan?',
      'cropCalendarResetConfirmBody':
          'This will clear the sowing date and any saved reminders for this crop.',
      'cropCalendarPlanSaved': 'Sowing plan saved',
      'cropCalendarPlanCleared': 'Plan cleared',
      'cropCalendarRegionalNote': 'Regional note',
      'cropCalendarReminderToggle': 'Notify me when stages start',
      'cropCalendarReminderHint':
          'Push notifications will arrive when each stage begins.',
      'cropCalendarBeforeSowing': 'Before sowing',
      'cropCalendarAfterHarvest': 'Season finished',
      'cropCalendarTodayLabel': 'Today',
      'cropCalendarCancel': 'Cancel',
      'cropCalendarConfirm': 'Confirm',
      'cropCalendarMonthsLabel': 'Months',
      'cropCalendarStageWindow': 'Stage window',
      // ── Crop Calendar — shared stage names ─────────────────────────────
      'stageLandPrep': 'Land Preparation',
      'stageNursery': 'Nursery',
      'stageSowing': 'Sowing',
      'stageTransplanting': 'Transplanting',
      'stageIrrigation1': 'First Irrigation',
      'stageIrrigation2': 'Second Irrigation',
      'stageIrrigation3': 'Third Irrigation',
      'stageIrrigation4': 'Fourth Irrigation',
      'stageFertilizer1': 'First Fertilizer',
      'stageFertilizer2': 'Second Fertilizer',
      'stageWeeding': 'Weeding & Thinning',
      'stageEarthingUp': 'Earthing Up',
      'stageTying': 'Tying',
      'stagePestControl': 'Pest Control',
      'stageHarvest': 'Harvest',
      'stagePicking1': 'First Picking',
      'stagePicking2': 'Second Picking',
      // ── Crop Calendar — per-area regional notes ───────────────────────
      'wheatLahoreNote':
          'Central Punjab is cooler. Sow Oct 25 – Nov 15 for best tillering. Late sowing reduces yield sharply.',
      'wheatMultanNote':
          'South Punjab is hotter. Sow Nov 1 – Nov 25 to keep grain-fill in cooler weather and avoid March heat stress.',
      'riceLahoreNote':
          'Basmati belt. Raise nursery around May 15; transplant Jun 15 – Jul 5. Use Super Basmati or Kainat varieties.',
      'riceMultanNote':
          'Less common here — most farmers prefer cotton. If grown, use IRRI-6 / IRRI-9 and transplant in May for cooler grain-fill.',
      'cottonLahoreNote':
          'Cotton sows Apr 20 – May 20 in Central Punjab. Cooler nights slow establishment — always use fungicide-treated Bt seed.',
      'cottonMultanNote':
          'Core cotton zone of Pakistan. Sow Apr 1 – May 5 — early sowing avoids monsoon boll-rot and pink boll-worm peak.',
      'sugarcaneLahoreNote':
          'Spring (Feb–Mar) gives an 11-month crop. Autumn (Sep–Oct) yields better but ties up land longer.',
      'sugarcaneMultanNote':
          'Autumn planting (Sep–Oct) is recommended — escapes the summer heat stress that hurts germination here.',
      'maizeLahoreNote':
          'Spring: late Feb – mid March. Autumn: Jul 20 – Aug 10. Use hybrid seed for both seasons.',
      'maizeMultanNote':
          'Spring sowing is risky (heat at flowering). Prefer autumn Aug 1 – Aug 25 with heat-tolerant hybrids.',
      // ── Crop Calendar — Wheat ─────────────────────────────────────────
      'wheatLandPrepDesc':
          'Plough deep twice, level the field, and apply 2–3 trolleys of farmyard manure per acre.',
      'wheatSowingDesc':
          '50 kg/acre treated seed, line spacing 22 cm, depth 5 cm. Apply 1 bag DAP + 1/3 bag Urea at sowing.',
      'wheatIrrigation1Desc':
          'Crown root irrigation 21–25 days after sowing — the most critical irrigation for tillering and yield.',
      'wheatFertilizer1Desc':
          'Top-dress 1 bag Urea per acre at first irrigation while soil is moist.',
      'wheatIrrigation2Desc':
          'Tillering-stage irrigation around day 60. Skip if rain has wet the field within 48 hours.',
      'wheatIrrigation3Desc':
          'Booting / heading irrigation — critical for grain fill. Avoid during strong winds to prevent lodging.',
      'wheatHarvestDesc':
          'Harvest when grains are hard and golden (moisture < 15%). A combine harvester is preferred to reduce loss.',
      // ── Crop Calendar — Rice ──────────────────────────────────────────
      'riceNurseryDesc':
          'Sow 8–10 kg seed per acre in a well-prepared nursery bed 25 days before transplanting.',
      'riceLandPrepDesc':
          'Puddle the field with 5–7 cm standing water and level it perfectly so water depth stays uniform.',
      'riceTransplantingDesc':
          'Transplant 25-day-old seedlings, 2–3 per hill at 22×22 cm spacing.',
      'riceFertilizer1Desc':
          'Apply 1 bag DAP + 1/3 bag Urea at transplanting as the basal dose.',
      'riceIrrigation1Desc':
          'Maintain 5–7 cm of continuous standing water for the first 60 days; then alternate wet & dry.',
      'riceFertilizer2Desc':
          'Top-dress the remaining ~2/3 bag of Urea split between tillering and panicle initiation.',
      'ricePestControlDesc':
          'Scout weekly for stem borer and leaf folder around panicle initiation. Use pheromone traps before pesticides.',
      'riceHarvestDesc':
          'Harvest when 80% of panicles turn golden. Drain water 10 days before cutting to firm up the field.',
      // ── Crop Calendar — Cotton ────────────────────────────────────────
      'cottonLandPrepDesc':
          'Deep ploughing in summer, two cross-ploughs, and final levelling for a clean seedbed.',
      'cottonSowingDesc':
          'Sow Bt cotton 6–8 kg/acre, line spacing 75 cm, plant spacing 22 cm. Treat seeds before sowing.',
      'cottonIrrigation1Desc':
          'First irrigation 25–30 days after sowing once true leaves appear.',
      'cottonWeedingDesc':
          'Thin to one healthy plant per spot. Hand weed or apply a post-emergence herbicide.',
      'cottonFertilizer1Desc':
          'Apply 1 bag DAP + 1 bag Urea per acre at first irrigation.',
      'cottonPestControlDesc':
          'Scout weekly for boll worm, whitefly and jassid. Use ETL-based spray decisions, not the calendar.',
      'cottonFertilizer2Desc':
          'Second Urea top-dress at flowering (~day 70). Foliar potassium helps boll retention in heat.',
      'cottonPicking1Desc':
          'Start first picking when 30–40% of bolls have opened. Pick only in dry weather.',
      'cottonPicking2Desc':
          'Second picking 3–4 weeks later. Keep cotton clean — moisture and trash drop the price.',
      // ── Crop Calendar — Sugarcane ─────────────────────────────────────
      'sugarcaneLandPrepDesc':
          'Deep plough and level the field. Trench planting saves water and lifts yield.',
      'sugarcaneSowingDesc':
          'Plant 3-bud setts treated with fungicide — about 30,000 setts per acre.',
      'sugarcaneIrrigation1Desc':
          'Light irrigation 15–20 days after planting to support germination of the buds.',
      'sugarcaneFertilizer1Desc':
          'Basal dose: 2 bags DAP + 1 bag SOP per acre at planting.',
      'sugarcaneWeedingDesc':
          'The first 90 days are critical. Hand-weed or apply post-emergence herbicide.',
      'sugarcaneFertilizer2Desc':
          'Top-dress 3 bags Urea per acre — split between months 2 and 4.',
      'sugarcaneEarthingUpDesc':
          'Earth up around the plant base at month 4 to prevent lodging and support tiller growth.',
      'sugarcaneTyingDesc':
          'Tie standing canes into bundles around month 6 so wind and irrigation do not flatten them.',
      'sugarcaneHarvestDesc':
          'Harvest at 11–12 months when brix reaches 18–20%. Cut close to the ground for maximum sugar recovery.',
      // ── Crop Calendar — Maize ─────────────────────────────────────────
      'maizeLandPrepDesc':
          'Plough twice and level. Add 2 trolleys of farmyard manure per acre.',
      'maizeSowingDesc':
          'Hybrid seed 8–10 kg/acre, line 75 cm, plant 22 cm. Apply 1 bag DAP at sowing.',
      'maizeIrrigation1Desc':
          'Light irrigation 15 days after sowing once seedlings establish.',
      'maizeWeedingDesc':
          'Thin extra plants to keep 22 cm spacing. Hand weed or spray atrazine pre-emergence.',
      'maizeFertilizer1Desc':
          '1 bag Urea per acre top-dressed at knee-high stage (~day 30).',
      'maizeIrrigation2Desc':
          'Second irrigation at tasseling — the most critical irrigation for grain fill.',
      'maizePestControlDesc':
          'Watch for stem borer at the whorl stage. Spray only if larvae cross the economic threshold.',
      'maizeFertilizer2Desc':
          'Final Urea top-dress at tasseling (~day 60).',
      'maizeHarvestDesc':
          'Harvest when kernels are hard and the dent appears. Grain moisture under 20% before storage.',
    },
    'ur': {
      'appName': 'پاک فصل',
      'welcome': 'پاک فصل میں خوش آمدید',
      'login': 'لاگ اِن',
      'signup': 'رجسٹر کریں',
      'or': 'یا',
      'email': 'ای میل',
      'username': 'صارف نام',
      'usernameHint': 'مثال: علی خان',
      'emailHint': 'you@example.com',
      'password': 'پاس ورڈ',
      'passwordHint': '••••••••',
      'phone': 'فون (اختیاری)',
      'phoneHint': '+92 300 0000000',
      'forgotPassword': 'پاس ورڈ بھول گئے؟',
      'rememberMe': 'مجھے یاد رکھیں',
      'requireBiometricAutofill': 'آٹو فل کے لیے بایومیٹرک تصدیق لازمی کریں',
      'rememberMeHint':
          'لاگ اِن معلومات اس ڈیوائس پر خفیہ انداز میں محفوظ ہوتی ہیں اور بایومیٹرک تصدیق درکار ہو سکتی ہے۔',
      'resetPassword': 'پاس ورڈ ری سیٹ کریں',
      'resetPasswordHint':
          'اپنا ای میل درج کریں، ہم آپ کو پاس ورڈ ری سیٹ لنک بھیجیں گے۔',
      'sending': 'بھیجا جا رہا ہے...',
      'backToLogin': 'لاگ اِن پر واپس جائیں',
      'home': 'ہوم',
      'learning': 'سیکھیں',
      'learningDashboardHint': 'سیکھنے کے لیے موضوع منتخب کریں',
      'learningHubEyebrow': 'پاک فصل · سیکھنے کا مرکز',
      'learningTopicsLabel': 'موضوعات',
      'learningHeadlineQuestion': 'آپ کیا سیکھنا\nچاہتے ہیں؟',
      'learningTipBoldPrefix': 'ہر ہفتے نئے موضوعات۔ ',
      'learningTipRest':
          'مواد پاکستانی کاشتکاروں کے لیے ترتیب دیا گیا ہے — اردو اور انگریزی میں۔',
      'learningStatusAvailable': 'دستیاب',
      'learningOptionYoutubeDesc': 'فصل کے مطابق ماہر ویڈیوز',
      'learningOptionArticlesDesc': 'رہنمائی، تجاویز اور تحقیق',
      'learningOptionPestsDesc': 'مسائل کی شناخت اور علاج',
      'learningOptionCropStagesDesc': 'بڑھوت اور کٹائی کے مراحل',
      'learningYoutubeVideos': 'یوٹیوب تعلیمی ویڈیوز',
      'learningOptionYoutube': 'یوٹیوب تعلیمی ویڈیوز',
      'learningOptionArticles': 'تعلیمی مضامین',
      'learningOptionPests': 'کیڑے اور بیماریاں',
      'learningOptionCropStages': 'فصل کی کاشت کے مراحل',
      'comingSoon': 'جلد آرہا ہے',
      'cropDiseasePickCrop': 'فصل منتخب کریں',
      'cropDiseasePickCropHint':
          'عام بیماریوں، علامات اور علاج کی تجاویز دیکھنے کے لیے فصل پر ٹیپ کریں۔',
      'cropDiseaseMoreCropsSoon': 'مزید فصلیں جلد شامل کی جائیں گی۔',
      'cropDiseaseDetailSubtitle': 'عام بیماریاں اور علاج کی تجاویز',
      'cropDiseaseSymptoms': 'علامات',
      'cropDiseaseSolution': 'علاج',
      'cropDiseaseTopicsShort': 'موضوعات',
      'cdCottonLcvName': 'لیف کرل وائرس',
      'cdCottonLcvDesc':
          'سفید مکھیوں سے پھیلنے والا وائرس جس سے پودے کی بڑھوت رک جاتی ہے اور پتے بگڑ جاتے ہیں۔',
      'cdCottonLcvSym1': 'پتے اوپر یا نیچے کی طرف مڑ جاتے ہیں',
      'cdCottonLcvSym2': 'پودے کی بڑھوت کم یا رک جاتی ہے',
      'cdCottonLcvSol1': 'مزاحم بیج استعمال کریں',
      'cdCottonLcvSol2': 'سفید مکھی پر قابو پائیں',
      'cdCottonBollName': 'ٹنکہ سڑن',
      'cdCottonBollDesc':
          'گرم نم موسم میں کپاس کے ٹنکوں پر فنگس کی سڑن۔',
      'cdCottonBollSym1': 'ٹنکے نرم ہو کر سڑ جاتے ہیں',
      'cdCottonBollSym2': 'ٹنکوں پر رنگ بدل جاتا ہے',
      'cdCottonBollSol1': 'درست آبپاشی کریں — پانی کھڑا نہ ہونے دیں',
      'cdCottonBollSol2': 'تجویز کردہ فنگس کش اسپرے کریں',
      'cdCottonWfName': 'سفید مکھی کا حملہ',
      'cdCottonWfDesc':
          'رس چوسنے والے کیڑے جو پودے کمزور کرتے اور وائرل بیماریاں پھیلاتے ہیں۔',
      'cdCottonWfSym1': 'پتے پیلے پڑ جاتے ہیں',
      'cdCottonWfSym2': 'پتوں پر چپچپا مادہ (شہد جیسا)',
      'cdCottonWfSol1': 'منظور شدہ کیڑے مار ادویات ہدایت کے مطابق',
      'cdCottonWfSol2': 'نیم کا اسپرے اضافی طور پر',
      'cdWheatRustName': 'رَسٹ (زنگ) کی بیماری',
      'cdWheatRustDesc':
          'فنگس سے پتوں اور تنے پر زنگ جیسے دھبے بنتے ہیں۔',
      'cdWheatRustSym1': 'پتوں پر نارنجی یا بھورے دھبے',
      'cdWheatRustSol1': 'رَسٹ سے مزاحم اقسام لگائیں',
      'cdWheatRustSol2': 'ماہر کے مشورے پر فنگس کش',
      'cdWheatSmutName': 'سَمَٹ (سُنڈی) کی بیماری',
      'cdWheatSmutDesc':
          'فنگس دانوں کی جگہ کالا بیجاں بنا دیتا ہے۔',
      'cdWheatSmutSym1': 'متاثرہ دانوں کے اندر کالی پاؤڈر جیسی چیز',
      'cdWheatSmutSol1': 'بوائی سے پہلے بیج کا علاج کریں',
      'cdWheatAphidName': 'ایفِڈ (چوسنے والے کیڑے)',
      'cdWheatAphidDesc':
          'چھوٹے کیڑے جو رس چوستے ہیں اور وائرل بھی پھیلا سکتے ہیں۔',
      'cdWheatAphidSym1': 'پودے کمزور، بڑھوت کم',
      'cdWheatAphidSym2': 'پتے مڑے یا بگڑے ہوئے',
      'cdWheatAphidSol1': 'نقصان کی حد پر پہنچنے پر کیڑے مار اسپرے',
      'cdRiceBlbName': 'جرثومہ سے پتوں کی جھلساہٹ',
      'cdRiceBlbDesc':
          'گرم نم موسم میں تیزی سے پھیلنے والی جرثومی بیماری۔',
      'cdRiceBlbSym1': 'پتوں کے کنارے پیلے ہو کر سوکھ جاتے ہیں',
      'cdRiceBlbSol1': 'کھیت کی نکاسی بہتر کریں',
      'cdRiceBlbSol2': 'مزاحم بیج استعمال کریں',
      'cdRiceBlastName': 'بلاسٹ فنگس',
      'cdRiceBlastDesc':
          'پتے، گانٹھیں اور بالیاں متاثر کرنے والی بڑی فنگس۔',
      'cdRiceBlastSym1': 'پتوں پر ہیرے کی شکل کے دھبے',
      'cdRiceBlastSol1': 'بروقت فنگس کش لگائیں',
      'cdRiceBlastSol2': 'متوازن کھاد کا استعمال',
      'cdRiceBorerName': 'تنے کا کیڑا',
      'cdRiceBorerDesc':
          'لاروا تنے کے اندر سراخ کر کے پانی اور غذائی اجزاء کی حرکت روک دیتا ہے۔',
      'cdRiceBorerSym1': 'نوجوان پودوں میں مُردہ دل (پودہ خشک نظر آتا ہے)',
      'cdRiceBorerSol1': 'فرومون جالے — نگرانی اور بڑے پیمانے پر پکڑ',
      'cdRiceBorerSol2': 'معاشی طور پر درست ہو تو کیڑے مار ادویات',
      'weather': 'موسم',
      'askAi': 'اے آئی سے پوچھیں',
      'sensorData': 'سینسر ڈیٹا',
      'marketplace': 'مارکیٹ پلیس',
      'cropCalendar': 'فصل کیلنڈر',
      'offline': 'آف لائن',
      'online': 'آن لائن',
      'cached': 'محفوظ',
      'lightMode': 'لائٹ موڈ',
      'darkMode': 'ڈارک موڈ',
      'language': 'زبان',
      'chat': 'چیٹ',
      'alerts': 'الرٹس',
      'profile': 'پروفائل',
      'saveChanges': 'تبدیلیاں محفوظ کریں',
      'saving': 'محفوظ کیا جا رہا ہے...',
      'profileUpdated': 'پروفائل کامیابی سے اپڈیٹ ہو گئی۔',
      'voice': 'آواز',
      'notifications': 'اطلاعات',
      'quickAccess': 'فوری رسائی',
      'goodMorning': 'صبح بخیر!',
      'goodAfternoon': 'دوپہر بخیر!',
      'goodEvening': 'شام بخیر!',
      'appTagline': 'اسمارٹ فارمنگ، بہتر کل',
      'notificationIrrigationReminder':
          'آبپاشی یاددہانی: آج مٹی کی نمی چیک کریں۔',
      'notificationWeatherAlert':
          'موسمی الرٹ: اگلے 24 گھنٹوں میں بارش کا امکان ہے۔',
      'notificationMarketplaceOffer':
          'مارکیٹ پلیس: کھاد کی نئی پیشکش دستیاب ہے۔',
      'feelsLike': 'محسوس ہوتا ہے',
      'updatedJustNow': 'ابھی اپڈیٹ ہوا',
      'wind': 'ہوا',
      'latest': 'تازہ ترین',
      'dayShort': 'دن',
      'temperature': 'درجہ حرارت',
      'humidity': 'نمی',
      'rainChance': 'بارش کا امکان',
      'weatherClear': 'صاف موسم',
      'weatherCloudy': 'ابر آلود',
      'weatherRain': 'بارش',
      'weatherSnow': 'برف',
      'weatherStorm': 'طوفانی',
      'weatherGeneral': 'موسم',

      // ── Weather screen redesign (Urdu) ──
      'weatherToday': 'آج',
      'weatherTomorrow': 'کل',
      'weatherNow': 'ابھی',
      'weatherHourlyTitle': 'گھنٹہ وار پیشن گوئی',
      'weather7DayTitle': '7 دن کی پیشن گوئی',
      'weatherHighlights': 'آج کی نمایاں جھلکیاں',
      'weatherSunrise': 'طلوع آفتاب',
      'weatherSunset': 'غروب آفتاب',
      'weatherUVIndex': 'یو وی انڈیکس',
      'weatherUVLow': 'کم',
      'weatherUVModerate': 'درمیانہ',
      'weatherUVHigh': 'زیادہ',
      'weatherUVVeryHigh': 'بہت زیادہ',
      'weatherUVExtreme': 'انتہائی',
      'weatherAirQuality': 'فضائی معیار',
      'weatherPressure': 'دباؤ',
      'weatherVisibility': 'منظر',
      'weatherDewPoint': 'شبنم نقطہ',
      'weatherCloudCover': 'بادل',
      'weatherHigh': 'زیادہ',
      'weatherLow': 'کم',
      'weatherMinMax': 'کم/زیادہ',
      'weatherRefresh': 'تازہ کریں',
      'weatherSearchCity': 'شہر تلاش کریں',
      'weatherSearchCityHint': 'شہر کا نام لکھیں (مثال: لاہور)',
      'weatherUseCurrentLocation': 'موجودہ مقام استعمال کریں',
      'weatherSavedLocations': 'محفوظ مقامات',
      'weatherRemove': 'ہٹائیں',
      'weatherNoSearchResults': 'کوئی شہر نہیں ملا۔',
      'dowMon': 'پیر',
      'dowTue': 'منگل',
      'dowWed': 'بدھ',
      'dowThu': 'جمعرات',
      'dowFri': 'جمعہ',
      'dowSat': 'ہفتہ',
      'dowSun': 'اتوار',
      'weatherSearchError': 'شہر تلاش نہیں ہو سکا۔ دوبارہ کوشش کریں۔',
      'weatherLocationDenied': 'مقام کی اجازت درکار ہے۔',
      'weatherLocationDisabled': 'براہ کرم ڈیوائس کی لوکیشن آن کریں۔',
      'weatherOpenSettings': 'سیٹنگز کھولیں',
      'weatherOfflineNotice':
          'آپ آف لائن ہیں۔ آخری محفوظ موسم دکھایا جا رہا ہے۔',
      'weatherFetchError':
          'تازہ موسم لوڈ نہیں ہوا۔ دوبارہ کوشش کے لیے کھینچیں۔',
      'weatherNoApiKeyNotice':
          'OPENWEATHER_API_KEY سیٹ نہیں ہے۔ مفت متبادل استعمال کیا جا رہا ہے۔',
      'weatherCancel': 'منسوخ',

      // ── Crop alerts (Urdu) ──
      'cropAlertHeavyRain': 'شدید بارش الرٹ',
      'cropAlertHeavyRainBody':
          'شدید بارش متوقع ہے۔ آبپاشی روک دیں اور پیداوار محفوظ کریں۔',
      'cropAlertHeatwave': 'گرمی کی لہر الرٹ',
      'cropAlertHeatwaveBody':
          'انتہائی گرمی متوقع ہے۔ صبح سویرے آبپاشی کریں اور نوجوان فصلوں کی حفاظت کریں۔',
      'cropAlertHighWind': 'تیز ہوا الرٹ',
      'cropAlertHighWindBody':
          'تیز ہوائیں متوقع ہیں۔ اسپرے سے گریز کریں اور کھیت کے ڈھکن محفوظ کریں۔',
      'cropAlertFrost': 'پالے کی وارننگ',
      'cropAlertFrostBody':
          'آج رات پالا متوقع ہے۔ حساس فصلوں اور پنیریوں کی حفاظت کریں۔',
      'cropAlertThunderstorm': 'گرج چمک کی وارننگ',
      'cropAlertThunderstormBody':
          'گرج چمک متوقع ہے۔ کھلے کھیتوں اور بلند درختوں سے دور رہیں۔',

      // ── Farmer advisories (Urdu) ──
      'farmerAdvisory': 'کاشتکار مشورہ',
      'advisoryGoodIrrigation': 'آبپاشی کے لیے اچھا دن',
      'advisoryGoodIrrigationBody':
          'موزوں درجہ حرارت اور بارش کا کم امکان۔ کھیت کو پانی دینے کا بہترین وقت۔',
      'advisoryAvoidIrrigation': 'آج آبپاشی نہ کریں',
      'advisoryAvoidIrrigationBody':
          'اگلے 24 گھنٹوں میں بارش متوقع \u2014 پانی بچائیں اور قدرت پر چھوڑیں۔',
      'advisoryAvoidSpraying': 'آج اسپرے نہ کریں',
      'advisoryAvoidSprayingBody':
          'تیز ہوا یا بارش اسپرے کا اثر کم کرتی ہے اور قریبی فصلوں کو نقصان دے سکتی ہے۔',
      'advisoryGoodSpraying': 'اسپرے کے لیے مناسب وقت',
      'advisoryGoodSprayingBody':
          'ہلکی ہوا اور خشک موسم \u2014 صبح سویرے کیڑے مار اسپرے کا محفوظ وقت۔',
      'advisoryRainTomorrow': 'کل بارش متوقع',
      'advisoryRainTomorrowBody':
          'آج کے کھیت کے کام مکمل کریں؛ ممکن ہو تو پکی پیداوار کاٹ لیں۔',
      'advisoryHarvestWindow': 'کٹائی کا اچھا موقع',
      'advisoryHarvestWindowBody':
          'اگلے 48 گھنٹے خشک اور موزوں موسم۔ کٹائی کی منصوبہ بندی کریں۔',
      'advisoryProtectFromHeat': 'گرمی سے فصل بچائیں',
      'advisoryProtectFromHeatBody':
          'ملچنگ کریں اور صبح سویرے آبپاشی سے گرمی کا دباؤ کم کریں۔',

      // ── Misc weather UI (Urdu) ──
      'mph': 'میل/گھنٹہ',
      'kmh': 'کلومیٹر/گھنٹہ',
      'percent': '٪',
      'degreeC': '°C',
      'hpa': 'ہیکٹو پاسکل',
      'km': 'کلومیٹر',
      'soilMoisture': 'مٹی کی نمی',
      'phLevel': 'پی ایچ لیول',
      'contact': 'رابطہ',
      'send': 'بھیجیں',
      'typeMessage': 'اپنا سوال لکھیں...',
      'listening': 'سن رہا ہے...',
      'voiceInputUnavailable':
          'آواز سے لکھنے کی سہولت دستیاب نہیں۔ براہ کرم مائیکروفون کی اجازت دیں۔',
      'voicePermissionDenied':
          'مائیکروفون کی اجازت نہیں دی گئی۔ براہ کرم ایپ سیٹنگز سے اجازت دیں۔',
      'voiceServiceUnavailable':
          'اس ڈیوائس پر اسپیچ سروس دستیاب نہیں۔ براہ کرم گوگل اسپیچ سروس اپڈیٹ/انسٹال کریں۔',
      'voiceInputStartFailed':
          'وائس ان پٹ شروع نہیں ہو سکا۔ دوبارہ کوشش کریں۔',
      'voiceTapToSpeak': 'بولنے کے لیے مائیک دبائیں',
      'voiceListeningNow': 'سن رہا ہے... اب بولیں',
      'voiceProcessing': 'آواز کو متن میں بدلا جا رہا ہے...',
      'openSettings': 'سیٹنگز کھولیں',
      'good': 'اچھا',
      'moderate': 'درمیانہ',
      'bad': 'خراب',
      'errorState': 'کچھ غلط ہوگیا۔',
      'retry': 'دوبارہ کوشش',
      'loading': 'لوڈ ہو رہا ہے...',
      'learningSubtitle': 'فصل کے حساب سے قابل اعتماد زرعی ویڈیوز',
      'featuredLearning': 'نمایاں سبق',
      'watchNow': 'ابھی دیکھیں',
      'learningEmpty': 'اس کیٹیگری کے لیے ابھی ویڈیوز دستیاب نہیں۔',
      'learningFilterByCrop': 'فصل کے مطابق',
      'learningSearchHint': 'عنوان یا چینل کے ذریعے تلاش کریں...',
      'learningNoSearchResults': 'آپ کی تلاش سے کوئی ویڈیو میل نہیں کھاتی۔',
      'learningDemoMode':
          'ڈیمو ویڈیوز دکھائی جا رہی ہیں۔ لائیو یوٹیوب ڈیٹا کے لیے --dart-define کے ساتھ YOUTUBE_API_KEY شامل کریں۔',
      'marketSearchHint': 'پروڈکٹ کا نام تلاش کریں',
      'marketFilterCompany': 'کمپنی کے مطابق فلٹر',
      'marketOfflineCached':
          'آف لائن حالت میں محفوظ شدہ پروڈکٹس دکھائی جا رہی ہیں۔',
      'marketNoProducts': 'تلاش یا فلٹر کے مطابق کوئی پروڈکٹ نہیں ملی۔',
      'marketCompany': 'کمپنی',
      'marketCategory': 'قسم',
      'marketDetail': 'پروڈکٹ کی تفصیل',
      'marketLocation': 'مقام',
      'callCompany': 'کمپنی کو کال کریں',
      'whatsapp': 'واٹس ایپ',
      'verified': 'تصدیق شدہ',
      'soilMoistureTrend': 'مٹی کی نمی کا رجحان (7 دن)',
      'phTrend': 'پی ایچ رجحان (7 دن)',
      'dssRecommendation': 'سمارٹ سفارش',
      'sensorRecommendationText':
          'مٹی کی نمی مناسب ہے۔ اگلی آبپاشی 24 سے 36 گھنٹے بعد کریں اور اس ہفتے متوازن کھاد استعمال کریں۔',
      'lastUpdated': 'آخری اپ ڈیٹ',
      'sensorCloudLive': 'لائیو کلاؤڈ سینسر ڈیٹا منسلک ہے۔',
      'sensorCloudError':
          'کلاؤڈ دستیاب نہیں۔ محفوظ/ڈیمو سینسر ڈیٹا دکھایا جا رہا ہے۔',
      'sensorManualInputTitle': 'دستی سینسر ان پٹ',
      'sensorCropLabel': 'فصل',
      'sensorMoistureInput': 'مٹی کی نمی (%)',
      'sensorPhInput': 'مٹی کا پی ایچ',
      'sensorRainExpected': 'اگلے 24 گھنٹوں میں بارش متوقع ہے',
      'sensorGenerateDss': 'ڈی ایس ایس سفارش بنائیں',
      'sensorSaveSession': 'سیشن محفوظ کریں',
      'sensorExportReadings': 'ریڈنگز ایکسپورٹ کریں',
      'sensorSessionSaved': 'سینسر سیشن محفوظ ہوگیا۔',
      'sensorCopiedClipboard': 'ریڈنگز CSV فارمیٹ میں کلپ بورڈ پر کاپی ہوگئیں۔',
      'sensorRecIrrigateSoon': 'اگلے 12-24 گھنٹوں میں آبپاشی کریں',
      'sensorRecWaitRain':
          'نمی کم ہے مگر بارش متوقع ہے، انتظار کریں اور دوبارہ چیک کریں',
      'sensorRecReduceIrrigation':
          'پانی کھڑا ہونے سے بچنے کے لیے آبپاشی کی مقدار کم کریں',
      'sensorRecMoistureOk': 'نمی مناسب حد میں ہے',
      'sensorRecAcidic': 'مٹی تیزابی ہے، چونا اور متوازن کھاد استعمال کریں',
      'sensorRecAlkaline': 'مٹی الکلائن ہے، جپسم اور نامیاتی مادہ استعمال کریں',
      'sensorRecPhSuitable': 'پی ایچ موزوں ہے برائے',
      'splashTagline': 'پاکستان کے لیے ذہین کھیت باڑی',
      'authSubtitle': 'جاری رکھنے کے لیے لاگ اِن کریں',
      'continueAsGuest': 'مہمان کے طور پر جاری رکھیں',
      'authSignOut': 'لاگ آؤٹ',
      'authLoggingIn': 'لاگ اِن ہو رہا ہے...',
      'authCreatingAccount': 'اکاؤنٹ بنایا جا رہا ہے...',
      'emailRequired': 'ای میل درکار ہے',
      'usernameRequired': 'صارف نام درکار ہے',
      'usernameMinLength': 'صارف نام کم از کم 3 حروف کا ہونا چاہیے',
      'passwordMin': 'کم از کم 6 حروف درکار ہیں',
      'weakPasswordForm': 'پاس ورڈ کم از کم 6 حروف کا ہونا چاہیے',
      'invalidEmail': 'درست ای میل درج کریں',
      'userDisabled': 'یہ اکاؤنٹ غیر فعال کردیا گیا ہے۔',
      'userNotFound': 'اس ای میل پر کوئی اکاؤنٹ نہیں ملا۔',
      'wrongPassword': 'غلط پاس ورڈ۔ دوبارہ کوشش کریں۔',
      'emailInUse': 'یہ ای میل پہلے سے رجسٹرڈ ہے۔',
      'weakPasswordAuth': 'پاس ورڈ بہت کمزور ہے۔',
      'tooManyRequests': 'بہت زیادہ کوششیں۔ بعد میں کوشش کریں۔',
      'networkFailed': 'نیٹ ورک خرابی۔ کنکشن چیک کریں۔',
      'authUnknown': 'لاگ اِن ناکام۔ دوبارہ کوشش کریں۔',
      'resetEmailSent': 'پاس ورڈ ری سیٹ کا لنک آپ کی ای میل پر بھیج دیا گیا۔',
      'confirmPassword': 'پاس ورڈ دوبارہ',
      'confirmPasswordRequired': 'براہ کرم پاس ورڈ دوبارہ درج کریں',
      'passwordsMismatch': 'پاس ورڈ میل نہیں کھاتے۔',
      'invalidPhone': 'درست فون نمبر درج کریں',
      'selectCrop': 'فصل منتخب کریں',
      'cropWheat': 'گندم',
      'cropRice': 'چاول',
      'cropCotton': 'کپاس',
      'cropSugarcane': 'گنا',
      'cropMaize': 'مکئی',
      'couldNotOpenVideo': 'ویڈیو لنک نہیں کھل سکا',
      'couldNotOpenDialer': 'ڈائلر نہیں کھل سکا',
      'couldNotOpenWhatsapp': 'واٹس ایپ نہیں کھل سکا',
      'aiSampleQuestion': 'گندم کو کیڑوں سے کیسے بچاؤں؟',
      'aiSampleAnswer':
          'منظور شدہ اسپرے صبح سویرے کریں اور ہفتہ وار نگرانی کریں۔',
      'aiPendingResponse':
          'شکریہ! اے آئی جواب بیک اینڈ انٹیگریشن کے بعد دستیاب ہوگا۔',
      'aiHistory': 'ہسٹری',
      'aiNewChat': 'نئی چیٹ',
      'aiNoMessagesTitle': 'اپنی پہلی اے آئی چیٹ شروع کریں',
      'aiNoMessagesSubtitle':
          'فصل، کیڑے، موسم یا کھاد کے بارے میں سوال پوچھیں۔',
      'aiAssistantLabel': 'پاک فصل اے آئی',
      'aiYouLabel': 'آپ',
      'aiHistoryLoaded': 'چیٹ ہسٹری لوڈ ہوگئی',
      'aiTyping': 'اے آئی ٹائپ کر رہا ہے...',
      'skip': 'اسکپ',
      'next': 'اگلا',
      'getStarted': 'شروع کریں',
      'onboardingTitle1': 'موسم کے مطابق فصل کی منصوبہ بندی',
      'onboardingDesc1':
          'روزانہ موسم کی اپڈیٹس اور آسان زرعی رہنمائی حاصل کریں تاکہ بہتر فیصلے کیے جا سکیں۔',
      'onboardingTitle2': 'بہتر زرعی طریقے سیکھیں',
      'onboardingDesc2':
          'فصل کے مطابق معتبر ویڈیوز دیکھیں اور عملی مشوروں سے پیداوار بہتر بنائیں۔',
      'onboardingTitle3': 'اپنے کھیت کی نگرانی اعتماد سے کریں',
      'onboardingDesc3':
          'سینسر ٹرینڈز اور سفارشات سے آبپاشی اور مٹی کی دیکھ بھال بروقت پلان کریں۔',
      // ── Crop Calendar — UI ─────────────────────────────────────────────
      'cropCalendarRegion': 'پنجاب علاقہ',
      'cropCalendarRegionLahore': 'لاہور (وسطی پنجاب)',
      'cropCalendarRegionMultan': 'ملتان (جنوبی پنجاب)',
      'cropCalendarSetSowingDate': 'بوائی کی تاریخ مقرر کریں',
      'cropCalendarChangeSowingDate': 'تاریخ تبدیل کریں',
      'cropCalendarSowingDateLabel': 'بوائی کی تاریخ',
      'cropCalendarHarvestEta': 'متوقع کٹائی',
      'cropCalendarRecommendedWindow': 'تجویز کردہ بوائی کا وقت',
      'cropCalendarSeasonProgress': 'موسم کی پیش رفت',
      'cropCalendarDaysSinceSowing': 'بوائی کو دن',
      'cropCalendarDaysToHarvest': 'کٹائی میں باقی دن',
      'cropCalendarTodayBadge': 'آج',
      'cropCalendarStatusPast': 'مکمل',
      'cropCalendarStatusCurrent': 'جاری',
      'cropCalendarStatusUpcoming': 'آنے والا',
      'cropCalendarNoSowingTitle': 'اپنا کیلنڈر ذاتی بنائیں',
      'cropCalendarNoSowingHint':
          'نیچے دبا کر بوائی کی تاریخ منتخب کریں (یا منصوبہ شدہ تاریخ)۔ تمام مراحل اور یاد دہانیاں اسی تاریخ کے مطابق بنیں گی۔',
      'cropCalendarStartsIn': 'شروع ہوگا',
      'cropCalendarEndedAgo': 'ختم',
      'cropCalendarDaysShort': 'دن',
      'cropCalendarReset': 'پلان ری سیٹ',
      'cropCalendarResetConfirmTitle': 'بوائی کا پلان ری سیٹ کریں؟',
      'cropCalendarResetConfirmBody':
          'اس فصل کی بوائی کی تاریخ اور یاد دہانیاں صاف ہو جائیں گی۔',
      'cropCalendarPlanSaved': 'بوائی کا پلان محفوظ ہوگیا',
      'cropCalendarPlanCleared': 'پلان صاف ہوگیا',
      'cropCalendarRegionalNote': 'علاقائی نوٹ',
      'cropCalendarReminderToggle': 'ہر مرحلے کے شروع پر یاد دہانی',
      'cropCalendarReminderHint':
          'ہر مرحلے کے شروع پر آپ کو پش نوٹیفکیشن ملے گی۔',
      'cropCalendarBeforeSowing': 'بوائی سے پہلے',
      'cropCalendarAfterHarvest': 'موسم مکمل',
      'cropCalendarTodayLabel': 'آج',
      'cropCalendarCancel': 'منسوخ',
      'cropCalendarConfirm': 'تصدیق',
      'cropCalendarMonthsLabel': 'مہینے',
      'cropCalendarStageWindow': 'مرحلے کا وقت',
      // ── Crop Calendar — shared stage names ─────────────────────────────
      'stageLandPrep': 'زمین کی تیاری',
      'stageNursery': 'نرسری',
      'stageSowing': 'بوائی',
      'stageTransplanting': 'پنیری منتقلی',
      'stageIrrigation1': 'پہلی آبپاشی',
      'stageIrrigation2': 'دوسری آبپاشی',
      'stageIrrigation3': 'تیسری آبپاشی',
      'stageIrrigation4': 'چوتھی آبپاشی',
      'stageFertilizer1': 'پہلی کھاد',
      'stageFertilizer2': 'دوسری کھاد',
      'stageWeeding': 'گوڈی اور چھدائی',
      'stageEarthingUp': 'مٹی چڑھائی',
      'stageTying': 'بندھائی',
      'stagePestControl': 'کیڑے مار اقدام',
      'stageHarvest': 'کٹائی',
      'stagePicking1': 'پہلی چنائی',
      'stagePicking2': 'دوسری چنائی',
      // ── Crop Calendar — per-area regional notes ───────────────────────
      'wheatLahoreNote':
          'وسطی پنجاب نسبتاً ٹھنڈا ہے۔ بہترین پھٹاؤ کے لیے 25 اکتوبر تا 15 نومبر بوائی کریں۔ دیر سے بوائی پیداوار بہت کم کر دیتی ہے۔',
      'wheatMultanNote':
          'جنوبی پنجاب گرم ہے۔ 1 تا 25 نومبر بوائی کریں تاکہ دانہ بھرنے کا وقت ٹھنڈے موسم میں آئے اور مارچ کی گرمی سے بچ جائے۔',
      'riceLahoreNote':
          'باسمتی کا علاقہ۔ پنیری 15 مئی کے قریب تیار کریں اور 15 جون تا 5 جولائی منتقل کریں۔ سپر باسمتی یا کائنات استعمال کریں۔',
      'riceMultanNote':
          'یہاں چاول کم بوتے ہیں — زیادہ تر کپاس۔ اگر بونا ہو تو IRRI-6/IRRI-9 استعمال کریں اور مئی میں منتقلی کریں۔',
      'cottonLahoreNote':
          'وسطی پنجاب میں 20 اپریل تا 20 مئی بوائی۔ ٹھنڈی راتیں اگاؤ سست کرتی ہیں — ہمیشہ علاج شدہ بی ٹی بیج استعمال کریں۔',
      'cottonMultanNote':
          'پاکستان کا اصل کپاس کا علاقہ۔ 1 اپریل تا 5 مئی بوائی — جلدی بوائی برسات کی سڑن اور گلابی سنڈی سے بچاتی ہے۔',
      'sugarcaneLahoreNote':
          'بہار (فروری-مارچ) کی فصل 11 ماہ کی۔ خزاں (ستمبر-اکتوبر) زیادہ پیداوار دیتی ہے مگر زمین زیادہ مدت کے لیے بند رہتی ہے۔',
      'sugarcaneMultanNote':
          'خزاں کی بوائی (ستمبر-اکتوبر) بہتر ہے — یہاں کی شدید گرمی سے اگاؤ کا تناؤ بچ جاتا ہے۔',
      'maizeLahoreNote':
          'بہار: آخر فروری تا وسط مارچ۔ خزاں: 20 جولائی تا 10 اگست۔ دونوں موسموں میں ہائبرڈ بیج استعمال کریں۔',
      'maizeMultanNote':
          'بہار کی بوائی خطرناک (پھول پر گرمی)۔ خزاں 1 تا 25 اگست بہتر ہے، گرمی برداشت کرنے والے ہائبرڈ کا انتخاب کریں۔',
      // ── Crop Calendar — Wheat ─────────────────────────────────────────
      'wheatLandPrepDesc':
          'دو بار گہری ہل چلائیں، کھیت ہموار کریں اور فی ایکڑ 2-3 ٹرالی روڑی کھاد ڈالیں۔',
      'wheatSowingDesc':
          'فی ایکڑ 50 کلو علاج شدہ بیج، قطار 22 سینٹی میٹر، گہرائی 5 سینٹی میٹر۔ بوائی پر 1 بوری DAP اور 1/3 بوری یوریا۔',
      'wheatIrrigation1Desc':
          'بوائی کے 21-25 دن بعد کراؤن روٹ آبپاشی — پھٹاؤ اور پیداوار کے لیے سب سے اہم۔',
      'wheatFertilizer1Desc':
          'پہلی آبپاشی پر زمین گیلی ہو تو فی ایکڑ 1 بوری یوریا چھٹا چھڑکیں۔',
      'wheatIrrigation2Desc':
          'پھٹاؤ کے مرحلے میں دن 60 کے قریب آبپاشی۔ اگر 48 گھنٹے میں بارش ہو چکی ہو تو چھوڑ دیں۔',
      'wheatIrrigation3Desc':
          'گوبھ اور سٹہ پر آبپاشی، دانہ بھرنے کے لیے اہم۔ تیز ہوا میں نہ کریں ورنہ فصل گر سکتی ہے۔',
      'wheatHarvestDesc':
          'دانے سخت اور سنہری ہوں (نمی 15% سے کم) تو کاٹیں۔ نقصان کم کرنے کے لیے کمبائن ہارویسٹر بہتر ہے۔',
      // ── Crop Calendar — Rice ──────────────────────────────────────────
      'riceNurseryDesc':
          'پنیری منتقلی سے 25 دن پہلے، تیار کیاری میں فی ایکڑ 8-10 کلو بیج بویں۔',
      'riceLandPrepDesc':
          '5-7 سینٹی میٹر کھڑے پانی میں کھیت کو گارا کریں اور بالکل ہموار کریں تاکہ پانی برابر رہے۔',
      'riceTransplantingDesc':
          '25 دن کی پنیری ہر گڑھے میں 2-3 پودے، 22×22 سینٹی میٹر فاصلہ پر لگائیں۔',
      'riceFertilizer1Desc':
          'پنیری لگاتے وقت بنیادی خوراک کے طور پر 1 بوری DAP اور 1/3 بوری یوریا ڈالیں۔',
      'riceIrrigation1Desc':
          'پہلے 60 دن 5-7 سینٹی میٹر کھڑا پانی برقرار رکھیں؛ اس کے بعد گیلی-خشک کا چکر چلائیں۔',
      'riceFertilizer2Desc':
          'بقیہ تقریباً 2/3 بوری یوریا پھٹاؤ اور سٹہ بنتے وقت دو حصوں میں ڈالیں۔',
      'ricePestControlDesc':
          'سٹہ بنتے وقت تنے کا کیڑا اور پتہ لپیٹ کیڑا ہفتہ وار چیک کریں۔ پہلے فرومون جالے استعمال کریں۔',
      'riceHarvestDesc':
          '80% بالیاں سنہری ہوں تو کٹائی کریں۔ کٹائی سے 10 دن پہلے پانی نکال دیں۔',
      // ── Crop Calendar — Cotton ────────────────────────────────────────
      'cottonLandPrepDesc':
          'گرمیوں میں گہری ہل، دو بار کراس ہل اور آخری ہمواری سے صاف بیڈ تیار کریں۔',
      'cottonSowingDesc':
          'بی ٹی کاٹن 6-8 کلو فی ایکڑ، قطار 75 سینٹی میٹر، پودا 22 سینٹی میٹر۔ بوائی سے پہلے بیج کا علاج۔',
      'cottonIrrigation1Desc':
          'بوائی کے 25-30 دن بعد جب اصل پتے نمودار ہوں تو پہلی آبپاشی کریں۔',
      'cottonWeedingDesc':
          'ہر جگہ ایک صحت مند پودا رکھیں۔ ہاتھ سے یا پوسٹ-ایمرجنس کیمیکل سے گوڈی۔',
      'cottonFertilizer1Desc':
          'پہلی آبپاشی پر فی ایکڑ 1 بوری DAP اور 1 بوری یوریا ڈالیں۔',
      'cottonPestControlDesc':
          'ہفتہ وار سنڈی، سفید مکھی اور جیسد کی نگرانی۔ ETL کے مطابق اسپرے کریں، کیلنڈر سے نہیں۔',
      'cottonFertilizer2Desc':
          'پھول آنے پر دوسری یوریا (تقریباً دن 70)۔ گرمی میں پوٹاش کا چھڑکاؤ ٹینڈے روکنے میں مدد دیتا ہے۔',
      'cottonPicking1Desc':
          '30-40% ٹینڈے کھل جائیں تو پہلی چنائی شروع کریں۔ صرف خشک موسم میں چنیں۔',
      'cottonPicking2Desc':
          'پہلی چنائی کے 3-4 ہفتے بعد دوسری چنائی۔ صاف رکھیں — نمی اور کچرا قیمت گرا دیتا ہے۔',
      // ── Crop Calendar — Sugarcane ─────────────────────────────────────
      'sugarcaneLandPrepDesc':
          'گہری ہل اور کھیت ہموار کریں۔ خندق میں بوائی پانی بچاتی ہے اور پیداوار بڑھاتی ہے۔',
      'sugarcaneSowingDesc':
          '3 آنکھ والی سیٹ فنگس کش سے علاج کر کے لگائیں — فی ایکڑ تقریباً 30,000 سیٹ۔',
      'sugarcaneIrrigation1Desc':
          'بوائی کے 15-20 دن بعد ہلکی آبپاشی تاکہ آنکھیں اگ سکیں۔',
      'sugarcaneFertilizer1Desc':
          'بنیادی خوراک: بوائی پر فی ایکڑ 2 بوری DAP اور 1 بوری SOP۔',
      'sugarcaneWeedingDesc':
          'پہلے 90 دن انتہائی اہم ہیں۔ ہاتھ سے یا پوسٹ-ایمرجنس کیمیکل سے گوڈی کریں۔',
      'sugarcaneFertilizer2Desc':
          'فی ایکڑ 3 بوری یوریا — 2 اور 4 ماہ پر دو حصوں میں ڈالیں۔',
      'sugarcaneEarthingUpDesc':
          '4 ماہ پر پودے کی جڑوں پر مٹی چڑھائیں تاکہ گرے نہیں اور پھٹاؤ بڑھے۔',
      'sugarcaneTyingDesc':
          '6 ماہ پر کھڑے گنوں کو بندھائی کریں تاکہ ہوا اور آبپاشی سے گرے نہیں۔',
      'sugarcaneHarvestDesc':
          '11-12 ماہ پر جب چینی 18-20% ہو تو کٹائی کریں۔ زمین کے قریب سے کاٹیں تاکہ زیادہ چینی ملے۔',
      // ── Crop Calendar — Maize ─────────────────────────────────────────
      'maizeLandPrepDesc':
          'دو بار ہل اور کھیت ہموار کریں۔ فی ایکڑ 2 ٹرالی روڑی کھاد ڈالیں۔',
      'maizeSowingDesc':
          'ہائبرڈ بیج 8-10 کلو فی ایکڑ، قطار 75 سینٹی میٹر، پودا 22 سینٹی میٹر۔ بوائی پر 1 بوری DAP۔',
      'maizeIrrigation1Desc':
          'بوائی کے 15 دن بعد جب پودے قائم ہو جائیں تو ہلکی آبپاشی۔',
      'maizeWeedingDesc':
          '22 سینٹی میٹر فاصلہ رکھنے کے لیے اضافی پودے نکالیں۔ ہاتھ سے یا اٹرازین سے گوڈی۔',
      'maizeFertilizer1Desc':
          'گھٹنے کی اونچائی (تقریباً دن 30) پر فی ایکڑ 1 بوری یوریا چھڑکیں۔',
      'maizeIrrigation2Desc':
          'پھول کے وقت دوسری آبپاشی — دانہ بھرنے کے لیے سب سے اہم۔',
      'maizePestControlDesc':
          'گٹھیاں بنتے وقت تنے کا کیڑا چیک کریں۔ صرف ضرورت پر اسپرے کریں۔',
      'maizeFertilizer2Desc':
          'پھول کے وقت آخری یوریا (تقریباً دن 60)۔',
      'maizeHarvestDesc':
          'دانے سخت اور دانتیلے ہوں تو کٹائی۔ ذخیرہ کرنے سے پہلے نمی 20% سے کم ہو۔',
    },
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
