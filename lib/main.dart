import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'widgets/auth_guard.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Widget gốc của ứng dụng
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Kingdragonvn',
      theme: ThemeData(
        // Đây là giao diện của ứng dụng.
        //
        // THỬ ĐIỀU NÀY: Thử chạy ứng dụng với "flutter run". Bạn sẽ thấy
        // ứng dụng có thanh công cụ màu tím. Sau đó, không cần thoát ứng dụng,
        // hãy thử thay đổi seedColor trong colorScheme bên dưới thành Colors.green
        // và sau đó gọi "hot reload" (lưu thay đổi hoặc nhấn nút "hot
        // reload" trong IDE hỗ trợ Flutter, hoặc nhấn "r" nếu bạn sử dụng
        // dòng lệnh để khởi động ứng dụng).
        //
        // Lưu ý rằng bộ đếm không được đặt lại về 0; trạng thái của ứng dụng
        // không bị mất trong quá trình tải lại. Để đặt lại trạng thái, sử dụng hot
        // restart thay thế.
        //
        // Điều này cũng hoạt động cho mã, không chỉ cho giá trị: Hầu hết các thay đổi mã có thể được
        // kiểm tra chỉ với hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const AuthGuard(
              child: DashboardScreen(),
            ),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // Widget này là trang chủ của ứng dụng. Nó là stateful, có nghĩa là
  // nó có một đối tượng State (được định nghĩa bên dưới) chứa các trường ảnh hưởng đến
  // cách nó hiển thị.

  // Lớp này là cấu hình cho trạng thái. Nó chứa các giá trị (trong trường hợp này
  // là tiêu đề) được cung cấp bởi phần tử cha (trong trường hợp này là widget App) và
  // được sử dụng bởi phương thức build của State. Các trường trong lớp con Widget luôn
  // được đánh dấu là "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // Lệnh gọi setState này cho Flutter biết rằng có điều gì đó
      // đã thay đổi trong State này, điều này khiến nó chạy lại phương thức build bên dưới
      // để màn hình có thể phản ánh các giá trị đã cập nhật. Nếu chúng ta thay đổi
      // _counter mà không gọi setState(), thì phương thức build sẽ không
      // được gọi lại, và do đó không có gì dường như xảy ra.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Phương thức này được chạy lại mỗi khi setState được gọi, ví dụ như được thực hiện
    // bởi phương thức _incrementCounter ở trên.
    //
    // Flutter framework đã được tối ưu hóa để làm cho việc chạy lại các phương thức build
    // nhanh chóng, để bạn có thể chỉ cần xây dựng lại bất cứ thứ gì cần cập nhật thay vì
    // phải thay đổi từng phiên bản widget một cách riêng lẻ.
    return Scaffold(
      appBar: AppBar(
        // THỬ ĐIỀU NÀY: Thử thay đổi màu ở đây thành một màu cụ thể (ví dụ:
        // Colors.amber) và kích hoạt hot reload để xem thanh AppBar
        // thay đổi màu trong khi các màu khác vẫn giữ nguyên.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Ở đây chúng ta lấy giá trị từ đối tượng MyHomePage được tạo bởi
        // phương thức App.build, và sử dụng nó để đặt tiêu đề của thanh ứng dụng.
        title: Text(widget.title),
      ),
      body: Center(
        // Center là một widget bố cục. Nó lấy một widget con và định vị nó
        // ở giữa của widget cha.
        child: Column(
          // Column cũng là một widget bố cục. Nó lấy một danh sách các con và
          // sắp xếp chúng theo chiều dọc. Mặc định, nó tự điều chỉnh kích thước để vừa với các con
          // theo chiều ngang, và cố gắng cao bằng với widget cha.
          //
          // Column có nhiều thuộc tính để kiểm soát cách nó định kích thước và
          // cách nó định vị các con. Ở đây chúng ta sử dụng mainAxisAlignment để
          // căn giữa các con theo chiều dọc; trục chính ở đây là trục dọc
          // vì Columns là dọc (trục chéo sẽ là
          // ngang).
          //
          // THỬ ĐIỀU NÀY: Gọi "debug painting" (chọn hành động "Toggle Debug Paint"
          // trong IDE, hoặc nhấn "p" trong bảng điều khiển), để xem
          // khung dây cho mỗi widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Bạn đã nhấn nút này nhiều lần:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Tăng',
        child: const Icon(Icons.add),
      ), // Dấu phẩy cuối này giúp định dạng tự động đẹp hơn cho các phương thức build.
    );
  }
}
