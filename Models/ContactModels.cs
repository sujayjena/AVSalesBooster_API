namespace Models
{
    public class CustomerContactsListRequest
    {
        public long CustomerId { get; set; }
        public bool? IsActive { get; set; }
    }

    public class CustomerContactsListForFields
    {
        public long ContactId { get; set; }
        public string ContactName { get; set; }
        public string MobileNo { get; set; }
        public string EmailId { get; set; }
    }
}
