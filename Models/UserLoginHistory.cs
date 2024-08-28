namespace Models
{
    public class UserLoginHistorySaveParameters
    {
        public long UserId { get; set; }
        public string UserToken { get; set; }
        public DateTime TokenExpireOn { get; set; }
        public string DeviceName { get; set; }
        public string IPAddress { get; set; }
        public bool RememberMe { get; set; }
        public bool IsLoggedIn { get; set; }
    }
}
