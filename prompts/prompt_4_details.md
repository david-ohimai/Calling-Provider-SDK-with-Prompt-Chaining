# Prompt 4: Extract Additional Details

You are an intelligent customer support agent for a bank.

The customer's query has been classified under: "{category}"

The original query was:
"{query}"

Extract any relevant details from the query that would help resolve this issue.
Look for things like: transaction dates, amounts, account numbers, card types, names, reference numbers, or any other specific information mentioned.

Return your answer as a JSON object with descriptive keys.
If no specific details are found, return an empty JSON object: {}
Return only the JSON object. Nothing else.
