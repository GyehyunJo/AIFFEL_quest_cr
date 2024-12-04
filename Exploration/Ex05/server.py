from flask import Flask, request, jsonify
from flask_cors import CORS
from langchain_community.chat_models import ChatOpenAI  # 수정된 부분
from langchain.chains import LLMChain
from langchain.memory import ConversationBufferMemory
from langchain.prompts import PromptTemplate
import os

app = Flask(__name__)
CORS(app)

# OpenAI API 키 설정
openai_api_key = 'sk-aYVeHgOIMnXB6mGRPILmR7lGBqugloU_3EzOqIfIVkT3BlbkFJL9YVKPydvH1gE9Sk36GkqyQZ4cYrpqLNlhTTZoaOEA' # 여기에 실제 OpenAI API 키를 입력하세요

# LangChain 설정
llm = ChatOpenAI(
    model_name="gpt-4o",  # 원하는 모델로 변경 가능 (예: "gpt-4")
    openai_api_key=openai_api_key
)

# 프롬프트 템플릿 정의
template = """다음은 사람과 어시스턴트 간의 친근한 대화입니다. 어시스턴트는 도움이 되고 자세한 답변을 제공합니다.

{history}
사람: {input}
어시스턴트:"""

prompt = PromptTemplate(
    input_variables=["history", "input"],
    template=template
)

# 메모리 설정
memory = ConversationBufferMemory(memory_key="history", return_messages=True)

# LLMChain 생성
conversation = LLMChain(
    llm=llm,
    prompt=prompt,
    memory=memory,
    verbose=True
)

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    user_input = data.get('message', '')

    if not user_input:
        return jsonify({'error': 'No input provided'}), 400

    # 응답 생성
    response = conversation.predict(input=user_input)

    return jsonify({'response': response})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)

