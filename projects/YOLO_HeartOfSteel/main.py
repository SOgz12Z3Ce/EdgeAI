from ultralytics import YOLO

if __name__ == '__main__':
    model = YOLO("yolo11l.pt")
    results = model.train(data='./train.yaml', project='.', epochs=24, batch=24, pretrained=False)
