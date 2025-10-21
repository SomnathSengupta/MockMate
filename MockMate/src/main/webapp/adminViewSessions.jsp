<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ===============================================
    // Caching Prevention Headers
    // ===============================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
    response.setDateHeader("Expires", 0); // Proxies.

    // ===============================================
    // 1. CRITICAL AUTHENTICATION AND ATTRIBUTE CHECK
    // ===============================================

    // Check user session
    if (session == null || session.getAttribute("role") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Safely retrieve the action attribute (REQUIRED)
    String action = (String) request.getAttribute("action");
    if (action == null || (!"viewRequested".equals(action) && !"viewApproved".equals(action))) {
        // If action is missing, redirect to dashboard or display an error page
        response.sendRedirect("adminDashboard.jsp");
        return;
    }

    // Safely retrieve the ResultSet (REQUIRED)
    ResultSet rs = (ResultSet) request.getAttribute("resultSet");

    // Set view-specific titles and styles
    boolean isRequestedView = "viewRequested".equals(action);
    boolean isApprovedView = "viewApproved".equals(action);

    String pageTitle = isRequestedView ? "Requested Interviews | Action Required" : "Approved Interviews | Ready for Feedback";
    String pageHeader = isRequestedView ? "Incoming Interview Requests" : "Approved Session Schedule";
    String headerIcon = isRequestedView ? "🚨" : "✅";
    String headerColor = isRequestedView ? "#ffc107" : "#28a745"; // Warning or Success Color

    String userName = (String) session.getAttribute("name");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MockMate | <%= pageTitle %></title>

    <style>
        :root {
            --primary-color: #0056b3;
            --primary-light: #007bff;
            --accent-color: #17a2b8;
            --warning-color: #ffc107;
            --success-color: #28a745;
            --background-color: #e9eef2;
            --card-color: #ffffff;
            --text-color: #343a40;
            --secondary-text: #6c757d;
            --danger-color: #dc3545; /* Added for error messages */
            --shadow-subtle: 0 2px 10px rgba(0, 0, 0, 0.05);
            --shadow-bold: 0 8px 25px rgba(0, 0, 0, 0.1);
            --font-family: 'Inter', 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        }

        /* GENERAL STYLES (CSS simplified for brevity, kept functional) */
        body { font-family: var(--font-family); margin: 0; padding: 0; background-color: var(--background-color); color: var(--text-color); min-height: 100vh; display: flex; flex-direction: column; }
        .container { max-width: 1300px; margin: 0 auto; padding: 0 20px; flex-grow: 1; }

        /* HEADER STYLING */
        .header { background-color: var(--card-color); padding: 15px 70px; box-shadow: var(--shadow-subtle); display: flex; justify-content: space-between; align-items: center; position: sticky; top: 0; z-index: 1000; }
        .logo { font-size: 2.0em; font-weight: 800; color: var(--primary-color); text-decoration: none; }
        .nav-link { padding: 8px 18px; color: var(--text-color); text-decoration: none; font-weight: 500; border-radius: 4px; }
        .nav-link:hover { color: var(--primary-color); background-color: rgba(0, 123, 255, 0.05); }
        .btn-logout { background-color: transparent; border: none; color: var(--primary-color); padding: 8px 15px; text-decoration: none; font-weight: 500; cursor: pointer; }
        .btn-logout:hover { background-color: var(--primary-color); color: var(--card-color); }

        /* MAIN CONTENT AREA */
        .dashboard-main { padding: 40px 0 80px; }
        .section-header { margin-bottom: 30px; padding: 0 10px; border-bottom: 2px solid #ddd; padding-bottom: 10px; display: flex; align-items: center; }
        .section-header h2 { font-size: 2.5em; color: <%= headerColor %>; margin: 0; font-weight: 800; }
        .section-header span { font-size: 1.5em; margin-right: 15px; }

        /* TABLE STYLING */
        .table-wrapper { background: var(--card-color); border-radius: 12px; box-shadow: var(--shadow-bold); overflow-x: auto; margin-top: 20px; }
        table { width: 100%; min-width: 1200px; border-collapse: collapse; font-size: 0.95em; }
        th, td { padding: 15px 12px; text-align: left; border-bottom: 1px solid #f0f0f0; vertical-align: middle; word-wrap: break-word; }
        th { background-color: var(--primary-color); color: var(--card-color); font-weight: 600; text-transform: uppercase; font-size: 0.85em; white-space: nowrap; }
        tbody tr:hover { background-color: #f7f9fb; }
        td:nth-child(1) { font-weight: 600; color: var(--primary-color); }

        /* ACTIONS AND LINKS */
        a { color: var(--primary-light); text-decoration: none; transition: color 0.2s; }
        a:hover { color: var(--primary-color); text-decoration: underline; }
        .resume-link { color: var(--accent-color); font-weight: 600; }
        .meet-link-text { font-weight: 500; color: var(--primary-light); text-decoration: underline; }
        .approve-form { display: flex; flex-direction: column; gap: 8px; align-items: stretch; min-width: 250px; }
        .approve-form input[type="text"] { padding: 8px 10px; border: 1px solid #ced4da; border-radius: 6px; font-size: 0.9em; }
        .btn-approve { background-color: var(--success-color); color: var(--card-color); padding: 10px 15px; border: none; border-radius: 6px; cursor: pointer; font-weight: 700; transition: background-color 0.2s, box-shadow 0.2s; box-shadow: 0 2px 5px rgba(40, 167, 69, 0.2); }
        .btn-approve:hover { background-color: #218838; box-shadow: 0 4px 8px rgba(40, 167, 69, 0.4); }
        .btn-feedback { background-color: var(--primary-light); color: var(--card-color); padding: 10px 15px; border: none; border-radius: 8px; cursor: pointer; font-weight: 700; transition: background-color 0.2s, box-shadow 0.2s; box-shadow: 0 4px 8px rgba(0, 123, 255, 0.3); white-space: nowrap; }
        .btn-feedback:hover { background-color: var(--primary-color); }
        /* Back to Dashboard Button */
        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-top: 35px;
            padding: 12px 25px;

            /* Primary button appearance */
            background-color: var(--primary-color);
            color: var(--card-color); /* WHITE Text */
            border: 2px solid var(--primary-color);
            border-radius: 8px;
            font-size: 1.0em;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;

            box-shadow: 0 4px 10px rgba(0, 86, 179, 0.3);
            transition: background-color 0.2s, box-shadow 0.2s, transform 0.1s;
        }

        /* Hover and Active states for interactivity */
        .back-link:hover {
            background-color: #004494; /* Slightly darker blue on hover */
            /* *** ADDED THIS LINE TO ENSURE TEXT REMAINS WHITE *** */
            color: var(--card-color);
            box-shadow: 0 6px 15px rgba(0, 86, 179, 0.4);
            text-decoration: none;
        }

        .back-link:active {
            transform: translateY(1px);
        }

        /* FOOTER STYLES */
        .footer { background-color: var(--text-color); color: var(--secondary-text); padding: 50px 70px 20px; font-size: 1em; border-top: 5px solid var(--primary-color); margin-top: auto; }
        .footer-grid { display: grid; grid-template-columns: 2fr 1fr 1fr 1fr; gap: 40px; padding-bottom: 30px; border-bottom: 1px solid #4a5d71; max-width: 1200px; margin: 0 auto; }
        .footer-logo-col .logo { font-size: 2.2em; color: var(--primary-light); }
        .footer h4 { color: var(--card-color); font-size: 1.3em; margin-bottom: 20px; font-weight: 600; }
        .footer ul { list-style: none; padding: 0; }
        .footer ul li a { color: var(--secondary-text); text-decoration: none; transition: color 0.3s; }
        .footer ul li a:hover { color: var(--primary-light); }
        .footer-bottom { text-align: center; padding-top: 20px; font-size: 0.85em; color: #7f8c8d; }
    </style>

    <script>
        function confirmFeedback(sessionId) {
            if (confirm("You are about to fill feedback for this session. Proceed to the form?")) {
                window.location.href = "feedbackForm.jsp?session_id=" + sessionId;
            }
        }

        function showFeedbackSaved() {
            alert("✅ Feedback submitted successfully! The client report is now available.");
        }
    </script>
</head>
<body>

<%
    String feedbackSaved = request.getParameter("feedback_saved");
    if ("true".equalsIgnoreCase(feedbackSaved)) {
%>
    <script>showFeedbackSaved();</script>
<%
    }
%>

<div class="header">
    <a href="homePage.jsp" class="logo">MockMate</a>
    <nav>
        <a href="adminDashboard.jsp" class="nav-link">Dashboard</a>
        <a href="adminAction?action=viewRequested" class="nav-link">Requested</a>
        <a href="adminAction?action=viewApproved" class="nav-link">Approved</a>
        <a href="logout.jsp" class="btn-logout">Logout</a>
    </nav>
</div>

<div class="dashboard-main">
    <div class="container">

        <div class="section-header" style="border-bottom-color: <%= headerColor %>;">
            <span><%= headerIcon %></span>
            <h2><%= pageHeader %></h2>
        </div>

        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                      <th>Client Name</th>
                      <th>Date / Time</th>
                      <th>Job Description</th>
                      <th>Experience Level</th>
                      <th>Client Resume</th>
                      <th>Status</th>
                      <th>Meet Link</th>
                      <th>Action</th>
                    </tr>
                </thead>
                <tbody>

                <%
                    // Use a try-catch block to render an error in the table if the ResultSet execution fails.
                    try {
                        if (rs != null) {
                            int rowsDisplayed = 0;
                            while (rs.next()) {
                                String feedbackStatus = rs.getString("feedback_submitted");
                                String sessionStatus = rs.getString("status");

                                // Original Logic: If viewing approved, skip entries that already have feedback.
                                if (isApprovedView && "yes".equalsIgnoreCase(feedbackStatus)) {
                                    continue;
                                }
                                rowsDisplayed++;

                                // Truncate Job Description for table fit
                                String jobDesc = rs.getString("job_description");
                                if (jobDesc.length() > 40) {
                                    jobDesc = jobDesc.substring(0, 37) + "...";
                                }
                    %>
                        <tr>
                          <td><%= rs.getString("client_name") %></td>
                          <td><%= rs.getDate("session_date") %> @ <%= rs.getTime("session_time") %></td>
                          <td><%= jobDesc %></td>
                          <td><%= rs.getString("experience_level") %></td>
                          <td>
                                <%
                                   String resumePath = rs.getString("resume_path");
                                   if (resumePath != null && !resumePath.trim().isEmpty()) {
                                %>
                                    <a href="<%= request.getContextPath() + "/" + resumePath %>" target="_blank" class="resume-link">Download/View</a>
                                <% } else { %>
                                    N/A
                                <% } %>
                          </td>

                          <td><%= sessionStatus %></td>
                          <td>
                              <%
                                 String meetLink = rs.getString("meet_link");
                                 if (meetLink != null && !meetLink.trim().isEmpty()) {
                              %>
                                     <a href="<%= meetLink %>" target="_blank" class="meet-link-text">Join Meeting</a>
                              <% } else { %>
                                     <span style="color: var(--secondary-text);">N/A</span>
                              <% } %>
                          </td>
                          <td>
                              <% if (isRequestedView) { %>
                                  <form action="ApproveInterviewServlet" method="post" class="approve-form">
                                      <input type="hidden" name="session_id" value="<%= rs.getInt("session_id") %>">
                                      <input type="text" name="meet_link"
                                             placeholder="Enter Meet/Zoom URL"
                                             pattern="https?://.+" title="Enter valid URL starting with http:// or https://"
                                             required>
                                      <button type="submit" class="btn-approve">Approve & Save</button>
                                  </form>
                              <% } else if (isApprovedView) { %>
                                  <button type="button" class="btn-feedback" onclick="confirmFeedback(<%= rs.getInt("session_id") %>)">Give Feedback</button>
                              <% } %>
                          </td>
                        </tr>
                    <%
                            } // end while loop

                            // Display message if no rows were found/displayed
                            if (rowsDisplayed == 0) {
                    %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 30px; color: var(--secondary-text); font-style: italic;">
                                **
                                <% if (isRequestedView) { %>
                                    🎉 No new interview requests currently awaiting approval.
                                <% } else if (isApprovedView) { %>
                                    🥳 All assigned approved sessions have been given feedback.
                                <% } else { %>
                                    No sessions found for this view.
                                <% } %>
                                **
                            </td>
                        </tr>
                    <%      }
                        } else { %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 30px; color: var(--danger-color); font-weight: 600;">
                                **🚨 Error: Session data not available (ResultSet is null). Check your servlet.**
                            </td>
                        </tr>
                    <% }
                    } catch (SQLException e) {
                        // Catch database errors specifically
                    %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 30px; color: var(--danger-color); font-weight: 600;">
                                **Database Error:** <%= e.getMessage() %>
                            </td>
                        </tr>
                    <%
                        // In a real environment, you should log the error: e.printStackTrace();
                    }
                    %>
                </tbody>
            </table>
        </div>

        <a href="adminDashboard.jsp" class="back-link">← Back to Dashboard</a>
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
                    <li><a href="adminAction?action=viewRequested">Requested</a></li>
                    <li><a href="adminAction?action=viewApproved">Approved</a></li>
                    <li><a href="login.jsp">Login</a></li>
                    <li><a href="signup.jsp">Sign Up</a></li>
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