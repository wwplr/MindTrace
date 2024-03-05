from flask import Flask, request
from openai import OpenAI
import requests
import re
from datetime import datetime
from datetime import timedelta
from flask_cors import CORS

app = Flask(__name__)
CORS(app)


@app.route('/', methods=['GET', 'POST'])
def process_file():
    file_content = request.files['file']
    file = file_content.read()

    timestamp_pattern = r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}'
    file_decoded = file.decode('utf-8')
    x = re.findall(timestamp_pattern, file_decoded)

    timestamps = []

    for item in x:
        timestamps.append(item)

    time_range = []
    input_time = '2023-12-24 20:31:43'

    for timestamp in timestamps:
        time = datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S')
        input_datetime = datetime.strptime(input_time, '%Y-%m-%d %H:%M:%S')
        five_minutes_before = input_datetime - timedelta(minutes=5)
        if five_minutes_before <= time <= input_datetime:
            time_range.append(timestamp)

    output = []
    for timestamp in time_range:
        z = re.findall(r'Date: ' + re.escape(timestamp) + r'\s*Link: https://www.tiktokv.com/share/video/\d+/', file_decoded)
        for item in z:
            output.append(item)

            # Extract TikTok video URLs
    url_pattern = r'https://www.tiktokv.com/share/video/\d+/'
    urls = []

    for element in output:
        if isinstance(element, str):
            urls_in_element = re.findall(url_pattern, element)
            urls.extend(urls_in_element)

    hashtags = []

    for url in urls:
        response = requests.get(url, headers={
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"})
        pattern_hashtags = r'"hashtagName":"([^"]+)"'
        tags = re.findall(pattern_hashtags, response.text)
        for tag in tags:
            hashtags.append(tag)

    # Use OpenAI GPT-3 to generate a response
    openai_response = generate_openai_response(hashtags)
    return openai_response


# -------------------------------------------------------------

def generate_openai_response(hashtags):
    # Set your OpenAI GPT-3 API key
    client = OpenAI(
        api_key='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'
    )

    # Your prompt or message to ChatGPT
    user_input = 'What are the top three TikTok content categories based on these hashtags in one word separated by a comma:' + str(hashtags)

    # Make a request to the OpenAI API
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": user_input}]
    )

    # Extract and print the generated response
    chatgpt_response = response.choices[0].message.content
    return chatgpt_response


if __name__ == '__main__':
    app.run(debug=True)
