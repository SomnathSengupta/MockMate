package com.mockmate.dao;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import java.io.FileOutputStream;
import java.util.Map;

public class PDFGenerator {
    public static String generateFeedbackPDF(String filePath, Map<String, String> data) throws Exception {
        Document document = new Document();
        PdfWriter.getInstance(document, new FileOutputStream(filePath));
        document.open();

        Font titleFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
        Font normalFont = new Font(Font.FontFamily.HELVETICA, 12);

        document.add(new Paragraph("MockMate - Interview Feedback Report", titleFont));
        document.add(new Paragraph("------------------------------------------------------------"));
        document.add(new Paragraph("Client: " + data.get("client_name"), normalFont));
        document.add(new Paragraph("Job Description: " + data.get("job_description"), normalFont));
        document.add(new Paragraph("Interview Date: " + data.get("interview_date"), normalFont));
        document.add(new Paragraph(" "));

        // Fixed field order
        String[] fields = {"fluency","listening","clarity","intro","gesture","posture",
                "confidence","coding","problem_solving","analytical",
                "teamwork","adaptability","creativity"};

        for(String field : fields) {
            String rating = data.get(field + "_rating");
            String comment = data.get(field + "_comment");

            if(rating != null) {
                document.add(new Paragraph(field + " rating: " + rating, normalFont));
            }
            if(comment != null) {
                document.add(new Paragraph(field + " comment: " + comment, normalFont));
            }
        }

        // Add additional suggestions at the end
        if(data.get("additional_suggestions") != null) {
            document.add(new Paragraph("Additional suggestions: " + data.get("additional_suggestions"), normalFont));
        }

        document.close();
        return filePath;
    }
}
