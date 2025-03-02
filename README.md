# 📷 Flutter Object Detection App

This is a Flutter-based **real-time object detection** app using **TensorFlow Lite**.\
It processes **live camera frames**, provides **real-time guidance** to the user, and **captures an image** when the object is correctly positioned.

---

## **📌 Features**

✔️ **Real-time Object Detection** using TensorFlow Lite\
✔️ **Live User Guidance** ("Move Closer", "Move Farther", "Object in Position")\
✔️ **Automatic Image Capture** when object is positioned correctly\
✔️ **Stores Image Metadata** (date, time, object type)\
✔️ **GetX State Management** for smooth UI updates
✔️ **Performance Optimization** by limiting frame processing

---

## **🚀 How to Run the App**

### **1️⃣ Clone the Repository**

```sh
git clone < https://github.com/hassan789852/Object_Detection4000.git>

```

### **2️⃣ Install Dependencies**

```sh
flutter pub get
```

### **3️⃣ Run the App on a Physical Device**

```sh
flutter run
```

🛑 **Important:**

- This app **requires a physical device** as it uses the **camera** for object detection.
- **Ensure you have TensorFlow Lite models in `assets/models/`.**

---

## **📦 Dependencies Used**

The following dependencies are used in this project (`pubspec.yaml`):

| Package Name     | Version   | Purpose                         |
| ---------------- | --------- | ------------------------------- |
| `flutter`        | latest    | Core Flutter framework          |
| `get`            | ^4.6.5    | State management & navigation   |
| `camera`         | ^0.10.5+2 | Accessing device camera         |
| `tflite_flutter` | ^0.11.0   | Running TensorFlow Lite models  |
| `image`          | ^4.0.17   | Image processing utilities      |
| `path_provider`  | ^2.0.15   | File system access              |
| `image_picker`   | ^1.0.0    | Selecting or capturing images   |
| `exif`           | ^3.1.4    | Extracting metadata from images |
| `intl`           | ^0.19.0   | Formatting date/time            |

---

## **⚠️ Challenges Faced & Solutions**

### **🧠 1. Performance Optimization (Device Overheating)**

#### **Issue:**
- Continuous processing of camera frames caused the **device to overheat** and **reduced performance**.

#### **Solution:**
- Introduced **frame skipping mechanism** to **reduce CPU/GPU workload**.
- Added:
  ```dart
  int frameCounter = 0; // Used to limit FPS processing
  ```
- **Optimized Image Processing**: Frames are only processed every **5th frame**, significantly improving performance.

---

### **🧠 2. Model Not Trained Well**

#### **Issue:**
- The TensorFlow Lite model **sometimes misclassifies objects** or **fails to detect them accurately**.
- Inconsistent detection caused **early or late object positioning messages**.

#### **Solution:**

- **Adjusted Confidence Threshold**:\
  We fine-tuned the model threshold (`confidence = 0.5`) to improve detection accuracy.


---

### **🧠 3. Sending Data Between Isolate and Main Thread**

#### **Issue:**

- The **TensorFlow Lite model** runs in a **separate isolate** to avoid blocking the UI.
- However, **sending camera frames** from the main thread to the isolate **caused serialization issues**.
- **CameraImage objects cannot be sent directly across isolates**.

#### **Solution:**

- We used **Background Isolate Channels** to **register the root isolate** before running background operations.
- Implemented a **Command-Based Messaging System**:
    - The **Main Isolate** sends **"detect"** commands to the detector isolate.
    - The **Detector Isolate** processes the image and sends back **"result"** commands.
    - **Captured Image Handling** uses a **capture lock** (`_isCapturing = true`) to prevent multiple captures.


💪 **This resolved the issue, allowing real-time image processing without UI lag!**








## **📝 License**

This project is licensed under the **MIT License**.

---

🎯 **Your project now has a structured `README.md` with all required details!** 🚀\
Let me know if you need any changes! 🚀💡

# Object-Detection

