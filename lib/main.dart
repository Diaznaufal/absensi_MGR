import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/data/datasources/attendance_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/payroll_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/izin_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/pengaduan_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/liburkaryawan_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/leave_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/overtime_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/qr_absen_remote_datasource.dart';
import 'package:flutter_absensi_app/presentation/auth/bloc/logout/logout_bloc.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/provider/izin_provider.dart';
import 'package:flutter_absensi_app/presentation/liburkaryawan/bloc/add_dayoff/add_dayoff_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/check_qr/check_qr_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/checkin_attendance/checkin_attendance_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/checkout_attendance/checkout_attendance_bloc.dart';
import 'package:flutter_absensi_app/presentation/history/blocs/get_attendance_by_date/get_attendance_by_date_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_company/get_company_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_qrcode_checkin/get_qrcode_checkin_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_qrcode_checkout/get_qrcode_checkout_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/is_checkedin/is_checkedin_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/update_user_register_face/update_user_register_face_bloc.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/bloc/create_izin/create_izin_bloc.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/bloc/create_leave/create_leave_bloc.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/bloc/leave_type/leave_type_bloc.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/bloc/leave_balance/leave_balance_bloc.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/bloc/get_all_leaves/get_all_leaves_bloc.dart';
import 'package:flutter_absensi_app/presentation/cutiIzin/provider/leave_provider.dart';
import 'package:flutter_absensi_app/presentation/liburkaryawan/bloc/get_dayoff/get_dayoff_bloc.dart';
import 'package:flutter_absensi_app/presentation/liburkaryawan/provider/liburKaryawan_provider.dart';
import 'package:flutter_absensi_app/presentation/overtimes/blocs/create_overtime/create_overtime_bloc.dart';
import 'package:flutter_absensi_app/presentation/overtimes/blocs/get_overtimes/get_overtimes_bloc.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/Provider/pengaduan_provider.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/bloc/pengaduan/pengaduan_bloc.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/bloc/pengaduan/pengaduan_event.dart';
import 'package:flutter_absensi_app/presentation/penggajian/bloc/dashboard_payroll/dashboard_payroll_bloc.dart';
import 'package:flutter_absensi_app/presentation/penggajian/bloc/history_payroll/payroll_history_bloc.dart';
import 'package:flutter_absensi_app/presentation/profile/bloc/get_user/get_user_bloc.dart';
import 'package:flutter_absensi_app/presentation/profile/bloc/update_user/update_user_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'core/core.dart';
import 'data/datasources/user_remote_datasource.dart';
import 'presentation/auth/bloc/login/login_bloc.dart';
import 'presentation/auth/pages/splash_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'presentation/overtimes/provider/overtime_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // PERBAIKAN: Mendaftarkan class custom kustom pesan yang kamu buat di bawah
  timeago.setLocaleMessages('id', KustomPesanIndonesia());
  timeago.setDefaultLocale('id');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginBloc(AuthRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => LogoutBloc(AuthRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) =>
              UpdateUserRegisterFaceBloc(AuthRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => GetCompanyBloc(AttendanceRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => IsCheckedinBloc(AttendanceRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) =>
              CheckinAttendanceBloc(AttendanceRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) =>
              CheckoutAttendanceBloc(AttendanceRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => AddDayoffBloc(DayOffRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => GetDayoffBloc(DayOffRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) =>
              GetAttendanceByDateBloc(AttendanceRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => CreateLeaveBloc(LeaveRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => CreateOvertimeBloc(OvertimeRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => GetOvertimesBloc(OvertimeRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => LeaveTypeBloc(LeaveRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => LeaveBalanceBloc(LeaveRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => CreateIzinBloc(IzinRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => GetAllLeavesBloc(LeaveRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => CheckQrBloc(QrAbsenRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => GetQrcodeCheckinBloc(),
        ),
        BlocProvider(
          create: (context) => GetQrcodeCheckoutBloc(),
        ),
        BlocProvider(
          create: (context) => GetUserBloc(UserRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => UpdateUserBloc(UserRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => DashboardPayrollBloc(),
        ),
        BlocProvider(
          create: (context) => PayrollHistoryBloc(),
        ),
        BlocProvider(
          create: (context) => PengaduanBloc(PengaduanRemoteDatasource())
            ..add(GetProductsEvent()),
        ),
        ChangeNotifierProvider(create: (_) => PengaduanProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => IzinProvider()),
        ChangeNotifierProvider(create: (_) => OvertimeProvider()),
        ChangeNotifierProvider(create: (_) => LiburkaryawanProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          MonthYearPickerLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id'),
          Locale('en'),
        ],
        title: 'GeoFence Attendance',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          dividerTheme:
              DividerThemeData(color: AppColors.light.withValues(alpha: 0.5)),
          dialogTheme: const DialogThemeData(elevation: 0),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            titleTextStyle: GoogleFonts.poppins(
              color: AppColors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}

// Custom kamus bahasa Indonesia agar "Baru saja" berdiri sendiri tanpa embel-embel suffix
class KustomPesanIndonesia implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';

  // Dikosongkan agar tidak menambahkan kata di belakang kalimat default "Baru saja"
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => 'dari sekarang';

  // Jika waktu berada di bawah 1 menit, otomatis menampilkan teks ini saja
  @override
  String lessThanOneMinute(int seconds) => 'Baru saja';

  // Menambahkan teks penunjuk waktu lampau secara manual di setiap kondisi unit waktu
  @override
  String aboutAMinute(int minutes) => '1 menit lalu';
  @override
  String minutes(int minutes) => '$minutes menit lalu';
  @override
  String aboutAnHour(int minutes) => '1 jam lalu';
  @override
  String hours(int hours) => '$hours jam lalu';
  @override
  String aDay(int hours) => '1 hari lalu';
  @override
  String days(int days) => '$days hari lalu';
  @override
  String aboutAMonth(int days) => '1 bulan lalu';
  @override
  String months(int months) => '$months bulan lalu';
  @override
  String aboutAYear(int months) => '1 tahun lalu';
  @override
  String years(int years) => '$years tahun lalu';
  @override
  String wordSeparator() => ' ';
}

// build apk
//flutter build apk --release
//flutter pub run build_runner build --delete-conflicting-outputs
//historiesAll.where