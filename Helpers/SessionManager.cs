using Microsoft.AspNetCore.Http;
using Models;

namespace Helpers
{
    public class SessionManager
    {
        static UsersLoginSessionData? sessionData;
        private static string[] _superAdminRolesList = new string[] { "Superadmin", "Superadmin" };
        //private static string[] _superAdminRolesList = new string[] { "Superadmin", "Sales Executive", "Business Development Manager", "Area Sales Manager", "Regional Sales Manager", "Zonal Head", "CTO", "Vise President", "Admin" };
        private static long _loggedInUserId;
        private static string? _roleName;
        private static bool _isUserSuperAdmin;

        public static long LoggedInUserId { set { _loggedInUserId = value; } get { return _loggedInUserId; } }
        public static string? RoleName { set { _roleName = value; } get { return _roleName?.SanitizeValue(); } }
        public static bool IsUserSuperAdmin { set { _isUserSuperAdmin = value; } get { return _isUserSuperAdmin; } }

        public SessionManager()
        {
            sessionData = (UsersLoginSessionData?)new HttpContextAccessor().HttpContext.Items["SessionData"]!;

            if (sessionData != null)
            {
                LoggedInUserId = sessionData.UserId;
                RoleName = sessionData.RoleName.SanitizeValue()!;
                IsUserSuperAdmin = _superAdminRolesList.Where(r => r.Equals(RoleName, StringComparison.OrdinalIgnoreCase)).Count() > 0;
            }
        }

        //public static void InitializesSessionData()
        //{ 

        //}
    }
}

