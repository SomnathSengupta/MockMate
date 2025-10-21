package com.mockmate.dao;

import java.io.File;
import java.io.IOException;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.Date;
import java.text.SimpleDateFormat;

public class FeedbackServlet extends HttpServlet {

    private int safeParse(String s) {
        if (s == null || s.trim().isEmpty() || "null".equalsIgnoreCase(s.trim())) return 0;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException ex) { return 0; }
    }

    private String formatDate(java.util.Date date) {
        if (date == null) return "";
        return new SimpleDateFormat("yyyy-MM-dd").format(date);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession userSession = req.getSession(false);
        if (userSession == null || userSession.getAttribute("role") == null || !"admin".equals(userSession.getAttribute("role"))) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String sessionIdStr = req.getParameter("session_id");
        if (sessionIdStr == null || sessionIdStr.trim().isEmpty()) {
            resp.sendRedirect("adminViewSessions.jsp?error=no_session_id");
            return;
        }

        int sessionId;
        try { sessionId = Integer.parseInt(sessionIdStr); }
        catch (NumberFormatException e) { resp.sendRedirect("adminViewSessions.jsp?error=invalid_session_id"); return; }

        req.setAttribute("session_id", sessionId);

        try (Connection conn = DBConnection.getConnection()) {
            // Load session + client info
            String sessionQuery = "SELECT s.client_id, s.job_description, s.session_date, u.name AS client_name " +
                    "FROM mock_sessions s JOIN users u ON s.client_id = u.user_id WHERE s.session_id = ?";
            boolean sessionFound = false;
            try (PreparedStatement ps = conn.prepareStatement(sessionQuery)) {
                ps.setInt(1, sessionId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        sessionFound = true;
                        req.setAttribute("client_name", rs.getString("client_name"));
                        req.setAttribute("job_description", rs.getString("job_description"));
                        req.setAttribute("client_id", rs.getInt("client_id"));
                        java.sql.Date sdate = rs.getDate("session_date");
                        req.setAttribute("session_date", formatDate(sdate));
                    }
                }
            }
            if (!sessionFound) {
                resp.sendRedirect("adminViewSessions.jsp?error=session_not_found");
                return;
            }

            // Load existing feedback if any
            String feedbackQuery = "SELECT * FROM feedback_reports WHERE session_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(feedbackQuery)) {
                ps.setInt(1, sessionId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        ResultSetMetaData meta = rs.getMetaData();
                        for (int i = 1; i <= meta.getColumnCount(); i++) {
                            String col = meta.getColumnName(i);
                            Object val = rs.getObject(i);
                            if ("interview_date".equalsIgnoreCase(col) && val != null) {
                                req.setAttribute(col, formatDate(rs.getDate(i)));
                            } else if (val != null) {
                                req.setAttribute(col, val);
                            }
                        }
                    }
                }
            }

            RequestDispatcher rd = req.getRequestDispatcher("feedbackForm.jsp");
            rd.forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("adminViewSessions.jsp?error=db_error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession userSession = req.getSession(false);
        if (userSession == null || userSession.getAttribute("role") == null || !"admin".equals(userSession.getAttribute("role"))) {
            resp.sendRedirect("login.jsp");
            return;
        }

        int interviewerId = (int) userSession.getAttribute("user_id");
        int sessionId = safeParse(req.getParameter("session_id"));
        if (sessionId == 0) { resp.sendRedirect("adminViewSessions.jsp?error=post_invalid_session"); return; }

        // convert interview_date
        String interviewDateStr = req.getParameter("interview_date");
        Date interviewDate = null;
        if (interviewDateStr != null && !interviewDateStr.trim().isEmpty()) {
            try { interviewDate = Date.valueOf(interviewDateStr); } catch (IllegalArgumentException ex) { interviewDate = null; }
        }

        // fields list must match names on your JSP (field_rating and field_comment)
        String[] fields = {"fluency","listening","clarity","intro","gesture","posture",
                "confidence","coding","problem_solving","analytical","teamwork","adaptability","creativity"};

        // collect data
        Map<String,Object> feedbackData = new HashMap<>();
        for (String f : fields) {
            feedbackData.put(f + "_rating", safeParse(req.getParameter(f + "_rating")));
            String c = req.getParameter(f + "_comment");
            feedbackData.put(f + "_comment", c != null ? c : "");
        }
        String additionalSuggestions = req.getParameter("additional_suggestions");

        // get client id, job description (to include in PDF)
        int clientId = 0;
        String jobDescription = "";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement("SELECT client_id, job_description FROM mock_sessions WHERE session_id = ?")) {
                ps.setInt(1, sessionId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        clientId = rs.getInt("client_id");
                        jobDescription = rs.getString("job_description");
                    }
                }
            }

            // Insert or update feedback_reports
            boolean exists = false;
            try (PreparedStatement psCheck = conn.prepareStatement("SELECT report_id FROM feedback_reports WHERE session_id = ?")) {
                psCheck.setInt(1, sessionId);
                try (ResultSet rs = psCheck.executeQuery()) { exists = rs.next(); }
            }

            if (exists) {
                // build UPDATE
                StringBuilder sb = new StringBuilder("UPDATE feedback_reports SET interviewer_id=?, client_id=?, interview_date=?");
                for (String f : fields) sb.append(", ").append(f).append("_rating=?, ").append(f).append("_comment=?");
                sb.append(", additional_suggestions=? WHERE session_id=?");

                try (PreparedStatement ps = conn.prepareStatement(sb.toString())) {
                    int idx = 1;
                    ps.setInt(idx++, interviewerId);
                    ps.setInt(idx++, clientId);
                    if (interviewDate != null) ps.setDate(idx++, interviewDate); else ps.setNull(idx++, Types.DATE);

                    for (String f : fields) {
                        ps.setInt(idx++, (Integer) feedbackData.get(f + "_rating"));
                        String comment = (String) feedbackData.get(f + "_comment");
                        if (comment == null) ps.setNull(idx++, Types.VARCHAR); else ps.setString(idx++, comment);
                    }
                    if (additionalSuggestions == null) ps.setNull(idx++, Types.VARCHAR); else ps.setString(idx++, additionalSuggestions);
                    ps.setInt(idx++, sessionId);
                    ps.executeUpdate();
                }
            } else {
                // build INSERT
                StringBuilder sb = new StringBuilder("INSERT INTO feedback_reports (session_id, interviewer_id, client_id, interview_date");
                for (String f : fields) sb.append(", ").append(f).append("_rating, ").append(f).append("_comment");
                sb.append(", additional_suggestions) VALUES (?,?,?,?");
                int totalPlaceholders = fields.length * 2 + 1; // per field rating+comment plus additional_suggestions
                for (int i = 0; i < totalPlaceholders; i++) sb.append(",?");
                sb.append(")");

                try (PreparedStatement ps = conn.prepareStatement(sb.toString())) {
                    int idx = 1;
                    ps.setInt(idx++, sessionId);
                    ps.setInt(idx++, interviewerId);
                    ps.setInt(idx++, clientId);
                    if (interviewDate != null) ps.setDate(idx++, interviewDate); else ps.setNull(idx++, Types.DATE);

                    for (String f : fields) {
                        ps.setInt(idx++, (Integer) feedbackData.get(f + "_rating"));
                        String comment = (String) feedbackData.get(f + "_comment");
                        if (comment == null) ps.setNull(idx++, Types.VARCHAR); else ps.setString(idx++, comment);
                    }
                    if (additionalSuggestions == null) ps.setNull(idx++, Types.VARCHAR); else ps.setString(idx++, additionalSuggestions);
                    ps.executeUpdate();
                }
            }

            // Mark session as feedback submitted (so admin's approved list can hide it)
            try (PreparedStatement psUpd = conn.prepareStatement("UPDATE mock_sessions SET feedback_submitted='yes' WHERE session_id = ?")) {
                psUpd.setInt(1, sessionId);
                psUpd.executeUpdate();
            }

        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendRedirect("adminViewSessions.jsp?error=db_save_fail");
            return;
        }

        // Generate PDF and save file (so client "Watch" can open it)
        try {
            // get client email/name for PDF header if required
            String clientName = null;
            try (Connection conn2 = DBConnection.getConnection();
                 PreparedStatement p = conn2.prepareStatement("SELECT name FROM users WHERE user_id = ?")) {
                p.setInt(1, clientId);
                try (ResultSet r = p.executeQuery()) {
                    if (r.next()) clientName = r.getString("name");
                }
            }

            Map<String, String> pdfData = new HashMap<>();
            pdfData.put("client_name", clientName != null ? clientName : "");
            pdfData.put("job_description", jobDescription != null ? jobDescription : "");
            pdfData.put("interview_date", interviewDate != null ? interviewDate.toString() : "");

            // add fields to pdf map
            for (String f : fields) {
                pdfData.put(f + "_rating", String.valueOf(feedbackData.get(f + "_rating")));
                String c = (String) feedbackData.get(f + "_comment");
                pdfData.put(f + "_comment", c != null ? c : "");
            }
            pdfData.put("additional_suggestions", additionalSuggestions != null ? additionalSuggestions : "");

            // ensure folder exists
            String uploadPath = getServletContext().getRealPath("/uploads/feedback_reports");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            String pdfPath = uploadPath + File.separator + "Feedback_" + sessionId + ".pdf";

            // call your PDF generator - you must have PDFGenerator.generateFeedbackPDF(String path, Map<String,String> data)
            PDFGenerator.generateFeedbackPDF(pdfPath, pdfData);
        } catch (Exception ex) {
            // log but do not stop the flow
            ex.printStackTrace();
        }

        // final redirect back to admin approved list (show success param)
        resp.sendRedirect("adminAction?action=viewApproved&feedback_saved=true");

    }
}
