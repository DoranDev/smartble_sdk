class PrayerTime {
  final int mFajrHour;
  final int mFajrMinute;
  final int mSunriseHour;
  final int mSunriseMinute;
  final int mDhuhrHour;
  final int mDhuhrMinute;
  final int mAsrHour;
  final int mAsrMinute;
  final int mMaghribHour;
  final int mMaghribMinute;
  final int mIshaHour;
  final int mIshaMinute;

  PrayerTime({
    required this.mFajrHour,
    required this.mFajrMinute,
    required this.mSunriseHour,
    required this.mSunriseMinute,
    required this.mDhuhrHour,
    required this.mDhuhrMinute,
    required this.mAsrHour,
    required this.mAsrMinute,
    required this.mMaghribHour,
    required this.mMaghribMinute,
    required this.mIshaHour,
    required this.mIshaMinute,
  });

  /// Convert to a Map to send via the method channel
  Map<String, int> toMap() {
    return {
      'mFajrHour': mFajrHour,
      'mFajrMinute': mFajrMinute,
      'mSunriseHour': mSunriseHour,
      'mSunriseMinute': mSunriseMinute,
      'mDhuhrHour': mDhuhrHour,
      'mDhuhrMinute': mDhuhrMinute,
      'mAsrHour': mAsrHour,
      'mAsrMinute': mAsrMinute,
      'mMaghribHour': mMaghribHour,
      'mMaghribMinute': mMaghribMinute,
      'mIshaHour': mIshaHour,
      'mIshaMinute': mIshaMinute,
    };
  }
}
