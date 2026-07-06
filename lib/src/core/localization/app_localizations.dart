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
      'learningYoutubeVideos': 'YouTube Learning Videos',
      'learningOptionYoutube': 'YouTube Learning Videos',
      'learningOptionArticles': 'Learning Articles',
      'learningOptionPests': 'Keera (Pests) aur Bimariyaan',
      'comingSoon': 'Coming soon',
      'cropDiseasePickCrop': 'Choose a crop',
      'cropDiseasePickCropHint':
          'Tap a crop to see common diseases, symptoms, and treatment tips.',
      'cropDiseaseMoreCropsSoon':
          'More crops and diseases are added regularly.',
      'cropDiseaseEmpty':
          'No crop content available yet. Please check back soon.',
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
      'cdSugarcaneRedRotName': 'Red Rot',
      'cdSugarcaneRedRotDesc':
          'Serious fungal disease causing internal reddening and drying of canes.',
      'cdSugarcaneRedRotSym1': 'Reddish patches inside the cane when cut',
      'cdSugarcaneRedRotSym2': 'Leaves dry from the top downward',
      'cdSugarcaneRedRotSol1': 'Plant only disease-free, resistant seed cane',
      'cdSugarcaneRedRotSol2': 'Remove and burn infected plants promptly',
      'cdSugarcaneBorerName': 'Stem Borer',
      'cdSugarcaneBorerDesc':
          'Larvae bore into stalks, weakening growth and reducing sugar yield.',
      'cdSugarcaneBorerSym1': 'Dead heart in young shoots',
      'cdSugarcaneBorerSym2': 'Small holes with frass on the stalk',
      'cdSugarcaneBorerSol1': 'Release Trichogramma egg parasitoids',
      'cdSugarcaneBorerSol2': 'Remove and destroy affected shoots early',
      'cdSugarcaneSmutName': 'Whip Smut',
      'cdSugarcaneSmutDesc':
          'Fungal disease producing a long black whip-like growth from the shoot.',
      'cdSugarcaneSmutSym1': 'Black whip-like structure emerging from top',
      'cdSugarcaneSmutSol1': 'Use resistant varieties and treated setts',
      'cdSugarcaneSmutSol2': 'Rogue out and destroy infected clumps',
      'cdMaizeBorerName': 'Stem Borer',
      'cdMaizeBorerDesc':
          'Larvae tunnel into stems, weakening plants and lodging stalks.',
      'cdMaizeBorerSym1': 'Rows of small holes on leaves',
      'cdMaizeBorerSym2': 'Broken or lodged stems',
      'cdMaizeBorerSol1': 'Apply recommended insecticide at whorl stage',
      'cdMaizeBorerSol2': 'Destroy crop residue after harvest',
      'cdMaizeBlightName': 'Leaf Blight',
      'cdMaizeBlightDesc':
          'Fungal disease causing long grey-green lesions on leaves.',
      'cdMaizeBlightSym1': 'Long cigar-shaped grey-green leaf lesions',
      'cdMaizeBlightSol1': 'Use resistant hybrids and crop rotation',
      'cdMaizeBlightSol2': 'Apply fungicide if infection spreads early',
      'cdMaizeFallArmywormName': 'Fall Armyworm',
      'cdMaizeFallArmywormDesc':
          'Invasive pest whose larvae feed heavily on leaves and the whorl.',
      'cdMaizeFallArmywormSym1': 'Ragged holes in leaves and whorl damage',
      'cdMaizeFallArmywormSym2': 'Sawdust-like frass near the whorl',
      'cdMaizeFallArmywormSol1': 'Scout fields weekly and act early',
      'cdMaizeFallArmywormSol2':
          'Apply approved insecticide directly into the whorl',

      // ── Learning Articles ──
      'articlesIntroTitle': 'Browse learning articles',
      'articlesIntroHint':
          'In-depth guides on soil, fertilizer, irrigation, weather, mandi rates and government schemes.',
      'articlesPickCategory': 'Browse by category',
      'articlesSearchHint': 'Search articles',
      'articlesEmpty': 'No articles found.',
      'articlesAllCategory': 'All',
      'articleReadTime4': '4 min read',
      'articleReadTime5': '5 min read',
      'articleReadTimeMinutes': '{minutes} min read',
      'articleCategorySoil': 'Soil & Land',
      'articleCategoryFertilizer': 'Fertilizer',
      'articleCategoryIrrigation': 'Irrigation',
      'articleCategoryWeather': 'Weather Advisory',
      'articleCategoryMandi': 'Mandi & Market',
      'articleCategoryGovt': 'Govt Schemes',

      'articleSoilPrepTitle': 'Getting Land Preparation Right',
      'articleSoilPrepSummary':
          'The basics of preparing your field for a strong, healthy crop.',
      'articleSoilPrepSec1Heading': 'Why Soil Testing Matters',
      'articleSoilPrepSec1Body':
          'Before every season, get your soil tested for pH and major nutrients. '
          'Knowing what your soil already has helps you avoid wasting money on '
          'fertilizer it doesn\'t need, and tells you exactly what to add for '
          'the crop you\'re planning to grow.',
      'articleSoilPrepSec2Heading': 'Ploughing the Right Way',
      'articleSoilPrepSec2Body':
          'Deep ploughing 2–3 times breaks up hard, compacted layers and helps '
          'roots grow deeper. Plough when the soil has moderate moisture — too '
          'wet or bone dry soil is harder to work and gives poor results. '
          'Follow with planking to break clods into a fine seedbed.',
      'articleSoilPrepSec3Heading': 'Levelling Your Field',
      'articleSoilPrepSec3Body':
          'An unlevel field means some parts get flooded while others stay dry '
          'during irrigation. Proper levelling — laser levelling if available — '
          'saves water, ensures even germination, and can raise yields '
          'noticeably with no extra input cost.',
      'articleSoilPrepSec4Heading': 'Adding Organic Matter',
      'articleSoilPrepSec4Body':
          'Mixing well-rotted farmyard manure (FYM) or compost into the soil '
          'before the final ploughing improves soil structure, water retention, '
          'and long-term fertility. It works alongside chemical fertilizer, not '
          'as a replacement for it.',

      'articleFertilizerTitle': 'A Complete Guide to Fertilizer (NPK)',
      'articleFertilizerSummary':
          'Understand nitrogen, phosphorus, and potash — and when to apply them.',
      'articleFertilizerSec1Heading': 'What NPK Actually Does',
      'articleFertilizerSec1Body':
          'Nitrogen (N) drives leafy, vegetative growth and greening. '
          'Phosphorus (P) builds strong roots and helps flowering and grain '
          'formation. Potassium (K) strengthens stems, improves disease '
          'resistance, and boosts grain and fruit quality.',
      'articleFertilizerSec2Heading': 'When to Apply Each Dose',
      'articleFertilizerSec2Body':
          'Apply full phosphorus and potash as a basal dose at sowing, since '
          'they move slowly in soil. Split nitrogen into 2–3 doses across key '
          'growth stages instead of giving it all at once — this reduces waste '
          'and matches the crop\'s actual demand.',
      'articleFertilizerSec3Heading': 'Balancing Organic and Chemical',
      'articleFertilizerSec3Body':
          'Farmyard manure and compost improve soil health over time but '
          'release nutrients slowly. Combining organic matter with chemical '
          'fertilizer usually gives better long-term results than relying on '
          'either one alone.',
      'articleFertilizerSec4Heading': 'Risks of Over-Fertilizing',
      'articleFertilizerSec4Body':
          'Too much fertilizer can burn young plants, encourage weak and '
          'disease-prone growth, pollute nearby water, and waste money. Apply '
          'based on soil test results and recommended rates for your crop, '
          'not guesswork.',

      'articleIrrigationTitle': 'Smart Irrigation: Saving Water, Raising Yield',
      'articleIrrigationSummary':
          'Practical tips to water your crop efficiently without wasting it.',
      'articleIrrigationSec1Heading': 'Water at the Right Growth Stage',
      'articleIrrigationSec1Body':
          'Every crop has critical stages — like flowering or grain filling — '
          'where a lack of water hurts yield the most. Prioritize irrigation at '
          'these stages rather than following a fixed calendar regardless of '
          'crop condition.',
      'articleIrrigationSec2Heading': 'Drip and Sprinkler Systems',
      'articleIrrigationSec2Body':
          'Drip and sprinkler irrigation can cut water use significantly '
          'compared to flood irrigation, especially for row crops and orchards. '
          'The upfront cost pays off over time through water and labor savings.',
      'articleIrrigationSec3Heading': 'Checking Soil Moisture First',
      'articleIrrigationSec3Body':
          'Before irrigating, check moisture by pressing a handful of soil from '
          'root depth — if it holds together, you likely don\'t need water yet. '
          'This simple habit avoids both under- and over-watering.',
      'articleIrrigationSec4Heading': 'The Cost of Overwatering',
      'articleIrrigationSec4Body':
          'Excess water causes waterlogging, root rot, and washes away '
          'nutrients before plants can use them. More water is not always '
          'better — matching supply to actual crop need is what improves '
          'yield.',

      'articleWeatherTitle': 'Managing Your Crop Around the Weather',
      'articleWeatherSummary':
          'How to plan farm activities using weather forecasts effectively.',
      'articleWeatherSec1Heading': 'Before Expected Rainfall',
      'articleWeatherSec1Body':
          'Clear field drains ahead of forecasted heavy rain to prevent '
          'waterlogging, and delay fertilizer or pesticide spraying so it '
          'isn\'t washed away — check the forecast a day or two in advance.',
      'articleWeatherSec2Heading': 'Protecting Crops in a Heat Wave',
      'articleWeatherSec2Body':
          'During extreme heat, irrigate early morning or evening to reduce '
          'evaporation loss and heat stress, and avoid spraying chemicals '
          'during the hottest part of the day.',
      'articleWeatherSec3Heading': 'Guarding Against Frost and Cold',
      'articleWeatherSec3Body':
          'On nights when frost is expected, light irrigation before nightfall '
          'or smoke/smudge fires around the field can help raise the local '
          'temperature enough to protect sensitive crops.',
      'articleWeatherSec4Heading': 'Using the Weather Forecast in This App',
      'articleWeatherSec4Body':
          'Check the Weather section regularly to time irrigation, spraying, '
          'and harvesting around upcoming conditions instead of reacting after '
          'damage has already happened.',

      'articleMandiTitle': 'Understanding Mandi Rates to Get a Better Price',
      'articleMandiSummary':
          'How mandi pricing works and how to time your sale wisely.',
      'articleMandiSec1Heading': 'What Determines the Mandi Rate',
      'articleMandiSec1Body':
          'Mandi rates change daily based on how much produce arrives that day, '
          'quality, demand from buyers, and prices in nearby markets. Rates can '
          'vary noticeably between nearby mandis on the same day.',
      'articleMandiSec2Heading': 'Timing Your Sale',
      'articleMandiSec2Body':
          'Prices often drop right after harvest season begins because supply '
          'is high everywhere at once. Where storage is possible, selling part '
          'of your produce later in smaller batches can sometimes fetch a '
          'better average price.',
      'articleMandiSec3Heading': 'Quality and Grading Matter',
      'articleMandiSec3Body':
          'Cleaning, sorting, and grading your produce before taking it to '
          'market usually earns a noticeably better rate than selling it mixed '
          'and unsorted.',
      'articleMandiSec4Heading': 'Compare Rates Before You Sell',
      'articleMandiSec4Body':
          'Use the Marketplace section of this app to compare current rates '
          'across mandis before deciding where and when to sell your crop.',

      'articleGovtTitle': 'Government Schemes Every Farmer Should Know',
      'articleGovtSummary':
          'An overview of common support programs available to farmers.',
      'articleGovtSec1Heading': 'Input Subsidy Schemes',
      'articleGovtSec1Body':
          'Federal and provincial governments periodically offer subsidies on '
          'seed, fertilizer, or machinery to registered farmers. Availability '
          'and eligibility change over time, so check with your local '
          'agriculture office for current programs.',
      'articleGovtSec2Heading': 'Agricultural Loans (e.g. ZTBL)',
      'articleGovtSec2Body':
          'Institutions like the Zarai Taraqiati Bank offer production and '
          'development loans to farmers, often at easier terms than commercial '
          'banks, to help cover input costs or equipment purchases.',
      'articleGovtSec3Heading': 'Crop Insurance',
      'articleGovtSec3Body':
          'Crop insurance schemes can help protect farmers from major losses '
          'due to floods, drought, or other natural calamities. Coverage '
          'details vary by program and region.',
      'articleGovtSec4Heading': 'How to Apply',
      'articleGovtSec4Body':
          'Visit your nearest agriculture department office or bank branch '
          'with your land records and CNIC to check current eligibility and '
          'application requirements — programs and rules are updated '
          'periodically.',

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
      'learningIntroTitle': 'Watch & learn',
      'learningIntroHint':
          'Short video tutorials from trusted channels, organized by crop.',
      'featuredLearning': 'Featured Lesson',
      'watchNow': 'Watch Now',
      'learningEmpty': 'No videos found for this category yet.',
      'learningFilterByCrop': 'Filter by crop',
      'learningSearchHint': 'Search e.g. wheat disease, cotton fertilizer…',
      'learningNoSearchResults': 'No videos match your search.',
      'learningPopularSearches': 'Popular searches',
      'learningTopicDisease': 'Diseases',
      'learningTopicFertilizer': 'Fertilizer',
      'learningTopicPest': 'Pest control',
      'learningTopicSowing': 'Sowing',
      'learningSearchResultsFor': 'Results for “{query}”',
      'learningSearching': 'Searching…',
      'learningResultCount': '{count} videos',
      'learningClearSearch': 'Clear',
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
      'sensorMoistureRequired': 'Soil moisture is required',
      'sensorMoistureRange': 'Soil moisture must be between 0 and 100',
      'sensorPhRequired': 'pH value is required',
      'sensorPhRange': 'pH must be between 0 and 14',
      'sensorInvalidNumber': 'Please enter a valid number',
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

      // ── Crop calendar ──
      'cropCalAreasTitle': 'Punjab Areas',
      'cropCalAreaMultan': 'Multan',
      'cropCalAreaLahore': 'Lahore',
      'cropCalAreaLabel': 'Area',
      'cropCalSeasonProgress': 'Season Progress',
      'cropCalSowingWindow': 'Best Sowing Window',
      'cropCalCurrentStage': 'Current stage',
      'cropCalUpcoming': 'Upcoming',
      'cropCalCompleted': 'Completed',
      'cropCalOffSeason': 'Off-season',
      'cropCalActivities': 'Activities',
      'cropCalProgressLabel': '{percent}% of season',
      'cropCalSowingFromTo': 'From {start} to {end}',
      'cropCalNoStageActive': 'No active stage. Plan ahead for the next sowing window.',

      'cropCalStageSowing': 'Sowing',
      'cropCalStageIrrigation': 'Irrigation',
      'cropCalStageFertilizer': 'Fertilizer',
      'cropCalStagePestControl': 'Pest Control',
      'cropCalStageHarvest': 'Harvest',

      'cropCalMonth1': 'Jan',
      'cropCalMonth2': 'Feb',
      'cropCalMonth3': 'Mar',
      'cropCalMonth4': 'Apr',
      'cropCalMonth5': 'May',
      'cropCalMonth6': 'Jun',
      'cropCalMonth7': 'Jul',
      'cropCalMonth8': 'Aug',
      'cropCalMonth9': 'Sep',
      'cropCalMonth10': 'Oct',
      'cropCalMonth11': 'Nov',
      'cropCalMonth12': 'Dec',

      'cropCalWheatSowingDesc':
          'Prepare seedbed and sow certified wheat seed; ensure good moisture before sowing.',
      'cropCalWheatIrrigationDesc':
          'Apply first irrigation 20–25 days after sowing; second around tillering stage.',
      'cropCalWheatFertilizerDesc':
          'Split-dose urea with second irrigation; balance with DAP at sowing.',
      'cropCalWheatHarvestDesc':
          'Harvest when grains are firm and moisture is around 14%.',

      'cropCalRiceSowingDesc':
          'Raise nursery in puddled soil and transplant healthy 25–30 day seedlings.',
      'cropCalRiceIrrigationDesc':
          'Maintain 5–7 cm standing water during tillering and panicle formation.',
      'cropCalRicePestControlDesc':
          'Scout for stem borer and leaf folder; spray only when economic threshold is crossed.',
      'cropCalRiceHarvestDesc':
          'Harvest when 80–85% of panicles turn golden; reduce moisture before threshing.',

      'cropCalCottonSowingDesc':
          'Sow on raised beds in warm dry soil; treat seed against sucking pests.',
      'cropCalCottonIrrigationDesc':
          'Schedule irrigation by canopy and weather; avoid late-season water stress.',
      'cropCalCottonPestControlDesc':
          'Monitor whitefly and pink bollworm; use IPM and resistant varieties.',
      'cropCalCottonHarvestDesc':
          'Pick mature open bolls in dry weather; keep trash low for premium grade.',

      'cropCalNoteWheatMultan':
          'South Punjab — sow earlier (mid-October) due to warmer winters; expect harvest 7–10 days sooner.',
      'cropCalNoteWheatLahore':
          'Central Punjab — standard late-October to mid-November sowing window works best.',
      'cropCalNoteRiceMultan':
          'Higher heat — irrigate early morning to reduce evapotranspiration losses.',
      'cropCalNoteRiceLahore':
          'Basmati performs best here with cooler nights during ripening.',
      'cropCalNoteCottonMultan':
          'Cotton belt — best yields with early sowing in March and disciplined IPM.',
      'cropCalNoteCottonLahore':
          'Sow after wheat harvest (late April–May) for a shorter cotton season.',
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
      'learningYoutubeVideos': 'یوٹیوب تعلیمی ویڈیوز',
      'learningOptionYoutube': 'یوٹیوب تعلیمی ویڈیوز',
      'learningOptionArticles': 'تعلیمی مضامین',
      'learningOptionPests': 'کیڑے اور بیماریاں',
      'comingSoon': 'جلد آرہا ہے',
      'cropDiseasePickCrop': 'فصل منتخب کریں',
      'cropDiseasePickCropHint':
          'عام بیماریوں، علامات اور علاج کی تجاویز دیکھنے کے لیے فصل پر ٹیپ کریں۔',
      'cropDiseaseMoreCropsSoon':
          'مزید فصلیں اور بیماریاں وقتاً فوقتاً شامل کی جاتی ہیں۔',
      'cropDiseaseEmpty': 'ابھی کوئی مواد دستیاب نہیں۔ جلد دوبارہ چیک کریں۔',
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
      'cdSugarcaneRedRotName': 'ریڈ روٹ (سرخ سڑن)',
      'cdSugarcaneRedRotDesc':
          'ایک سنگین فنگس بیماری جس سے گنے کے اندر سرخی مائل حصے بن جاتے ہیں اور وہ سوکھ جاتا ہے۔',
      'cdSugarcaneRedRotSym1': 'گنا کاٹنے پر اندر سرخی مائل دھبے',
      'cdSugarcaneRedRotSym2': 'پتے اوپر سے نیچے کی طرف سوکھنا شروع ہوتے ہیں',
      'cdSugarcaneRedRotSol1': 'صرف بیماری سے پاک، مزاحم بیج والا گنا لگائیں',
      'cdSugarcaneRedRotSol2': 'متاثرہ پودے فوراً نکال کر جلا دیں',
      'cdSugarcaneBorerName': 'تنے کا کیڑا',
      'cdSugarcaneBorerDesc':
          'لاروا تنے میں سوراخ کر کے بڑھوت کمزور کرتا ہے اور چینی کی مقدار کم کر دیتا ہے۔',
      'cdSugarcaneBorerSym1': 'نئی شاخوں میں مُردہ دل',
      'cdSugarcaneBorerSym2': 'تنے پر چھوٹے سوراخ اور بُرادہ',
      'cdSugarcaneBorerSol1': 'ٹرائیکوگراما (انڈوں کا پیراسائٹ) چھوڑیں',
      'cdSugarcaneBorerSol2': 'متاثرہ شاخیں جلد نکال کر تلف کریں',
      'cdSugarcaneSmutName': 'وہپ سمَٹ',
      'cdSugarcaneSmutDesc':
          'فنگس بیماری جس سے پودے کی چوٹی سے لمبا کالا کوڑے نما بڑھاؤ نکلتا ہے۔',
      'cdSugarcaneSmutSym1': 'چوٹی سے کالا کوڑے نما ڈھانچہ نکلنا',
      'cdSugarcaneSmutSol1': 'مزاحم اقسام اور علاج شدہ بیج استعمال کریں',
      'cdSugarcaneSmutSol2': 'متاثرہ جھنڈ نکال کر تلف کریں',
      'cdMaizeBorerName': 'تنے کا کیڑا',
      'cdMaizeBorerDesc':
          'لاروا تنے کے اندر سوراخ کر کے پودے کمزور کر دیتا ہے اور تنا گر جاتا ہے۔',
      'cdMaizeBorerSym1': 'پتوں پر قطار میں چھوٹے سوراخ',
      'cdMaizeBorerSym2': 'تنا ٹوٹا یا گرا ہوا',
      'cdMaizeBorerSol1': 'وہرل مرحلے پر تجویز کردہ کیڑے مار دوا لگائیں',
      'cdMaizeBorerSol2': 'کٹائی کے بعد فصل کی باقیات تلف کریں',
      'cdMaizeBlightName': 'پتوں کا جھلساؤ',
      'cdMaizeBlightDesc':
          'فنگس بیماری جس سے پتوں پر لمبے سرمئی سبز دھبے بن جاتے ہیں۔',
      'cdMaizeBlightSym1': 'پتوں پر لمبے سگار نما سرمئی سبز دھبے',
      'cdMaizeBlightSol1': 'مزاحم اقسام اور فصل کی تبدیلی اپنائیں',
      'cdMaizeBlightSol2': 'ابتدا میں پھیلاؤ ہو تو فنگس کش لگائیں',
      'cdMaizeFallArmywormName': 'فال آرمی ورم',
      'cdMaizeFallArmywormDesc':
          'ایک نیا حملہ آور کیڑا جس کا لاروا پتوں اور وہرل کو شدید نقصان پہنچاتا ہے۔',
      'cdMaizeFallArmywormSym1': 'پتوں پر بے ترتیب سوراخ اور وہرل کو نقصان',
      'cdMaizeFallArmywormSym2': 'وہرل کے قریب بُرادے جیسا مادہ',
      'cdMaizeFallArmywormSol1': 'ہر ہفتے کھیت کا معائنہ کریں اور جلد عمل کریں',
      'cdMaizeFallArmywormSol2':
          'منظور شدہ کیڑے مار دوا براہ راست وہرل میں ڈالیں',

      // ── Learning Articles (تعلیمی مضامین) ──
      'articlesIntroTitle': 'تعلیمی مضامین دیکھیں',
      'articlesIntroHint':
          'زمین، کھاد، آبپاشی، موسم، منڈی ریٹس اور سرکاری اسکیموں پر تفصیلی رہنمائی۔',
      'articlesPickCategory': 'موضوع کے مطابق دیکھیں',
      'articlesSearchHint': 'مضامین تلاش کریں',
      'articlesEmpty': 'کوئی مضمون نہیں ملا۔',
      'articlesAllCategory': 'تمام',
      'articleReadTime4': '4 منٹ کا مطالعہ',
      'articleReadTime5': '5 منٹ کا مطالعہ',
      'articleReadTimeMinutes': '{minutes} منٹ کا مطالعہ',
      'articleCategorySoil': 'زمین',
      'articleCategoryFertilizer': 'کھاد',
      'articleCategoryIrrigation': 'آبپاشی',
      'articleCategoryWeather': 'موسمی رہنمائی',
      'articleCategoryMandi': 'منڈی اور مارکیٹ',
      'articleCategoryGovt': 'سرکاری اسکیمیں',

      'articleSoilPrepTitle': 'زمین کی تیاری کا صحیح طریقہ',
      'articleSoilPrepSummary':
          'مضبوط اور صحت مند فصل کے لیے کھیت کی تیاری کے بنیادی اصول۔',
      'articleSoilPrepSec1Heading': 'مٹی کی جانچ کیوں ضروری ہے',
      'articleSoilPrepSec1Body':
          'ہر موسم سے پہلے اپنی مٹی کی پی ایچ اور اہم غذائی اجزاء کی جانچ کروائیں۔ '
          'یہ جاننا کہ مٹی میں پہلے سے کیا موجود ہے، غیر ضروری کھاد پر پیسہ ضائع '
          'ہونے سے بچاتا ہے اور بتاتا ہے کہ آپ کی فصل کے لیے کیا ڈالنا چاہیے۔',
      'articleSoilPrepSec2Heading': 'ہل چلانے کا صحیح طریقہ',
      'articleSoilPrepSec2Body':
          '2–3 بار گہرا ہل چلانے سے سخت تہہ ٹوٹ جاتی ہے اور جڑیں گہرائی تک '
          'بڑھ سکتی ہیں۔ ہل اس وقت چلائیں جب مٹی میں مناسب نمی ہو — بہت زیادہ '
          'گیلی یا بالکل خشک مٹی پر کام مشکل اور نتائج کمزور ہوتے ہیں۔ اس کے '
          'بعد سہاگہ لگا کر ڈھیلے توڑ کر باریک بیج کیاری بنائیں۔',
      'articleSoilPrepSec3Heading': 'کھیت کو ہموار کرنا',
      'articleSoilPrepSec3Body':
          'ناہموار کھیت میں آبپاشی کے دوران کچھ حصے ڈوب جاتے ہیں جبکہ کچھ خشک '
          'رہ جاتے ہیں۔ صحیح ہمواری — ممکن ہو تو لیزر لیولنگ — پانی بچاتی ہے، '
          'یکساں اگاؤ یقینی بناتی ہے اور بغیر اضافی خرچ کے پیداوار بڑھا سکتی ہے۔',
      'articleSoilPrepSec4Heading': 'نامیاتی مادہ شامل کرنا',
      'articleSoilPrepSec4Body':
          'آخری ہل سے پہلے اچھی طرح گلی ہوئی گوبر کھاد یا کمپوسٹ مٹی میں ملانے '
          'سے مٹی کی ساخت، پانی روکنے کی صلاحیت اور طویل مدتی زرخیزی بہتر ہوتی '
          'ہے۔ یہ کیمیائی کھاد کا متبادل نہیں بلکہ اس کے ساتھ مل کر کام کرتی ہے۔',

      'articleFertilizerTitle': 'کھاد (این پی کے) کا مکمل رہنما',
      'articleFertilizerSummary':
          'نائٹروجن، فاسفورس اور پوٹاش کو سمجھیں — اور یہ کب ڈالنی چاہیے۔',
      'articleFertilizerSec1Heading': 'این پی کے اصل میں کیا کرتی ہے',
      'articleFertilizerSec1Body':
          'نائٹروجن (N) پتوں کی بڑھوت اور ہریالی بڑھاتی ہے۔ فاسفورس (P) مضبوط '
          'جڑیں بناتی ہے اور پھول و دانہ بننے میں مدد دیتی ہے۔ پوٹاشیم (K) تنے '
          'مضبوط کرتا ہے، بیماریوں کے خلاف مزاحمت بڑھاتا ہے اور دانے و پھل کی '
          'کوالٹی بہتر کرتا ہے۔',
      'articleFertilizerSec2Heading': 'ہر خوراک کب دینی چاہیے',
      'articleFertilizerSec2Body':
          'بوائی کے وقت مکمل فاسفورس اور پوٹاش بطور بنیادی خوراک ڈالیں کیونکہ '
          'یہ مٹی میں آہستہ حرکت کرتے ہیں۔ نائٹروجن کو ایک ساتھ دینے کے بجائے '
          'اہم بڑھوت کے مراحل میں 2–3 حصوں میں تقسیم کریں — اس سے ضیاع کم اور '
          'فصل کی اصل ضرورت پوری ہوتی ہے۔',
      'articleFertilizerSec3Heading': 'نامیاتی اور کیمیائی کھاد میں توازن',
      'articleFertilizerSec3Body':
          'گوبر کھاد اور کمپوسٹ وقت کے ساتھ مٹی کی صحت بہتر کرتے ہیں لیکن '
          'غذائی اجزاء آہستہ خارج کرتے ہیں۔ نامیاتی مادے کو کیمیائی کھاد کے '
          'ساتھ ملانا عام طور پر اکیلے استعمال سے بہتر طویل مدتی نتائج دیتا ہے۔',
      'articleFertilizerSec4Heading': 'زیادہ کھاد ڈالنے کے نقصانات',
      'articleFertilizerSec4Body':
          'ضرورت سے زیادہ کھاد نئے پودوں کو نقصان پہنچا سکتی ہے، کمزور اور '
          'بیماری کا شکار بڑھوت کو فروغ دیتی ہے، قریبی پانی کو آلودہ کرتی ہے '
          'اور پیسہ ضائع کرتی ہے۔ اندازے کے بجائے مٹی کی جانچ اور تجویز کردہ '
          'مقدار کے مطابق کھاد ڈالیں۔',

      'articleIrrigationTitle': 'سمارٹ آبپاشی: پانی بچائیں، پیداوار بڑھائیں',
      'articleIrrigationSummary':
          'پانی ضائع کیے بغیر فصل کو مؤثر طریقے سے سیراب کرنے کی تجاویز۔',
      'articleIrrigationSec1Heading': 'صحیح بڑھوت کے مرحلے پر پانی دیں',
      'articleIrrigationSec1Body':
          'ہر فصل کے کچھ اہم مراحل ہوتے ہیں — جیسے پھول یا دانہ بھرنا — جہاں '
          'پانی کی کمی سب سے زیادہ نقصان دیتی ہے۔ فصل کی حالت کو نظر انداز '
          'کرتے ہوئے مقررہ شیڈول کے بجائے انہی مراحل پر آبپاشی کو ترجیح دیں۔',
      'articleIrrigationSec2Heading': 'ڈرپ اور سپرنکلر نظام',
      'articleIrrigationSec2Body':
          'ڈرپ اور سپرنکلر آبپاشی سیلابی آبپاشی کے مقابلے میں پانی کا استعمال '
          'نمایاں طور پر کم کر سکتی ہے، خاص طور پر قطار والی فصلوں اور باغات '
          'کے لیے۔ ابتدائی خرچ وقت کے ساتھ پانی اور مزدوری کی بچت سے پورا '
          'ہو جاتا ہے۔',
      'articleIrrigationSec3Heading': 'پہلے مٹی کی نمی چیک کریں',
      'articleIrrigationSec3Body':
          'آبپاشی سے پہلے جڑوں کی گہرائی سے مٹی کی مٹھی بھر کر دبائیں — اگر یہ '
          'جڑی رہے تو ابھی پانی کی ضرورت نہیں۔ یہ آسان عادت پانی کی کمی اور '
          'زیادتی دونوں سے بچاتی ہے۔',
      'articleIrrigationSec4Heading': 'زیادہ پانی دینے کا نقصان',
      'articleIrrigationSec4Body':
          'زیادہ پانی سے کھیت میں پانی کھڑا ہونا، جڑوں کی سڑن اور غذائی اجزاء '
          'کا بہہ جانا ہوتا ہے۔ زیادہ پانی ہمیشہ بہتر نہیں ہوتا — فصل کی اصل '
          'ضرورت کے مطابق پانی دینا ہی پیداوار بہتر بناتا ہے۔',

      'articleWeatherTitle': 'موسم کے مطابق فصل کی دیکھ بھال',
      'articleWeatherSummary':
          'موسمی پیشگوئی کو مؤثر طریقے سے کھیتی کے کاموں کی منصوبہ بندی میں '
          'استعمال کرنے کا طریقہ۔',
      'articleWeatherSec1Heading': 'متوقع بارش سے پہلے',
      'articleWeatherSec1Body':
          'شدید بارش کی پیشگوئی سے پہلے کھیت کی نکاسی صاف کریں تاکہ پانی کھڑا '
          'نہ ہو، اور کھاد یا دوا کا اسپرے مؤخر کریں تاکہ بارش سے بہہ نہ جائے '
          '— ایک دو دن پہلے موسم چیک کر لیں۔',
      'articleWeatherSec2Heading': 'شدید گرمی میں فصل کی حفاظت',
      'articleWeatherSec2Body':
          'شدید گرمی کے دوران صبح سویرے یا شام کو آبپاشی کریں تاکہ پانی کم '
          'اڑے اور گرمی کا دباؤ کم ہو، اور دن کے سب سے گرم حصے میں دوا کا '
          'اسپرے نہ کریں۔',
      'articleWeatherSec3Heading': 'دھند اور سردی سے بچاؤ',
      'articleWeatherSec3Body':
          'جن راتوں میں پالا پڑنے کا امکان ہو، رات سے پہلے ہلکی آبپاشی یا کھیت '
          'کے اردگرد دھواں کرنے سے مقامی درجہ حرارت اتنا بڑھ سکتا ہے کہ حساس '
          'فصل محفوظ رہے۔',
      'articleWeatherSec4Heading': 'اس ایپ میں موسمی پیشگوئی کا استعمال',
      'articleWeatherSec4Body':
          'نقصان ہونے کے بعد رد عمل دینے کے بجائے، آبپاشی، اسپرے اور کٹائی کا '
          'وقت طے کرنے کے لیے موسم کا سیکشن باقاعدگی سے چیک کریں۔',

      'articleMandiTitle': 'بہتر قیمت کے لیے منڈی ریٹ سمجھیں',
      'articleMandiSummary':
          'منڈی کی قیمتیں کیسے طے ہوتی ہیں اور فصل بیچنے کا صحیح وقت کیسے چنیں۔',
      'articleMandiSec1Heading': 'منڈی ریٹ کیا طے کرتا ہے',
      'articleMandiSec1Body':
          'منڈی ریٹ روزانہ اس بات پر منحصر ہوتا ہے کہ اس دن کتنی فصل منڈی میں '
          'آئی، کوالٹی کیسی ہے، خریداروں کی مانگ کتنی ہے، اور قریبی منڈیوں میں '
          'قیمتیں کیا ہیں۔ ایک ہی دن قریبی منڈیوں میں ریٹ نمایاں طور پر مختلف '
          'ہو سکتا ہے۔',
      'articleMandiSec2Heading': 'بیچنے کا صحیح وقت',
      'articleMandiSec2Body':
          'فصل کا موسم شروع ہوتے ہی قیمتیں اکثر گر جاتی ہیں کیونکہ ہر جگہ '
          'یکدم زیادہ فصل آ جاتی ہے۔ جہاں ذخیرہ ممکن ہو، تھوڑی تھوڑی مقدار میں '
          'بعد میں بیچنا بعض اوقات بہتر اوسط قیمت دے سکتا ہے۔',
      'articleMandiSec3Heading': 'کوالٹی اور گریڈنگ اہم ہے',
      'articleMandiSec3Body':
          'منڈی لے جانے سے پہلے فصل صاف اور چھانٹ کر لے جانا عام طور پر '
          'ملی جلی اور غیر ترتیب شدہ فصل کے مقابلے میں نمایاں بہتر ریٹ دلاتا '
          'ہے۔',
      'articleMandiSec4Heading': 'بیچنے سے پہلے ریٹ موازنہ کریں',
      'articleMandiSec4Body':
          'فصل کہاں اور کب بیچنی ہے، یہ فیصلہ کرنے سے پہلے مختلف منڈیوں کے '
          'موجودہ ریٹ موازنہ کرنے کے لیے اس ایپ کے مارکیٹ پلیس سیکشن کا '
          'استعمال کریں۔',

      'articleGovtTitle': 'ہر کسان کے لیے ضروری سرکاری اسکیمیں',
      'articleGovtSummary': 'کسانوں کے لیے دستیاب عام امدادی پروگراموں کا خلاصہ۔',
      'articleGovtSec1Heading': 'ان پٹ سبسڈی اسکیمیں',
      'articleGovtSec1Body':
          'وفاقی اور صوبائی حکومتیں وقتاً فوقتاً رجسٹرڈ کسانوں کو بیج، کھاد یا '
          'مشینری پر سبسڈی دیتی ہیں۔ دستیابی اور اہلیت وقت کے ساتھ بدلتی '
          'رہتی ہے، اس لیے موجودہ پروگراموں کے لیے اپنے مقامی زرعی دفتر سے '
          'رابطہ کریں۔',
      'articleGovtSec2Heading': 'زرعی قرضے (مثلاً زرعی ترقیاتی بینک)',
      'articleGovtSec2Body':
          'زرعی ترقیاتی بینک جیسے ادارے کسانوں کو پیداواری اور ترقیاتی قرضے '
          'دیتے ہیں، اکثر کمرشل بینکوں کے مقابلے میں آسان شرائط پر، تاکہ ان '
          'پٹ لاگت یا آلات کی خریداری میں مدد ملے۔',
      'articleGovtSec3Heading': 'فصل بیمہ',
      'articleGovtSec3Body':
          'فصل بیمہ اسکیمیں کسانوں کو سیلاب، خشک سالی یا دیگر قدرتی آفات سے '
          'ہونے والے بڑے نقصان سے بچانے میں مدد دے سکتی ہیں۔ کوریج کی تفصیلات '
          'پروگرام اور علاقے کے مطابق مختلف ہوتی ہیں۔',
      'articleGovtSec4Heading': 'اپلائی کیسے کریں',
      'articleGovtSec4Body':
          'موجودہ اہلیت اور درخواست کی شرائط جاننے کے لیے اپنی زمین کے کاغذات '
          'اور شناختی کارڈ کے ساتھ قریبی زرعی دفتر یا بینک شاخ جائیں — '
          'پروگرام اور قوانین وقتاً فوقتاً اپ ڈیٹ ہوتے رہتے ہیں۔',

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
      'learningIntroTitle': 'دیکھیں اور سیکھیں',
      'learningIntroHint':
          'قابلِ اعتماد چینلز کے مختصر ویڈیو ٹیوٹوریلز، فصل کے مطابق ترتیب دیے گئے۔',
      'featuredLearning': 'نمایاں سبق',
      'watchNow': 'ابھی دیکھیں',
      'learningEmpty': 'اس کیٹیگری کے لیے ابھی ویڈیوز دستیاب نہیں۔',
      'learningFilterByCrop': 'فصل کے مطابق',
      'learningSearchHint': 'تلاش کریں مثلاً گندم کی بیماری، کپاس کی کھاد…',
      'learningNoSearchResults': 'آپ کی تلاش سے کوئی ویڈیو میل نہیں کھاتی۔',
      'learningPopularSearches': 'مقبول تلاش',
      'learningTopicDisease': 'بیماریاں',
      'learningTopicFertilizer': 'کھاد',
      'learningTopicPest': 'کیڑوں کا تدارک',
      'learningTopicSowing': 'کاشت',
      'learningSearchResultsFor': '“{query}” کے نتائج',
      'learningSearching': 'تلاش جاری ہے…',
      'learningResultCount': '{count} ویڈیوز',
      'learningClearSearch': 'صاف کریں',
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
      'sensorMoistureRequired': 'مٹی کی نمی درج کرنا ضروری ہے',
      'sensorMoistureRange': 'نمی 0 سے 100 کے درمیان ہونی چاہیے',
      'sensorPhRequired': 'پی ایچ ویلیو درج کرنا ضروری ہے',
      'sensorPhRange': 'پی ایچ 0 سے 14 کے درمیان ہونا چاہیے',
      'sensorInvalidNumber': 'براہ کرم درست عدد درج کریں',
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

      // ── Crop calendar (Urdu) ──
      'cropCalAreasTitle': 'پنجاب کے علاقے',
      'cropCalAreaMultan': 'ملتان',
      'cropCalAreaLahore': 'لاہور',
      'cropCalAreaLabel': 'علاقہ',
      'cropCalSeasonProgress': 'موسمی پیش رفت',
      'cropCalSowingWindow': 'بہترین بوائی کا وقت',
      'cropCalCurrentStage': 'موجودہ مرحلہ',
      'cropCalUpcoming': 'آنے والا',
      'cropCalCompleted': 'مکمل',
      'cropCalOffSeason': 'بے موسم',
      'cropCalActivities': 'سرگرمیاں',
      'cropCalProgressLabel': '{percent}٪ موسم گزر چکا',
      'cropCalSowingFromTo': '{start} سے {end} تک',
      'cropCalNoStageActive':
          'کوئی فعال مرحلہ نہیں۔ اگلی بوائی کے لیے پہلے سے منصوبہ بنائیں۔',

      'cropCalStageSowing': 'بوائی',
      'cropCalStageIrrigation': 'آبپاشی',
      'cropCalStageFertilizer': 'کھاد',
      'cropCalStagePestControl': 'کیڑے مار اقدام',
      'cropCalStageHarvest': 'کٹائی',

      'cropCalMonth1': 'جنوری',
      'cropCalMonth2': 'فروری',
      'cropCalMonth3': 'مارچ',
      'cropCalMonth4': 'اپریل',
      'cropCalMonth5': 'مئی',
      'cropCalMonth6': 'جون',
      'cropCalMonth7': 'جولائی',
      'cropCalMonth8': 'اگست',
      'cropCalMonth9': 'ستمبر',
      'cropCalMonth10': 'اکتوبر',
      'cropCalMonth11': 'نومبر',
      'cropCalMonth12': 'دسمبر',

      'cropCalWheatSowingDesc':
          'بیج بستر تیار کریں اور تصدیق شدہ گندم کا بیج بوئیں؛ بوائی سے پہلے زمین میں مناسب نمی یقینی بنائیں۔',
      'cropCalWheatIrrigationDesc':
          'بوائی کے 20 تا 25 دن بعد پہلی آبپاشی کریں؛ دوسری آبپاشی شاخوں کے نکلنے کے وقت کریں۔',
      'cropCalWheatFertilizerDesc':
          'یوریا تقسیم خوراک میں دوسری آبپاشی کے ساتھ دیں؛ بوائی پر ڈی اے پی سے توازن قائم کریں۔',
      'cropCalWheatHarvestDesc':
          'دانے سخت ہو جائیں اور نمی تقریباً 14٪ پر آ جائے تو فصل کاٹ لیں۔',

      'cropCalRiceSowingDesc':
          'پانی والی زمین میں نرسری اگائیں اور 25 تا 30 دن کی صحت مند پنیری منتقل کریں۔',
      'cropCalRiceIrrigationDesc':
          'شاخوں اور بالیوں کے بننے کے دوران 5 تا 7 سینٹی میٹر پانی برقرار رکھیں۔',
      'cropCalRicePestControlDesc':
          'تنے کے کیڑے اور پتا لپیٹنے والے کیڑے کی نگرانی کریں؛ صرف معاشی حد عبور ہونے پر اسپرے کریں۔',
      'cropCalRiceHarvestDesc':
          '80 تا 85٪ بالیاں سنہری ہو جائیں تو کٹائی کریں؛ گہائی سے پہلے نمی کم کریں۔',

      'cropCalCottonSowingDesc':
          'گرم اور خشک زمین میں اونچی پٹریوں پر بوائی کریں؛ رس چوسنے والے کیڑوں سے بچاؤ کے لیے بیج کا علاج کریں۔',
      'cropCalCottonIrrigationDesc':
          'پودے کی شاخ بندی اور موسم کے مطابق آبپاشی کا شیڈول بنائیں؛ آخری مرحلے میں پانی کی کمی سے بچائیں۔',
      'cropCalCottonPestControlDesc':
          'سفید مکھی اور گلابی سنڈی کی نگرانی کریں؛ آئی پی ایم اور مزاحم اقسام استعمال کریں۔',
      'cropCalCottonHarvestDesc':
          'پکے کھلے ٹنڈے خشک موسم میں چنیں؛ بہترین معیار کے لیے کوڑا کم رکھیں۔',

      'cropCalNoteWheatMultan':
          'جنوبی پنجاب — گرم سردیوں کی وجہ سے وسط اکتوبر میں جلد بوائی کریں؛ کٹائی 7 تا 10 دن پہلے ممکن ہے۔',
      'cropCalNoteWheatLahore':
          'وسطی پنجاب — اکتوبر کے آخر سے نومبر کے وسط تک معیاری بوائی بہترین نتائج دیتی ہے۔',
      'cropCalNoteRiceMultan':
          'زیادہ گرمی — تبخیر کم کرنے کے لیے صبح سویرے آبپاشی کریں۔',
      'cropCalNoteRiceLahore':
          'باسمتی یہاں بہترین رہتی ہے کیونکہ پکنے کے وقت راتیں ٹھنڈی ہوتی ہیں۔',
      'cropCalNoteCottonMultan':
          'کپاس کا گڑھ — مارچ میں جلد بوائی اور منظم آئی پی ایم سے بہترین پیداوار۔',
      'cropCalNoteCottonLahore':
          'گندم کی کٹائی کے بعد (اپریل کے آخر تا مئی) بوائی کریں تاکہ کپاس کا موسم مختصر رہے۔',
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
    },
  };

  /// Looks up [key] for the active locale, falling back to English then to
  /// the key itself. When [params] is provided, every `{name}` placeholder
  /// in the resolved string is replaced with `params[name]`.
  String t(String key, {Map<String, Object?>? params}) {
    final resolved = _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
    if (params == null || params.isEmpty) return resolved;
    var output = resolved;
    params.forEach((name, value) {
      output = output.replaceAll('{$name}', value?.toString() ?? '');
    });
    return output;
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
