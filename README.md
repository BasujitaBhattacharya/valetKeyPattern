# Introduction

This GitHub repository implement the [Valet Key Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/valet-key) to retrieve picture from the Azure Storage.

The SAS Token is returned using an Azure Function.

# Architecture


In this example the Azure Function doesn't use a private endpoint and this is for simplicity purpose.  In **production** all traffic should pass in the Application Gateway with a WAF.

The function will return you a SAS token, you will need to construct the URL to retrieve the picture.

The URL will have this format.

```
https://<FQDN>/pictures/<imagename>?<sas token>
```

1. The user requests a SAS token for a specific picture
2. One the user retrieve the SAS token it can get the picture 