import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/models/evolucion_model.dart';
import '../../data/models/paciente_model.dart';

class PdfGenerator {
  static Future<void> compartirConsentimiento(PacienteModel paciente) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Consentimiento informado',
                style:
                    pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 18),
            pw.Text('Paciente: ${paciente.nombreCompleto}'),
            pw.Text('Documento: ${paciente.tipoDoc} ${paciente.numDoc}'),
            pw.Text('Area de atencion: ${paciente.areaAtencion}'),
            pw.SizedBox(height: 24),
            pw.Text(
              'Autorizo la valoracion, intervencion y registro de informacion clinica conforme a la normatividad colombiana aplicable a la historia clinica.',
            ),
            pw.Spacer(),
            pw.Text(
                'Firma paciente/acudiente: ________________________________'),
            pw.SizedBox(height: 18),
            pw.Text(
                'Firma profesional: _______________________________________'),
          ],
        ),
      ),
    );
    await Printing.sharePdf(
        bytes: await doc.save(),
        filename: 'consentimiento_${paciente.codigo}.pdf');
  }

  static Future<void> compartirHistoriaClinica({
    required PacienteModel paciente,
    required List<EvolucionModel> evoluciones,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text('Historia clinica FonoClinic',
              style:
                  pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Text('${paciente.nombreCompleto} - ${paciente.codigo}'),
          pw.Text(
              '${paciente.tipoDoc} ${paciente.numDoc} - ${paciente.areaAtencion}'),
          pw.SizedBox(height: 20),
          pw.Text('Evoluciones',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ...evoluciones.map(
            (e) => pw.Container(
              margin: const pw.EdgeInsets.only(top: 12),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Sesion ${e.numSesion} - ${e.fechaAtencion}'),
                  pw.Text('Objetivo: ${e.motivoConsulta}'),
                  pw.Text('Hallazgos: ${e.hallazgos}'),
                  pw.Text('Intervencion: ${e.intervencion}'),
                  pw.Text('Respuesta: ${e.respuestaPaciente}'),
                  pw.Text('Plan casero: ${e.plan}'),
                  ...e.anexos.map(
                    (a) => pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 6),
                      child: pw.Text('${a.titulo}: ${a.contenido}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    await Printing.sharePdf(
        bytes: await doc.save(), filename: 'historia_${paciente.codigo}.pdf');
  }
}
