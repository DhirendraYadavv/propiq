\# PropIQ 🏠 — Property Management SaaS



> A full-stack property management platform built for Indian landlords.



\*\*🌐 Live Demo: http://3.6.88.245\*\*

\*\*👤 Demo Login: owner2@test.com / password123\*\*



\## Features

\- JWT Authentication + Google OAuth2

\- Role-Based Access Control (OWNER / TENANT)

\- Property Management

\- Tenant Management with masked Aadhaar

\- Lease \& Rent Tracking in ₹

\- PropBot AI — chatbot for Indian tenancy law (Gemini)

\- Deployed on AWS EC2 (Mumbai)



\## Tech Stack

\- Backend: Spring Boot 3, Spring Security, PostgreSQL, Docker

\- Frontend: React 18, Vite, Axios

\- AI: FastAPI, Google Gemini

\- DevOps: AWS EC2, Nginx, Docker



\## Local Setup

1\. git clone https://github.com/DhirendraYadavv/propiq.git

2\. docker-compose up -d

3\. cd backend \&\& ./mvnw spring-boot:run

4\. cd ai-service \&\& uvicorn main:app --port 8000

5\. cd frontend \&\& npm run dev



\## Demo Credentials

\- Owner: owner2@test.com / password123

\- Tenant: tenant1@test.com / password123



\## Author

Dhirendra Yadav

LinkedIn: https://www.linkedin.com/in/dhirendra-yadav-/

GitHub: https://github.com/DhirendraYadavv

