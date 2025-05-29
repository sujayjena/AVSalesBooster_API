using Google.Apis.Auth.OAuth2;
using Interfaces.Services;
using Microsoft.AspNetCore.Hosting;
using Models;
using Nancy.Json;
using System;
using System.ComponentModel.DataAnnotations;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace Helpers
{

    public interface IFCMPushNotification
    {
        Task<bool> SendNotification(FCMNotificationModel notification);
    }

    public class FCMPushNotification : IFCMPushNotification
    {
        private readonly IHostingEnvironment _environment;

        private IProfileService _profileService;


        public FCMPushNotification(IHostingEnvironment environment, IProfileService profileService)
        {
            _environment = environment;
            _profileService = profileService;
        }

        public async Task<bool> SendNotification(FCMNotificationModel notification)
        {
            bool isNotificationSent = false;
            var vFCMTokenId = string.Empty;
            var vFileName = string.Empty;
            var vBaseAddress = string.Empty;
            var vRequestJson = string.Empty;
            var vResponseJson = string.Empty;

            if (notification == null || string.IsNullOrEmpty(notification.UserId.ToString()))
            {
                return isNotificationSent = false;
            }
            else
            {
                var vUsers = _profileService.GetUserDetails(notification.UserId).Result;
                if (vUsers != null || !string.IsNullOrEmpty(vUsers.FCMTokenId))
                {
                    vFCMTokenId = vUsers.FCMTokenId;
                }
            }

            try
            {
                //----------Generating Bearer token for FCM---------------

                string fileName = Path.Combine(_environment.ContentRootPath, "av-sales-booster-ef658-firebase-adminsdk-fbsvc-3df3104f40.json"); // Adjust the path as needed
                vFileName = fileName;

                string scopes = "https://www.googleapis.com/auth/firebase.messaging";
                var bearertoken = ""; // Bearer Token in this variable

                using (var stream = new FileStream(fileName, FileMode.Open, FileAccess.Read))
                {
                    bearertoken = GoogleCredential
                      .FromStream(stream) // Loads key file
                      .CreateScoped(scopes) // Gathers scopes requested
                      .UnderlyingCredential // Gets the credentials
                      .GetAccessTokenForRequestAsync().Result; // Gets the Access Token
                }

                ///--------Calling FCM-----------------------------

                var clientHandler = new HttpClientHandler();
                var client = new HttpClient(clientHandler);

                client.BaseAddress = new Uri("https://fcm.googleapis.com/v1/projects/av-sales-booster-ef658/messages:send"); // FCM HttpV1 API

                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                //client.DefaultRequestHeaders.Accept.Add("Authorization", "Bearer " + bearertoken);
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", bearertoken); // Authorization Token in this variable

                vBaseAddress = client.BaseAddress.ToString();

                //---------------Assigning Of data To Model --------------

                Root rootObj = new Root()
                {
                    message = new Message()
                    {
                        token = vFCMTokenId, //FCM Token id

                        data = new Data()
                        {
                            body = "This is a sample data body",
                            title = "Sample Data Title",
                            key_1 = "Sample Key 1",
                            key_2 = "Sample Key 2"
                        },

                        notification = new Notification()
                        {
                            title = notification.title,
                            body = notification.body
                        }
                    }
                };

                //-------------Convert Model To JSON ----------------------

                var jsonObj = new JavaScriptSerializer().Serialize(rootObj);
                vRequestJson = jsonObj;

                //------------------------Calling Of FCM Notify API-------------------

                var data = new StringContent(jsonObj, Encoding.UTF8, "application/json");
                data.Headers.ContentType = new MediaTypeHeaderValue("application/json");

                var response = client.PostAsync("https://fcm.googleapis.com/v1/projects/av-sales-booster-ef658/messages:send", data).Result; // Calling The FCM httpv1 API
                isNotificationSent = response.IsSuccessStatusCode;

                //---------- Deserialize Json Response from API ----------------------------------

                var jsonResponse = response.Content.ReadAsStringAsync().Result;
                var responseObj = new JavaScriptSerializer().DeserializeObject(jsonResponse);
                vResponseJson = jsonResponse;
            }
            catch (Exception e)
            {
                isNotificationSent = false;
                Console.WriteLine($"Error sending message: {e.Message}");
            }


            #region // Save notification details to the database 

            FCMPushNotificationModel fCMPushNotificationModel = new FCMPushNotificationModel
            {
                UserId = notification.UserId,
                RequestJson = vRequestJson,
                BaseAddress = vBaseAddress,
                ResponseJson = vResponseJson,
                IsSent = isNotificationSent,
            };

            await _profileService.SaveFCMPushNotification(fCMPushNotificationModel);

            #endregion


            return isNotificationSent;
        }
    }

    public class Data
    {
        public string body { get; set; }
        public string title { get; set; }
        public string key_1 { get; set; }
        public string key_2 { get; set; }
    }

    public class Message
    {
        public string token { get; set; }
        public Data data { get; set; }
        public Notification notification { get; set; }
    }

    public class Notification
    {
        public string title { get; set; }
        public string body { get; set; }
    }

    public class Root
    {
        public Message message { get; set; }
    }
}
