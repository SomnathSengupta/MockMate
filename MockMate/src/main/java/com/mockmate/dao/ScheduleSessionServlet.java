package com.mockmate.dao;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;

@MultipartConfig(maxFileSize = 16177215) // For handling file upload
public class ScheduleSessionServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession(false);

        //  Ensure the user is logged in and is a client
        if (session == null || !"client".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        int clientId = (int) session.getAttribute("user_id");
        String jobDescription = request.getParameter("job_description");
        String experienceLevel = request.getParameter("experience_level");
        String sessionDate = request.getParameter("session_date");
        String sessionTime = request.getParameter("session_time");

        // Handle resume upload
        Part filePart = request.getPart("resume");
        String resumePath = null;

        if (filePart != null && filePart.getSize() > 0) {
            //  getRealPath("/uploads") gives the deployed uploads folder path
            String uploadPath = getServletContext().getRealPath("/uploads");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            String fileName = getFileName(filePart);
            String savedFileName = System.currentTimeMillis() + "_" + fileName;

            //  Save the file in the deployed uploads folder
            String filePath = uploadPath + File.separator + savedFileName;
            filePart.write(filePath);

            //  Store only relative path (browser-accessible)
            resumePath = "uploads/" + savedFileName;
        }

        // Insert record into database
        try (Connection conn = DBConnection.getConnection()) {
            String query = "INSERT INTO mock_sessions (client_id, job_description, resume_path, experience_level, session_date, session_time, status) "
                    + "VALUES (?, ?, ?, ?, ?, ?, 'pending')";

            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, clientId);
            ps.setString(2, jobDescription);
            ps.setString(3, resumePath); // store relative path
            ps.setString(4, experienceLevel);
            ps.setString(5, sessionDate);
            ps.setString(6, sessionTime);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                out.println("<script>alert('Session scheduled successfully!'); window.location='viewSessions.jsp';</script>");
            } else {
                out.println("<script>alert('Failed to schedule session. Please try again.'); window.location='scheduleSession.jsp';</script>");
            }

            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Error: " + e.getMessage() + "'); window.location='scheduleSession.jsp';</script>");
        }
    }

    // Utility function to extract original file name
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "";
    }
}
