<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MockMate | Login</title>

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
            min-height: 100vh; /* Ensure full viewport height */
            display: flex;
            flex-direction: column; /* Allows footer to stick to the bottom */
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

        /* MAIN CONTENT AREA for form */
        .main-content {
            flex-grow: 1; /* Pushes the footer down */
            padding: 60px 20px;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        /* FORM CARD STYLING (Consistent Style) */
        .login-card {
            background-color: var(--card-color);
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.1);
            max-width: 400px; /* Slightly smaller for login */
            width: 100%;
            border-top: 5px solid var(--primary-color);
        }

        .login-card h2 {
            text-align: center;
            margin-bottom: 30px;
            color: var(--primary-dark);
            font-size: 2em;
        }

        .login-card label {
            display: block;
            font-weight: 600;
            margin-bottom: 5px;
            color: var(--text-color);
            font-size: 0.95em;
        }

        .login-card input[type="email"],
        .login-card input[type="password"] {
            width: 100%;
            padding: 12px;
            margin-bottom: 20px;
            border: 1px solid #ced4da;
            border-radius: 6px;
            box-sizing: border-box;
            transition: border-color 0.3s, box-shadow 0.3s;
            font-size: 1em;
        }

        .login-card input:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
            outline: none;
        }

        /* SUBMIT BUTTON STYLING */
        .btn-primary {
            background-color: var(--primary-color); /* Using blue for login button */
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
            box-shadow: 0 4px 10px rgba(0, 123, 255, 0.3);
            margin-top: 10px;
        }

        .btn-primary:hover {
            background-color: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(0, 123, 255, 0.4);
        }

        /* SIGNUP LINK STYLING */
        .signup-link {
            text-align: center;
            margin-top: 25px;
            font-size: 1em;
            color: var(--secondary-text);
        }

        .signup-link a {
            color: var(--accent-color); /* Highlighting the signup link in green */
            text-decoration: none;
            font-weight: 600;
        }

        .signup-link a:hover {
            text-decoration: underline;
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
            <a href="homePage.jsp" class="nav-link">Home</a>
            <a href="homePage.jsp#features" class="nav-link">Features</a>
            <a href="homePage.jsp#workflow" class="nav-link">Workflow</a>
            <a href="#footer" class="nav-link">Contact</a>
        </nav>
    </div>

    <div class="main-content">
        <div class="login-card">
            <h2>Welcome Back!</h2>

            <form action="login" method="post">

                <label for="email">Email:</label>
                <input type="email" id="email" name="email" required>

                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>

                <input type="submit" value="Log In" class="btn-primary">
            </form>

            <p class="signup-link">Don't have an account? <a href="signup.jsp">Sign up here</a></p>
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
                        <li><a href="homePage.jsp#features">Features</a></li>
                        <li><a href="homePage.jsp#workflow">The Workflow</a></li>
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