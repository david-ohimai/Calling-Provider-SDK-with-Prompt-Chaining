# Bank Customer Support - Prompt Chain

An intelligent customer support system for a bank. It takes a free-text customer query and processes it through a 5-step prompt chain to understand, classify, and respond to the customer.

## How It Works

Each step builds on the previous one:

1. Interpret Intent - Understand what the customer is asking.
2. Map to Categories - Identify all categories that could apply.
3. Choose Best Category - Pick the single most appropriate category.
4. Extract Details - Pull out any specific information from the query.
5. Generate Response - Compose a short, friendly reply to the customer.

## Available Categories

- Account Opening
- Billing Issue
- Account Access
- Transaction Inquiry
- Card Services
- Account Statement
- Loan Inquiry
- General Information

## Setup

1. Install the Dart SDK: https://dart.dev/get-dart

2. Install dependencies:
   ```
   dart pub get
   ```

3. Create a `.env` file in the project root (copy from `.env`):
   ```
   OPENROUTER_API_KEY=your_openrouter_api_key_here
   MODEL_NAME=your_model_name_here
   API_URL=your_api_url_here
   ```

4. Run the script with a customer query:
   ```
   dart main.dart "I tried to make a transfer of 50,000 naira to GTBank on Thursday evening but the money left my account and the recipient never received it. This is the third time this is happening and I am very frustrated."
   ```

## Project Structure

```
bank_support/
├── main.dart
├── pubspec.yaml
├── .env.example
├── .gitignore
├── README.md
└── prompts/
    ├── prompt_1_intent.md
    ├── prompt_2_categories.md
    ├── prompt_3_best_category.md
    ├── prompt_4_details.md
    └── prompt_5_response.md
```

## Notes

- The `.env` file is already listed in `.gitignore`.
- The API key is loaded from the `.env` file at runtime.
- You set the model via the `MODEL_NAME` variable. Any model available on OpenRouter works.
- You set the `API_URL` to use https://openrouter.ai/api/v1
