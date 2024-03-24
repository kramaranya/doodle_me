from flask import Flask, request, jsonify
from PIL import Image, ImageDraw
import numpy as np
from skimage.draw import line_aa
from skimage.transform import resize
import cv2

app = Flask(__name__)

def preprocess_drawing(drawing, output_size=(28, 28)):
    img = np.full((393, 393, 3), 255, dtype=np.uint8)
    
    for stroke in drawing:
        for i in range(1, len(stroke[0])):
            cv2.line(img, 
                     (int(stroke[0][i-1]), int(stroke[1][i-1])), 
                     (int(stroke[0][i]), int(stroke[1][i])), 
                     (0, 0, 0), 20)
    #cv2.imwrite('step_initial_drawing.png', img)

    img = cv2.resize(img, output_size, interpolation=cv2.INTER_AREA)

    #cv2.imwrite('step_resized.png', img)
    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    img_gray = 255 - img_gray
    
    img_normalized = img_gray / 255.0
    #cv2.imwrite('step_normalized.png', img_normalized * 255)
    
    return img_normalized

@app.route('/preprocess', methods=['POST'])
def preprocess():
    content = request.json
    drawing = content['strokes']
    preprocessed_data = preprocess_drawing(drawing)
    preprocessed_data_list = preprocessed_data.tolist()
    return jsonify(preprocessed_data_list)

if __name__ == '__main__':
    app.run(debug=True)