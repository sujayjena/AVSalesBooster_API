namespace Helpers
{
    public static class SanitizeValues
    {
        public static string SanitizeValue(this string value)
        {
            return string.IsNullOrEmpty(value) ? string.Empty : value.Trim();
        }

        public static int SanitizeValue(this int? value)
        {
            return value == null ? 0 : Convert.ToInt32(value);
        }

        public static long SanitizeValue(this long? value)
        {
            return value == null ? 0 : Convert.ToInt64(value);
        }

        public static string SanitizeValue(this DateTime value)
        {
            return value.ToString("yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture);
        }
    }
}
