<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%

    // ===============================================
    // Caching Prevention Headers
    // ===============================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
    response.setDateHeader("Expires", 0); // Proxies.

    // AUTHENTICATION LOGIC
    if (session == null || session.getAttribute("role") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get user name for personalization
    String userName = (String) session.getAttribute("name");
    if (userName == null) userName = "Admin";
    String userRole = (String) session.getAttribute("role");
    if (userRole == null) userRole = "Interviewer";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MockMate | <%= userName %>'s Dashboard</title>

    <style>
        :root {
            --primary-color: #0056b3; /* Deep, professional Blue */
            --primary-light: #007bff; /* Standard Blue */
            --accent-color: #17a2b8; /* Cyan/Teal for secondary actions */
            --warning-color: #ffc107; /* Yellow for attention/requested */
            --success-color: #28a745; /* Green for success/approved */
            --background-color: #e9eef2; /* Lighter, modern background */
            --card-color: #ffffff;
            --text-color: #343a40; /* Darker text */
            --secondary-text: #6c757d;
            --shadow-subtle: 0 2px 10px rgba(0, 0, 0, 0.05);
            --shadow-bold: 0 8px 25px rgba(0, 0, 0, 0.1);
            --font-family: 'Inter', 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        }

        /* GENERAL STYLES */
        body {
            font-family: var(--font-family);
            margin: 0;
            padding: 0;
            background-color: var(--background-color);
            color: var(--text-color);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        h1, h2, h3 {
            color: var(--text-color);
            font-weight: 700;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        /* HEADER & NAVIGATION (Exact match to client pages) */
        .header {
            background-color: var(--card-color);
            padding: 15px 70px;
            box-shadow: var(--shadow-subtle);
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
            color: var(--primary-color);
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


        /* DASHBOARD CONTENT */
        .dashboard-main {
            flex-grow: 1;
            padding: 50px 0;
        }

        .welcome-header {
            margin-bottom: 50px;
            padding: 0 20px;
        }

        .welcome-header h1 {
            font-size: 3.5em;
            color: var(--primary-color); /* Highlight with the main color */
            margin: 0 0 5px;
            font-weight: 800;
            letter-spacing: -1px;
        }

        .welcome-header p {
            color: var(--secondary-text);
            font-size: 1.2em;
        }

        /* ADMIN ACTION CARDS (Modern, Elevated Design) */
        .action-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 40px; /* Increased gap for better separation */
            padding: 0 20px;
        }

        .action-card {
            background-color: var(--card-color);
            padding: 40px;
            border-radius: 15px; /* Softer rounded corners */
            box-shadow: var(--shadow-bold);
            transition: transform 0.3s, box-shadow 0.3s;
            border-top: 5px solid; /* Feature strip at the top */
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }

        .action-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
        }

        .card-requested {
            border-top-color: var(--warning-color);
        }
        .card-approved {
            border-top-color: var(--success-color); /* Used success-color for approved */
        }

        .action-card .icon {
            font-size: 4em;
            margin-bottom: 15px;
        }

        .card-requested .icon { color: var(--warning-color); }
        .card-approved .icon { color: var(--success-color); }

        .action-card h3 {
            font-size: 1.8em;
            margin: 0 0 10px;
            font-weight: 700;
        }

        .action-card p {
            color: var(--secondary-text);
            margin-bottom: 30px;
            font-size: 1em;
            flex-grow: 1;
        }

        /* The buttons from the original form are now highly styled CTA links */
        .btn-card-action {
            display: block;
            width: 100%;
            padding: 15px 20px;
            border: none; /* Removed default button border */
            border-radius: 10px;
            text-align: center;
            font-size: 1.1em;
            font-weight: 700;
            cursor: pointer;
            transition: background-color 0.3s, box-shadow 0.3s;
        }

        .card-requested .btn-card-action {
            background-color: var(--warning-color);
            color: var(--text-color);
            box-shadow: 0 4px 15px rgba(255, 193, 7, 0.4);
        }
        .card-requested .btn-card-action:hover {
            background-color: #e0a800; /* Darker yellow */
        }

        .card-approved .btn-card-action {
            background-color: var(--success-color);
            color: var(--card-color);
            box-shadow: 0 4px 15px rgba(40, 167, 69, 0.4);
        }
        .card-approved .btn-card-action:hover {
            background-color: #218838; /* Darker green */
        }

        /* PROFESSIONAL FOOTER STYLES (Exact match to client pages) */
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
            <a href="adminDashboard.jsp" class="nav-link">Dashboard</a>
            <a href="adminAction?action=viewRequested" class="nav-link">Requested</a>
            <a href="adminAction?action=viewApproved" class="nav-link">Approved</a>
            <a href="logout.jsp" class="btn-logout">Logout</a>
        </nav>
    </div>

    <div class="dashboard-main">
        <div class="container">

            <div class="welcome-header">
                <h1>Welcome Back, <%= userName %>! 👋</h1>
                <p>Role: **<%= userRole %>**. Focus on reviewing and managing sessions to maintain platform efficiency and quality.</p>
            </div>

            <div class="action-grid">

                <form action="adminAction" method="get" class="action-card card-requested">
                    <span class="icon">🔔</span>
                    <h3>Review Interview Requests</h3>
                    <p>Immediate action is required! Evaluate new client submissions, assign appropriate interviewers, and approve the session details.</p>
                    <button type="submit" name="action" value="viewRequested" class="btn-card-action">
                        View Requested Sessions
                    </button>
                </form>

                <form action="adminAction" method="get" class="action-card card-approved">
                    <span class="icon">🗓️</span>
                    <h3>Monitor Approved Schedule</h3>
                    <p>Keep track of all confirmed, upcoming, and in-progress sessions. This is your primary source for active workload management.</p>
                    <button type="submit" name="action" value="viewApproved" class="btn-card-action">
                        View Approved Sessions
                    </button>
                </form>

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