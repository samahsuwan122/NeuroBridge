import 'package:flutter/material.dart';

class PatientI18n extends InheritedWidget {
  final String language;

  const PatientI18n({
    super.key,
    required this.language,
    required super.child,
  });

  static PatientI18n of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PatientI18n>() ??
      const PatientI18n(language: 'ar', child: SizedBox.shrink());

  bool get isRtl => language == 'ar';

  String t(String key) =>
      (_values[language] ?? _values['en']!)[key] ?? _values['ar']![key] ?? key;

  @override
  bool updateShouldNotify(PatientI18n oldWidget) => language != oldWidget.language;

  static const Map<String, Map<String, String>> _values = {
    'ar': {
      'home': 'الرئيسية', 'exercises': 'التمارين', 'care': 'الرعاية',
      'progress': 'التقدّم', 'account': 'حسابي', 'careCenter': 'مركز الرعاية',
      'careSubtitle': 'تواصل مع الأطباء والمعالجين واحجز موعدك',
      'providers': 'الأطباء والمعالجون', 'messages': 'الرسائل',
      'appointments': 'المواعيد', 'doctors': 'الأطباء', 'therapists': 'المعالجون',
      'all': 'الكل', 'doctor': 'دكتور', 'therapist': 'معالج',
      'message': 'مراسلة', 'book': 'حجز موعد', 'retry': 'إعادة المحاولة',
      'noProviders': 'لا يوجد مقدمو رعاية متاحون حاليًا',
      'newMessage': 'رسالة جديدة', 'writeMessage': 'اكتب رسالتك', 'send': 'إرسال',
      'noMessages': 'لا توجد رسائل بعد', 'conversation': 'المحادثة',
      'reply': 'اكتب ردًا', 'newAppointment': 'حجز موعد جديد',
      'noAppointments': 'لا توجد مواعيد بعد', 'reason': 'سبب الموعد',
      'date': 'التاريخ', 'time': 'الوقت', 'provider': 'مقدم الرعاية',
      'inPerson': 'حضوري', 'online': 'عن بُعد (Zoom)', 'save': 'إرسال الطلب',
      'zoom': 'فتح جلسة Zoom', 'cancel': 'إلغاء الموعد', 'pending': 'بانتظار الموافقة',
      'approved': 'مؤكد', 'completed': 'مكتمل', 'cancelled': 'ملغي',
      'selectAll': 'اختر مقدم الرعاية والتاريخ والوقت واكتب السبب',
      'sent': 'تم الإرسال بنجاح', 'zoomError': 'تعذر فتح رابط Zoom',
    },
    'en': {
      'home': 'Home', 'exercises': 'Exercises', 'care': 'Care', 'progress': 'Progress',
      'account': 'Account', 'careCenter': 'Care center',
      'careSubtitle': 'Contact doctors and therapists and book an appointment',
      'providers': 'Doctors & therapists', 'messages': 'Messages', 'appointments': 'Appointments',
      'doctors': 'Doctors', 'therapists': 'Therapists', 'all': 'All', 'doctor': 'Doctor',
      'therapist': 'Therapist', 'message': 'Message', 'book': 'Book appointment',
      'retry': 'Retry', 'noProviders': 'No providers are currently available',
      'newMessage': 'New message', 'writeMessage': 'Write your message', 'send': 'Send',
      'noMessages': 'No messages yet', 'conversation': 'Conversation', 'reply': 'Write a reply',
      'newAppointment': 'Book a new appointment', 'noAppointments': 'No appointments yet',
      'reason': 'Appointment reason', 'date': 'Date', 'time': 'Time', 'provider': 'Provider',
      'inPerson': 'In person', 'online': 'Online (Zoom)', 'save': 'Send request',
      'zoom': 'Open Zoom session', 'cancel': 'Cancel appointment', 'pending': 'Pending approval',
      'approved': 'Confirmed', 'completed': 'Completed', 'cancelled': 'Cancelled',
      'selectAll': 'Select a provider, date and time, and enter the reason',
      'sent': 'Sent successfully', 'zoomError': 'Could not open the Zoom link',
    },
    'fr': {
      'home': 'Accueil', 'exercises': 'Exercices', 'care': 'Soins', 'progress': 'Progrès',
      'account': 'Compte', 'careCenter': 'Centre de soins',
      'careSubtitle': 'Contactez les médecins et thérapeutes et prenez rendez-vous',
      'providers': 'Médecins et thérapeutes', 'messages': 'Messages', 'appointments': 'Rendez-vous',
      'doctors': 'Médecins', 'therapists': 'Thérapeutes', 'all': 'Tous', 'doctor': 'Médecin',
      'therapist': 'Thérapeute', 'message': 'Message', 'book': 'Prendre rendez-vous',
      'retry': 'Réessayer', 'noProviders': 'Aucun prestataire disponible',
      'newMessage': 'Nouveau message', 'writeMessage': 'Écrivez votre message', 'send': 'Envoyer',
      'noMessages': 'Aucun message', 'conversation': 'Conversation', 'reply': 'Écrire une réponse',
      'newAppointment': 'Nouveau rendez-vous', 'noAppointments': 'Aucun rendez-vous',
      'reason': 'Motif', 'date': 'Date', 'time': 'Heure', 'provider': 'Prestataire',
      'inPerson': 'En personne', 'online': 'À distance (Zoom)', 'save': 'Envoyer la demande',
      'zoom': 'Ouvrir Zoom', 'cancel': 'Annuler', 'pending': 'En attente',
      'approved': 'Confirmé', 'completed': 'Terminé', 'cancelled': 'Annulé',
      'selectAll': 'Choisissez le prestataire, la date, l’heure et le motif',
      'sent': 'Envoyé', 'zoomError': 'Impossible d’ouvrir Zoom',
    },
    'es': {
      'home': 'Inicio', 'exercises': 'Ejercicios', 'care': 'Atención', 'progress': 'Progreso',
      'account': 'Cuenta', 'careCenter': 'Centro de atención',
      'careSubtitle': 'Contacta médicos y terapeutas y reserva una cita',
      'providers': 'Médicos y terapeutas', 'messages': 'Mensajes', 'appointments': 'Citas',
      'doctors': 'Médicos', 'therapists': 'Terapeutas', 'all': 'Todos', 'doctor': 'Médico',
      'therapist': 'Terapeuta', 'message': 'Mensaje', 'book': 'Reservar cita', 'retry': 'Reintentar',
      'noProviders': 'No hay proveedores disponibles', 'newMessage': 'Nuevo mensaje',
      'writeMessage': 'Escribe tu mensaje', 'send': 'Enviar', 'noMessages': 'No hay mensajes',
      'conversation': 'Conversación', 'reply': 'Escribe una respuesta',
      'newAppointment': 'Nueva cita', 'noAppointments': 'No hay citas', 'reason': 'Motivo',
      'date': 'Fecha', 'time': 'Hora', 'provider': 'Proveedor', 'inPerson': 'Presencial',
      'online': 'En línea (Zoom)', 'save': 'Enviar solicitud', 'zoom': 'Abrir Zoom',
      'cancel': 'Cancelar', 'pending': 'Pendiente', 'approved': 'Confirmada',
      'completed': 'Completada', 'cancelled': 'Cancelada',
      'selectAll': 'Selecciona proveedor, fecha, hora y motivo', 'sent': 'Enviado',
      'zoomError': 'No se pudo abrir Zoom',
    },
    'de': {
      'home': 'Start', 'exercises': 'Übungen', 'care': 'Betreuung', 'progress': 'Fortschritt',
      'account': 'Konto', 'careCenter': 'Betreuungszentrum',
      'careSubtitle': 'Ärzte und Therapeuten kontaktieren und Termine buchen',
      'providers': 'Ärzte & Therapeuten', 'messages': 'Nachrichten', 'appointments': 'Termine',
      'doctors': 'Ärzte', 'therapists': 'Therapeuten', 'all': 'Alle', 'doctor': 'Arzt',
      'therapist': 'Therapeut', 'message': 'Nachricht', 'book': 'Termin buchen',
      'retry': 'Erneut versuchen', 'noProviders': 'Keine Anbieter verfügbar',
      'newMessage': 'Neue Nachricht', 'writeMessage': 'Nachricht schreiben', 'send': 'Senden',
      'noMessages': 'Keine Nachrichten', 'conversation': 'Unterhaltung', 'reply': 'Antwort schreiben',
      'newAppointment': 'Neuer Termin', 'noAppointments': 'Keine Termine', 'reason': 'Grund',
      'date': 'Datum', 'time': 'Uhrzeit', 'provider': 'Anbieter', 'inPerson': 'Vor Ort',
      'online': 'Online (Zoom)', 'save': 'Anfrage senden', 'zoom': 'Zoom öffnen',
      'cancel': 'Absagen', 'pending': 'Ausstehend', 'approved': 'Bestätigt',
      'completed': 'Abgeschlossen', 'cancelled': 'Abgesagt',
      'selectAll': 'Anbieter, Datum, Uhrzeit und Grund auswählen', 'sent': 'Gesendet',
      'zoomError': 'Zoom-Link konnte nicht geöffnet werden',
    },
    'tr': {
      'home': 'Ana Sayfa', 'exercises': 'Egzersizler', 'care': 'Bakım', 'progress': 'İlerleme',
      'account': 'Hesabım', 'careCenter': 'Bakım merkezi',
      'careSubtitle': 'Doktor ve terapistlerle iletişim kurun ve randevu alın',
      'providers': 'Doktorlar ve terapistler', 'messages': 'Mesajlar', 'appointments': 'Randevular',
      'doctors': 'Doktorlar', 'therapists': 'Terapistler', 'all': 'Tümü', 'doctor': 'Doktor',
      'therapist': 'Terapist', 'message': 'Mesaj', 'book': 'Randevu al', 'retry': 'Tekrar dene',
      'noProviders': 'Uygun sağlayıcı yok', 'newMessage': 'Yeni mesaj',
      'writeMessage': 'Mesajınızı yazın', 'send': 'Gönder', 'noMessages': 'Henüz mesaj yok',
      'conversation': 'Görüşme', 'reply': 'Yanıt yazın', 'newAppointment': 'Yeni randevu',
      'noAppointments': 'Henüz randevu yok', 'reason': 'Randevu nedeni', 'date': 'Tarih',
      'time': 'Saat', 'provider': 'Sağlayıcı', 'inPerson': 'Yüz yüze', 'online': 'Çevrimiçi (Zoom)',
      'save': 'İstek gönder', 'zoom': 'Zoom’u aç', 'cancel': 'İptal et',
      'pending': 'Onay bekliyor', 'approved': 'Onaylandı', 'completed': 'Tamamlandı',
      'cancelled': 'İptal edildi', 'selectAll': 'Sağlayıcı, tarih, saat ve nedeni seçin',
      'sent': 'Gönderildi', 'zoomError': 'Zoom bağlantısı açılamadı',
    },
  };
}

extension PatientTranslation on BuildContext {
  PatientI18n get patientI18n => PatientI18n.of(this);
  String tr(String key) => PatientI18n.of(this).t(key);
}


