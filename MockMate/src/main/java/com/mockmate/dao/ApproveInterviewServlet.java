package com.mockmate.dao;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class ApproveInterviewServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        int sessionId = Integer.parseInt(request.getParameter("session_id"));
        String meetLink = request.getParameter("meet_link");

        HttpSession session = request.getSession();
        Integer interviewerId = (Integer) session.getAttribute("user_id");  // currently logged-in interviewer

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/mockmate?useSSL=false&serverTimezone=UTC",
                    "root", "system");

            // Update meet_link, status, and interviewer_id
            String sql = "UPDATE mock_sessions SET status='accepted', interviewer_id=?, meet_link=? WHERE session_id=?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, interviewerId);
            ps.setString(2, meetLink);
            ps.setInt(3, sessionId);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                String contextPath = request.getContextPath();
                response.sendRedirect(contextPath + "/adminAction?action=viewApproved");
            } else {
                response.getWriter().println("Error: Could not approve interview.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}
