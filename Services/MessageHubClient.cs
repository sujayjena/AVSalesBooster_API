using Interfaces.Services;
using Microsoft.AspNetCore.SignalR;

namespace Services
{
    public class MessageHubClient : Hub<IMessageHubClient>
    {
        public async Task SendVisitNotificationToEmployee(List<string> message)
        {
            await Clients.All.SendVisitNotificationToEmployee(message);
        }
    }
}
