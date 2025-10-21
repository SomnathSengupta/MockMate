package com.mockmate.dao;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class SignupServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String college = request.getParameter("college");
        String experience = request.getParameter("experience_level");

        try {
            Connection conn = DBConnection.getConnection();
            String query = "INSERT INTO users (name, email, password, role, college, experience_level) VALUES (?, ?, ?, 'client', ?, ?)";
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, password);
            ps.setString(4, college);
            ps.setString(5, experience);

            int result = ps.executeUpdate();

            if (result > 0) {
                out.println("<script>alert('Signup successful! Please login.'); window.location='login.jsp';</script>");
            } else {
                out.println("<script>alert('Error during signup. Please try again.'); window.location='signup.jsp';</script>");
            }

            ps.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Database error: " + e.getMessage() + "'); window.location='signup.jsp';</script>");
        }
    }
}
