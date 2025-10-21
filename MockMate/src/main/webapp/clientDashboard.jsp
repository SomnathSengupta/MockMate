<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ===============================================
    // Caching Prevention Headers
    // ===============================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
    response.setDateHeader("Expires", 0); // Proxies.

    // Original Authentication Logic (MUST BE KEPT)
    if (session == null || !"client".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Static Data
    String clientName = (String) session.getAttribute("name");
    if (clientName == null) clientName = "Client";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MockMate | <%= clientName %>'s Dashboard</title>

    <style>
        :root {
            --primary-color: #007bff; /* Professional Blue */
            --primary-dark: #0056b3; /* Darker Blue */
            --accent-color: #28a745; /* Green for success/callouts */
            --info-color: #17a2b8;   /* Teal for information */
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

        /* Fixed Logout button style */
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

        /* DASHBOARD LAYOUT */
        .dashboard-main {
            flex-grow: 1;
            padding: 40px 20px 80px;
        }

        .welcome-banner {
            background-color: var(--card-color);
            padding: 30px;
            border-radius: 12px;
            margin-bottom: 30px;
            box-shadow: var(--shadow-light);
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-left: 8px solid var(--primary-color);
        }

        .welcome-banner h2 {
            margin: 0;
            font-size: 2.2em;
        }

        .welcome-banner p {
            color: var(--secondary-text);
            margin: 5px 0 0;
        }

        /* New Task-Oriented Card Grid */
        .task-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 30px;
            margin-bottom: 40px;
        }

        .task-card {
            background-color: var(--card-color);
            padding: 30px;
            border-radius: 12px;
            box-shadow: var(--shadow-light);
            transition: transform 0.3s, box-shadow 0.3s;
            text-decoration: none; /* Make the whole card a clickable link */
            display: block;
        }

        .task-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
        }

        .task-card .icon {
            font-size: 2.5em;
            margin-bottom: 10px;
            display: block;
        }

        .task-card h3 {
            font-size: 1.6em;
            margin: 0 0 10px;
        }

        .task-card p {
            font-size: 1em;
            color: var(--secondary-text);
            margin: 0 0 15px;
        }

        /* Color Overrides for Cards */
        .card-schedule { border-bottom: 5px solid var(--accent-color); }
        .card-schedule h3 { color: var(--accent-color); }

        .card-view { border-bottom: 5px solid var(--primary-color); }
        .card-view h3 { color: var(--primary-dark); }

        .card-progress { border-bottom: 5px solid var(--info-color); }
        .card-progress h3 { color: var(--info-color); }


        /* Primary Action Button (Schedule Session) - Reused from welcome banner */
        .btn-schedule {
            background-color: var(--accent-color);
            color: var(--card-color);
            border: none;
            padding: 15px 30px;
            font-size: 1.1em;
            font-weight: 700;
            border-radius: 8px;
            text-decoration: none;
            transition: all 0.3s ease;
            box-shadow: 0 4px 10px rgba(40, 167, 69, 0.3);
            display: inline-block;
            margin-top: 15px;
        }

        .btn-schedule:hover {
            background-color: #218838;
            box-shadow: 0 6px 12px rgba(40, 167, 69, 0.4);
        }

        /* Progress Guide Section (Kept static and functional) */
        .progress-guide {
            background-color: var(--card-color);
            padding: 30px;
            border-radius: 12px;
            box-shadow: var(--shadow-light);
            margin-top: 20px;
        }

        .progress-guide h3 {
            border-bottom: 2px solid #eee;
            padding-bottom: 10px;
            margin-bottom: 20px;
            font-size: 1.8em;
            color: var(--primary-color);
        }

        .guide-step {
            display: flex;
            align-items: flex-start;
            margin-bottom: 25px;
        }

        .guide-icon {
            font-size: 2em;
            color: var(--primary-color);
            margin-right: 20px;
            flex-shrink: 0;
        }

        .guide-content h4 {
            margin: 0 0 5px;
            font-size: 1.2em;
            color: var(--primary-dark);
        }

        .guide-content p {
            margin: 0;
            color: var(--secondary-text);
            font-size: 0.95em;
        }


        /* PROFESSIONAL FOOTER STYLES (Consistent Style) */
        .footer {
            background-color: var(--text-color);
            color: var(--secondary-text);
            padding: 50px 70px 20px;
            font-size: 1em;
            border-top: 5px solid var(--primary-color);
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
            <a href="#tasks" class="nav-link">Actions</a>
            <a href="#progress" class="nav-link">Guide</a>
            <a href="logout.jsp" class="btn-logout">Logout</a>
        </nav>
    </div>

    <div class="dashboard-main">
        <div class="container">

            <div class="welcome-banner">
                <div>
                    <h2>Welcome, <%= clientName %>!</h2>
                    <p>Your preparation hub is active. Choose a focus area below to advance your interview readiness.</p>
                </div>
                <a href="scheduleSession.jsp" class="btn-schedule">Schedule Now &rarr;</a>
            </div>

            <div class="task-grid" id="tasks">

                <a href="scheduleSession.jsp" class="task-card card-schedule">
                    <span class="icon" style="color: var(--accent-color);">📅</span>
                    <h3>Schedule Your Mock Session</h3>
                    <p>Find the right mentor and book your next practice interview focusing on your weakest areas.</p>
                </a>

                <a href="viewSessions.jsp" class="task-card card-view">
                    <span class="icon" style="color: var(--primary-color);">📄</span>
                    <h3>Review Feedback Reports</h3>
                    <p>Access past performance metrics and detailed reports from completed interviews.</p>
                </a>

                <a href="viewSessions.jsp" class="task-card card-progress">
                    <span class="icon" style="color: var(--info-color);">⬆️</span>
                    <h3>Track Upcoming Sessions</h3>
                    <p>View the status of your requested sessions and check your confirmed interview calendar.</p>
                </a>

            </div>

            <div class="progress-guide" id="progress">
                <h3>Your MockMate Progress Guide</h3>

                <div class="guide-step">
                    <span class="guide-icon">🎯</span>
                    <div class="guide-content">
                        <h4>Step 1: Define Your Goal</h4>
                        <p>Identify the specific skill (e.g., Data Structures, System Design, Behavioral) you need to focus on for your next interview.</p>
                    </div>
                </div>

                <div class="guide-step">
                    <span class="guide-icon">🗓️</span>
                    <div class="guide-content">
                        <h4>Step 2: Schedule & Prepare</h4>
                        <p>Use the 'Schedule a New Session' button to book time with an expert mentor who specializes in your target area.</p>
                    </div>
                </div>

                <div class="guide-step">
                    <span class="guide-icon">💡</span>
                    <div class="guide-content">
                        <h4>Step 3: Review Your Feedback</h4>
                        <p>After your session, check **Review Feedback Reports** for your detailed analysis and actionable steps for improvement.</p>
                    </div>
                </div>
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
                        <li><a href="scheduleSession.jsp">Schedule Session</a></li>
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