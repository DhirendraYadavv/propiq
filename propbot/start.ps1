Write-Host "Installing dependencies..." -ForegroundColor Cyan
pip install -r requirements.txt

Write-Host "Starting PropBot on port 8000..." -ForegroundColor Green
python run.py
