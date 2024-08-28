namespace Models.Constants
{
    public static class ErrorConstants
    {
        public const string InternalServerError = "Internal Server Error occurred while processing request";
        public const string ValidationFailureError = "Invalid parameter(s) provided for the request";
        public const string InactiveProfileError = "Your profile is in-active, please contact to administrator";
        public const string ExpiredSessionError = "Your session has been expired, please re-login to continue";
    }
}
