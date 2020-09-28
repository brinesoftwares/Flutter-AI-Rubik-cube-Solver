from flask import Flask, jsonify,request,render_template,flash
from rubikscubetracker import RubiksImage
from rubik_solver import utils
import numpy as np

app = Flask(__name__)

@app.route('/', methods = ['POST'])
def api_root():
    img = request.files['image']
    img.save(img.filename)
    try:
        rimg = RubiksImage()
        rimg.analyze_file(img.filename)
        color_short = ""
        color_rgb = []
        
        _color_rgb =        [ [0,0,255], [0,0,255],  [255,255,255], [255,255,0],  [255,255,0],     [255,255,0],    [0,128,0],      [0,128,0],    [255,165,0], [255,165,0],   [255,165,0],      [255,0,0],  [255,0,0],  [255,0,0],  [255,0,0],  [255,255,255],  [255,255,255]]
        color_name =       ["Blue",      "Blue",     "White",     "Yellow",        "Yellow",        "Yellow",      "Green",       "Green",      "Orange",     "Orange",      "Orange",       "Red",       "Red",         "Red",       "Red",     "White",      "White"]
        colors = np.array([[50,50,255],[26, 82, 147],[255,255,255],[200,180,100] ,[237, 218, 49],[191, 152, 5],[120,170,120],[13, 130, 114],[255,150,50],[238, 125, 87],[224, 57, 16],[255,20,20],[211, 117, 138],[169, 53, 58],[203, 83, 93],[100,100,100], [173, 179, 175]])

#         _color_rgb =        [ [0,0,255], [0,0,255],  [255,255,255], [255,255,0], [255,255,0],    [0,128,0],      [0,128,0],    [255,165,0], [255,165,0],   [255,165,0],      [255,0,0],  [255,0,0],  [255,0,0],  [255,0,0],  [255,255,255]]
#         color_name =       ["Blue",      "Blue",     "White",     "Yellow",       "Yellow",      "Green",       "Green",      "Orange",     "Orange",      "Orange",       "Red",       "Red",         "Red",       "Red",     "White"]
#         colors = np.array([[50,50,255],[26, 82, 147],[255,255,255],[200,180,100],[237, 218, 49],[120,170,120],[13, 130, 114],[255,150,50],[238, 125, 87],[224, 57, 16],[255,20,20],[211, 117, 138],[169, 53, 58],[203, 83, 93],[100,100,100]])

        for key,value in rimg.data.items():
            color = np.array(value)
            distances = np.sqrt(np.sum((colors-color)**2,axis=1))
            index_of_smallest = np.where(distances==np.amin(distances))
            # smallest_distance = colors[index_of_smallest]
            color_short = color_short + color_name[index_of_smallest[0][0]][0] 
            color_rgb.insert(key,_color_rgb[index_of_smallest[0][0]])
        return jsonify({"status":True,"color_name":color_short,"color_rgb":color_rgb })

    except:
        return jsonify({"status":False,"message":"unable to detect colors, try again..."})
 

@app.route('/solve', methods = ['GET'])
def api_solve():
    colors = request.args.get("colors")
    print(colors.lower())
    try:
        rotations = utils.solve(colors.lower(), 'Kociemba')
        return jsonify({"status":True,"rotations": [str(i) for i in rotations]})
    except:
        return jsonify({"status":False})  

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=False)
    
