namespace Models
{
    public class UsersLoginSessionData
    {
        public long UserId { get; set; }
        public string EmailId { get; set; }
        public string MobileNo { get; set; }
        public int? EmployeeId { get; set; }
        public int? CustomerId { get; set; }
        public bool IsActive { get; set; }
        public string EmployeeName { get; set; }
        public string EmployeeCode { get; set; }
        public int? RoleId { get; set; }
        public string RoleName { get; set; }
        public string CompanyName { get; set; }
        public int? CustomerTypeId { get; set; }
        public string CustomerTypeName { get; set; }
        public bool IsWebUser { get; set; }
        public bool IsMobileUser { get; set; }
    }

    public class SessionDataCustomer
    {
        public string EmailId { get; set; }
        public string MobileNo { get; set; }
        public string Name { get; set; }
        public string CustomerTypeName { get; set; }
        public string Token { get; set; }
    }

    public class SessionDataEmployee
    {
        public int? EmployeeId { get; set; }
        public string EmployeeCode { get; set; }
        public string Name { get; set; }
        public int? RoleId { get; set; }
        public string EmailId { get; set; }
        public string MobileNo { get; set; }
        public string RoleName { get; set; }
        public string Token { get; set; }
        public List<RoleMasterEmployeePermissionList> UserRoleList { get; set; }
        public List<NotificationResponse> UserNotificationList { get; set; }
    }
    public class RoleMasterEmployeePermissionList
    {
        public string AppType { get; set; }
        public long ModuleId { get; set; }
        public string ModuleName { get; set; }
        public bool View { get; set; }
        public bool Add { get; set; }
        public bool Edit { get; set; }
    }
}
