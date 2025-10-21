package com.mockmate.dao;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class AdminActionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession session = request.getSession(false); // don't create new session

        // Check if user is logged in
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Integer interviewerObj = (Integer) session.getAttribute("user_id");
        int interviewerId = interviewerObj.intValue(); // safe now

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/mockmate?useSSL=false&serverTimezone=UTC",
                    "root", "system");

            String query = "";


            if ("viewRequested".equals(action)) {
                // include feedback_submitted so JSP can decide
                query = "SELECT s.session_id, u.name AS client_name, s.session_date, " +
                        "s.session_time, s.status, s.meet_link, s.resume_path, s.job_description, s.experience_level, s.feedback_submitted " +
                        "FROM mock_sessions s " +
                        "JOIN users u ON s.client_id = u.user_id " +
                        "WHERE s.status='pending'";
                ps = conn.prepareStatement(query);
            }
            else if ("viewApproved".equals(action)) {
                query = "SELECT s.session_id, u.name AS client_name, s.session_date, " +
                        "s.session_time, s.status, s.meet_link, s.resume_path, s.job_description, s.experience_level, s.feedback_submitted " +
                        "FROM mock_sessions s " +
                        "JOIN users u ON s.client_id = u.user_id " +
                        "WHERE s.status='accepted' AND s.interviewer_id=? AND (s.feedback_submitted='no' OR s.feedback_submitted IS NULL)";
                ps = conn.prepareStatement(query);
                ps.setInt(1, interviewerId);
            }
            else {
                // Invalid action, redirect or show error
                response.sendRedirect("adminDashboard.jsp");
                return;
            }

            rs = ps.executeQuery();

            // Forward ResultSet via request attribute (note: usually better to extract data first)
            request.setAttribute("resultSet", rs);
            request.setAttribute("action", action);

            String path = "/adminViewSessions.jsp";
            RequestDispatcher dispatcher = request.getRequestDispatcher(path);

            // Use forward() to internally transfer control to the JSP
            dispatcher.forward(request, response);


        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error processing request: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}
