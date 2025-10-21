<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ===============================================
    // Caching Prevention Headers (Prevents users from seeing this
    // page in history if they successfully log in and then press back)
    // ===============================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
    response.setDateHeader("Expires", 0); // Proxies.
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MockMate | Login Failed</title>

    <style>
        :root {
            --primary-color: #dc3545; /* Red for Error */
            --primary-light: #ff6b6b;
            --background-color: #f4f7f6;
            --card-color: #ffffff;
            --text-color: #2c3e50;
            --secondary-text: #7f8c8d;
            --shadow-bold: 0 10px 30px rgba(0, 0, 0, 0.1);
            --font-family: 'Inter', 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        }

        body {
            font-family: var(--font-family);
            background-color: var(--background-color);
            color: var(--text-color);
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            text-align: center;
        }

        .error-container {
            background-color: var(--card-color);
            padding: 50px 40px;
            border-radius: 12px;
            box-shadow: var(--shadow-bold);
            max-width: 500px;
            width: 90%;
            border-top: 8px solid var(--primary-color);
        }

        .icon {
            font-size: 5em;
            color: var(--primary-color);
            margin-bottom: 20px;
            display: block;
        }

        h1 {
            font-size: 2.5em;
            color: var(--primary-color);
            margin-top: 0;
            margin-bottom: 10px;
            font-weight: 800;
        }

        p {
            font-size: 1.1em;
            color: var(--secondary-text);
            margin-bottom: 30px;
            line-height: 1.5;
        }

        .btn-back {
            display: inline-block;
            background-color: var(--primary-color);
            color: var(--card-color);
            padding: 12px 30px;
            text-decoration: none;
            border-radius: 8px;
            font-size: 1.1em;
            font-weight: 600;
            transition: background-color 0.3s, transform 0.2s;
            border: none;
            cursor: pointer;
        }

        .btn-back:hover {
            background-color: #c82333; /* Darker red on hover */
            transform: translateY(-2px);
        }
    </style>
</head>
<body>

    <div class="error-container">
        <span class="icon">❌</span>
        <h1>Oops! Login Failed</h1>
        <p>
            We couldn't find an account matching that **Email** and **Password**.
            Please double-check your credentials and try again.
        </p>

        <a href="login.jsp" class="btn-back">Go Back to Login Page</a>
    </div>

</body>
</html>