<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MockMate - Intelligent Interview Management</title>

    <style>
        :root {
            --primary-color: #2563eb; /* Elegant Royal Blue */
            --primary-dark: #1e40af; /* Deep Navy */
            --accent-color: #10b981; /* Emerald Green */
            --background-color: #f9fafb; /* Soft Gray White */
            --card-color: #ffffff;
            --text-color: #1f2937; /* Deep Gray */
            --secondary-text: #6b7280; /* Muted Gray */
            --shadow-light: 0 4px 15px rgba(0, 0, 0, 0.08);
            --font-family: 'Inter', 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        }

        body {
            font-family: var(--font-family);
            margin: 0;
            padding: 0;
            background-color: var(--background-color);
            color: var(--text-color);
            line-height: 1.6;
            overflow-x: hidden;
        }

        h1, h2, h3 {
            color: var(--text-color);
            font-weight: 600;
        }

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
            background-color: rgba(37, 99, 235, 0.08);
        }

        /* HERO SECTION */
        .hero {
            position: relative;
            background: linear-gradient(to bottom right, rgba(37, 99, 235, 0.85), rgba(30, 64, 175, 0.85)),
                        url('https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=1600&q=80') center/cover no-repeat;
            color: #ffffff;
            padding: 120px 70px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            min-height: 550px;
            overflow: hidden;
        }

        .hero-content {
            max-width: 600px;
            z-index: 2;
        }

        .hero h1 {
            font-size: 3.5em;
            margin-bottom: 15px;
            color: #fff;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
            animation: fadeInDown 1s ease-out;
        }

        .hero p {
            font-size: 1.4em;
            font-weight: 300;
            line-height: 1.5;
            margin-bottom: 40px;
            color: #f3f4f6;
            animation: fadeInUp 1.2s ease-out;
        }

        .btn-primary {
            background-color: var(--accent-color);
            color: #fff;
            border: none;
            padding: 16px 40px;
            font-size: 1.2em;
            font-weight: 700;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s ease;
            box-shadow: 0 8px 15px rgba(16, 185, 129, 0.3);
            animation: bounceIn 1.8s ease-out;
        }

        .btn-primary:hover {
            background-color: #059669;
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(16, 185, 129, 0.4);
        }

        /* FEATURES SECTION */
        .features {
            padding: 80px 70px;
            text-align: center;
        }

        .features h2 {
            font-size: 2.6em;
            color: var(--text-color);
            margin-bottom: 10px;
            font-weight: 700;
        }

        .features > p {
            color: var(--secondary-text);
            font-size: 1.2em;
            margin-bottom: 60px;
        }

        .feature-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 30px;
            max-width: 1200px;
            margin: 0 auto;
        }

        .feature-card {
            background-color: var(--card-color);
            padding: 35px;
            border-radius: 12px;
            box-shadow: var(--shadow-light);
            border-top: 5px solid var(--primary-color);
            transition: transform 0.4s ease, box-shadow 0.4s ease;
            text-align: left;
        }

        .feature-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
        }

        .feature-card h3 {
            font-size: 1.6em;
            color: var(--primary-dark);
            margin-bottom: 10px;
        }

        .feature-card p {
            color: var(--secondary-text);
        }

        /* WORKFLOW SECTION */
        .workflow-section {
            background-color: var(--card-color);
            padding: 80px 70px;
            text-align: center;
            border-top: 1px solid #e0e0e0;
        }

        .workflow-step {
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 40px;
            text-align: left;
            max-width: 900px;
            margin-left: auto;
            margin-right: auto;
        }

        .step-number {
            width: 50px;
            height: 50px;
            background-color: var(--primary-color);
            color: #fff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8em;
            font-weight: 700;
            margin-right: 30px;
            box-shadow: 0 4px 10px rgba(37, 99, 235, 0.4);
        }

        .step-content {
            max-width: 600px;
            padding: 20px;
            border-left: 3px solid var(--primary-color);
        }

        .step-content h3 {
            color: var(--primary-dark);
            margin-top: 0;
        }

        /* FOOTER */
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
            color: #fff;
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
            color: #9ca3af;
        }

        /* ANIMATIONS */
        @keyframes fadeInDown {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes bounceIn {
            0% { transform: scale(0.3); opacity: 0; }
            50% { transform: scale(1.05); opacity: 1; }
            70% { transform: scale(0.9); }
            100% { transform: scale(1); }
        }

        @media (max-width: 900px) {
            .hero {
                flex-direction: column;
                text-align: center;
                padding: 80px 20px;
            }

            .hero-content {
                margin: 0;
            }

            .feature-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

    <div class="header">
        <a href="homePage.jsp" class="logo">MockMate</a>
        <nav>
            <a href="homePage.jsp" class="nav-link">Home</a>
            <a href="#features" class="nav-link">Features</a>
            <a href="#workflow" class="nav-link">Workflow</a>
            <a href="#footer" class="nav-link">Contact</a>
        </nav>
    </div>

    <div class="hero">
        <div class="hero-content">
            <h1>Ace Your Interviews. Guaranteed.</h1>
            <p>MockMate connects job seekers and students with expert interviewers for personalized sessions and actionable feedback to boost your confidence and performance.</p>
            <button id="getStartedBtn" class="btn-primary">Get Started Now &rarr;</button>
            <input type="hidden" id="signupPagePath" value="signup.jsp">
        </div>
    </div>

    <div class="features" id="features">
        <div class="container">
            <h2>The MockMate Advantage</h2>
            <p>From scheduling to comprehensive feedback, MockMate streamlines your interview preparation journey.</p>
            <div class="feature-grid">
                <div class="feature-card">
                    <h3>Effortless Scheduling</h3>
                    <p>Clients book sessions easily, while interviewers manage requests efficiently.</p>
                </div>
                <div class="feature-card">
                    <h3>High-Quality Sessions</h3>
                    <p>Engage in realistic mock interviews with industry professionals for real-world readiness.</p>
                </div>
                <div class="feature-card">
                    <h3>Actionable Feedback</h3>
                    <p>Access detailed feedback instantly to identify your strengths and areas of improvement.</p>
                </div>
            </div>
        </div>
    </div>

    <div class="workflow-section" id="workflow">
        <div class="container">
            <h2>Our Seamless Interview Workflow</h2>
            <p style="color: var(--secondary-text); font-size: 1.1em; max-width: 800px; margin: 0 auto 50px;">We ensure a smooth, end-to-end process for both clients and interviewers.</p>

            <div class="workflow-step">
                <div class="step-number">1</div>
                <div class="step-content">
                    <h3>Client Schedules a Session</h3>
                    <p>Clients select a mentor and preferred slot. The interviewer gets notified instantly.</p>
                </div>
            </div>

            <div class="workflow-step" style="flex-direction: row-reverse;">
                <div class="step-number">2</div>
                <div class="step-content" style="border-left: none; border-right: 3px solid var(--primary-color); text-align: right;">
                    <h3>Interviewer Approves & Conducts</h3>
                    <p>Interviewers approve requests and conduct insightful mock sessions via the platform.</p>
                </div>
            </div>

            <div class="workflow-step">
                <div class="step-number">3</div>
                <div class="step-content">
                    <h3>Feedback Submission</h3>
                    <p>Interviewers submit detailed, structured feedback for every session.</p>
                </div>
            </div>

            <div class="workflow-step" style="flex-direction: row-reverse;">
                <div class="step-number">4</div>
                <div class="step-content" style="border-left: none; border-right: 3px solid var(--primary-color); text-align: right;">
                    <h3>Client Improvement</h3>
                    <p>Clients review reports and track their improvement across sessions.</p>
                </div>
            </div>
        </div>
    </div>

    <div class="footer" id="footer">
        <div class="container">
            <div class="footer-grid">
                <div class="footer-logo-col">
                    <a href="homePage.jsp" class="logo">MockMate</a>
                    <p>Intelligent interview management platform empowering candidates through real-world practice and feedback.</p>
                </div>

                <div>
                    <h4>Quick Links</h4>
                    <ul>
                        <li><a href="#features">Features</a></li>
                        <li><a href="#workflow">Workflow</a></li>
                        <li><a href="login.jsp">Login</a></li>
                        <li><a href="signup.jsp">Sign Up</a></li>
                    </ul>
                </div>

                <div>
                    <h4>Support</h4>
                    <ul>
                        <li><a href="#">Help Center</a></li>
                        <li><a href="#">Contact</a></li>
                        <li><a href="#">FAQ</a></li>
                    </ul>
                </div>

                <div>
                    <h4>Legal</h4>
                    <ul>
                        <li><a href="#">Terms of Service</a></li>
                        <li><a href="#">Privacy Policy</a></li>
                    </ul>
                </div>
            </div>

            <div class="footer-bottom">
                &copy; <%= java.time.Year.now() %> MockMate. All rights reserved.
            </div>
        </div>
    </div>

    <script>
        document.getElementById('getStartedBtn').addEventListener('click', function() {
            var path = document.getElementById('signupPagePath').value;
            window.location.href = path;
        });
    </script>
</body>
</html>
