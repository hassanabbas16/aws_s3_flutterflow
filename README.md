# aws_s3_flutterflow

## Description

Welcome to **aws_s3_flutterflow**! This repo is your go-to solution for integrating AWS S3 multipart uploads into a FlutterFlow app. It handles large file uploads (more than 5GB) efficiently with all the necessary API endpoints and Flutter code.

## Features

- Initiate multipart uploads
- Generate pre-signed URLs
- Upload chunks
- Complete multipart uploads

## Getting Started

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/flutterflow-s3-multipart-upload.git

## My Journey
If you’ve ever felt like tearing your hair out over missing documentation and broken examples, welcome to the club. I plunged into this project with nothing but a vague outline and emerged with a working solution after a relentless battle with confusing APIs and cryptic errors. It was like being thrown into the deep end without a life jacket. But hey, if I can make it through, so can you!

## API Endpoints
- Initiate Multipart Upload: /initiate-upload
- Generate Pre-signed URLs: /generate-presigned-urls
- Upload Chunk: Use pre-signed URLs
- Complete Multipart Upload: /complete-upload

The API code is present in index.js. You can deploy this on firebase as I did or any other deployment service as well. I have included the json depedencies required for the api to run as well. After deployment of the API, you will have to copy its url to the flutter/flutterflow project code where it says "Your_URL". This would make your uploads smooth and hassle free.

Feel free to customize it further based on your preferences!

## Queries

For any questions or issues, reach out via [email](mailto:gaha87818@gmail.com).

