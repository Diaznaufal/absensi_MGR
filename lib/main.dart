import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/data/datasources/attendance_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/permisson_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/leave_remote_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/overtime_remote_datasource.dart';
import 'package:flutter_absensi_app/data/models/response/qr_absen_remote_datasource.dart';
import 'package:flutter_absensi_app/presentation/auth/bloc/logout/logout_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/add_permission/add_permission_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/check_qr/check_qr_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/checkin_attendance/checkin_attendance_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/checkout_attendance/checkout_attendance_bloc.dart';
import 'package:flutter_absensi_app/presentation/history/blocs/get_attendance_by_date/get_attendance_by_date_bloc.dart';
import 'package:flutter_absensi_app/presentation/history/blocs/get_all_attendances/get_all_attendances_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_company/get_company_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_qrcode_checkin/get_qrcode_checkin_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_qrcode_checkout/get_qrcode_checkout_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/is_checkedin/is_checkedin_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/update_user_register_face/update_user_register_face_bloc.dart';
import 'package:flutter_absensi_app/presentation/leaves/bloc/create_leave/create_leave_bloc.dart';
import 'package:flutter_absensi_app/presentation/leaves/bloc/leave_type/leave_type_bloc.dart';
import 'package:flutter_absensi_app/presentation/leaves/bloc/leave_balance/leave_balance_bloc.dart';
import 'package:flutter_absensi_app/presentation/leaves/bloc/get_all_leaves/get_all_leaves_bloc.dart';
import 'package:flutter_absensi_app/presentation/overtimes/blocs/get_overtimes/get_overtimes_bloc.dart';
import 'package:flutter_absensi_app/presentation/overtimes/blocs/get_overtime_status/get_overtime_status_bloc.dart';
import 'package:flutter_absensi_app/presentation/overtimes/blocs/start_overtime/start_overtime_bloc.dart';
import 'package:flutter_absensi_app/presentation/overtimes/blocs/end_overtime/end_overtime_bloc.dart';
import 'package:flutter_absensi_app/presentation/pengaduan/Provider/pengaduan_provider.dart';
import 'package:flutter_absensi_app/presentation/profile/bloc/get_user/get_user_bloc.dart';
import 'package:flutter_absensi_app/presentation/profile/bloc/update_user/update_user_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'core/core.dart';
import 'data/datasources/user_remote_datasource.dart';
import 'presentation/auth/bloc/login/login_bloc.dart';
import 'presentation/auth/pages/splash_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
          create: (context) => AddPermissionBloc(PermissonRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) =>
              GetAttendanceByDateBloc(AttendanceRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) =>
              GetAllAttendancesBloc(AttendanceRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => CreateLeaveBloc(LeaveRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => LeaveTypeBloc(LeaveRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => LeaveBalanceBloc(LeaveRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => GetAllLeavesBloc(LeaveRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => GetOvertimesBloc(OvertimeRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) =>
              GetOvertimeStatusBloc(OvertimeRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => StartOvertimeBloc(OvertimeRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => EndOvertimeBloc(OvertimeRemoteDatasource()),
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
        ChangeNotifierProvider(create: (_) => PengaduanProvider()),
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
