#!/bin/bash

# Set the API key for GPT-3
api_key="YOUR API KEY"

# Remove existent text file
if [ -f essay.txt ]; then
	rm essay.txt
fi

# Create a new text file
touch essay.txt

# Generate a topic for the essay
topic=$(curl https://api.openai.com/v1/completions \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $api_key" \
  -d '{
  "model": "text-davinci-003",
  "prompt": "Create one task for TOEFL independent writing:\n",
  "max_tokens": 100,
  "temperature": 0.7
}' \
--insecure | jq '.choices[0].text'  | sed 's/\\n/\n/g' | sed 's/\\//g' | sed 's/\"//g')

# Write the topic to the text file
echo "Topic: $topic" >> essay.txt
echo "Essay: " >> essay.txt

# Open the text file in vim
vim essay.txt

# Wait for the user to close the file
wait

# Get the text of the essay from the text file
essay=$(cat essay.txt | grep -A100000 "Essay: ")

#Set the prompt for the request

score_prompt=$(echo "Score the TOEFL essay on the following topic: $topic, on a scale of 1 to 10, select weakest parts and suggest improvements, add the model response: \n $essay \n\n Your score: " | sed ':a;N;$!ba;s/\n/\\n/g')

#Score the essay and get recommendations to refine it
score=$(curl https://api.openai.com/v1/completions \
-H 'Content-Type: application/json' \
-H "Authorization: Bearer $api_key" \
-d "{ \"model\": \"text-davinci-003\", \"prompt\": \"$score_prompt\", \"max_tokens\": 2000, \"temperature\": 0.7}" \
--insecure  | jq '.choices[0].text' | sed 's/\\n/\n/g' | sed 's/\\//g' | sed 's/\"//g')

# Write the score and recommendations to the text file
echo -e "Your score: $score" >> essay.txt

# Open the text file in vim
vim essay.txt
