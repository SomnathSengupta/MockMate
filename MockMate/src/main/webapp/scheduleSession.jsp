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

    String clientName = (String) session.getAttribute("name");
    if (clientName == null) clientName = "Client";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MockMate | Schedule Interview</title>

    <style>
        :root {
            --primary-color: #007bff; /* Professional Blue */
            --primary-dark: #0056b3; /* Darker Blue */
            --accent-color: #28a745; /* Green for success/callouts */
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

        h1, h2, h3 {
            color: var(--text-color);
            font-weight: 600;
        }

        .container {
            max-width: 1200px;
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

        /* Logout button style */
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

        /* MAIN CONTENT AREA for form */
        .main-content {
            flex-grow: 1;
            padding: 60px 20px;
            display: flex;
            justify-content: center;
            align-items: flex-start; /* Aligned to start for better flow */
        }

        /* FORM CARD STYLING (Consistent with login/signup) */
        .schedule-card {
            background-color: var(--card-color);
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.1);
            max-width: 600px; /* Wider form for better field separation */
            width: 100%;
            border-top: 5px solid var(--accent-color); /* Green accent for scheduling */
        }

        .schedule-card h2 {
            text-align: center;
            margin-bottom: 5px;
            color: var(--accent-color);
            font-size: 2.5em;
            font-weight: 700;
        }

        .schedule-card p.subtitle {
            text-align: center;
            color: var(--secondary-text);
            margin-bottom: 30px;
            font-size: 1.1em;
        }

        .schedule-card label {
            display: block;
            font-weight: 600;
            margin-bottom: 5px;
            margin-top: 15px;
            color: var(--text-color);
            font-size: 0.95em;
        }

        .schedule-card input:not([type="submit"]),
        .schedule-card textarea,
        .schedule-card select {
            width: 100%;
            padding: 12px;
            margin-bottom: 10px;
            border: 1px solid #ced4da;
            border-radius: 6px;
            box-sizing: border-box;
            transition: border-color 0.3s, box-shadow 0.3s;
            font-size: 1em;
        }

        .schedule-card input:focus,
        .schedule-card textarea:focus,
        .schedule-card select:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
            outline: none;
        }

        /* File Input Custom Styling */
        .schedule-card input[type="file"] {
            border: 1px dashed #ced4da;
            padding: 15px 12px;
            background-color: #f8f9fa;
        }

        /* Grouping date and time for better visual flow */
        .date-time-group {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .date-time-group > div {
            margin-top: 10px;
        }


        /* SUBMIT BUTTON STYLING (Accent Green for scheduling action) */
        .btn-submit {
            background-color: var(--accent-color);
            color: var(--card-color);
            border: none;
            width: 100%;
            padding: 15px;
            font-size: 1.1em;
            font-weight: 700;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s ease;
            box-shadow: 0 4px 10px rgba(40, 167, 69, 0.3);
            margin-top: 25px;
        }

        .btn-submit:hover {
            background-color: #218838;
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(40, 167, 69, 0.4);
        }

        /* PROFESSIONAL FOOTER STYLES (Consistent Style) */
        .footer {
            background-color: var(--text-color);
            color: var(--secondary-text);
            padding: 50px 70px 20px;
            font-size: 1em;
            border-top: 5px solid var(--primary-color);
            margin-top: 40px;
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
            <a href="viewSessions.jsp" class="nav-link">Sessions</a>
            <a href="logout.jsp" class="btn-logout">Logout</a>
        </nav>
    </div>

    <div class="main-content">
        <div class="schedule-card">
            <h2>Book Your Mock Interview</h2>
            <p class="subtitle">Provide the details below to request a session with a professional mentor.</p>

            <form action="ScheduleSessionServlet" method="post" enctype="multipart/form-data">

                <label for="job_description">Target Role/Job Description (Crucial for mentor prep):</label>
                <textarea id="job_description" name="job_description" rows="5" required></textarea>

                <label for="resume">Upload Resume (Optional, but highly recommended):</label>
                <input type="file" id="resume" name="resume">

                <label for="experience_level">Your Target Experience Level:</label>
                <select id="experience_level" name="experience_level" required>
                    <option value="" disabled selected>--- Select Level ---</option>
                    <option value="Fresher">Fresher</option>
                    <option value="Intermediate">Intermediate</option>
                    <option value="Experienced">Experienced</option>
                </select>

                <div class="date-time-group">
                    <div>
                        <label for="session_date">Preferred Date:</label>
                        <input type="date" id="session_date" name="session_date" required>
                    </div>
                    <div>
                        <label for="session_time">Preferred Time:</label>
                        <input type="time" id="session_time" name="session_time" required>
                    </div>
                </div>

                <input type="submit" value="Schedule Session Request" class="btn-submit">
            </form>
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
                        <li><a href="viewSessions.jsp">View Reports</a></li>
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