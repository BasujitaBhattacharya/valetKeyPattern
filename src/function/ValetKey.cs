using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Azure.Storage.Blobs;
using Azure.Storage.Sas;

namespace ValetKey
{
    public static class ValetKey
    {
        // Because we use AppGW to call the Azure Function, we use the "anonymous" authorization level
        // This is for demo purposes only, in production you should use a more secure authorization level or JWT token        
        [FunctionName("GetBlobUrl")]        
        [StorageAccount("PicturesStorage")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "{blobname}")] HttpRequest req,            
            [Blob("pictures/{blobname}", FileAccess.Read)] BlobClient blobClient,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            if (!await blobClient.ExistsAsync()) 
            {
                return new BadRequestObjectResult($"The blob {blobClient.Name} doesn't exists");
            }

            var blobSasBuilder = new BlobSasBuilder
            {
                BlobContainerName = blobClient.BlobContainerName, 
                BlobName = blobClient.Name,
                Resource = "b",
                StartsOn = DateTime.UtcNow.AddMinutes(-5),
                ExpiresOn= DateTime.UtcNow.AddMinutes(5),       
                Protocol = SasProtocol.Https
            };
            blobSasBuilder.SetPermissions(BlobSasPermissions.Read);
            
            var sasUri = blobClient.GenerateSasUri(blobSasBuilder);
            
            return new OkObjectResult(sasUri.ToString());
        }
    }
}
