# 🐦 Flappy Bird - Flutter Game for Android

Dự án trò chơi Flappy Bird cổ điển được phát triển bằng Flutter & Dart, sẵn sàng tự động build ra file cài đặt `.apk` cho điện thoại Android.

---

## 🎮 Tính năng trò chơi
- **Đồ họa Vector mượt mà:** Vẽ hoàn toàn bằng Canvas (CustomPainter) 60fps, tương thích mọi độ phân giải màn hình điện thoại.
- **Vật lý Flappy Bird chuẩn:** Trọng lực rơi tự do, lực bay khi chạm, góc xoay chúc đầu khi rơi, vỗ cánh mượt mà.
- **Cột chướng ngại vật:** Sinh ngẫu nhiên độ cao khoảng cách, tự động tăng điểm khi vượt qua.
- **Hiệu ứng & Giao diện:** Màn hình chờ (Ready), màn hình kết thúc (Game Over), bảng điểm chi tiết, kỷ lục (Best score), hệ thống huy chương (Đồng, Bạc, Vàng).
- **Hỗ trợ điều khiển:** Chạm vào màn hình điện thoại hoặc phím `Space`/`Mũi tên lên` trên máy tính.

---

## 🚀 Cách 1: Xuất file `.apk` tự động bằng GitHub Actions (Khuyên dùng - Không cần cài gì trên máy)

Đây là cách tiện lợi nhất: toàn bộ việc biên dịch file `.apk` sẽ được máy chủ GitHub (Ubuntu + Flutter + Android SDK) tự động xử lý trên Cloud.

### Các bước thực hiện:

1. **Khởi tạo và đẩy code lên GitHub:**
   Mở terminal tại thư mục dự án và chạy các lệnh sau:
   ```bash
   git init
   git add .
   git commit -m "feat: complete Flappy Bird game with APK workflow"
   git branch -M main
   git remote add origin <LINK_REPO_GITHUB_CUA_BAN>
   git push -u origin main
   ```

2. **Chờ GitHub tự động build APK:**
   - Vào repository của bạn trên GitHub, bấm sang tab **Actions**.
   - Bạn sẽ thấy workflow **Build Android APK** đang chạy tự động (khoảng 2-3 phút).

3. **Tải file `.apk` về điện thoại:**
   - Khi workflow chạy xong (dấu tích xanh ✅), bấm vào tên lượt chạy đó.
   - Kéo xuống mục **Artifacts** ở dưới cùng.
   - Bấm tải file **`FlappyBird-Android-APK`** (bên trong chứa file `app-release.apk`).
   - Chuyển file `.apk` sang điện thoại Android hoặc tải trực tiếp bằng trình duyệt trên điện thoại và bấm **Cài đặt**.

---

## 💻 Cách 2: Chạy hoặc Build trực tiếp trên máy tính (Local)

Nếu máy tính của bạn đã cài sẵn **Flutter SDK** và **Android Studio / Android SDK**:

1. **Chạy thử game trên máy tính / máy ảo:**
   ```bash
   flutter pub get
   flutter run
   ```

2. **Xuất file `.apk` trực tiếp:**
   ```bash
   flutter build apk --release
   ```
   File `.apk` sau khi build xong sẽ nằm tại:
   `build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 Hướng dẫn cài đặt file APK trên điện thoại Android

1. Mở file `app-release.apk` trên điện thoại.
2. Nếu điện thoại hiển thị cảnh báo *"Cho phép cài đặt từ nguồn không xác định"* (Install from Unknown Sources), hãy bấm **Cài đặt** -> Bật cho phép cho trình duyệt hoặc trình quản lý file.
3. Nhấn **Cài đặt** và mở game lên trải nghiệm!
