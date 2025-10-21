<%@ page import="java.sql.*" %>
<%@ page import="com.mockmate.dao.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ===============================================
    // Caching Prevention Headers (NEW ADDITION)
    // ===============================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
    response.setDateHeader("Expires", 0); // Proxies.

    // Original Authentication Logic (MUST BE KEPT)
    if (session == null || !"client".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fix casting issue (MUST BE KEPT)
    int clientId = ((Integer) session.getAttribute("user_id")).intValue();

    String clientName = (String) session.getAttribute("name");
    if (clientName == null) clientName = "Client";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MockMate | <%= clientName %>'s Sessions</title>

    <style>
        :root {
            --primary-color: #007bff; /* Professional Blue */
            --primary-dark: #0056b3; /* Darker Blue */
            --accent-color: #28a745; /* Green for success/callouts */
            --warning-color: #ffc107; /* Yellow/Orange for pending */
            --danger-color: #dc3545; /* Red for rejected/cancelled */
            --background-color: #f4f7f6; /* Very light, professional background */
            --card-color: #ffffff;
            --text-color: #2c3e50; /* Darker, modern text */
            --secondary-text: #7f8c8d; /* Muted gray for secondary text */
            --shadow-light: 0 4px 15px rgba(0, 0, 0, 0.08);
            --font-family: 'Inter', 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        }

        /* GENERAL STYLES */
        body {
            font-family: var(--font-family);
            margin: 0;
            padding: 0;
            background-color: var(--background-color);
            color: var(--text-color);
            line-height: 1.6;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        h2 {
            color: var(--primary-dark);
            font-weight: 700;
            font-size: 2.5em;
            margin-bottom: 5px;
        }

        .container {
            max-width: 1300px; /* Increased width to accommodate all 9 columns */
            margin: 0 auto;
            padding: 0 20px;
        }

        /* HEADER & NAVIGATION (Consistent Style) */
        .header {
            background-color: var(--card-color);
            padding: 15px 70px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 1000;
        }

        .logo {
            font-size: 2.0em;
            font-weight: 800;
            color: var(--primary-color);
            text-decoration: none;
            transition: color 0.3s;
        }

        .nav-link {
            padding: 8px 18px;
            color: var(--text-color);
            text-decoration: none;
            font-weight: 500;
            transition: color 0.3s;
            border-radius: 4px;
        }

        .nav-link:hover {
            color: var(--primary-dark);
            background-color: rgba(0, 123, 255, 0.05);
        }

        .btn-logout {
            background-color: transparent;
            border: none;
            color: var(--primary-color);
            padding: 8px 15px;
            border-radius: 4px;
            text-decoration: none;
            transition: all 0.3s;
            font-size: 1em;
            font-weight: 500;
            cursor: pointer;
        }

        .btn-logout:hover {
            background-color: var(--primary-color);
            color: var(--card-color);
        }

        /* MAIN CONTENT & TABLE STYLING */
        .dashboard-main {
            flex-grow: 1;
            padding: 40px 20px 80px;
            text-align: center;
        }

        .table-wrapper {
            background: var(--card-color);
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            overflow-x: auto; /* Allows horizontal scroll for many columns */
            margin-top: 30px;
        }

        table {
            width: 100%;
            min-width: 1200px; /* Ensure table is wide enough for all cols */
            border-collapse: collapse;
            margin: 0;
            font-size: 0.9em; /* Slightly smaller font for more columns */
        }

        th, td {
            padding: 12px 10px;
            text-align: left;
            border-bottom: 1px solid #e9ecef;
            vertical-align: middle;
        }

        th {
            background-color: var(--primary-color);
            color: var(--card-color);
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.8em;
            white-space: nowrap;
        }

        /* Specific column widths for readability */
        th:nth-child(2) { width: 18%; } /* Job Description */
        th:nth-child(3) { width: 10%; } /* Experience Level */

        tbody tr:hover {
            background-color: #f8f9fa;
        }

        /* Status Badges */
        .status-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.8em;
            text-transform: capitalize;
            white-space: nowrap;
        }

        .status-Approved, .status-Completed {
            background-color: #d4edda;
            color: var(--accent-color);
        }

        .status-Pending {
            background-color: #fff3cd;
            color: var(--warning-color);
        }

        .status-Rejected, .status-Cancelled {
            background-color: #f8d7da;
            color: var(--danger-color);
        }

        /* Action Links Styling */
        .action-link {
            text-decoration: none;
            font-weight: 500;
            transition: color 0.3s;
        }

        .report-link {
            color: var(--accent-color);
            font-weight: 600;
        }
        .join-meet-link {
            color: var(--primary-color);
            font-weight: 600;
        }

        /* CTA button group below the table */
        .action-footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e9ecef;
        }

        .action-footer a {
            display: inline-block;
            margin: 0 10px;
            padding: 10px 20px;
            border-radius: 6px;
            font-weight: 600;
            text-decoration: none;
            transition: background-color 0.3s, color 0.3s;
        }

        .btn-schedule-new {
            background-color: var(--accent-color);
            color: var(--card-color);
            box-shadow: 0 4px 8px rgba(40, 167, 69, 0.2);
        }

        .btn-dashboard-back {
            background-color: var(--primary-color);
            color: var(--card-color);
            box-shadow: 0 4px 8px rgba(0, 123, 255, 0.2);
        }


        /* PROFESSIONAL FOOTER STYLES (Consistent Style) */
        .footer {
            background-color: var(--text-color);
            color: var(--secondary-text);
            padding: 50px 70px 20px;
            font-size: 1em;
            border-top: 5px solid var(--primary-color);
            margin-top: auto;
        }

        .footer-grid {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr;
            gap: 40px;
            padding-bottom: 30px;
            border-bottom: 1px solid #4a5d71;
            max-width: 1200px;
            margin: 0 auto;
        }

        .footer-logo-col .logo {
            font-size: 2.2em;
            color: var(--primary-color);
        }

        .footer-logo-col p {
            margin-top: 15px;
            font-size: 0.95em;
            color: #bdc3c7;
        }

        .footer h4 {
            color: var(--card-color);
            font-size: 1.3em;
            margin-bottom: 20px;
            font-weight: 600;
        }

        .footer ul {
            list-style: none;
            padding: 0;
        }

        .footer ul li {
            margin-bottom: 10px;
        }

        .footer ul li a {
            color: var(--secondary-text);
            text-decoration: none;
            transition: color 0.3s;
        }

        .footer ul li a:hover {
            color: var(--primary-color);
        }

        .footer-bottom {
            text-align: center;
            padding-top: 20px;
            font-size: 0.85em;
            color: #7f8c8d;
        }
    </style>
