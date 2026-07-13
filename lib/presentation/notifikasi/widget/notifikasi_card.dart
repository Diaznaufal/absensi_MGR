import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/presentation/notifikasi/model/notifikasi_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

class notifikasiButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const notifikasiButton({super.key, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(77),
                  blurRadius: 5,
                  spreadRadius: 1)
            ]),
        child: Icon(
          icon,
          size: 20,
          color: Colors.black,
        ),
      ),
    );
  }
}

class NotifikasiCard extends StatelessWidget {
  final NotifikasiModel notif;
  const NotifikasiCard({super.key, required this.notif});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
          color: notif.isread ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(77),
                blurRadius: 5,
                offset: Offset(0, 3))
          ]),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 15),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: notif.iconBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(
            notif.icon,
            color: notif.color,
            size: 26,
          ),
        ),
        title: Row(
          children: [
            Expanded(
                child: Text(
              notif.title,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: notif.isread ? FontWeight.w500 : FontWeight.w700),
            ))
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notif.subtitle,
                style: GoogleFonts.poppins(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                timeago.format(notif.time, locale: 'id'),
                style: GoogleFonts.poppins(fontSize: 10),
              )
            ],
          ),
        ),
      ),
    );
  }
}
