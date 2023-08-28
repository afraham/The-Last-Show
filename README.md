# The-Last-Show 🎭
"The Last Show" was a final, group assignment in our Full Stack Web Development class where we created a full stack application with React and AWS that generates obituaries for people (fictional or otherwise). We used ChatGPT to generate an obituary, Amazon Polly to turn the obituary into speech, and Cloudinary to store the speech and a picture of the deceased, where the image is modified slightly within Cloudinary Upload API. Our aim was to create a functional React application where a user can input a picture, the name, birth and death date of a deceased person (once again, fictional or otherwise) and receive a generated ChatGPT obituary response, an edited picture of the departed, and a text-to-speech button to listen to the obitury prompt.

## Features ✨
- **Obituary Generation with ChatGPT:** With OpenAI's ChatGPT API, we can generate obituaries that capture the essence of the departed. Using a prompt like "write an obituary about a fictional character named {name} who was born on {born_year} and died on {died_year}" provides personalized narratives.

- **Audio Synthesis using Amazon Polly:** Amazon Polly's synthesize_speech method transforms written obituaries into spoken tributes. Users can listen to these narratives, adding another feature to our application.

- **Cloud Storage with Cloudinary:** With Cloudinary's Upload API, we securely store speech recordings and images of the departed, as well as editing the photos within, without the use of any external photo-editing website or application.

- **AWS DynamoDB Database:** We use Amazon Web Services DynamoDB as our database to manage and store obituary data, ensuring efficient and reliable data management. Here we stored a randomly generated ID, name of the deceased, the birth and death date, the image response as a link, the ChatGPT response, and the Amazon Polly response as a link.

- **Serverless Backend with AWS Lambda:** We implement serverless architecture using AWS Lambda functions, enabling efficient execution and integration between various services.

## Tech Stack 🛠️
- **Terraform for Resource Provisioning:** All AWS resources are created using Terraform, with configurations defined in the main.tf file.

- **AWS DynamoDB:** We utilize DynamoDB as the database to store obituary data, ensuring scalability and high availability.

- **AWS Lambda Functions:** We create two Lambda functions - get-obituaries-<your-ucid> and create-obituary-<your-ucid> - to manage obituary retrieval and creation.

- **Python Programming Language:** Our Lambda functions are written in Python, following the provided guidelines and restrictions.

- **AWS Systems Manager Parameter Store:** We securely store keys for ChatGPT and Cloudinary using AWS Parameter Store's SecureString data type.

- **Amazon Polly:** Amazon Polly's synthesize_speech method converts written obituaries to speech.

- **Cloudinary API:** We interact with Cloudinary's Upload API to manage media content storage.

## Personal Focus 🎯
My primary area of expertise and responsibility for this project was centered around the backend components. I  designed and implemented the backend architecture to ensure the coordination of the different services that power "The Last Show." This involved:

- **AWS Resource Provisioning with Terraform:** I leveraged Terraform to create all the necessary resources on AWS. The main.tf file contains all the configurations needed to set up our application's infrastructure.

- **AWS Lambda Functions:** I developed the two essential Lambda functions required for the project: `get-obituaries` for retrieving obituaries and `create-obituary` for generating new obituaries. These functions follow the guidelines, using Python to handle interactions.

- **Integration of External Services:** I integrated AWS DynamoDB for database management, Amazon Polly for audio synthesis, and Cloudinary for image and speech storage. These integrations were vital for the application's core functionalities.

- **AWS Systems Manager Parameter Store:** To ensure security and compliance, I employed the Systems Manager Parameter Store to securely store keys required for external services, such as ChatGPT and Cloudinary. This implementation guarantees that sensitive information remains safe.

- **Serverless Backend Design:** I adhered to best practices in serverless architecture, optimizing the backend for efficient execution and minimal resource consumption.

## Credits 🙌
**Afrah Mohammad** ([afraham](https://github.com/afraham) on GitHub) for the backend 🧩

**Rimal Rizvi** ([Rimal01](https://github.com/Rimal01) on GitHub) for the frontend 🖼️
