from flask import Flask, request
from openai import OpenAI
import requests
import re
from datetime import datetime
from datetime import timedelta
from flask_cors import CORS
from waitress import serve
import socket

app = Flask(__name__)
CORS(app)

@app.route('/', methods=['GET', 'POST'])
def process_file():
    file_content = request.files['file']
    file = file_content.read()
    timestamp_req = request.form['timestamp_r']

    timestamp_pattern = r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}'
    file_decoded = file.decode('utf-8')
    x = re.findall(timestamp_pattern, file_decoded)
    timestamps = []

    for item in x:
        timestamps.append(item)

    time_range = []
    input_time = datetime.strptime(timestamp_req, '%Y-%m-%d %H:%M:%S')

    for timestamp in timestamps:
        time = datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S')
        input_datetime = input_time
        five_minutes_before = input_datetime - timedelta(minutes=5)
        if five_minutes_before <= time <= input_datetime:
            time_range.append(timestamp)

    if not time_range:
        return 'No watched video data found within the specified time range.'

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

def generate_openai_response(hashtags):
    # Set your OpenAI GPT-3 API key
    client = OpenAI(
        api_key='OpenAI_API_KEY'
    )
    # Your prompt or message to ChatGPT
    user_input = 'Top 5 TikTok categories (excluding "fyp") based on these hashtags in one word separated by a comma, treat synonyms as identical:' + str(hashtags)

    # Make a request to the OpenAI API
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": user_input}]
    )

    # Extract and print the generated response
    chatgpt_response = response.choices[0].message.content
    return chatgpt_response

if __name__ == '__main__':
    serve(app, host='0.0.0.0', port=5000)