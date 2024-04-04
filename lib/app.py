from flask import Flask, request, jsonify, send_file
import numpy as np
import imageio
import cv2

app = Flask(__name__)

def preprocess_drawing(drawing, canvas_size, output_size=(28, 28)):
    width, height = canvas_size['width'], canvas_size['height']
    img = np.full((int(height), int(width), 3), 255, dtype=np.uint8)
    print(width, height)
    
    for stroke in drawing:
        for i in range(1, len(stroke[0])):
            cv2.line(img, 
                     (int(stroke[0][i-1]), int(stroke[1][i-1])), 
                     (int(stroke[0][i]), int(stroke[1][i])), 
                     (0, 0, 0), 17)

    img = cv2.resize(img, output_size, interpolation=cv2.INTER_AREA)

    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    img_gray = 255 - img_gray
    
    img_normalized = img_gray / 255.0
    
    return img_normalized

@app.route('/preprocess', methods=['POST'])
def preprocess():
    content = request.json
    drawing = content['strokes']
    canvas_size = content.get('canvasSize', {'width': 393, 'height': 393})
    preprocessed_data = preprocess_drawing(drawing, canvas_size)
    preprocessed_data_list = preprocessed_data.tolist()
    return jsonify(preprocessed_data_list)

if __name__ == '__main__':
    app.run(debug=True)