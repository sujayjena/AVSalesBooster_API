namespace Models.Constants
{
    public static class ValidationConstants
    {
        public const string FirstNameRequired_Msg = @"First Name is required";
        public const string LastNameRequired_Msg = @"Last Name is required";
        public const string FirstOrLastNameRegExp = @"^[a-zA-Z]+$";
        public const string FirstName_RegExp_Msg = "First Name is Invalid";
        public const string LastName_RegExp_Msg = "Last Name is Invalid";
        public const int FirstName_MaxLength = 50;
        public const string FirstName_MaxLength_Msg = "More than 50 characters are not allowed for First Name";
        public const int LastName_MaxLength = 50;
        public const string LastName_MaxLength_Msg = "More than 50 characters are not allowed for Last Name";

        public const string NameRegExp = @"^[a-zA-Z\s]+$";

        public const string RoleNameRegExp = @"^[a-zA-Z\s]+$";
        public const string RoleNameRegExp_Msg = @"Role Name is Invalid";
        public const string RoleNameRequied_Msg = @"Role Name is required";
        public const int RoleName_MaxLength = 100;
        public const string RoleName_MaxLength_Msg = "More than 100 characters are not allowed for Role Name";

        public const string RefPartyNameRequired_Msg = @"Ref. Party Name is required";
        public const string RefPartyNameRegExp_Msg = "Ref. Party Name value is invalid";
        public const int RefPartyName_MaxLength = 100;
        public const string RefPartyName_MaxLength_Msg = "More than 100 characters are not allowed for Ref. Party Name";

        public const int ContactName_MaxLength = 50;
        public const string ContactName_MaxLength_Msg = "More than 50 characters are not allowed for Contact Name";

        public const string ProductRequied_Dropdown_Msg = @"Product is required";
        public const string BrandRequied_Dropdown_Msg = @"Brand is required";
        public const string SizeRequied_Dropdown_Msg = @"Size is required";
        public const string CategoryRequied_Dropdown_Msg = @"Category is required";
        public const string SeriesRequied_Dropdown_Msg = @"Series is required";
        public const string DesignTypeRequied_Dropdown_Msg = @"Design Type is required";
        public const string BaseDesignRequied_Dropdown_Msg = @"Base Design Type is required";
        public const string RoleRequied_Dropdown_Msg = @"Role is required";
        public const string ReportingToRequied_Dropdown_Msg = @"Reporting To is required";
        public const string StateRequied_Dropdown_Msg = @"State is required";
        public const string RegionRequied_Dropdown_Msg = @"Region is required";
        public const string DistrictRequied_Dropdown_Msg = @"District is required";
        public const string AreaRequied_Dropdown_Msg = @"Area is required";
        public const string LeaveRequied_Dropdown_Msg = @"Leave is required";
        public const string AddressTypeRequied_Dropdown_Msg = @"Address Type is required";


        public const string EmpIdRequired_Msg = @"Employee ID is required";
        public const string EmpCodeRequired_Msg = @"Employee Code is required";
        public const string EmpCodeRegExp = @"^[a-zA-Z0-9-]+$";
        public const string EmpCodeRegExp_Msg = "Employee Code is Invalid";
        public const int EmpCode_MaxLength = 20;
        public const string EmpCode_MaxLength_Msg = "More than 20 characters are not allowed for Employee Code";

        public const string EmployeeNameRequied_Msg = @"Employee Name is required";
        public const string EmployeeNameRegExp_Msg = @"Employee Name is Invalid";
        public const string EmployeeNameRegExp = @"^[a-zA-Z\s]+$";
        public const int EmployeeName_MaxLength = 100;
        public const string EmployeeName_MaxLength_Msg = "More than 100 characters are not allowed for Employee Name";

        public const string EmailIdRequied_Msg = @"Email Id is required";
        public const string EmailRegExp = "^([a-zA-Z0-9_-]([-\\.\\w]*[a-zA-Z0-9_-])*@([a-zA-Z0-9_-][-\\w]*[a-zA-Z0-9_-]\\.)+[a-zA-Z]{2,9})$";
        public const string EmailRegExp_Msg = "Email Id is invalid";
        public const int Email_MaxLength = 200;
        public const string Email_MaxLength_Msg = "More than 200 characters are not allowed for Email Id";

        public const string MobileNumberRequied_Msg = @"Mobile Number is required";
        public const string MobileNumberRegExp = @"^[0-9]+$";
        public const string MobileNumberRegExp_Msg = "Mobile Number value is invalid";
        public const int MobileNumber_MaxLength = 10;
        public const string MobileNumber_MaxLength_Msg = "More than 10 characters are not allowed for Mobile Number";

        public const string PhoneNumberRequied_Msg = @"Phone Number is required";
        public const string PhoneNumberRegExp = @"^[0-9]+$";
        public const string PhoneNumberRegExp_Msg = "Phone Number value is invalid";
        public const string LandlineNumberRegExp_Msg = "Landline Number value is invalid";
        public const int PhoneNumber_MaxLength = 10;
        public const string PhoneNumber_MaxLength_Msg = "More than 10 characters are not allowed for Phone Number";
        public const string LandlineNumber_MaxLength_Msg = "More than 10 characters are not allowed for Landline Number";

        public const string GSTNumberRequired_Msg = @"GST Number is required";
        public const string GSTNumberRegExp = @"^[0-9a-zA-Z]+$";
        public const string GSTNumberRegExp_Msg = "GST Number value is invalid";
        public const int GSTNumber_MaxLength = 15;
        public const string GST_MaxLength_Msg = "More than 15 characters are not allowed for GST Number";

        public const string PANNumberRequired_Msg = @"PAN Number is required";
        public const string PANNumberRegExp = @"^[0-9a-zA-Z]+$";
        public const string PANNumberRegExp_Msg = "PAN Number value is invalid";
        public const int PANNumber_MaxLength = 10;
        public const string PANNumber_MaxLength_Msg = "More than 10 characters are not allowed for PAN Number";

        public const string StateNameRegExp = @"^[a-zA-Z-\s]+$";
        public const string StateNameRequied_Msg = @"State Name is required";
        public const string StateNameRegExp_Msg = @"State Name is Invalid";
        public const int StateName_MaxLength = 100;
        public const string StateName_MaxLength_Msg = "More than 100 characters are not allowed for State Name";

        public const string RegionNameRegExp = @"^[a-zA-Z-\s]+$";
        public const string RegionNameRequied_Msg = @"Region Name is required";
        public const string RegionNameRegExp_Msg = @"Region Name is Invalid";
        public const int RegionName_MaxLength = 100;
        public const string RegionName_MaxLength_Msg = "More than 100 characters are not allowed for Region Name";

        public const string DistrictNameRegExp = @"^[a-zA-Z-\s]+$";
        public const string DistrictNameRequied_Msg = @"District Name is required";
        public const string DistrictNameRegExp_Msg = @"District Name is Invalid";
        public const int DistrictName_MaxLength = 100;
        public const string DistrictName_MaxLength_Msg = "More than 100 characters are not allowed for District Name";

        public const string CityNameRequied_Msg = @"City is required";
        public const string CityNameRegExp_Msg = @"City Name is Invalid";
        public const string CityName_MaxLength_Msg = "More than 100 characters are not allowed for City Name";

        public const string AreaNameRegExp = @"^[a-zA-Z-\s]+$";
        public const string AreaNameRequied_Msg = @"Area Name is required";
        public const string AreaNameRegExp_Msg = @"Area Name is Invalid";
        public const int AreaName_MaxLength = 100;
        public const string AreaName_MaxLength_Msg = "More than 100 characters are not allowed for Area Name";

        public const string PincodeRequied_Msg = @"Pincode is required";
        public const int Pincode_MinLength = 4;
        public const int Pincode_MaxLength = 11;
        public const string PincodeExp = @"^[0-9-]+$";
        public const string Pincode_MinLength_Msg = "Pincode must be of at least 4 character long";
        public const string Pincode_MaxLength_Msg = "More than 11 characters are not allowed for Pincode";
        public const string Pincode_Validation_Msg = "Pincode is Invalid";

        public const string DateOfBirthRequied_Msg = @"Date Of Birth is required";
        public const string DateOfJoiningRequied_Msg = @"Date Of Joining is required";


        public const int Name_MaxLength = 100;


        public const string CompanyNameRequied_Msg = @"Company Name is required";
        public const string CompanyNameRegExp = @"^[a-zA-Z0-9-\s.]+$";
        public const string CompanyNameRegExp_Msg = @"Company Name is Invalid";
        public const int CompanyName_MaxLength = 100;
        public const string CompanyName_MaxLength_Msg = "More than 100 characters are not allowed for Company Name";

        public const string CompanyTypeRequied_Msg = @"Company Type is required";
        public const string CompanyTypeRegExp_Msg = @"Company Type is Invalid";
        public const string CompanyType_MaxLength_Msg = "More than 100 characters are not allowed for Company Type";

        public const string CountryRequied_Msg = @"Country is required";
        public const string CountryRegExp_Msg = @"Country is Invalid";
        public const string Country_MaxLength_Msg = "More than 100 characters are not allowed for Country";

        public const string LeaveTypeRequied_Msg = @"Leave Type is required";
        public const string LeaveTypeRegExp_Msg = @"Leave Type is Invalid";
        public const string LeaveType_MaxLength_Msg = "More than 100 characters are not allowed for Leave Type";

        public const string LeaveId_Required_Msg = @"Leave ID is required";
        public const string LeaveStatus_Required_Msg = @"Leave Status is required";
        public const int LeaveReason_MaxLength = 100;
        public const string LeaveReason_MaxLength_Msg = "More than 100 characters are not allowed for Leave Reason";

        public const string StatusNameRequied_Msg = @"Status Name is required";
        public const string StatusNameRegExp_Msg = @"Status Name is Invalid";
        public const string StatusName_MaxLength_Msg = "More than 100 characters are not allowed for Status Name";
        public const string VisitStatus_Required_Msg = @"Visit Status is required";

        public const string ProductNameRequied_Msg = @"Product Name is required";
        public const string ProductNameRegExp = @"^[a-zA-Z0-9-\s]+$";
        public const string ProductNameRegExp_Msg = "Please enter a valid value for Product Name";
        public const int ProductName_MaxLength = 100;
        public const string ProductName_MaxLength_Msg = "More than 100 characters are not allowed for Product Name";
        
        public const string ExcelFileRegExp = @"^[a-zA-Z0-9\s_\\.:-]+(.xls|.xlsx)$";
        public const string ExcelFileRegExp_Msg = "Excel file name is not valid or file extension is other than xls or xlsx";

        public const string ImageFileRegExp = @"^[a-zA-Z0-9\s_\\.:)(-]+(.png|.jpg|.jpeg)$";
        public const string ImageFileRegExp_Msg = "Image file name is not valid or file extension is other than png or jpg or jpeg";

        public const string ImageOrPdfFileRegExp = @"^[a-zA-Z0-9\s_\\.:)(-]+(.png|.jpg|.jpeg|.pdf)$";
        public const string ImageOrPdfFileRegExp_Msg = "File name is not valid or file extension is other than png or jpg or jpeg or pdf";

        public const string BrandNameRequied_Msg = @"Brand Name is required";
        public const string BrandNameRegExp = @"^[a-zA-Z0-9-\s]+$";
        public const string BrandNameRegExp_Msg = "Please enter a valid value for Brand Name";
        public const int BrandName_MaxLength = 100;
        public const string BrandName_MaxLength_Msg = "More than 100 characters are not allowed for Brand Name";

        public const string CategoryNameRequied_Msg = @"Category Name is required";
        public const string CategoryNameRegExp = @"^[a-zA-Z0-9-\s]+$";
        public const string CategoryNameRegExp_Msg = "Please enter a valid value for Category Name";
        public const int CategoryName_MaxLength = 100;
        public const string CategoryName_MaxLength_Msg = "More than 100 characters are not allowed for Category Name";

        public const string SizeNameRequied_Msg = @"Size Name is required";
        public const string SizeNameRegExp = @"^[a-zA-Z0-9\s.-]+$";
        public const string SizeNameRegExp_Msg = "Please enter a valid value for Size Name";
        public const int SizeName_MaxLength = 100;
        public const string SizeName_MaxLength_Msg = "More than 100 characters are not allowed for Size Name";

        public const string DesignTypeNameRequied_Msg = @"DesignType Name is required";
        public const string DesignTypeNameRegExp = @"^[a-zA-Z0-9-\s]+$";
        public const string DesignTypeNameRegExp_Msg = "Please enter a valid value for DesignType Name";
        public const int DesignTypeName_MaxLength = 100;
        public const string DesignTypeName_MaxLength_Msg = "More than 100 characters are not allowed for DesignType Name";

        public const string SeriesNameRequied_Msg = @"Series Name is required";
        public const string SeriesNameRegExp = @"^[a-zA-Z0-9-\s]+$";
        public const string SeriesNameRegExp_Msg = "Please enter a valid value for Series Name";
        public const int SeriesName_MaxLength = 100;
        public const string SeriesName_MaxLength_Msg = "More than 100 characters are not allowed for Series Name";

        public const string BaseDesignNameRequied_Msg = @"Base Design Name is required";
        public const string BaseDesignNameRegExp = @"^[a-zA-Z0-9-\s]+$";
        public const string BaseDesignNameRegExp_Msg = "Please enter a valid value for Base Design Name";
        public const int BaseDesignName_MaxLength = 100;
        public const string BaseDesignName_MaxLength_Msg = "More than 100 characters are not allowed for Base Design Name";

        public const string CustomerNameRequired_Msg = @"Customer Name is required";

        public const string CustomerTypeNameRequied_Msg = @"Customer Type Name is required";
        public const string CustomerTypeNameRegExp = @"^[a-zA-Z0-9-\s]+$";
        public const string CustomerTypeNameRegExp_Msg = "Please enter a valid value for Customer Type Name";
        public const int CustomerTypeName_MaxLength = 100;
        public const string CustomerTypeName_MaxLength_Msg = "More than 100 characters are not allowed for Customer Type Name";

        public const string LeaveTypeNameRequied_Msg = @"Leave Type Name is required";
        public const string LeaveTypeNameRegExp = @"^[a-zA-Z0-9-\s]+$";
        public const string LeaveTypeNameRegExp_Msg = "Please enter a valid value for Leave Type Name";
        public const int LeaveTypeName_MaxLength = 100;
        public const string LeaveTypeName_MaxLength_Msg = "More than 100 characters are not allowed for Leave Type Name";

        public const string DesignNameRequied_Msg = @"Design Name is required";
        public const string DesignNameRegExp = @"^[a-zA-Z0-9-\s]+$";
        public const string DesignNameRegExp_Msg = "Please enter a valid value for Design Name";
        public const int DesignName_MaxLength = 100;
        public const string DesignName_MaxLength_Msg = "More than 100 characters are not allowed for Design Name";

        public const string DesignCodeRequied_Msg = @"Design Code is required";
        public const string DesignCodeRegExp = @"^[a-zA-Z0-9-\s]+$";
        public const string DesignCodeRegExp_Msg = "Please enter a valid value for Design Code";
        public const int DesignCode_MaxLength = 100;
        public const string DesignCode_MaxLength_Msg = "More than 100 characters are not allowed for Design Code";

        public const string ReferencePartyRequied_Msg = @"Reference Party is required";
        public const string ReferencePartyRegExp_Msg = @"Reference Party is Invalid";
        public const string ReferencePartyRegExp = @"^[a-zA-Z\s]+$";
        public const int ReferenceParty_MaxLength = 100;
        public const string ReferenceParty_MaxLength_Msg = "More than 100 characters are not allowed for Reference Party";

        public const string AddressIdRequired_Msg = @"Address ID is required";
        public const string AddressRequied_Msg = @"Address is required";
        public const int Address_MaxLength = 100;
        public const string Address_MaxLength_Msg = "More than 100 characters are not allowed for Address";

        public const string VisitAddress_Required_Msg = @"Visit Address value is required";
        public const string VisitAddress_MaxLength_Msg = "More than 100 characters are not allowed for Visit Address";

        public const string RemarkRequied_Msg = @"Remark is required";
        public const int Remark_MaxLength = 500;
        public const string Remark_MaxLength_Msg = "More than 500 characters are not allowed for Remark";

        public const string OTP_Required_Msg = @"OTP is required";
        public const string OTP_RegExp = @"^[0-9]+$";
        public const string OTP_RegExp_Msg = "OTP value is invalid";
        public const int OTP_MinLength = 4;
        public const int OTP_MaxLength = 4;
        public const string OTP_Range_Msg = "OTP must be of 4 characters long";

        public const string Id_Required_Msg = "id field value must be required";

        public const string BloodGroup_Required_Msg = "Blood Group value is required";
        public const string BloodGroup_RegExp = @"^[a-zA-Z\s+-]+$";
        public const string BloodGroup_RegExp_Msg = "Blood Group value is invalid";
        public const int BloodGroup_MaxLength = 10;
        public const string BloodGroup_MaxLength_Msg = "More than 10 characters are not allowed for Blood Group";

        public const string CollectionName_Required_Msg = "Collection Name value is required";
        public const string CollectionName_RegExp = @"^[a-zA-Z0-9\s+_#-]+$";
        public const string CollectionName_RegExp_Msg = "Collection Name value is invalid";
        public const int CollectionName_MaxLength = 100;
        public const string CollectionName_MaxLength_Msg = "More than 100 characters are not allowed for Collection Name";

        public const string CollectionNameId_Required_Msg = "Collection Name Id value is required";
        public const string CollectionNameId_RegExp_Msg = "Collection Name Id value is invalid";
        public const string CollectionNameId_MaxLength_Msg = "More than 100 characters are not allowed for Collection Name Id";

        public const int MobileUniqueId_MaxLength = 250;
        public const string MobileUniqueId_MaxLength_Msg = "More than 250 characters are not allowed for Mobile Unique Id";

        public const string Latitude_Required_Msg = "Latitude value is required";
        public const int Latitude_MaxLength = 15;
        public const string Latitude_MaxLength_Msg = "More than 15 characters are not allowed for Latitude";

        public const string Longitude_Required_Msg = "Longitude value is required";
        public const int Longitude_MaxLength = 15;
        public const string Longitude_MaxLength_Msg = "More than 15 characters are not allowed for Longitude";

        public const string Parameters_Required_Msg = "Parameter's values are required";

        public const string LaunchDateRequied_Msg = @"Launch Date is required";
        public const string CollectionNameRequied_Msg = @"Collection Name is required";

        public const string CatelogRequied_Msg = @"Catelog is required";
        public const string CategoryRequied_Msg = @"Category is required";
        public const string DesignRequied_Msg = @"Design Name is required";
        public const string SizeRequied_Msg = @"Size is required";
        public const string SeriesRequied_Msg = @"Series is required";
        public const string ProjectNameRequied_Msg = @"Project Name is required";

    }
}
