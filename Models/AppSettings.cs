namespace Models
{
    public class JWT
    {
        public string SecretKey { get; set; }
    }

    public class AppSettings
    {
        public JWT JWT { get; set; }
        public bool EnableWriteLog { get; set; }
    }
}