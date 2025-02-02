# rice-datathon-2025
# ServerlessDataPredict

## Inspiration
I was inspired by the growing need to understand future vehicle populations and their impact on fuel demand. The Chevron Rice Datathon 2025 challenge presented an opportunity to tackle this real-world problem using modern cloud infrastructure and machine learning techniques.

## What it does
ServerlessDataPredict is a cloud-native solution that:
- Predicts vehicle population for 2025 using historical data from 2019-2024
- Leverages AWS serverless infrastructure including S3 and SageMaker
- Processes vehicle data features including model year, vehicle type, fuel type, and registration patterns
- Provides scalable and reproducible predictions through infrastructure as code

## How we built it
Our solution architecture consists of:
- Infrastructure as Code using Terraform for AWS resource provisioning
- AWS SageMaker for model development and training
- S3 buckets for secure data storage and versioning
- Automated deployment pipeline for reproducible results

## Challenges we ran into
I don't know anything about data science and model prediction so I have to learn it along the way

## Accomplishments that we're proud of
- Successfully implemented a serverless architecture using Terraform
- Created a secure and scalable machine learning pipeline


## What we learned
- Best practices for AWS serverless infrastructure deployment
- Techniques for handling time-series prediction problems

## What's next for ServerlessDataPredict
- Expose API endpoints for serving the model using Lambda+ API gateway so user could effective query the result