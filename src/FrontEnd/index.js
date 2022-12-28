//----------------------------------------------------------------------------------
// Microsoft Developer & Platform Evangelism
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
//----------------------------------------------------------------------------------
// The example companies, organizations, products, domain names,
// e-mail addresses, logos, people, places, and events depicted
// herein are fictitious.  No association with any real company,
// organization, product, domain name, email address, logo, person,
// places, or events is intended or should be inferred.
//----------------------------------------------------------------------------------

// <snippet_ImportLibrary>
// index.js
const { BlobServiceClient } = require("@azure/storage-blob");
// Now do something interesting with BlobServiceClient
// </snippet_ImportLibrary>

// <snippet_DeclareVariables>
const createContainerButton = document.getElementById("create-container-button");
const deleteContainerButton = document.getElementById("delete-container-button");
const selectButton = document.getElementById("select-button");
const fileInput = document.getElementById("file-input");
const listButton = document.getElementById("list-button");
const deleteButton = document.getElementById("delete-button");
const status = document.getElementById("status");
const imageList = document.getElementById("image-list");
const downloadImageButton = document.getElementById("download-image-button");

const reportStatus = message => {
    status.innerHTML += `${message}<br/>`;
    status.scrollTop = status.scrollHeight;
}
// </snippet_DeclareVariables>

// <snippet_StorageAcctInfo>
// Update <placeholder> with your Blob service SAS URL string
const blobSasUrl = "<placeholder>";
// </snippet_StorageAcctInfo>

// <snippet_CreateClientObjects>
// Create a new BlobServiceClient
const blobServiceClient = new BlobServiceClient(blobSasUrl);

// Create a unique name for the container by 
// appending the current time to the file name
const containerName = "container" + new Date().getTime();
const containerNameExisting = "blob-image-store";
const blobName = "Azure_1.png";

// Get a container client from the BlobServiceClient
const containerClient = blobServiceClient.getContainerClient(containerName);
const containerClientExisting = blobServiceClient.getContainerClient(containerNameExisting);
// </snippet_CreateClientObjects>

// <snippet_CreateDeleteContainer>
const createContainer = async () => {
    try {
        reportStatus(`Creating container "${containerName}"...`);
        await containerClient.create();
        reportStatus(`Done. URL:${containerClient.url}`);
    } catch (error) {
        reportStatus(error.message);
    }
};

const deleteContainer = async () => {
    try {
        reportStatus(`Deleting container "${containerName}"...`);
        await containerClient.delete();
        reportStatus(`Done.`);
    } catch (error) {
        reportStatus(error.message);
    }
};

createContainerButton.addEventListener("click", createContainer);
deleteContainerButton.addEventListener("click", deleteContainer);
// </snippet_CreateDeleteContainer>

// <snippet_ListBlobs>
const listFiles = async () => {
    imageList.size = 1;
    imageList.innerHTML = "";
    try {
        reportStatus("Retrieving Image list...");
        let iter = containerClientExisting.listBlobsFlat();
        let blobItem = await iter.next();
        while (!blobItem.done) {
            
            const a = document.createElement('a');
            const linkText = document.createTextNode("Image " + imageList.size);
            a.appendChild(linkText);
            a.title = "My Image";
            a.href = containerClientExisting.getBlobClient(blobItem.value.name).url;
            document.body.appendChild(a);

            const para = document.createElement("P");
            document.body.appendChild(para);

            imageList.size += 1;
            blobItem = await iter.next();
        }
        if (imageList.size > 0) {
            reportStatus("Done.");
        } else {
            reportStatus("The container does not contain any files.");
        }
    } catch (error) {
        reportStatus(error.message);
    }
};

listButton.addEventListener("click", listFiles);
// </snippet_ListBlobs>

// <snippet_UploadBlobs>
const uploadFiles = async () => {
    try {
        reportStatus("Uploading files...");
        const promises = [];
        for (const file of fileInput.files) {
            const blockBlobClient = containerClient.getBlockBlobClient(file.name);
            promises.push(blockBlobClient.uploadBrowserData(file));
        }
        await Promise.all(promises);
        reportStatus("Done.");
        listFiles();
    }
    catch (error) {
            reportStatus(error.message);
    }
}

selectButton.addEventListener("click", () => fileInput.click());
fileInput.addEventListener("change", uploadFiles);
// </snippet_UploadBlobs>

// <snippet_DeleteBlobs>
const deleteFiles = async () => {
    try {
        if (imageList.selectedOptions.length > 0) {
            reportStatus("Deleting files...");
            for (const option of imageList.selectedOptions) {
                await containerClient.deleteBlob(option.text);
            }
            reportStatus("Done.");
            listFiles();
        } else {
            reportStatus("No files selected.");
        }
    } catch (error) {
        reportStatus(error.message);
    }
};

deleteButton.addEventListener("click", deleteFiles);
// </snippet_DeleteBlobs>
