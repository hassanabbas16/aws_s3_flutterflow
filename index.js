const functions = require('firebase-functions');
const AWS = require('aws-sdk');
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors({ origin: true }));

const s3 = new AWS.S3({
    accessKeyId: '***YOUR_ACCESS_KEY***',
    secretAccessKey: '***YOUR_SECRET_ACCESS_KEY***',
    region: '***YOUR_REGION***'
});

app.post('/initiate-multipart-upload', async (req, res) => {
    const params = {
        Bucket: '***YOUR_BUCKET_NAME***',
        Key: req.body.key,
    };

    try {
        const data = await s3.createMultipartUpload(params).promise();
        res.status(200).send(data);
    } catch (error) {
        res.status(500).send(error);
    }
});

app.post('/generate-presigned-url', async (req, res) => {
    const params = {
        Bucket: '***YOUR_BUCKET_NAME***',
        Key: req.body.key,
        PartNumber: req.body.partNumber,
        UploadId: req.body.uploadId,
        Expires: 60 * 60 // 1 hour expiration
    };

    try {
        const url = await s3.getSignedUrlPromise('uploadPart', params);
        res.status(200).send({ url });
    } catch (error) {
        res.status(500).send(error);
    }
});

app.post('/complete-multipart-upload', async (req, res) => {
    const params = {
        Bucket: '***YOUR_BUCKET_NAME***',
        Key: req.body.key,
        MultipartUpload: {
            Parts: req.body.parts.map(part => ({
                ETag: part.ETag, // Make sure to use the correct ETag value
                PartNumber: part.PartNumber // Ensure the part number is correctly assigned
            })),
        },
        UploadId: req.body.uploadId,
    };

    try {
        const data = await s3.completeMultipartUpload(params).promise();
        res.status(200).send(data);
    } catch (error) {
        res.status(500).send(error);
    }
});


exports.api = functions.https.onRequest(app);
