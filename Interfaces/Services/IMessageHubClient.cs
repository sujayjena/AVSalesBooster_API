namespace Interfaces.Services
{
    public interface IMessageHubClient
    {
        Task SendVisitNotificationToEmployee(List<string> message);
    }
}
