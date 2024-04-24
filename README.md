# doodle_me

`Doodle Me` repository is a platform designed to transform the way individuals communicate by leveraging the simplicity of doodles. This Flutter-based project aims to bridge communication gaps through an intuitive and accessible application that interprets doodles into recognizable categories.

## Project Overview

Doodle Me uses advanced machine learning algorithms, particularly a Convolutional Neural Network (CNN), to accurately recognize and classify doodles. The app is engineered to assist individuals who face challenges with traditional language-based communication, including those with disabilities and non-native language speakers. By converting simple sketches into predefined categories, Doodle Me enhances communication inclusivity and offers a new avenue for expression.

The application is built using Flutter, ensuring a cross-platform functionality. It integrates a CNN model developed in a separate repository dedicated to AI models (`doodle_me_AI_models`), which processes and classifies the doodles.

## Technical Details

- **Framework**: The application is developed in Flutter, which allows for a single codebase for both iOS and Android platforms.
- **Machine Learning**: Employs a CNN model for the recognition and classification of doodles. The model is trained and managed in a separate repository and is central to the app's functionality.
- **Web Service**: Utilizes a cloud-based web service deployed on Heroku for the preprocessing of doodle data. This service ensures that doodle inputs are appropriately formatted and ready for analysis by the CNN model.

## Availability

Doodle Me is available for download on the App Store. You can access it through the following link: [Doodle Me on the App Store](https://apps.apple.com/be/app/doodle-me/id6483368910)