</head>
<body>

    <div class="header">
        <a href="homePage.jsp" class="logo">MockMate</a>
        <nav>
            <a href="clientDashboard.jsp" class="nav-link">Dashboard</a>
            <a href="scheduleSession.jsp" class="nav-link">Schedule New</a>
            <a href="logout.jsp" class="btn-logout">Logout</a>
        </nav>
    </div>

    <div class="dashboard-main">
        <div class="container">

            <h2>My Interview History & Status</h2>
            <p style="color: var(--secondary-text); margin-bottom: 40px;">Review the status of your mock session requests and access your performance reports here.</p>

            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Session ID</th>
                            <th>Job Description</th>
                            <th>Experience Level</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Status</th>
                            <th>Interviewer</th>
                            <th>Meet Link</th>
                            <th>Feedback Report</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        Connection conn = null;
                        PreparedStatement ps = null;
                        ResultSet rs = null;

                        try {
                            // DATABASE CONNECTION AND QUERY (Original logic preserved)
                            conn = DBConnection.getConnection();
                            String query = "SELECT s.*, u.name AS interviewer_name " +
                                           "FROM mock_sessions s " +
                                           "LEFT JOIN users u ON s.interviewer_id = u.user_id " +
                                           "WHERE s.client_id = ? ORDER BY s.session_date DESC, s.session_time DESC";
                            ps = conn.prepareStatement(query);
                            ps.setInt(1, clientId);
                            rs = ps.executeQuery();

                            // LOOP THROUGH RESULTS
                            while (rs.next()) {
                                String meetLink = rs.getString("meet_link");
                                String interviewer = rs.getString("interviewer_name");
                                String feedbackStatus = rs.getString("feedback_submitted");
                                String sessionStatus = rs.getString("status");
                                int sessionId = rs.getInt("session_id");

                                // Truncate job description for table fit
                                String jobDescription = rs.getString("job_description");
                                if (jobDescription.length() > 50) {
                                    jobDescription = jobDescription.substring(0, 47) + "...";
                                }
                    %>
                        <tr>
                            <td>#<%= sessionId %></td>
                            <td><%= jobDescription %></td>
                            <td><%= rs.getString("experience_level") %></td>
                            <td><%= rs.getDate("session_date") %></td>
                            <td><%= rs.getTime("session_time") %></td>
                            <td>
                                <span class="status-badge status-<%= sessionStatus.replace(" ", "") %>">
                                    <%= sessionStatus %>
                                </span>
                            </td>
                            <td><%= (interviewer != null) ? interviewer : "TBD" %></td>
                            <td>
                                <%
                                    // FIXED Meet Link logic
                                    if (meetLink != null && !meetLink.trim().isEmpty()) {
                                %>
                                    <a href="<%= meetLink %>" target="_blank" class="join-meet-link">Join Meet</a>
                                <%
                                    } else {
                                %>
                                    -
                                <%
                                    }
                                %>
                            </td>
                            <td>
                                <%
                                    // If feedback_submitted is 'yes', show report link
                                    if ("yes".equalsIgnoreCase(feedbackStatus)) {
                                        String pdfPath = request.getContextPath() + "/uploads/feedback_reports/Feedback_" + sessionId + ".pdf";
                                %>
                                        <a href="<%= pdfPath %>" target="_blank" class="action-link report-link">View Report</a>
                                <%
                                    } else {
                                %>
                                        Pending
                                <%
                                    }
                                %>
                            </td>
                        </tr>
                    <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                    %>
                        <tr><td colspan="9" style="text-align: center; color: var(--danger-color); font-weight: 600;">⚠️ Error loading sessions. Please check the console for details.</td></tr>
                    <%
                        } finally {
                            // Close resources (MUST BE KEPT)
                            try { if(rs != null) rs.close(); } catch(Exception e) { }
                            try { if(ps != null) ps.close(); } catch(Exception e) { }
                            try { if(conn != null) conn.close(); } catch(Exception e) { }
                        }
                    %>
                    </tbody>
                </table>
            </div>

            <div class="action-footer">
                <a href="scheduleSession.jsp" class="btn-schedule-new">Schedule New Session &nbsp; +</a>
                <a href="clientDashboard.jsp" class="btn-dashboard-back">← Back to Dashboard</a>
            </div>

        </div>
    </div>

    <div class="footer" id="footer">
        <div class="container">
            <div class="footer-grid">
                <div class="footer-logo-col">
                    <a href="homePage.jsp" class="logo">MockMate</a>
                    <p>Intelligent interview management and feedback platform, streamlining success for job seekers and professionals worldwide.</p>
                </div>

                <div>
                    <h4>Quick Links</h4>
                    <ul>
                        <li><a href="clientDashboard.jsp">Dashboard</a></li>
                        <li><a href="scheduleSession.jsp">Schedule Session</a></li>
                        <li><a href="viewSessions.jsp">View Reports</a></li>
                        <li><a href="logout.jsp">Logout</a></li>
                    </ul>
                </div>

                <div>
                    <h4>Support</h4>
                    <ul>
                        <li><a href="#">Help Center</a></li>
                        <li><a href="#">Contact Support</a></li>
                        <li><a href="#">FAQ</a></li>
                        <li><a href="#">Careers</a></li>
                    </ul>
                </div>

                <div>
                    <h4>Legal</h4>
                    <ul>
                        <li><a href="#">Terms of Service</a></li>
                        <li><a href="#">Privacy Policy</a></li>
                        <li><a href="#">Sitemap</a></li>
                    </ul>
                </div>
            </div>

            <div class="footer-bottom">
                &copy; <%= java.time.Year.now() %> MockMate. All rights reserved. | Built for effective interview preparation.
            </div>
        </div>
    </div>
</body>
</html>