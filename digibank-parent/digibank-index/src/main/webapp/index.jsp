<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Digi Bank - Home</title>
<style>
* {
margin: 0;
padding: 0;
box-sizing: border-box;
}

body {
font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
min-height: 100vh;
display: flex;
justify-content: center;
align-items: center;
padding: 20px;
}

.container {
background: white;
border-radius: 10px;
box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
max-width: 800px;
width: 100%;
padding: 50px;
text-align: center;
}

.logo {
font-size: 48px;
margin-bottom: 20px;
color: #667eea;
}

h1 {
color: #333;
margin-bottom: 20px;
font-size: 36px;
}

.version {
color: #888;
font-size: 14px;
margin-bottom: 30px;
}

.description {
color: #555;
font-size: 16px;
line-height: 1.8;
margin: 30px 0;
text-align: justify;
}

.features {
background: #f5f5f5;
padding: 30px;
border-radius: 8px;
margin: 30px 0;
text-align: left;
}

.features h3 {
color: #667eea;
margin-bottom: 15px;
}

.features ul {
list-style: none;
padding: 0;
}

.features li {
padding: 8px 0;
color: #555;
border-bottom: 1px solid #ddd;
}

.features li:last-child {
border-bottom: none;
}

.features li:before {
content: "✓ ";
color: #667eea;
font-weight: bold;
margin-right: 10px;
}

.links {
margin: 40px 0 0 0;
display: flex;
gap: 15px;
justify-content: center;
flex-wrap: wrap;
}

.btn {
display: inline-block;
padding: 12px 30px;
border-radius: 5px;
text-decoration: none;
font-weight: 600;
transition: all 0.3s ease;
cursor: pointer;
border: none;
font-size: 14px;
}

.btn-primary {
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
color: white;
}

.btn-primary:hover {
transform: translateY(-2px);
box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
}

.btn-secondary {
background: white;
color: #667eea;
border: 2px solid #667eea;
}

.btn-secondary:hover {
background: #f5f5f5;
transform: translateY(-2px);
}

.api-info {
background: #e8f4f8;
padding: 20px;
border-left: 4px solid #667eea;
margin: 30px 0;
text-align: left;
border-radius: 5px;
}

.api-info h4 {
color: #667eea;
margin-bottom: 10px;
}

.api-info p {
color: #555;
font-size: 14px;
font-family: 'Courier New', monospace;
margin: 5px 0;
}

footer {
margin-top: 40px;
padding-top: 30px;
border-top: 1px solid #eee;
color: #888;
font-size: 12px;
}
</style>
</head>
<body>
<div class="container">
<div class="logo">🏦</div>
<h1>Digi Bank</h1>
<div class="version">Version 1.0 - Workshop 2</div>

<div class="description">
<p>
<strong>Digi Bank</strong> is a digital financial management platform based on a modular monolithic architecture. It offers an integrated solution for managing customers, accounts, transactions and compliance checks.
</p>
</div>

<div class="features">
<h3>Available Modules</h3>
<ul>
<li>Customer Management (Customer Module)</li>
<li>Account Management (Account Module)</li>
<li>Transaction Management (Transaction Module)</li>
<li>Compliance Controls (Compliance Module)</li>
<li>Shared Services (Shared Module)</li>
</ul>
</div>

<div class="api-info">
<h4>📡 Access to REST APIs</h4>
<p><strong>Base URL:</strong> http://localhost:8080/digibank-app/api/</p>
<p><strong>Available endpoints:</strong></p>
<p>• GET /api/index - General Information</p>
<p>• POST /api/customers - Create a customer</p>
<p>• GET /api/customers - List customers</p>
<p>• POST /api/accounts - Create an account</p>
<p>• GET /api/accounts - List accounts</p>
<p>• POST /api/transactions - Create a transaction</p>
<p>• GET /api/transactions - List transactions</p>
<p>• GET /api/compliance/validate/{amount} - Validate an amount</p>
</div>

<div class="links">
<a href="<%= request.getContextPath() %>/api" class="btn btn-primary">REST API Root</a>
<a href="<%= request.getContextPath() %>/swagger.html" class="btn btn-secondary">Swagger API Playground</a>
<a href="http://localhost:8082" class="btn btn-secondary" target="_blank">Adminer DB Console</a>
</div>

<footer>
<p>Professional Bachelor's Degree in Cloud Computing - University of the Mountains</p>
<p>Supervisor: Eng. Willy Damtchou | June 2026</p>
</footer>
</div>
</body>
</html>
