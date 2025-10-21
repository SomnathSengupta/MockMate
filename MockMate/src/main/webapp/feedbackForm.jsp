<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.Date" %>
<%
    // ===============================================
    // Caching Prevention Headers
    // ===============================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
    response.setDateHeader("Expires", 0); // Proxies.


    if (session == null || session.getAttribute("role") == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    Integer session_id = null;
    String sidParam = request.getParameter("session_id");
    if (sidParam != null && !"null".equalsIgnoreCase(sidParam) && !sidParam.trim().isEmpty()) {
        try { session_id = Integer.parseInt(sidParam.trim()); } catch (NumberFormatException e) { session_id = null; }
    } else if (request.getAttribute("session_id") != null) {
        session_id = (Integer) request.getAttribute("session_id");
    }

    // Define colors for consistency with the Admin view
    String primaryColor = "#0056b3";
    String successColor = "#28a745";
    String cardColor = "#ffffff";
    String backgroundColor = "#e9eef2";
    String textColor = "#343a40";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MockMate | Submit Feedback</title>

    <style>
        /* Base Colors (Matching Admin View) */
        :root {
            --primary-color: <%= primaryColor %>;
            --primary-light: #007bff;
            --success-color: <%= successColor %>;
            --card-color: <%= cardColor %>;
            --background-color: <%= backgroundColor %>;
            --text-color: <%= textColor %>;
            --secondary-text: #6c757d;
            --border-color: #dee2e6;
            --shadow-subtle: 0 2px 10px rgba(0, 0, 0, 0.05);
            --shadow-bold: 0 4px 12px rgba(0, 0, 0, 0.08);
            --font-family: 'Inter', 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        }

        /* 1. GENERAL & BODY LAYOUT */
        body {
            font-family: var(--font-family);
            background-color: var(--background-color);
            color: var(--text-color);
            line-height: 1.6;
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .main-content {
             flex-grow: 1;
             padding: 40px 20px;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
            padding: 30px;
            background-color: var(--card-color);
            border-radius: 15px;
            box-shadow: var(--shadow-bold);
        }

        /* 2. HEADER STYLING */
        .header { background-color: var(--card-color); padding: 15px 70px; box-shadow: var(--shadow-subtle); display: flex; justify-content: space-between; align-items: center; position: sticky; top: 0; z-index: 1000; }
        .logo { font-size: 2.0em; font-weight: 800; color: var(--primary-color); text-decoration: none; }
        .nav-link { padding: 8px 18px; color: var(--text-color); text-decoration: none; font-weight: 500; border-radius: 4px; }
        .nav-link:hover { color: var(--primary-color); background-color: rgba(0, 123, 255, 0.05); }
        .btn-logout { background-color: transparent; border: none; color: var(--primary-color); padding: 8px 15px; text-decoration: none; font-weight: 500; cursor: pointer; }
        .btn-logout:hover { background-color: var(--primary-color); color: var(--card-color); }

        /* 3. FORM CONTENT STYLING (Rest of the main form styles preserved) */
        h1 {
            font-size: 2.2em;
            color: var(--primary-color);
            border-bottom: 3px solid var(--primary-color);
            padding-bottom: 10px;
            margin-bottom: 25px;
            font-weight: 800;
        }

        .feedback-section {
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 25px;
            background-color: #f8f9fa;
        }

        .feedback-section h3 {
            font-size: 1.6em;
            color: var(--primary-color);
            margin-top: 0;
            margin-bottom: 20px;
            padding-bottom: 8px;
            border-bottom: 1px solid #cce5ff;
        }

        .form-group {
            margin-bottom: 15px;
            padding: 15px;
            border-left: 5px solid #0056b333;
            background-color: var(--card-color);
            border-radius: 6px;
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            display: block;
            font-weight: 600;
            color: var(--text-color);
            margin-bottom: 5px;
        }

        .rating-input-container {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 10px;
        }

        input[type="date"],
        input[type="number"],
        textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 1em;
            transition: border-color 0.3s, box-shadow 0.3s;
            box-sizing: border-box;
        }

        input[type="number"] {
            width: 80px;
            text-align: center;
            font-weight: 700;
            color: var(--success-color);
        }

        input[type="date"]:focus,
        input[type="number"]:focus,
        textarea:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
            outline: none;
        }

        textarea[name="additional_suggestions"] {
            min-height: 120px;
            margin-top: 5px;
        }

        .submit-btn {
            background-color: var(--success-color);
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 8px;
            font-size: 1.1em;
            font-weight: 700;
            cursor: pointer;
            transition: background-color 0.3s, box-shadow 0.3s;
            display: block;
            width: 100%;
            margin-top: 30px;
            box-shadow: 0 4px 10px rgba(40, 167, 69, 0.3);
        }

        .submit-btn:hover {
            background-color: #1e7e34;
            box-shadow: 0 6px 15px rgba(40, 167, 69, 0.4);
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-top: 30px;
            padding: 10px 20px;
            background-color: #f0f0f0;
            color: var(--text-color);
            border-radius: 6px;
            font-weight: 600;
            text-decoration: none;
            transition: background-color 0.2s;
        }
        .back-link:hover {
            background-color: #e2e2e2;
            text-decoration: none;
        }

        /* 4. CORRECTED FOOTER STYLING for DARK background */
        .footer {
            background-color: var(--text-color); /* Dark background */
            color: #bdc3c7; /* Light text for general content */
            padding: 50px 0 20px; /* Removed horizontal padding from the footer container */
            font-size: 1em;
            border-top: 5px solid var(--primary-color);
            margin-top: auto;
        }

        .footer-inner { /* New inner wrapper to limit grid width */
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 70px; /* Apply necessary padding here */
        }

        .footer-grid {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr;
            gap: 40px;
            padding-bottom: 30px;
            border-bottom: 1px solid #4a5d71;
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
            color: var(--card-color); /* White text for headings */
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
            color: #95a5a6; /* Light gray for links */
            text-decoration: none;
            transition: color 0.3s;
        }

        .footer ul li a:hover {
            color: var(--primary-color); /* Primary color on hover */
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
    <a href="adminDashboard.jsp" class="logo">MockMate</a>
    <nav>
        <a href="adminDashboard.jsp" class="nav-link">Dashboard</a>
        <a href="AdminActionServlet?action=viewRequested" class="nav-link">Requested</a>
        <a href="AdminActionServlet?action=viewApproved" class="nav-link">Approved</a>
        <a href="logout.jsp" class="btn-logout">Logout</a>
    </nav>
</div>

<div class="main-content">
    <div class="container">
        <h1><span style="color: <%= primaryColor %>;">📝</span> Interview Feedback Report</h1>
        <p style="font-size: 1.1em; color: var(--secondary-text);">
            Please use the form below to submit your comprehensive feedback for Session ID:
            <strong style="color: var(--primary-color);"><%= session_id != null ? session_id : "N/A" %></strong>
        </p>

        <form action="feedback" method="post">
            <input type="hidden" name="session_id" value="<%= session_id %>">

            <div class="feedback-section" style="padding: 15px 20px;">
                <div class="form-group" style="border-left: 5px solid var(--success-color); margin-bottom: 0;">
                    <label for="interview_date">Interview Date:</label>
                    <input type="date" name="interview_date" id="interview_date" required>
                </div>
            </div>

            <div class="feedback-section">
                <h3>Communication Skills</h3>

                <div class="form-group">
                    <div class="rating-input-container">
                        <label>Fluency (0-5):</label>
                        <input type="number" name="fluency_rating" min="0" max="5" required>
                    </div>
                    <label>Comment:</label>
                    <textarea name="fluency_comment" rows="2"></textarea>
                </div>

                <div class="form-group">
                    <div class="rating-input-container">
                        <label>Listening (0-5):</label>
                        <input type="number" name="listening_rating" min="0" max="5" required>
                    </div>
                    <label>Comment:</label>
                    <textarea name="listening_comment" rows="2"></textarea>
                </div>

                <div class="form-group">
                    <div class="rating-input-container">
                        <label>Clarity (0-5):</label>
                        <input type="number" name="clarity_rating" min="0" max="5" required>
                    </div>
                    <label>Comment:</label>
                    <textarea name="clarity_comment" rows="2"></textarea>
                </div>

                <div class="form-group">
                    <div class="rating-input-container">
                        <label>Introduction (0-5):</label>
                        <input type="number" name="intro_rating" min="0" max="5" required>
                    </div>
                    <label>Comment:</label>
                    <textarea name="intro_comment" rows="2"></textarea>
                </div>

                <div class="form-group">
                    <div class="rating-input-container">
                        <label>Gesture (0-5):</label>
                        <input type="number" name="gesture_rating" min="0" max="5" required>
                    </div>
                    <label>Comment:</label>
                    <textarea name="gesture_comment" rows="2"></textarea>
                </div>

                <div class="form-group">
                    <div class="rating-input-container">
                        <label>Posture (0-5):</label>
                        <input type="number" name="posture_rating" min="0" max="5" required>
                    </div>
                    <label>Comment:</label>
                    <textarea name="posture_comment" rows="2"></textarea>
                </div>

                <div class="form-group">
                    <div class="rating-input-container">
                        <label>Confidence (0-5):</label>
                        <input type="number" name="confidence_rating" min="0" max="5" required>
                    </div>
                    <label>Comment:</label>
                    <textarea name="confidence_comment" rows="2"></textarea>
                </div>
            </div>

            <div class="feedback-section">
                <h3>Technical Skills</h3>

                <div class="form-group">
                    <div class="rating-input-container">
                        <label>Coding (0-5):</label>
                        <input type="number" name="coding_rating" min="0" max="5" required>
                    </div>
                    <label>Comment:</label>
                    <textarea name="coding_comment" rows="2"></textarea>
                </div>

                <div class="form-group">
                    <div class="rating-input-container">
                        <label>Problem Solving (0-5):</label>
                        <input type="number" name="problem_solving_rating" min="0" max="5" required>
                    </div>
                    <label>Comment:</label>
                    <textarea name="problem_solving_comment" rows="2"></textarea>
                </div>

                <div class="form-group">
                    <div class="rating-input-container">
                        <label>Analytical (0-5):</label>
                        <input type="number" name="analytical_rating" min="0" max="5" required>
                    </div>
                    <label>Comment:</label>
                    <textarea name="analytical_comment" rows="2"></textarea>
                </div>
            </div>

            <div class="feedback-section">
                <h3>Teamwork & Attitude</h3>

                <div class="form-group">
                    <div class="rating-input-container">
                        <label>Teamwork (0-5):</label>
                        <input type="number" name="teamwork_rating" min="0" max="5" required>
                    </div>
                    <label>Comment:</label>
                    <textarea name="teamwork_comment" rows="2"></textarea>
                </div>

                <div class="form-group">
                    <div class="rating-input-container">
                        <label>Adaptability (0-5):</label>
                        <input type="number" name="adaptability_rating" min="0" max="5" required>
                    </div>
                    <label>Comment:</label>
                    <textarea name="adaptability_comment" rows="2"></textarea>
                </div>

                <div class="form-group">
                    <div class="rating-input-container">
                        <label>Creativity (0-5):</label>
                        <input type="number" name="creativity_rating" min="0" max="5" required>
                    </div>
                    <label>Comment:</label>
                    <textarea name="creativity_comment" rows="2"></textarea>
                </div>
            </div>

            <div class="feedback-section">
                <h3>Final Notes & Suggestions</h3>
                <label>Additional suggestions for the client:</label>
                <textarea name="additional_suggestions" rows="6" cols="80"></textarea>
            </div>

            <input type="submit" value="Submit Full Feedback Report" class="submit-btn">
        </form>
        <p style="text-align: center; margin-top: 20px;">
            <a href="adminAction?action=viewApproved" class="back-link">
                ← Back to Approved Sessions
            </a>
        </p>

    </div>
</div>
<div class="footer" id="footer">
    <div class="footer-inner">
        <div class="footer-grid">
            <div class="footer-logo-col">
                <a href="adminDashboard.jsp" class="logo">MockMate</a>
                <p>Intelligent interview management and feedback platform, streamlining success for job seekers and professionals worldwide.</p>
            </div>

            <div>
                <h4>Quick Links</h4>
                <ul>
                    <li><a href="adminDashboard.jsp">Dashboard</a></li>
                    <li><a href="AdminActionServlet?action=viewRequested">Requested Sessions</a></li>
                    <li><a href="AdminActionServlet?action=viewApproved">Approved Sessions</a></li>
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