from ultralytics import YOLO

if __name__ == '__main__':
    model = YOLO("yolo11n.yaml")
    results = model.train(data='./train.yaml', epochs=24, batch=24, pretrained=False)
